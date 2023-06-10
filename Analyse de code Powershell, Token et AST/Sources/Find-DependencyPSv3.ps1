#Recherche de dépendances de module
#Version PS v3
#La liste des tokens permet de retrouver ceux imbriqués dans une sous-expression.
 
$PSModuleAutoloadingPreference='All'
$RuntimeModules=@(
 'Microsoft.PowerShell.Core',
 'Microsoft.PowerShell.Diagnostics',
 'Microsoft.PowerShell.Host',
 'Microsoft.PowerShell.Management',
 'Microsoft.PowerShell.Security',
 'Microsoft.PowerShell.Utility',
 'Microsoft.WSMan.Management',
 'ISE',
 'PSDesiredStateConfiguration', #PS v4
 'PSScheduledJob',
 'PSWorkflow',
 'PSWorkflowUtility'
)

$Code=@'
 function Show-BitsTransfer{
  Write-Host "BitsTransfer report" -fore Green
  Get-BitsTransfer
  Get-Ghost   #Erreur
  Disable-PSTrace
   #Sous-expression, nécessite le module Psionic
   # http://psionic.codeplex.com/
  $ExpandableString="$(Get-ZipFile C:\temp\F1.zip).Count)"
 }#Show-BitsTransfer
'@

		
$tokenAst = $null
$parseErrorsAst = $null
$scriptBlockAst	= [System.Management.Automation.Language.Parser]::ParseInput($Code, [ref]$tokenAst, [ref]$parseErrorsAst)

$Modules=$tokenAst|
  Foreach-object {
   if ($_ -is [System.Management.Automation.Language.StringExpandableToken])
   {$_.NestedTokens}
   else
   {$_} 
  }|
  Where-Object {$_.TokenFlags -eq 'CommandName'}|
  Foreach-Object{
   try {
     $CommandName=$_.Value
     $Command=Get-Command $CommandName -EA Stop
     $ModuleName=$Command.ModuleName
     $Version=$Command.Module.Version
     if ($RuntimeModules -NotContains $ModuleName)
     { Write-Output ('@{{ModuleName="{0}";ModuleVersion={1}}}' -F $ModuleName,$Version) }

     Write-Host "La commande '$CommandName' dépend du module :"
     Write-Host "`t $ModuleName -> $((Get-Module $ModuleName).ModuleBase)"
   } 
   catch {
     Write-Error "Commande inconnue : '$CommandName'"         
   }                 
 }

$OFS=','
Write-host "#Requires -Version 3.0"
Write-host "#Requires -Modules $Modules"
