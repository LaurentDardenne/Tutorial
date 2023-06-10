#Partie 2/2
#Le script Test_WMIEvent_Buffer-Surveillance.ps1 doit avoir �t� 
# ex�cut� dans une console PowerShell distincte.


#Le script de tests a ex�cuter dans une seconde console PowerShell :
 #Ne pas oublier de cr�er les deux fonctions utilis�es.

 #ATTENTION � ne pas remplir l'eventlog s�lectionn� ;-) 
 #On cr�e une source d'�v�nement ainsi : 
 # [System.Diagnostics.EventLog]::CreateEventSource("TestEventWatcher",'Application')
 # Autres fonctions li�es au source : 
 #  [System.Diagnostics.EventLog]::SourceExists("TestEventWatcher")
 #  [System.Diagnostics.EventLog]::LogNameFromSourceName("TestEventWatcher", ".");
 #  [System.Diagnostics.EventLog]::DeleteEventSource("TestEventWatcher") 

function New-EventLogEntryType([string]$EventLogName="Application")
{ #cr�e un �v�nement de test dans l'eventlog $EventLogName

 $Event=new-object System.Diagnostics.EventLog($EventLogName)
 $Event.Source="TestEventWatcher"
  #Cr�e la source si elle n'existe pas
 $Event.WriteEntry("Test �v�nement WMI sous PowerShell",[System.Diagnostics.EventLogEntryType]::Information)
}

function Start-Process([string]$Path)
{ 
 [diagnostics.process]::start($Path)
}

 #puisqu'on �coute la cr�ation de fichier on supprime les fichiers de tests existants.
del c:\temp\PSTest*.txt
1..10|% {Start-Process Notepad.exe;"test" > "c:\temp\PSTest$_.txt";New-EventLogEntryType}
# Consulter la console PowerShell o� est ex�cut� 
#le script Test_WMIEvent_Buffer-Surveillance.ps1 