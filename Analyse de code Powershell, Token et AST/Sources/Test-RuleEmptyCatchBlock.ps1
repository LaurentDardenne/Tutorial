Function Test-RuleEmptyCatchBlock {
#D'après CheckInPolicy.CheckForEmptyCatchBlock - MS Script Browser
 param($catchClauseAst) 
 $Result=$false
 if ($catchClauseAst -is [System.Management.Automation.Language.CatchClauseAst])
 {
   $Result=$catchClauseAst.Body.Statements.Count -eq 0
   Write-Warning "RuleEmptyCatchBlock is $Result := $catchClauseAst"
 }
 $Result
}


