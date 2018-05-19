#Module TestContainsWildcardCharacters

 #Le caract�re $_ d'une fonction de validation n'est pas 
 # correctement g�r� dans un module.
 #
 # Import-Module "fullpathname\TestAcceptsWildcards.psm1"
 #
 
# La variable $_ est celle du module pas de l'appelant
Function Test-ContainsWildcardCharacters{
 if ($MyInvocation.CommandOrigin -eq "Internal")
  { Write-Debug "Ex�cution via un attribut"  }
 else 
  { Write-Debug "Ex�cution via un runspace" }
 Write-Debug "In  Test-ContainsWildcardCharacters `$_= $_"
 If ( ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($_)))
  { 
     $VMEx="System.Management.Automation.ValidationMetadataException"
     $EGlobbing='Le globbing (?,*,[]) n''est pas support� ({0}).'
    Throw (new-object $VMEx ($EGlobbing -F $_)) 
  }
 #La valeur est valide
 $true 
}#Test-ContainsWildcardCharacters

 # La variable $_ de l'appelant est pass� � la fonction du module via $InputObject 
Function Test-ContainsWildcardCharacters2($InputObject,[switch] $No){
 Write-Debug "In Test-ContainsWildcardCharacters2 `$_= $_" 
 Write-Debug ("Call : {0}" -F $MyInvocation.MyCommand)
 Write-Debug "In  Test-ContainsWildcardCharacters2 `$InputObject= $InputObject"
 Write-Debug ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($InputObject))
 If ( $No  -and 
    ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($InputObject)))
  { 
    $VMException="System.Management.Automation.ValidationMetadataException"
    $EVAGlobbing='Le globbing (?,*,[]) n''est pas support� ({0}).'
    throw (new-object $VMException ($EVAGlobbing -F $InputObject)) 
  }
  # La valeur est valide
 $true 
} #Test-ContainsWildcardCharacters2

# La variable $_ est celle de l'appelant
# Car on la lit dans l'�tat de session de l'appellant
Function Test-ContainsWildcardCharacters3{
 #N�cessaire pour acc�der � $PSCmdlet.
 [CmdletBinding()]    
 param () 
  $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value
  If ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($PipelineObjectInScopeOfCaller))
  { 
    $VMException="System.Management.Automation.ValidationMetadataException"
    $EVAGlobbing='Le globbing (?,*,[]) n''est pas support� ({0}).'
    throw (new-object $VMException ($EVAGlobbing -F $PipelineObjectInScopeOfCaller)) 
  }
 $true 
} #Test-ContainsWildcardCharacters3

