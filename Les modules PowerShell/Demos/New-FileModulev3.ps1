#Crée un module nommé  MyModule.psm1 
#dans le sous répertoire MyModule du répertoire $PathModule
#Exporte uniquement un alias

$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le répertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
Function Get-Files{
 Dir C:\Windows
}

New-Alias glf Get-Files 
export-modulemember -alias glf 
"@ > "$PathModule\MyModule.psm1"
