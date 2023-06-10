Throw "Modifiez le chemin dans le fichier source"

cd 'C:\temp\LesJobSousPowershell\Sources\C#" # <-------  
Import-Module .\JobSourceAdapter.dll

#Crée un job de surveillance sur le fichier 'C:\temp\Test.ps1'
#En interne le cmdlet utilise un objet de type FileSystemWatcher.
#Dés que la date (LastWriteTime) du fichier est modifiée, cet objet déclenche un événement, 
#puis le job recopie le fichier dans 'C:\temp\Copie\Test.ps1'.
#Le job reste à l'état Running et reste à l'écoute du FileSystemWatcher    
 
Get-FileCopyJob -Name Copy1 -SourcePath C:\temp\Test.ps1 -DestinationPath C:\temp\Copie\Test.ps1
Get-Job 
receive-job  -id 2
dir C:\Temp\Copie

#On doit modifier le fichier Source pour déclencher le job.

#Suspend le job et l'écoute du FileSystemWatcher   
Suspend-Job 
Resume-Job  

Stop-Job 
Remove-Job
#Cette classe de job utilise les mêmes cmdlets que les autres type de job. 