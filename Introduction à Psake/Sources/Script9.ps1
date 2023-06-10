 #Déclare une propriété accessible dans toutes les tâches
properties {
    $Message= "Init failed"
}

 #formatage du nom de tâche exécutée
FormatTaskName "-------- {0} --------"


Task default -Depends Build

Task Build -Depends Init,Clean,Compile {
   Write-Host "Tâche Build : On termine la construction."
}

Task Compile -Depends Clean, Init {
   Write-Host "Tâche Compile : On exécute la compilation"
}

 #Continue l'exécution, le message est affiché en jaune 
Task Clean -ContinueOnError -Depends Init  {
   Write-Host "Tâche Clean : On nettoie les fichiers issus de la précédente compilation."
   Throw $Message 
}

#Place une condition AVANT l'exécution de la tâche
#si le code de la condition renvoi false, la tâche n'est pas exécutée
# le message est affiché avec la couleur Cyan (codée en dur)...
Task Init -Precondition { "10/10/2013" -as [datetime] -gt [datetime]::now } {
   Write-Host "Tâche Init: On initialise la construction."
}


