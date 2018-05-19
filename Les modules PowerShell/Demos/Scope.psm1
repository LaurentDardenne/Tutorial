$Script:Compteur=-7
function CompteurOK{
    Write-Host "AVANT valeur du compteur OK : $Compteur $Script:Compteur"
    $script:Compteur++
    Write-Host "APRES valeur du compteur OK : $Compteur $Script:Compteur"
 }
 function CompteurNOK{
    Write-Host "AVANT valeur du compteur NOK : $Compteur $Script:Compteur"          
    $Compteur++
    Write-Host "APRES valeur du compteur NOK : $Compteur $Script:Compteur"
 }
 
Export-ModuleMember CompteurNOK,CompteurOK  -variable Compteur