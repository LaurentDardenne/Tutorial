#Scénario d'erreur
Task default -Depends Build

Task Build -Depends Init,Clean,Compile {
   Write-Host "Tâche Build : On termine la construction."
}

Task Compile -Depends Clean, Init {
   Write-Host "Tâche Compile : On exécute la compilation"
}

Task Clean -Depends Init {
   Write-Host "Tâche Clean : On nettoie les fichiers issus de la précédente compilation."
}

#Contrôle de référence circulaire
Task Init -Depends Build {
   Write-Host "Tâche Init: On initialise la construction."
}


