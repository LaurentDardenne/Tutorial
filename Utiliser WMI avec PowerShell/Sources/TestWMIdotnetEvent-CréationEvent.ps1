#Partie 2/2
#Le script de tests a exécuter dans une seconde console PowerShell :
 #Ne pas oublier de créer les deux fonctions utilisées.

function Start-Process([string]$Path)
{ 
 [diagnostics.process]::start($Path)
}

#---- Fonctions de test -----
 #ATTENTION à ne pas saturer l'eventlog sélectionné ;-)
function New-EventLogEntryType([string]$EventLogName="Application",$Source="TestEventWatcher")
{ #crée un événement de test dans l'eventlog $EventLogName

 $Event=new-object System.Diagnostics.EventLog($EventLogName)
  #on crée une source ainsi :
  # [System.Diagnostics.EventLog]::CreateEventSource("TestEventWatcher",'Application')
 $Event.Source=$Source
 $Event.WriteEntry("Test événement WMI sous PowerShell",[System.Diagnostics.EventLogEntryType]::Information)
}

 #puisqu'on surveille la création de fichier on supprime les fichiers de tests existants.
del c:\temp\PSTest*.txt

[reflection.assembly]::loadwithpartialname("WMIEvent")
 #On vérifie que la surveillance des process est active
Start-Process Notepad.exe
 #Arrête la surveillance des process notepad
$Event=New-object WMIEvent.PoshStopWatchingEvent("Process",
                                                 $pid,
                                                ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                 [WMIEvent.PoshTransmissionActor]::PowerShell)
$Event
 #déclenche l'événement
$Event.Fire()
Sleep 1
 #On vérifie que la surveillance des process est inactive
Start-Process Notepad.exe
 #On émet une seconde demande, elle n'est pas prise en compte 
 # mais un message signale le cas
$Event.Fire()
 #Test la gestion d'une Event WMI dotnet inconnu 
 # dans le script de surveillance
$Event=New-object WMIEvent.PoshOperationEvent("Unknown EventName",
                                              $pid,
                                              ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                              [WMIEvent.PoshTransmissionActor]::PowerShell)
$Event.Fire()

 #Redémarre la surveillance des process notepad
$Event=New-object WMIEvent.PoshOperationEvent("StartWatching Process",
                                                 $pid,
                                                ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                 [WMIEvent.PoshTransmissionActor]::PowerShell)
$Event
$Event.Fire()
 #On vérifie que la surveillance des process est active
Start-Process Notepad.exe
Sleep 4
 #Arrête la surveillance, ici la session PS de surveillance quittera la boucle While  
$StopWatching=New-object WMIEvent.PoshStopWatchingEvent("AllWatching",
                                                        $pid,
                                                        ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                        [WMIEvent.PoshTransmitter]::Host)
                                                        
$StopWatching.Fire()
pause #Consultez la console de la première instance de PowerShell

#Pour relancer ce test ou d'autres il suffit d'éxécuter le script TestWMIEvents dans la première instance de PowerShell
