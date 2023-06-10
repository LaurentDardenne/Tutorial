Function TestAttenuationRisque2_2
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
    [Boolean] $yesToAll=$false  #Autorise tous type de réponses, selon la réponse il y a une double confirmation
    [Boolean] $noToAll=$false
    
    #[Boolean] $yesToAll=$True   #Autorise les réponses O,O puis T, pas de double confirmation 
    #[Boolean] $noToAll=$false
    
    #[Boolean] $yesToAll=$False   #pas d'appel au traitement 
    #[Boolean] $noToAll=$true
    
    #[Boolean] $yesToAll=$True    #pas d'appel au traitement 
    #[Boolean] $noToAll=$true


  }#Begin 
  
  Process 
  { 
      #ShouldContinue(string query, string caption, System.Boolean [ref] yesToAll, System.Boolean [ref] noToAll)
      # Demande une confirmation de l'utilisateur en prcisant les options yesToall et noToall.   
     if ($psCmdlet.ShouldProcess("ShouldProcess target"))
      {
        #L'implémentation deu paramètre Force se fait sur ShouldContinue 
       if ($force –or $psCmdlet.ShouldContinue("Requête sur [$_]", "Caption",[ref]$yesToAll, [ref]$noToAll))
        { Traitement $_ }
      else {Write-host "Pas de traitement avec ShouldContinue"} 
      }
    else {Write-host "Pas de traitement avec ShouldProcess"} 
  }#Process 
  
  End 
  { 
  }#End
}

1..4|TestAttenuationRisque2_2 -whatif

 #répondre T puis T pour n'avoir plus aucune confirmation.
1..4|TestAttenuationRisque2_2 -Confirm

 #répondre T puis O pour avoir une confirmation pour chaque objet.
 #Si ensuite on répond T à la seconde confirmation, alors aucune 
 #confirmation n'est demandé pour les objets restants.
1..4|TestAttenuationRisque2_2 -Confirm 
 #Il rester possible de répondre O pour chaque objet, mais on aura deux confirmation.

#1..4|TestAttenuationRisque2_2 -verbose
#Affiche :
#COMMENTAIRES : Opération « TestAttenuationRisque2_2 » en cours sur la cible « ShouldProcess target ».
  