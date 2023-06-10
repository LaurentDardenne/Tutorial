Function TestAttenuationRisque1_3
{
  [CmdletBinding( 
      SupportsShouldProcess=$True, 
      ConfirmImpact="Medium")] 
   param( 
    [Parameter(
      Position=0,
      Mandatory = $true,
      ValueFromPipeline = $true)] 
    $ID) 

  Begin 
  {
    Function Traitement($Object) {
     Write-Host "Traite $Object" 
    }
  }#Begin 
  
  Process 
  { 
    # ShouldProcess(string verboseDescription, string verboseWarning, string caption, 
    #                System.Management.Automation.ShouldProcessReason [ref]shouldProcessReason) :
    # Affiche une description d�taill�e de la ressource cible � modifier et de l'op�ration � ex�cuter. 
    # ShouldProcessReason sp�cifie la raison de la valeur de retour: Pr�sence/absence du param�tre -Whatif.
    # 
   [System.Management.Automation.ShouldProcessReason] $shouldProcessReason="None" 
   if ($psCmdlet.shouldProcess("verboseDescription", "verboseWarning","Caption",[ref] $shouldProcessReason))
    { Traitement $_}
   else {Write-host "Pas de traitement avec ShouldProcess"} 
   Write-host "`t Raison de la valeur de retour : $shouldProcessReason"   
  }#Process 
  
  End 
  { 
  }#End
}

1..3|TestAttenuationRisque1_3 -whatif
1..3|TestAttenuationRisque1_3 -confirm