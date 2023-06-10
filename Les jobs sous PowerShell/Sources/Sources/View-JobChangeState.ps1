#View-JobChangeState

$Job=Start-Job -Name 'VisuEtat' -ScriptBlock {Sleep -s 3;Get-Item C:\}

$null=Register-ObjectEvent $Job StateChanged -SourceIdentifier "StateChanged_$($Job.Name)" -Action {
      $EventName=$EventArgs.JobStateInfo.ToString()
      
      # Etat précédent
      Write-Warning "Précédent: $($EventArgs.PreviousJobStateInfo.State)"
      Switch ($EventName) {
      'Completed' { Write-Warning 'Job dans l''état Completed.'; 
                    $global:datas =Receive-Job -id $Sender.Id                     
                    Remove-job -id $Sender.Id
                    Break                  }
      'Failed'    { Write-Warning 'Job dans l''état Failed'; Break}   
      'Stopped'   { Write-Warning 'Job dans l''état Stopped'; Break}
      default     {Write-Warning 'Cet état n''est pas géré : $EventName.'}  
     }#Switch 
       Write-Warning "Annule l'abonnement de l'event 'StateChanged'."
     UnRegister-Event -SubscriptionId $EventSubscriber.SubscriptionId
       Write-Warning "Supprime le job lié à la gestion de l'événement."
     Remove-job -id $EventSubscriber.Action.Id
    }  #Action

Get-EventSubscriber
Get-job
  Sleep -S 8
Get-EventSubscriber
Get-job

