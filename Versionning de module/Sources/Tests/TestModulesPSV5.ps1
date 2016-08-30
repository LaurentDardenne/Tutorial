#Test module version 5.0
#Requires -Version 5.0

if (-not (Test-Path Variable:oldPSModulePath))
{
  . .\Initialize-Environment.ps1
  Invoke-Pester .\IPMO-DirectoryStructurePSV4.ps1
  Invoke-Pester .\AutoLoading-DirectoryStructurePSV4.Tests.ps1
}

Invoke-Pester .\IPMO-PSV5-FQN_With_DirectoryStructurePSV4.Tests.ps1

$MyPath = $Source + '\ModulesV5'
$FabrikamPath = $Source + '\FabrikamModulesV5'

Write-host "`r`nSource=$Source"
Write-host "MyPath=$MyPath"
Write-host "FabrikamPath=$FabrikamPath"

Invoke-Pester .\IPMO-DirectoryStructurePSV5.Tests.ps1
Invoke-Pester .\IPMO-PSV5-FQN_With_DirectoryStructurePSV5.Tests.ps1
Invoke-Pester .\AutoLoading-DirectoryStructurePSV5.Tests.ps1  