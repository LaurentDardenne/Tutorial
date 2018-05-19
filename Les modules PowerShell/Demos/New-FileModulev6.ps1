#Cr�e un module nomm�  MyModule.psm1 
#dans le sous r�pertoire MyModule du r�pertoire $PathModule

#Affiche dynamiquement le nom du chemin de chargement du module
#Impl�mente la propri�te OnRemove


$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le r�pertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
#Initialisation
 `$Name=`$MyInvocation.MyCommand.ScriptBlock.Module.Name
 Write-Host "Chargement du module [`$Name)] � partir du r�pertoire: `$PSScriptRoot"

#Finalisation
function OnRemoveMyModule {
  Write-Host "Finalise le module $Name" �fore Green
}
 #Le code de la propri�t� 'OnRemove' est appel� lors de 
#la suppression du module. 
`$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveMyModule }  
"@ > "$PathModule\MyModule.psm1"
