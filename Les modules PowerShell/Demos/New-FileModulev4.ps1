#Cr�e un module nomm�  MyModule.psm1 
#dans le sous r�pertoire MyModule du r�pertoire $PathModule
#pr�cise l'export d'un alias et d'une fonction

$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le r�pertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
Function Get-Files{
 Dir C:\Windows
}

New-Alias glf Get-Files 
export-modulemember -function Get-Files -alias glf 
"@ > "$PathModule\MyModule.psm1"
