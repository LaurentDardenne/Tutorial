 #tâche Maître
Task default -Depends Build

 #Dépendences ordonnées et imbriquées 
 #Ici la tâche 'Build" est constituée d'une sous-tâche. 
 #Celles-ci sont d'abord exécutées avant que la tâche 
 # dépendante (ici 'Build') ne soit traitée 
Task Build { Write-Host "Tâche Build : On exécute la construction "} -Depends Init

Task Init {
   Write-Host "Tâche Init: dépendance imbriquée. On initialise la construction."
}
