#Tests-ContainsWildcardCharacters.ps1

Import-Module "$PWD\TestContainsWildcardCharacters.psm1"

function Test{
 param (
     [ValidateScript( {Test-ContainsWildcardCharacters } )]
     [Parameter(Mandatory = $true,Position=0,ValueFromPipeline = $true)]
    $Path
 )
 
 process {
   $Path
 } 
}

$DebugPreference="Continue"

 #$_ n'est pas renseigné dans la fonction 'Test-AcceptWildcards'  du module
 #Tous les test suivants échouent ( ne valide pas la contrainte).
"C:\*.exe"|Test
Test-ContainsWildcardCharacters "C:\*.exe"
"recl:\*.exe"|Test-ContainsWildcardCharacters

 #$_ est renseigné dans la fonction 'Test-AcceptWildcards2' du module
 #Le premier test réussit (valide la contrainte).
function Test{
 Param(
       [ValidateScript( {Write-Debug "In ValidateScript `$_= $_";Test-ContainsWildcardCharacters2 $_ -No} )]
       [Parameter(Mandatory = $true,Position=0,ValueFromPipeline = $true)]
      $Path
 )

 process {
    Write-Debug "In Test `$_=$_"; $Path
  }
}
 #$_ n'est pas renseigné, mais $InputObject l'est.
"C:\*.exe"|Test
Test-ContainsWildcardCharacters2 "C:\*.exe"
"recl:\*.exe"|Test-ContainsWildcardCharacters2 -No

function Test{
 param(
    [ValidateScript( {Test-ContainsWildcardCharacters3})]
    [Parameter(Mandatory = $true,Position=0,ValueFromPipeline = $true)]
   $Path
 )

 process {
    Write-Debug "In Test `$_=$_"; $Path
 }
}

 #$_ est renseigné, le test valide la contrainte.
"C:\*.exe"|Test
#les autres type d'appel ne sont plus valide.

Push-Location
cd Env:
"C:\Windows\notepad.exe",
"C:\Windows\*.exe",
"Truc:\Windows\Existepas.exe",
"..\*.exe",
"ORCL:\*.exe"|Test
Pop-Location
#Seul les chemins suivant passe le test : "C:\Windows\notepad.exe" et "Truc:\Windows\Existepas.exe"
#Les autres chemins déclenchent une exception


