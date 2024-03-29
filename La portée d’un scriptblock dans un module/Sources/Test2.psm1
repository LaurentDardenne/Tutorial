# si $maVar existe InvokeWithContext l'utilse sinon il utilise la portée parent ?   
# $maVar='Portée du module.'
 $script:evaluator={'.';Write-Warning "maVar=$maVar"}

 Function Edit-String {
  param(
   [string]$pattern,
   [string] $Text,
   [scriptblock] $evaluator 
  )         
  $listVar=[System.Collections.Generic.List[System.Management.Automation.PSVariable]]::New()
  $listVar.Add((New-Object PSVariable @('maVar', $maVar)))

  $Regex=New-Object System.Text.RegularExpressions.RegEx $pattern
  $Regex.Replace(
    $Text, 
    $script:evaluator.InvokeWithContext( @{}, $ListVar)
  )
 }
Export-ModuleMember -variable evaluator -function Edit-String

