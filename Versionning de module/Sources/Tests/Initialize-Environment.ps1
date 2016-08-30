#Initialize-Environment.ps1

New-Variable -name oldPSModulePath -value $env:PSModulePath -Option ReadOnly

$MyGuidModule='a5d7c151-56cf-40a4-839f-0019898eb324'
$FabrikamGuidModule='9df5e76c-91a5-46f2-8e3f-1683d42ea1c8'

$Source= split-path $PSScriptRoot -Parent
$MyPath = $Source + '\Modules'
$FabrikamPath = $Source + '\FabrikamModules'

Write-host "Source=$Source"
Write-host "MyPath=$MyPath"
Write-host "FabrikamPath=$FabrikamPath"
