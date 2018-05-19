# cd r�pertoire d�installation des scripts du tutoriel
Import-Module "$pwd\EtatSession"

$Info=New-object psobject -property @{nom="Jean"; age=25} 
TestData -datas $Info -sb {Write-Host $Info.Nom -fore Green}


TestData -datas $Info -sb {
    $Info=New-object psobject -property @{nom="Claude"; age=37}
    Write-Host $Info.Nom
  }

 #Ne fonctionne pas, pas d'erreur.
 #Par d�faut Write-Host n'effectue aucun contr�le, il n'affiche aucune donn�e.
TestData -datas $Info -sb {Write-Host $Datas.Nom -fore Green}
 
 #Ne fonctionne pas, mais avec une erreur.
 #Par d�faut Get-Variable effectue un contr�le d'existence de la variable.
TestData -datas $Info -sb {Get-Variable Datas}


 #d�clare $Datas dans la port� courante
$Datas=New-object psobject -property @{nom="Pierre"; age=50}
$sb={Write-Host $Datas.Nom -fore Green} 

 # Pas la bonne variable -> collision 
 # On acc�de � la variable Datas d�clar�e dans la port� de l'appelant  
 # et pas le param�tre Datas d�clar� dans la fonction TestData du module Test1
TestData -data $Info -sb $sb
 #visu des champs du scriptblock
$sb|select *

 #fonctionne le SB est li� � la port� du module
TestData2 -data $Info -sb $sb 
 
 #visu 
TestData3 -data $Info -sb $sb 
 