
#Construit la liste des références nécessaires à la compilation
#Il s'agit du chemin des DLL.
$References=@(
 ([System.Management.Automation.PSObject].Assembly.Location),
 ([System.Collections.ObjectModel.Collection[String]].Assembly.Location)
)
$csFile="$PsScriptRoot\TouchFile.cs"
$code=Gc $csFile -Raw
 #Compile une DLL
Add-Type -TypeDefinition $Code -OutputAssembly "$PsScriptRoot\TouchFile.dll" -OutputType Library -ReferencedAssemblies $References
 
 #Touch n'est pas un verbe reconnu
Import-Module "$PsScriptRoot\TouchFile.dll" -WarningAction SilentlyContinue
#Import-Module "$pwd\TouchFile.dll"-WarningAction SilentlyContinue 
   #todo alias "Update-FileLastWriteTime" 'Touch-File'