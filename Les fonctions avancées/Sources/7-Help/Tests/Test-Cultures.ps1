. .\Using-Culture.ps1
. .\View-Localized.ps1

# $env:path +=";G:\temp\Help"
Get-Help View-Localized
Read-Host "Saisir enter"
 #Get-Help semble r�f�rencer la culture du poste 
 #et pas celle du thread courant.
 
 #L'aide Fr ou l'aide de la culture invariant (si
 #le r�pertoire Fr n'existe pas) est tjr appel�.  
Using-Culture de-DE { Get-Help View-Localized }
Read-Host "Saisir enter"

Using-Culture en-US { Get-Help View-Localized }
Read-Host "Saisir enter"
