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
    # Affiche une description détaillée de la ressource cible à modifier et de l'opération à exécuter. 
    # ShouldProcessReason spécifie la raison de la valeur de retour: Présence/absence du paramètre -Whatif.
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