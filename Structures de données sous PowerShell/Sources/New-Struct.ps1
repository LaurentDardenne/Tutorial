# New-Struct
# Auteurs : Joel Bennett 
# Ce script modifie la version original dispos sur  http://poshcode.org/190
#
#note :
# Les compilateurs C#, Visual Basic .NET et C++ appliquent par défaut 
# la valeur de disposition Sequential aux structures, c'est à dire :
#  [StructLayout(LayoutKind.Sequential)]
#  Struct MonNom {....}
#
# Cette information précise comment sont marshallé les données et pas comment elles sont stockées. 
# L'ordre de déclaration des champs, dans une structure, n'est donc pas important dans ce cas,
#       -------------
#    #Définition PowerShell de la structure
#   Disque=@{
#           Nom=[String]
#          Partitions="Partition[]"
#         }
# sauf pour la déclaration du constructeur pour qui l'ordre peut ne pas correspondre :
#       -------------
#     Définition C# du code de la structure Disque
#   public struct Disque {
#    public Partition[] Partitions;
#    public System.String Nom;
# 
#    public Disque (Partition[] partitions,System.String nom) {
#      Partitions = partitions;
#      Nom = nom;
#   }
#
#    #Affichage du constructeur via Get-Constructeur
# Disque(
#        Partition[] partitions,
#        String nom,
# )
# Ceci est du au fait qu'une hashtable n'est pas ordonnée.
#

# Si on souhaite utiliser la version originale on ne peut pas créer de structures utilisant d'autres structures,
# à moins de passer par un fichier DLL externe tout en modifiant le script d'origine  
# Dans ce cas le nom de l'assembly doit avoir une extension .DLL et son chemin pointer de préférence sur %Temp%.
#
 
##   Creates a Struct class and emits it into memory
##   The Struct includes a constructor which takes the parameters in order...
## 
## Usage:
##   # Assuming you have a csv file with no header and columns: artist,name,length
##   New-Struct Song @{
##     Artist=[string];
##     Name=[string];
##     Length=[TimeSpan];
##   }
##   $songs = gc C:\Scripts\songlist.csv | % { new-object Song @($_ -split ",") }
##
function New-Struct {
        param([HashTable]$Structs)
              
        switch($Structs.Keys){{$_ -isnot [String]}{throw "Invalid Syntax."}}
        switch($Structs.Values){{$_ -isnot [hashtable]}{throw "Invalid Syntax."}}
        #switch($Structs.Values){{$_ -isnot [type]}{throw "Invalid Syntax."}}
 
        
        # CODE GENERATION MAGIKS!
        $code = @"
using System;        
 $($Structs.Keys|% {$Name=$_;$Properties=$Structs.$_; "`n  public struct $Name {`r`n"
 $($Properties.Keys | % { "  public {0} {1};`n" -f $Properties[$_],($_.ToUpper()[0] + 
$_.SubString(1)) })
  "`n   public $Name ("+$( [String]::join(',',($Properties.Keys | % { "{0} {1}" -f $Properties[$_],($_.ToLower()) })) )+")
 {`r`n"
    $($Properties.Keys | % { "    {0} = {1};`n" -f ($_.ToUpper()[0] + $_.SubString(1)),($_.ToLower()
) })
  "`n  }`n }"
  })
"@

         ## Obtains an ICodeCompiler from a CodeDomProvider class.
        $provider = New-Object Microsoft.CSharp.CSharpCodeProvider
        ## Get the location for System.Management.Automation DLL
        $dllName = [PsObject].Assembly.Location
        ## Configure the compiler parameters
        $compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters
        $assemblies = @("System.dll", $dllName)
        $compilerParameters.ReferencedAssemblies.AddRange($assemblies)
        $compilerParameters.IncludeDebugInformation = $true
        $compilerParameters.GenerateInMemory = $true
 
        $compilerResults = $provider.CompileAssemblyFromSource($compilerParameters, $code)
        if($compilerResults.Errors.Count -gt 0) {
          $compilerResults.Errors | % { Write-Error ("{0} :`t {1}" -F  $_.Line,$_.ErrorText) }
        }  
} 
