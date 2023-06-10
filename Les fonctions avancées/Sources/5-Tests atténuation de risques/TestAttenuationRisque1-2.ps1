Function TestAttenuationRisque1_2
{
  [CmdletBinding( 
      SupportsShouldProcess=$True, 
      ConfirmImpact="Medium")] 
   param( 
    [Parameter(
      Position=0,
      Mandatory = $true,
      ValueFromPipeline = $true)] 
    $ID, 
    [Switch]$Force) 

  Begin 
  {
    Function Traitement($Object) {
     Write-Host "Traite $Object" 
    }
  }#Begin 
  
  Process 
  { 
    # ShouldProcess(string verboseDescription, string verboseWarning, string caption) :
    #   Affiche une description de l'opération à exécuter, un message de warning incluant 
    #   la question et un titre du message de warning.
    #
   # Avec $ErrorActionPreference="Inquire" et présence du paramètre -Confirm.
   if ($psCmdlet.shouldProcess("verboseDescription", "verboseWarning","Caption"))
    {
      if ($force –or $pscmdlet.ShouldContinue($_, "Opération Traitement"))
       { Traitement $_}
    }
   else {Write-host "Pas de traitement avec ShouldProcess"} 
  }#Process 
  
  End 
  { 
  }#End
}

1..3|TestAttenuationRisque1_2 -whatif
1..3|TestAttenuationRisque1_2 -confirm