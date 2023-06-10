Function TestAttenuationRisque1_1
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
    # ShouldProcess(string target, string action) : 
    #   Affiche le nom de l'op�ration � ex�cuter et le nom de la ressource cible � modifier.Exemple :
    #    WhatIf�: Op�ration ��Op�ration Traitement�� en cours sur la cible ��1��.
   if ($psCmdlet.shouldProcess($_, "Op�ration Traitement"))
       { Traitement $_}
   else {Write-host "Pas de traitement avec ShouldProcess"} 
  }#Process 
  
  End 
  { 
  }#End
}

1..3|TestAttenuationRisque1_1 -whatif
1..3|TestAttenuationRisque1_1 -confirm
#1..3|TestAttenuationRisque1_1 -verbose  
# Affiche : 
#COMMENTAIRES�: Op�ration ��Op�ration Traitement�� en cours sur la cible ��1��.