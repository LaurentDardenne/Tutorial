﻿$InitialSessionState= [System.Management.Automation.Runspaces.InitialSessionState]::Create()

$SessionStateCmdletEntry = New-Object System.Management.Automation.Runspaces.SessionStateCmdletEntry 'Get-ChildItem','Microsoft.PowerShell.Commands.GetChildItemCommand',$null
$InitialSessionState.Commands.Add($SessionStateCmdletEntry)

$Provider = New-Object System.Management.Automation.Runspaces.SessionStateProviderEntry 'FileSystem',([Microsoft.PowerShell.Commands.FileSystemProvider]),$null
$InitialSessionState.Providers.Add($Provider)

try {
 $Runspace= [RunspaceFactory]::CreateRunspace($InitialSessionState)
 $Runspace.Open()
 try {
  $PS = [PowerShell]::Create()
  $PS.Runspace = $Runspace
  $null=$PS.AddCommand("Get-ChildItem").AddParameter('Path','C:\temp\')

  $Results = $PS.Invoke()
  if ($PS.Streams.Error.Count -gt 0)
  { 
   Write-Warning "Erreur"
   $PS.Streams.Error 
  }
 }
 finally {
  $PS.Dispose()
 }
}
finally {
 $Runspace.Dispose()
}

