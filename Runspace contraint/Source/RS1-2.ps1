$InitialSessionState= [System.Management.Automation.Runspaces.InitialSessionState]::Create()

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
  $PS.AddCommand("Get-Process") > $null
  
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
