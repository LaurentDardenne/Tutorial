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
    [Boolean] $yesToAll=$false  #Autorise tous type de r�ponses, selon la r�ponse il y a une double confirmation
    [Boolean] $noToAll=$false
    
    #[Boolean] $yesToAll=$True   #Autorise les r�ponses O,O puis T, pas de double confirmation 
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
        #L'impl�mentation deu param�tre Force se fait sur ShouldContinue 
       if ($force �or $psCmdlet.ShouldContinue("Requ�te sur [$_]", "Caption",[ref]$yesToAll, [ref]$noToAll))
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

 #r�pondre T puis T pour n'avoir plus aucune confirmation.
1..4|TestAttenuationRisque2_2 -Confirm

 #r�pondre T puis O pour avoir une confirmation pour chaque objet.
 #Si ensuite on r�pond T � la seconde confirmation, alors aucune 
 #confirmation n'est demand� pour les objets restants.
1..4|TestAttenuationRisque2_2 -Confirm 
 #Il rester possible de r�pondre O pour chaque objet, mais on aura deux confirmation.

#1..4|TestAttenuationRisque2_2 -verbose
#Affiche :
#COMMENTAIRES�: Op�ration ��TestAttenuationRisque2_2�� en cours sur la cible ��ShouldProcess target��.
  