Function TestAttenuationRisque2
{
  [CmdletBinding(SupportsShouldProcess=$True)] 
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
     #ShouldContinue(string query, string caption)
     # Demande une confirmation de l'utilisateur.
     #Affiche : [O] Oui  [N] Non  [S] Suspendre  [?] Aide (la valeur par d�faut est ��O��)�:
   if ($force �or $psCmdlet.ShouldContinue("Requ�te ?", "Caption"))
     { Traitement $_} 
    else {Write-host "Pas de traitement avec ShouldContinue"}
  }#Process 
  
  End 
  { 
  }#End
}

 #Ainsi cod� -Confirm ou -whatif n'influence pas l'ex�cution du code
1..3|TestAttenuationRisque2  

  #Force �vite la demande de confirmation
1..3|TestAttenuationRisque2