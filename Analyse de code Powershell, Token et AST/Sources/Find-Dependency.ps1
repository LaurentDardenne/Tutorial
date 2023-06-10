#Recherche de dépendances de module
#Version PS v2
#On exécute le code sous PS v3

#Requires -Version 3.0

$PSModuleAutoloadingPreference=’All’
$RuntimeModules=@(
 'Microsoft.PowerShell.Diagnostics',
 'Microsoft.PowerShell.Host',
 'Microsoft.PowerShell.Management',
 'Microsoft.PowerShell.Security',
 'Microsoft.PowerShell.Utility',
 'Microsoft.WSMan.Management'
)
$Code=@'
 function Show-BitsTransfer{
  Write-Host "BitsTransfer report" -fore Green
  Get-BitsTransfer
  Get-Ghost   #Erreur
  Disable-PSTrace
 }#Show-BitsTransfer
'@
[ref]$Errors = [System.Management.Automation.PSParseError[]] @()
$Result=[System.Management.Automation.PSParser]::Tokenize($Code, $Errors)
$Modules=$Result|  Where-Object {$_.Type -eq 'Command'}|
  Foreach-Object {
   try {
     $CommandName=$_.Content
     $Command=Get-Command $CommandName -EA Stop
     $ModuleName=$Command.ModuleName
     if ($RuntimeModules -NotContains $ModuleName)
     {Write-Output $ModuleName}
     Write-Host "La commande '$CommandName' dépend du module :"
     Write-Host "`t $ModuleName -> $((Get-Module $ModuleName).ModuleBase)"
   } 
   catch {
     Write-Error "Commande inconnue: '$CommandName'"         
   }                 
 }
$OFS=','
Write-host "#Requires -Modules $Modules"
