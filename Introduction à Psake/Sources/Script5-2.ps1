 #Déclare une tâche nommée 'Default', celle-ci doit déclarer des tâches dépendantes
 #On utilise donc le paramètre -Depend
 #Sous PSake il faut déclarer au moins une tâche nommée 'Default' qui est un point d'entrée vers d'autres tâches

Task default -Depends Build

Task Build -Depends UneAutreTache {
   Write-Host "Tâche default + Include"
}

 #Ces mots clés peuvent être placés en fin de script
 #Au détriment de la relecture du script...
Include .\Script5-1-Include.ps1 

Properties {
   $Mode = "Debug"
}

