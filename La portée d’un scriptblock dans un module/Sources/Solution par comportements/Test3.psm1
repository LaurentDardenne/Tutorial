$maVar='Portée du module.'
$script:evaluator={ '.';Write-Warning "maVar=$MaVar" }

Function Edit-String {
  param(
   [string]$pattern,
   [string] $Text,
   [scriptblock] $evaluator 
  )         
  $Regex=New-Object System.Text.RegularExpressions.RegEx $pattern
  $Regex.Replace($Text, $script:evaluator)
}

Write-warning "Utilise le scripblock du module"
Edit-String '\s' "Dans le module personne ne vous entend crier." $script:evaluator

Write-warning "Affecte un scriptblock créée dans la portée de l'appelant."
$script:evaluator=New-SBOuter
 
 #Supprime, car inutile désormais
Remove-item function:New-SBOuter

Write-warning "Utilise le Scripblock du module"
Edit-String '\s' "Dans le module personne ne vous entend crier." $script:evaluator

Export-ModuleMember -variable evaluator -function Edit-String