#Script PSake ne déclarant pas de tâche default
#Task default -Depends Build

Task Build -Depends Init,Clean,Compile {
   Write-Host "Tâche Build : On termine la construction."
}

Task Compile -Depends Clean, Init {
   Write-Host "Tâche Compile : On exécute la compilation"
}

Task Clean -Depends Init {
   Write-Host "Tâche Clean : On nettoie les fichiers issus de la précédente compilation."
}


Task Init {
   Write-Host "Tâche Init: On initialise la construction."
}

Task Autonome  -Depends Init {
   Write-Host "Tâche Autonome: On initialise la construction."
}

Task Build2 -Depends Init,Clean,Compile {
   Write-Host "Tâche Build2 : On termine la construction."
}

