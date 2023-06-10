
#---- Initialise les prérequis du lanceur de Job 
 #Nom de l'eventlog dédié hébergeant les demandes de job
$EventLogName='Launcher'  

 #Nom d'une source pour l'eventlog dédié.
 #On y émet des demandes de job 
$EventLogSourceName='ReceptionOrdre' 

 #Create
New-EventLog -logname $EventLogName -Source $EventLogSourceName
#[System.Diagnostics.EventLog]::CreateEventSource($EventLogSourceName,$EventLogName)

Get-EventLog -List
Dir HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Launcher

 #Delete
#[System.Diagnostics.EventLog]::DeleteEventSource($EventLogSourceName)
#Remove-EventLog -LogName $EventLogName


#--- Launcher
 $EventLogName='Launcher'  
 $EventLogSourceName='ReceptionOrdre' 

  #Récupère l'eventlog à surveiller
 $EventLog=Get-EventLog -List |Where {$_.log -eq $EventLogName}
 if ($EventLog -eq $null)
  {Throw "Le journal d'événement $EventLogName est introuvable. Le laucnher est dans l'impossibilité de fonctionner."}   

   #On s'abonne à la création d'entrées sur l'eventlog à surveiller
   #L'événement est déclenché lors de la création d'un event dans le journal d'événement Windows 'Launcher'
   #L'événement est traité par Wait-Event, car le paramétre -Action n'est pas précisé.
$JobEventEntryWritten=Register-ObjectEvent $EventLog EntryWritten -SourceIdentifier EventEntryWrittenInEventLog 

 #Noms des commandes 
$CmdTraitement=1
$CmdInventaire=$CmdTraitement+1  
$CmdStopLauncher=$CmdTraitement+2 

#Simule un autre process
Start-Job {
   #Reprend les mêmes déclarations connues du Launcher
   # Elles devraient être dans un script ou un module commun 
  $EventLogName='Launcher'  
  $EventLogSourceName='ReceptionOrdre'
   
  $CmdTraitement=1
  $CmdInventaire=$CmdTraitement+1  
  $CmdStopLauncher=$CmdTraitement+2 
  
   Sleep -S 5
   #Emet les demandes, traité par le launcher dans un autre process
   #Ici ce n'est pas du forwarding d'event
  Write-Eventlog -logname $EventLogName -source $EventLogSourceName -eventID $CmdTraitement  -entrytype Information -message 'MesDonnées' -category 1 
   Sleep -S 2
  Write-Eventlog -logname $EventLogName -source $EventLogSourceName -eventID $CmdInventaire -entrytype Information -message 'ServerName' -category 1  
   #pas de déclenchement, EntryType n'est pas géré
  Write-Eventlog -logname $EventLogName -source $EventLogSourceName -eventID $CmdStopLauncher -entrytype FailureAudit -message 'Test' -category 1
  Sleep -S 2
  #Write-Eventlog -logname $EventLogName -source $EventLogSourceName -eventID $CmdStopLauncher -entrytype Information -message 'Stop' -category 1
   #Le launcher ne teste pas la source
  Write-Eventlog -logname $EventLogName -source 'Launcher' -eventID $CmdStopLauncher -entrytype Information -message 'Stop. Source Launcher' -category 1
} -Name SimuleProcess

 #Variable du launcher 
$ActivateLaunch=$true
 
While ($ActivateLaunch -eq $true)
{
   try { 
     $CurrentEvent=Wait-Event 
      #Le launcher peut traiter plusieurs source d'évenement.
      # On peut ajouter un timeout via un timer,etc.
     Switch ($CurrentEvent.SourceIdentifier) {
       "EventEntryWrittenInEventLog" {
           #Pointe sur les données typées de l'événement courant
         $EventArgs=$CurrentEvent.SourceEventArgs
         Write-Warning "Event[JobEventEntryWritten] EntryType=$($Eventargs.Entry.EntryType) EventID=$($Eventargs.Entry.EventID) Message=$($Eventargs.Entry.Message)."
      
         if ($Eventargs.Entry.EntryType -ne "Information" )
         { Write-Warning "La valeur du champ EntryType n'est pas gérée : $($Eventargs.Entry.EntryType)" }       
         else 
         {
            Write-Warning "Data=$($Eventargs.Entry.Message)"
            $Data=$Eventargs.Entry.Message 
            Write-Warning "Cmd=$($Eventargs.Entry.EventID) Datas=$Data"
            switch ($Eventargs.Entry.EventID)
            {
               $CmdTraitement     { 
                                    Start-Job { "Exécution d'un traitement" }  -Name 'CmdTraitement'
                                    Break 
                                  }

               $CmdInventaire     { 
                                    Start-Job { "Exécution de l'inventaire" }  -Name 'CmdInventaire'
                                    Break 
                                  }

               $CmdStopLauncher   { 
                                    Write-Warning "Stop Launcher"
                                      Write-Warning "Annule l'abonnement de l'event 'EntryWritten'."
                                       #Dans ce cas la variable automatique $EventSubscriber n'est pas disponible,
                                       #et il n'y a pas de job lié à la gestion de l'événement
                                    UnRegister-Event  -SourceIdentifier EventEntryWrittenInEventLog 
                                    $ActivateLaunch=$false
                                    Break 
                                  }
               default { Write-Error "EventID inconnu: $($Eventargs.Entry.EventID)" }
            } #switch Entry
         }#else
        } #EventEntryWrittenInEventLog
       
       #Autre event, Timer par exemple
       
       default { Write-Error "Identifiant de message inconnu $_" }
     }#Switch  SourceIdentifier
    }Finally {
       #On prend en charge la suppression du message dans le file d'attente
      Remove-Event -EventIdentifier $CurrentEvent.EventIdentifier -EA SilentlyContinue
    }
}#While
Write-Warning "Fin de l'attente d'event"

 #On fait de le ménage
Get-EventSubscriber
Get-Job
Get-EventLog $EventLogName
Get-Job|Receive-Job

# Get-Job|Remove-Job -Force

