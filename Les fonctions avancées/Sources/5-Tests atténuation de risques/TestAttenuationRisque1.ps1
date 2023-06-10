Function TestAttenuationRisque1
{
  [CmdletBinding(SupportsShouldProcess=$True)]  
      #par défaut ConfirmImpact="Medium"
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
    # ShouldProcess(string target) : 
    #   Affiche le nom de l'opération exécutée. Exemple :
    #    WhatIf : Opération « TestAttenuationRisque » en cours sur la cible « Opération Traitement ».
   if ($psCmdlet.shouldProcess("Opération Traitement"))
    { Traitement $_}
   else {Write-host "Pas de traitement avec ShouldProcess"} 
  }#Process
   
  End 
  { 
  }#End
}

1..3|TestAttenuationRisque1 -whatif
1..3|TestAttenuationRisque1 -confirm