 #Déclare une tâche nommée 'Default', celle-ci doit déclarer des tâches dépendantes
 #On utilise donc le paramètre -Depend
 #Sous PSake il faut déclarer au moins une tâche nommée 'Default' qui est un point d'entrée vers d'autres tâches

 #Déclare une variable afin de la rendre accessible à toutes les tâches 
Properties {
   $Mode = "Release"
}

 #Inclu une tâche déclarée dans un autre script Psake
Include .\Script5-1-Include.ps1

 #Point d'entrée du script
Task default -Depends Build

 #référence la tâche incluse
Task Build -Depends UneAutreTache {
   Write-Host "Tâche default + Include"
   View
}

Function View {
 Write-host "Function View Mode=$mode"
}

