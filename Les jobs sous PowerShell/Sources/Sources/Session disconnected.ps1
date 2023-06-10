http://powertoe.wordpress.com/2012/06/25/receiving-a-disconnected-powershell-session-asjob/

$Session  = New-PSSession -ComputerName Localhost -Name Job

$job = Invoke-Command $Session  {sleep -s 30; "Message"} -AsJob
$null=Register-ObjectEvent $Job StateChanged -SourceIdentifier "StateChanged_$($Job.Name)" -MessageData  $Logname -Action {
      $EventName=$EventArgs.JobStateInfo.ToString()
      Write-Warning "Etat précédent : $($EventArgs.PreviousJobStateInfo.State)"
      Switch ($EventName) {
      'Completed' { Write-Warning 'Job dans l''état Completed.'; 
                    $global:datas=Receive-Job -id $Sender.Id                     
                    Remove-job -id $Sender.Id
                    Break                  }
      'Failed'    { Write-Warning 'Job dans l''état Failed'; Break}   
      'Stopped'   { Write-Warning 'Job dans l''état Stopped'; Break}
      'Stopped'   { Write-Warning 'Job dans l''état Stopped'; Break}
      default     { Write-Warning "Cet état n''est pas géré : $EventName."}  
     }#Switch 
   }  #Action
   
get-job
Disconnect-PSSession $Session
get-job

sleep 7
Connect-PSSession $Session
get-job

$session|Receive-PSSession
Receive-Job $job
# Remove-PSSession -name Job
