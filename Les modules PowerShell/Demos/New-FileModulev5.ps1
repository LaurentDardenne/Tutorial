#Crée un module nommé  MyModule.psm1 
#dans le sous répertoire MyModule du répertoire $PathModule
#Affiche dynamiquement le nom du chemin de chargement du module

$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le répertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
 #Initialisation
 `$Name=`$MyInvocation.MyCommand.ScriptBlock.Module.Name
 Write-Host "Chargement du module [`$Name)] à partir du répertoire: `$PSScriptRoot"
"@ > "$PathModule\MyModule.psm1"
