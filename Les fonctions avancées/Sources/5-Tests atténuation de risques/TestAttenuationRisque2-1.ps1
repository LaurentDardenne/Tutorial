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
     if ($psCmdlet.ShouldProcess("Opération Traitement"))
      {
       if ($force –or $psCmdlet.ShouldContinue("Requête sur [$_]", "Caption"))
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

 #répondre T pour n'avoir qu'une demande de confirmation :ShouldContinue
1..3|TestAttenuationRisque2_1 -Confirm

 #répondre O puis O et enfin répondre T pour n'avoir qu'une confirmation (ShouldContinue) sur chaque objet
 #sinon si on répond O à chaque fois on a deux demandes de confirmation. 
1..3|TestAttenuationRisque2_1 -Confirm  

 #La réponse T couplée à la présence de -Force fait qu'il 
 #n'y a qu'une demande de confirmation.
1..3|TestAttenuationRisque2_1 -Confirm  -Force