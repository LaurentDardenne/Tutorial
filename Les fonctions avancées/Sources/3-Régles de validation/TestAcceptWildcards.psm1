 #Le caractère $_ d'une fonction de validation n'est pas 
 # correctement géré dans un module.
 #
 # Import-Module "fullpathname\TestAcceptsWildcards.psm1"
 #
Function Test-AcceptsWildcards{
 if ($MyInvocation.CommandOrigin -eq "Internal")
  { Write-Debug "Exécution via un attribut"  }
 else 
  { Write-Debug "Exécution via un runspace" }
 Write-Debug "In  Test-AcceptsWildcards `$_= $_"
 If (     ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($_)))
  { 
     $VMEx="System.Management.Automation.ValidationMetadataException"
     $EGlobbing="Le globbing (?,*,[]) n'est pas supporté ({0})."
    Throw (new-object $VMEx ($EGlobbing -F $_)) 
  }
 #La valeur est valide
 $true }

Function Test-AcceptsWildcards2($InputObject,[switch] $No){
 if ($MyInvocation.CommandOrigin -eq "Internal")
  { Write-Debug "Exécution via un attribut"
  }
 else 
  { Write-Debug "Exécution via un runspace" }
 
 Write-Debug "In Test-AcceptsWildcards2 `$_= $_" 
 Write-Debug ("Call : {0}" -F $MyInvocation.MyCommand)
 Write-Debug "In  Test-AcceptsWildcards `$InputObject= $InputObject"
 Write-Debug ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($InputObject))
 If ( $No  -and 
    ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($InputObject)))
  { 
    $VMException="System.Management.Automation.ValidationMetadataException"
    $EVAGlobbing="Le globbing (?,*,[]) n'est pas supporté ({0})."
    throw (new-object $VMException ($EVAGlobbing -F $InputObject)) 
  }
  # La valeur est valide
 $true 
} #Test-AcceptsWildcards2

