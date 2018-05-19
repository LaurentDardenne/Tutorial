cd "G:\PS\Log4NET\Log4Poshv2"
signe .\Log4Posh.psm1
dbgon
import-module "G:\PS\Log4NET\Log4Poshv2\Log4Posh.psd1" -verbose

Remove-Module log4pos
Set-LogBasicConfigurator


$m=Get-Module
wp $m

[AppDomain]::CurrentDomain.GetAssemblies()|select location

Remove-Module log*

Get-Member -In $From -MemberType *Property -Name $propertyName|Sort name

Get-Member : Cannot evaluate parameter 'InputObject' because its argument is specified as a script block and there is no input. A script block cannot be evaluated without input.
