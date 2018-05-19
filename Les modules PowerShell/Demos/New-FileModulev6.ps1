#Crée un module nommé  MyModule.psm1 
#dans le sous répertoire MyModule du répertoire $PathModule

#Affiche dynamiquement le nom du chemin de chargement du module
#Implémente la propriéte OnRemove


$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le répertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
#Initialisation
 `$Name=`$MyInvocation.MyCommand.ScriptBlock.Module.Name
 Write-Host "Chargement du module [`$Name)] à partir du répertoire: `$PSScriptRoot"

#Finalisation
function OnRemoveMyModule {
  Write-Host "Finalise le module $Name" –fore Green
}
 #Le code de la propriété 'OnRemove' est appelé lors de 
#la suppression du module. 
`$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveMyModule }  
"@ > "$PathModule\MyModule.psm1"
