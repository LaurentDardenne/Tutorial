#Partie 2/2
#Le script Test_WMIEvent_Buffer-Surveillance.ps1 doit avoir été 
# exécuté dans une console PowerShell distincte.


#Le script de tests a exécuter dans une seconde console PowerShell :
 #Ne pas oublier de créer les deux fonctions utilisées.

 #ATTENTION à ne pas remplir l'eventlog sélectionné ;-) 
 #On crée une source d'événement ainsi : 
 # [System.Diagnostics.EventLog]::CreateEventSource("TestEventWatcher",'Application')
 # Autres fonctions liées au source : 
 #  [System.Diagnostics.EventLog]::SourceExists("TestEventWatcher")
 #  [System.Diagnostics.EventLog]::LogNameFromSourceName("TestEventWatcher", ".");
 #  [System.Diagnostics.EventLog]::DeleteEventSource("TestEventWatcher") 

function New-EventLogEntryType([string]$EventLogName="Application")
{ #crée un événement de test dans l'eventlog $EventLogName

 $Event=new-object System.Diagnostics.EventLog($EventLogName)
 $Event.Source="TestEventWatcher"
  #Crée la source si elle n'existe pas
 $Event.WriteEntry("Test événement WMI sous PowerShell",[System.Diagnostics.EventLogEntryType]::Information)
}

function Start-Process([string]$Path)
{ 
 [diagnostics.process]::start($Path)
}

 #puisqu'on écoute la création de fichier on supprime les fichiers de tests existants.
del c:\temp\PSTest*.txt
1..10|% {Start-Process Notepad.exe;"test" > "c:\temp\PSTest$_.txt";New-EventLogEntryType}
# Consulter la console PowerShell où est exécuté 
#le script Test_WMIEvent_Buffer-Surveillance.ps1 