$File='C:\Temp\DataSection1.ps1'
@'
Data {
  if ($PSCulture -eq 'Fr-fr')
  {"Français"}    
  else
  {"Autre"}
}
'@ > $File

. $File 

$File='C:\Temp\DataSection2.ps1'
@'
Data {
  if ($PSVersionTable.PSVersion -eq ([version]"2.0.0.0"))
  {"PowerShell 2.0"}    
  else
  {"PowerShell >= 3.0 "}
}
'@ > $File

. $File

$File='C:\Temp\DataSection4.ps1'
@'
Function Get-RSInfo {$ExecutionContext.host.Runspace|Select-Object * }

Data -supportedCommand Get-RSInfo {
  Get-RSInfo
}
'@ > $File

. $File 