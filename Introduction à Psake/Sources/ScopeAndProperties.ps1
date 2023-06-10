#Voir : https://github.com/psake/psake/wiki/How-can-I-set-a-variable-in-one-task-and-reference-it-in-another%3F

properties {
  $x = 1
}

 #Si on ne supprime pas la variable $script:X
 #son contenu persiste entre deux appels de la fonction Invoke-Psake 
 #
 #Une fois le problème constaté, décommenter le nom de la tâche Finalyze
task default -depends TaskA, TaskB #, Finalyze

task TaskA {
  write-host "$TaskName script:X = $script:x"
  write-host "$TaskName X = $x"
  
 $script:x = 100
}

task TaskB {
 Write-Host "$TaskName $x = $script:x"
}

task Finalyze {
 #Supprime la variable en fin d'exécution
 #Sinon celle-ci demeure présente dans la portée du module
 Remove-Variable X -Scope script
}