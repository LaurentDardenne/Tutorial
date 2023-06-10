#Affiche le détail de la variable $Psake hors tâche et à l'intéreur d'une tâche

function Convert-DictionnaryEntry($Parameters) 
{   #Converti un DictionnaryEntry en une string "clé=valeur clé=valeur..." 
  $Parameters.GetEnumerator()|% {Write-host "$($_.key)=$($_.value)"}
}#Convert-DictionnaryEntry

Write-Host 'VAR  $psake' -fore green
#$psake.GetEnumerator()
Convert-DictionnaryEntry $psake

Write-Host 'VAR $psake.Context'  -fore green
#Context est du type System.Collections.Stack
$psake.Context.GetEnumerator()
#
#Ici $psake.Context.tasks est vide 
Read-Host 'Cliquez sur Entrée pour continuer...' | Out-Null

if ($psake.Context.tasks.Count -eq 0)
{Task default -Depends Build }

Write-Host ('-' * 80)

task Default -Depends Build   
Task Build -depend Init {
Write-Host 'Inner Build Var  $psake.Context'  -fore green
#$psake.Context|select *
$psake.Context.GetEnumerator()     
}

Task Init {
   Write-Host "Tâche Init : On termine la construction."
Write-Host 'Inner Init VAR  $psake' -fore green
#$psake|select *
Convert-DictionnaryEntry $psake

Write-Host 'Inner Init VAR $psake.Context'  -fore green
#$psake.Context|select *
$psake.Context.GetEnumerator()

Write-Host 'Inner Init VAR $psake.Context.tasks'  -fore green
$psake.Context.GetEnumerator()|% {$_.tasks.GetEnumerator()}
#ou
#$currentContext.tasks.GetEnumerator()

Write-Host 'Inner Init VAR default task'  -fore green
$psake.Context.GetEnumerator()|
 foreach {$_.tasks.GetEnumerator()|Where {$_.Name -eq 'Default'}}|
 foreach {$_.Value}

Read-Host 'Cliquez sur Entrée pour continuer...' | Out-Null
}
