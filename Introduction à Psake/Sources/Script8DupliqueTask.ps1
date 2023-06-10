Properties {
   $BOMSourcePath='C:\Temp'
}

Task default -Depends Build

Task Build -Depends Clean2,Compile {
   Write-Host "Tâche Build : On termine la construction."
   Remove-Variable BOMSourcePath -Scope script
}

#On ne peut exécuter deux fois une tâche
#On doit donc la dupliquer 
Task Clean2  -precondition { $script:BOMSourcePath='G:\ps\temp';return $true } -Depends Clean -Action {
  #Dépend de $VerbosePreference
 Write-Verbose "Validation finale de l'encodage '$BOMSourcePath'"
} #TestBomFinal
    
 #
Task Compile -Depends Clean {
   Write-Host "Tâche Compile : On exécute la compilation"
}

Task Clean -Depends Init {
    #Deux variables de portée différente
   Write-host "BOMSourcePath=$BOMSourcePath"
   Write-host "script:BOMSourcePath=$script:BOMSourcePath"
   Write-Host "Tâche Clean : On nettoie les fichiers issus de la précédente compilation."
}

Task Init {
   Write-Host "Tâche Init: On initialise la construction."
}


