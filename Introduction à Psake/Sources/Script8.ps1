 #doc : tâche Maître
Task default -Depends Build

 #Ici la tâche 'Build" est constituée d'une sous-tâche 'Compile"
 #qui à son tour dépend des tâches Init,Clean et Compile 
Task Build -Depends Compile {
   Write-Host "Tâche Build : On termine la construction."
}

Task Compile -Depends Clean {
   Write-Host "Tâche Compile : On exécute la compilation"
}

Task Clean -Depends Init {
   # On nettoie les fichiers issus de la précédente compilation.
    Write-Host "Tâche Clean : On nettoie les fichiers créés précédemment."
}

Task Init {
   Write-Host "Tâche Init: On initialise la construction."
}


