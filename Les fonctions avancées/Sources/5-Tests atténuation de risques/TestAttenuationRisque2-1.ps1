Function TestAttenuationRisque2_1
{ #Exemple de double confirmation
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
     if ($psCmdlet.ShouldProcess("Op�ration Traitement"))
      {
       if ($force �or $psCmdlet.ShouldContinue("Requ�te sur [$_]", "Caption"))
        { 
          Traitement $_
        }
      else {Write-host "Pas de traitement avec ShouldContinue"} 
      }
    else {Write-host "Pas de traitement avec SouldProcess"} 
  }#Process 
  
  End 
  { 
  }#End
}

1..3|TestAttenuationRisque2_1 -whatif

 #r�pondre T pour n'avoir qu'une demande de confirmation :ShouldContinue
1..3|TestAttenuationRisque2_1 -Confirm

 #r�pondre O puis O et enfin r�pondre T pour n'avoir qu'une confirmation (ShouldContinue) sur chaque objet
 #sinon si on r�pond O � chaque fois on a deux demandes de confirmation. 
1..3|TestAttenuationRisque2_1 -Confirm  

 #La r�ponse T coupl�e � la pr�sence de -Force fait qu'il 
 #n'y a qu'une demande de confirmation.
1..3|TestAttenuationRisque2_1 -Confirm  -Force