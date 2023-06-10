$DllFile='C:\Program Files (x86)\Microsoft Corporation\Microsoft Script Browser\CheckInPolicy.dll'
if ( -not (Test-Path $DllFile) )
{Throw "Le fichier n'existe pas : $DllFile" }

Function Test-ScriptRules{
#Extrait de l'addon ISE Microsoft Script Analyzer.
#Ce script sert également de fichier de test pour 
#les régles de l'addon
 param(
  [string] $FilePath
 )
 try {
   #Initialize or RAZ the Problem collection
   #Create private AST from a script
  $PSAnalyzer = new-object CheckInPolicy.PSAnalyzer($FilePath)
  $PSAnalyzer.GetAvailableCmdletsAndAlias();   
   
   #Ces classes renseignent les propriétés de $PSAnalyzer
  new-object CheckInPolicy.IsAliasUsed >$null
  new-object CheckInPolicy.CheckForEmptyCatchBlock >$null
  new-object CheckInPolicy.PositionalArgumentsFound >$null
  new-object CheckInPolicy.FunctionNameUseStandardVerbName >$null
  new-object CheckInPolicy.InvokeExpressionFound >$null
  
  $pbCount=$PSAnalyzer.getProblemCount
  if ($pbCount -gt 0)
  {
     for ($i = 0; $i -lt $pbCount; $i++)
     {
        $pSAnalyzer.GetProblem($i)
     }
  }
 }
 catch 
 {
  #bloc vide 
 }
}#Test-ScriptRule

$Asm=Add-Type -Path $DllFile -pass
$Require="1.2.1"
if ($Asm[0].assembly.GetName().Version -le $Require)
{throw "Microsoft Script Browser\CheckInPolicy.dll : version '$Require' requise." }

$filePath="$PSScriptRoot\$($MyInvocation.MyCommand)"

Write-host "Analyse $FilePath" 
Write-host "$(Get-Date)"
$Result=Test-ScriptRules -FilePath $FilePath |
 Select ID, Line, Name, Script,Statement 
Write-host "$(Get-Date)"
$Result

#toutes les classes implémentant une régle
#hérite de System.Management.Automation.Language.AstVisitor
# [CheckInPolicy.IsAliasUsed]
# [CheckInPolicy.CheckForEmptyCatchBlock]
# [CheckInPolicy.PositionalArgumentsFound]
# [CheckInPolicy.FunctionNameUseStandardVerbName]
# [CheckInPolicy.InvokeExpressionFound]