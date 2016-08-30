#Test Import-Module 
#Requires -Version 4.0

#Note : 
#   Certains résultats ne sont pas considérés comme des erreurs.
#   On utilise simplement le mécanisme de Pester pour afficher le résultat des différents cas.

. .\Initialize-Environment.ps1

Invoke-Pester $PSScriptRoot\IPMO-DirectoryStructurePSV4.Tests.ps1
Invoke-Pester $PSScriptRoot\AutoLoading-DirectoryStructurePSV4.Tests.ps1


if ($PSVersiontable.PSVersion -ge '5.0')
{
  .\TestModulesPSV5.ps1
}   
Remove-Variable -name oldPSModulePath -Force -ea SilentlyContinue