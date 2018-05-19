#Cr�e un module nomm�  MyModule.psm1 
#dans le sous r�pertoire MyModule du r�pertoire $PathModule

#Impl�mente le passage d'argument et leur validation
#Source :
#http://www.nivot.org/nivot2/post/2009/10/22/PowerShell20ModuleInitializers.aspx

$myPath="C:\Temp"

if (-not (Test-Path  $myPath)) 
{ throw "Le r�pertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"

@"
param (
  #[ValidateNotNullOrEmpty()]
 [String] `$DataPath,
 [bool] `$Switch
)

Write-Host "DataPath=`$DataPath Switch=`$Switch"
 
"@ > "$PathModule\MyModule.psm1"

#Syntaxe impossible 
# Import-Module MyModule.psm1 -DataPath "C:\temp" -Switch

#Syntaxe d'appel � disposition
# Import-Module MyModule.psm1 -ArgumentList "C:\temp",$True