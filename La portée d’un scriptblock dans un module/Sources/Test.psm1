 $maVar='Portée du module.'
 $script:evaluator={'.';Write-Warning "maVar=$maVar"}

 Function Edit-String {
  param(
   [string]$pattern,
   [string] $Text,
   [scriptblock] $evaluator 
  )         
  $Regex=New-Object System.Text.RegularExpressions.RegEx $pattern
  $Regex.Replace($Text, $script:evaluator)
 }
Export-ModuleMember -variable evaluator -function Edit-String
