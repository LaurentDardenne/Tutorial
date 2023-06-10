 #Déclare une tâche nommée 'Default', celle-ci doit déclarer des tâches dépendantes
 #On utilise donc le paramètre -Depend
 #Sous PSake il faut déclarer au moins une tâche nommée 'Default' qui est un point d'entrée vers d'autres tâches
Task default -Depend UneAutreTache

 #Déclare une seconde tâche nommée UneAutreTache, celle ci est exécutée par la tâche nommée 'Default'
Task UneAutreTache {Write-Host "UneAutreTache : exécute du code"}