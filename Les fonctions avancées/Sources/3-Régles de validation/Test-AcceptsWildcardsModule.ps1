Import-Module "$PWD\TestAcceptsWildcards.psm1"

function Test([ValidateScript( {Test-AcceptsWildcards } )]
              [Parameter(Mandatory = $true,Position=0,
                         ValueFromPipeline = $true,
                         HelpMessage="Nom de chemin.")]$Path)
{ $Path }

$DebugPreference=Continue

 #$_ n'est pas renseigné
"C:\*.exe"|Test
Test-AcceptsWildcards "C:\*.exe"
"recl:\*.exe"|Test-AcceptsWildcards

function Test([ValidateScript( {Write-Debug "In ValidateScript `$_= $_";Test-AcceptsWildcards2 $_ -No} )]
              [Parameter(Mandatory = $true,Position=0,
                         ValueFromPipeline = $true,
                         HelpMessage="Nom de chemin.")]$Path)
{
 process {Write-Debug "In Test `$_=$_"; $Path}
}
 #$_ n'est pas renseigné, mais $InputObject l'est.
"C:\*.exe"|Test
Test-AcceptsWildcards2 "C:\*.exe"
"recl:\*.exe"|Test-AcceptsWildcards2 -No

cd Env:
"C:\Windows\notepad.exe",
"C:\Windows\*.exe",
"Truc:\Windows\Existepas.exe",
"..\*.exe",
"ORCL:\*.exe"|Test