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
    #   Affiche une description de l'op�ration � ex�cuter, un message de warning incluant 
    #   la question et un titre du message de warning.
    #
   # Avec $ErrorActionPreference="Inquire" et pr�sence du param�tre -Confirm.
   if ($psCmdlet.shouldProcess("verboseDescription", "verboseWarning","Caption"))
    {
      if ($force �or $pscmdlet.ShouldContinue($_, "Op�ration Traitement"))
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