Function New-PersonnalPSObject{
#Compile une ou plusieurs classes dans un assembly.
#Chaque membre est construit à l'aide d'un PsObject 
 param (
    #Hashtable : la clé est le nom de l'espace de nom, les valeurs les noms des membres 
    # $MyObjects.Application=@("Serveur","Nom")
    [Parameter(Position=1)]
   [System.Collections.IDictionary] $Enums,
     
     #Nom de l'espace de nom contenant les classes déclarées via $Enums
    [Parameter(Position=2, ParameterSetName="AddType")]
   [string] $Namespace,
    
    #Permet d'insérer le code généré : $(New-Enum $Enums -pass)
    [Parameter(ParameterSetName="GetCode")]
   [switch] $PassThru 
 ) 
   
#
#Exemples :
# $Classes=@{} 
# $Classes.Personne=@("Nom","Prenoms","Informations")
# New-PersonnalPSObject $Classes 'PersonnalPSObject'
# [PersonnalPSObject.Personne]
# $Personne=New-Object 'PersonnalPSObject.Personne'
# 
# $MyObjects=@{} 
# $MyObjects.Application=@("Serveur","Nom")
# $MyObjects.Serveur=@("Nom","Domaine","Ip")
# $s=New-PersonnalPSObject $MyObjects -pass
# $s

 if ($Enums -eq $Null -or $Enums.Count -eq 0) 
 { Write-Error "L'énumération ne contient aucune entrée." }
 else 
 { 
  $TextHelper=(Get-Culture).TextInfo
  $Code= New-Object System.Text.StringBuilder
  if (!$Passthru)
  { [void]$Code.AppendLine(@"
using System;
using System.Management.Automation;
`r`n 
namespace $Namespace
{
 
"@
) 
}
  
  $Enums.GetEnumerator()|
   Where {$_.Value.Count -ne 0}| 
   Foreach {
     if ( $DebugPreference -ne "SilentlyContinue")  
      { Write-debug "[New-PersonnalPSObject] $($_.Key)" }

[void]$Code.Append( 
@"

    public class $($_.Key)
    { 
        public $($_.Key)()
        {
      $($_.value|Foreach {
@"
`t    $($_.ToLower())= new PSObject();`r`n
"@ 
    }#foreach
)          
        }

      $($_.value|Foreach {
@" 
`r`n 
`tprivate readonly PSObject $($_.ToLower());
        public PSObject $($TextHelper.ToTitleCase($_.ToLower()))
        {
            get { return $($_.ToLower()); }
        }

"@ 
    }#foreach
)    
    }
`r`n
"@
)
   } #foreach $Enums
   
   if (!$Passthru)
   { [void]$Code.AppendLine("}`r`n") } #end of namespace
 
   if ($Passthru)
   {$Code.ToString()}
   else
   {
     if ( $DebugPreference -ne "SilentlyContinue")  
     { Write-debug $Code.ToString() }    
     #Un seul ajout d'assembly par session, peu importe le nombre d'apppel de cette méthode avec une même énumération 
     Add-Type $Code.ToString() 
   }
 }#else
}# New-PersonnalPSObject