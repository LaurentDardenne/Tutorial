#Cr�e dans le r�pertoire $PathModule
#un module nomm�  MyModule.psm1 
$PathModule="C:\Temp"
if (-not (Test-Path  $PathModule)) 
{ throw "Le r�pertoire n'existe pas: $PathModule" }
@"
Function Get-Files{
 Dir C:\Windows
}

New-Alias glf Get-Files  
"@ > "$PathModule\MyModule.psm1"
