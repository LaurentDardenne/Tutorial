Throw "Modifiez le chemin dans le fichier source"

cd 'C:\temp\LesJobSousPowershell\Sources\C#" # <-------  
Import-Module .\JobSourceAdapter.dll

#Cr�e un job de surveillance sur le fichier 'C:\temp\Test.ps1'
#En interne le cmdlet utilise un objet de type FileSystemWatcher.
#D�s que la date (LastWriteTime) du fichier est modifi�e, cet objet d�clenche un �v�nement, 
#puis le job recopie le fichier dans 'C:\temp\Copie\Test.ps1'.
#Le job reste � l'�tat Running et reste � l'�coute du FileSystemWatcher    
 
Get-FileCopyJob -Name Copy1 -SourcePath C:\temp\Test.ps1 -DestinationPath C:\temp\Copie\Test.ps1
Get-Job 
receive-job  -id 2
dir C:\Temp\Copie

#On doit modifier le fichier Source pour d�clencher le job.

#Suspend le job et l'�coute du FileSystemWatcher   
Suspend-Job 
Resume-Job  

Stop-Job 
Remove-Job
#Cette classe de job utilise les m�mes cmdlets que les autres type de job. 