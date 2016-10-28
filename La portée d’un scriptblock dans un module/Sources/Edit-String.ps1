Function Edit-String {
  param(
   [string]$pattern,
   [string] $Text,
   [scriptblock] $evaluator 
  )         
 
 $Regex=New-Object System.Text.RegularExpressions.RegEx $pattern
 $Regex.Replace($Text, $evaluator)
}
