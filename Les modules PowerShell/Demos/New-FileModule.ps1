#Crée dans le répertoire $PathModule
#un module nommé  MyModule.psm1 
$PathModule="C:\Temp"
if (-not (Test-Path  $PathModule)) 
{ throw "Le répertoire n'existe pas: $PathModule" }
@"
Function Get-Files{
 Dir C:\Windows
}

New-Alias glf Get-Files  
"@ > "$PathModule\MyModule.psm1"
