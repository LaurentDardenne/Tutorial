Throw "Modifiez les path des fichiers d'aide, puis supprimez cette ligne."
# .ExternalHelp C:\temp\HELP\View-Localized.ps1.xml

#View-Localized.ps1

#Ce fichier et la La fonction suivante contiennent une référence à 
#un fichier d'aide externe distinct.
#Le discriminant est l'extension .ps1 dans le nom du fichier d'aide.

#Renommer le répertoire fr-FR pour accéder au fichier d'aide de ce script.
#Dans ce cas Get-Help utilisera la culture invariant pour le fichier d'aide 
#de la fonction et de ce script.   

# Dans une fonction ExternalHelp doit être la première ligne, et 
# ne doit pas être suivi de commentaire (bug ?).
Function View-Localized {
# .ExternalHelp C:\temp\HELP\View-Localized.xml
  [CmdletBinding( 
      SupportsShouldProcess=$True, 
      ConfirmImpact="Medium")] 
  Param (   
  [Parameter(
      ValueFromPipeline = $true)]
  $NomParam,
  $Count)
  
  #Test
 Begin {  Write-host "Begin block View-Localized"  }
 Process {
   Write-host "Process block View-Localized : $_"
   }

 End { Write-host "End block View-Localized" }
}

 #Appel de l'aide de la fonction
Get-Help View-Localized
 #Appel de l'aide de ce script (FullPath).
Get-Help "$pwd\View-Localized.ps1"
