#Cr�e un module nomm�  MyModule.psm1 
#dans le sous r�pertoire MyModule du r�pertoire $PathModule
#Affiche dynamiquement le nom du chemin de chargement du module

$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le r�pertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
 #Initialisation
 `$Name=`$MyInvocation.MyCommand.ScriptBlock.Module.Name
 Write-Host "Chargement du module [`$Name)] � partir du r�pertoire: `$PSScriptRoot"
"@ > "$PathModule\MyModule.psm1"
