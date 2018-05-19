 #Construit le squelette de l'aide des fonctions exportées d'un module
. .\new-XML.ps1
. .\new-MAMLv2.ps1
Push-Location ..\ValidationsArgument
$Module=Import-Module "$pwd\ValidationsArgument.psm1" -Force -Pass
Pop-Location

$Number=0

$CmdNames=$Module.ExportedFunctions.GetEnumerator()|%{$_.key}
$xml =New-MAML $CmdNames -Verbose

$xml.Declaration.ToString() | Out-File "ValidationsArgument-Help.xml" -encoding "UTF8" 
$xml.ToString() | Out-File "ValidationsArgument-Help.xml" -encoding "UTF8" -append

