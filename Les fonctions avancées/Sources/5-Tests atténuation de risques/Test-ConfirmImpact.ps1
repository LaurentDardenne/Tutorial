Function TestConfirmImpact
{
  [CmdletBinding(SupportsShouldProcess=$true)]# ConfirmImpact="High")]
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
    #   Affiche le nom de l'op�ration ex�cut�e. Exemple :
    #    WhatIf�: Op�ration ��TestAttenuationRisque�� en cours sur la cible ��Op�ration Traitement��.
   if ($psCmdlet.shouldProcess("Op�ration Traitement"))
    { Traitement $_}
   else {Write-host "Pas de traitement avec ShouldProcess"} 
  }#Process
   
  End 
  { 
  }#End
}

 #ConfirmImpact est inf�rieure $ConfirmPreference, pas de demande confirmation automatique. 
 #On doit pr�ciser -Confirm
$ConfirmPreference="High"
1..3|TestConfirmImpact

 #ConfirmImpact est sup�rieur ou �gal � $ConfirmPreference, demande de confirmation automatique. 
$ConfirmPreference="Medium" 
1..3|TestConfirmImpact
 
 #ConfirmImpact est sup�rieur ou �gal � $ConfirmPreference, demande de confirmation automatique. 
$ConfirmPreference="None" 
1..3|TestConfirmImpact -Confirm

 #Liste les cmdlet et fonctions d�clarant
 #le param�tre -Whatif 
gcm -command cmdlet,function|
 %{$Current=$_.name;$_}|
 get-help  -parameter whatif -ea "silentlycontinue"|
 ? {$_ -ne $null}|
 % {Write-host $current}
 