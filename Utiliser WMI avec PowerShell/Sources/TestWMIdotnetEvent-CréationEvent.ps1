#Partie 2/2
#Le script de tests a ex�cuter dans une seconde console PowerShell :
 #Ne pas oublier de cr�er les deux fonctions utilis�es.

function Start-Process([string]$Path)
{ 
 [diagnostics.process]::start($Path)
}

#---- Fonctions de test -----
 #ATTENTION � ne pas saturer l'eventlog s�lectionn� ;-)
function New-EventLogEntryType([string]$EventLogName="Application",$Source="TestEventWatcher")
{ #cr�e un �v�nement de test dans l'eventlog $EventLogName

 $Event=new-object System.Diagnostics.EventLog($EventLogName)
  #on cr�e une source ainsi :
  # [System.Diagnostics.EventLog]::CreateEventSource("TestEventWatcher",'Application')
 $Event.Source=$Source
 $Event.WriteEntry("Test �v�nement WMI sous PowerShell",[System.Diagnostics.EventLogEntryType]::Information)
}

 #puisqu'on surveille la cr�ation de fichier on supprime les fichiers de tests existants.
del c:\temp\PSTest*.txt

[reflection.assembly]::loadwithpartialname("WMIEvent")
 #On v�rifie que la surveillance des process est active
Start-Process Notepad.exe
 #Arr�te la surveillance des process notepad
$Event=New-object WMIEvent.PoshStopWatchingEvent("Process",
                                                 $pid,
                                                ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                 [WMIEvent.PoshTransmissionActor]::PowerShell)
$Event
 #d�clenche l'�v�nement
$Event.Fire()
Sleep 1
 #On v�rifie que la surveillance des process est inactive
Start-Process Notepad.exe
 #On �met une seconde demande, elle n'est pas prise en compte 
 # mais un message signale le cas
$Event.Fire()
 #Test la gestion d'une Event WMI dotnet inconnu 
 # dans le script de surveillance
$Event=New-object WMIEvent.PoshOperationEvent("Unknown EventName",
                                              $pid,
                                              ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                              [WMIEvent.PoshTransmissionActor]::PowerShell)
$Event.Fire()

 #Red�marre la surveillance des process notepad
$Event=New-object WMIEvent.PoshOperationEvent("StartWatching Process",
                                                 $pid,
                                                ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                 [WMIEvent.PoshTransmissionActor]::PowerShell)
$Event
$Event.Fire()
 #On v�rifie que la surveillance des process est active
Start-Process Notepad.exe
Sleep 4
 #Arr�te la surveillance, ici la session PS de surveillance quittera la boucle While  
$StopWatching=New-object WMIEvent.PoshStopWatchingEvent("AllWatching",
                                                        $pid,
                                                        ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                        [WMIEvent.PoshTransmitter]::Host)
                                                        
$StopWatching.Fire()
pause #Consultez la console de la premi�re instance de PowerShell

#Pour relancer ce test ou d'autres il suffit d'�x�cuter le script TestWMIEvents dans la premi�re instance de PowerShell
