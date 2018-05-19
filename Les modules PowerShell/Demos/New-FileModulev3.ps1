#Cr�e un module nomm�  MyModule.psm1 
#dans le sous r�pertoire MyModule du r�pertoire $PathModule
#Exporte uniquement un alias

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
export-modulemember -alias glf 
"@ > "$PathModule\MyModule.psm1"
