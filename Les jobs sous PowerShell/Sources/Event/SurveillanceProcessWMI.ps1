$Query=@"
  Select * from __InstanceCreationEvent within 1
   where targetinstance isa 'Win32_Process'
"@
$Action = { 
   $Target=$event.SourceEventArgs.Newevent.TargetInstance
   $S="Process créé {0} {1}\{2} : {3}"
   $msg= $S –F $Target.Handle,$Target.ExecutablePath,$Target.Name,$Target.CommandLine
   Write-Warning $msg
}#$Action

Register-WMIEvent -query $Query -sourceIdentifier "TraceCreateProcess" -action $Action > $Null


$Query=@"
  Select * from __InstanceDeletionEvent within 1
   where targetinstance isa 'Win32_Process'
"@
$Action = { 
   $Target=$event.SourceEventArgs.Newevent.TargetInstance
   $S="Process détruit {0} {1}\{2}"
   $msg= $S –F $Target.Handle,$Target.ExecutablePath,$Target.Name
   Write-Warning $msg
}#$Action

Register-WMIEvent -query $Query -sourceIdentifier "TraceDestroyProcess" -action $Action > $Null


