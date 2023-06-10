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

 #ConfirmImpact est inférieure $ConfirmPreference, pas de demande confirmation automatique. 
 #On doit préciser -Confirm
$ConfirmPreference="High"
1..3|TestConfirmImpact

 #ConfirmImpact est supérieur ou égal à $ConfirmPreference, demande de confirmation automatique. 
$ConfirmPreference="Medium" 
1..3|TestConfirmImpact
 
 #ConfirmImpact est supérieur ou égal à $ConfirmPreference, demande de confirmation automatique. 
$ConfirmPreference="None" 
1..3|TestConfirmImpact -Confirm

 #Liste les cmdlet et fonctions déclarant
 #le paramètre -Whatif 
gcm -command cmdlet,function|
 %{$Current=$_.name;$_}|
 get-help  -parameter whatif -ea "silentlycontinue"|
 ? {$_ -ne $null}|
 % {Write-host $current}
 