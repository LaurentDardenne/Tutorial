 #Tâche à inclure dans un script Psake
 #Cette tâche utilise la varaible $Mode déclaré via le mot clé Properties ( voir le script Script5-1.ps1) 
Task UneAutreTache {
  Write-Host "UneAutreTache : exécute du code en mode $Mode"
  View
}