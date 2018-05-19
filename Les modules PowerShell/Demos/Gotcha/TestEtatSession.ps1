# cd répertoire d’installation des scripts du tutoriel
Import-Module "$pwd\EtatSession"

$Info=New-object psobject -property @{nom="Jean"; age=25} 
TestData -datas $Info -sb {Write-Host $Info.Nom -fore Green}


TestData -datas $Info -sb {
    $Info=New-object psobject -property @{nom="Claude"; age=37}
    Write-Host $Info.Nom
  }

 #Ne fonctionne pas, pas d'erreur.
 #Par défaut Write-Host n'effectue aucun contrôle, il n'affiche aucune donnée.
TestData -datas $Info -sb {Write-Host $Datas.Nom -fore Green}
 
 #Ne fonctionne pas, mais avec une erreur.
 #Par défaut Get-Variable effectue un contrôle d'existence de la variable.
TestData -datas $Info -sb {Get-Variable Datas}


 #déclare $Datas dans la porté courante
$Datas=New-object psobject -property @{nom="Pierre"; age=50}
$sb={Write-Host $Datas.Nom -fore Green} 

 # Pas la bonne variable -> collision 
 # On accède à la variable Datas déclarée dans la porté de l'appelant  
 # et pas le paramètre Datas déclaré dans la fonction TestData du module Test1
TestData -data $Info -sb $sb
 #visu des champs du scriptblock
$sb|select *

 #fonctionne le SB est lié à la porté du module
TestData2 -data $Info -sb $sb 
 
 #visu 
TestData3 -data $Info -sb $sb 
 