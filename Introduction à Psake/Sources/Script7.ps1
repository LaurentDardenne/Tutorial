#!!!! 
#Ceci est un script Powershell, pas un script PSake
 
 #Affiche les dépendances des tâches sans exécuter le script
Invoke-psake .\Script8.ps1 -doc

 #Exécuter les tâches du script
Invoke-psake .\Script8.ps1

Write-Warning "Affiche le contenu de la variable `$PSake"
$psake


