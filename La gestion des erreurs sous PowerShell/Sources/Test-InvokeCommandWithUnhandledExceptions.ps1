$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. .\Invoke-CommandWithUnhandledExceptions

function Get-LastError{
  param (
     [Parameter(Position=1, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
      #Chemin contenant les fichiers de log générés
      # par la fonction Invoke-CommandWithUnhandledExceptions
    [String] $Path
  )     
 if (-not (Test-Path $Path)) 
 { Throw "Le répertoire n'existe pas :$path" }           
 $Fichier=
   Dir "$Path\*.xml"|
   Sort LastWriteTime -Desc|
   Select -First 1
  
  If ($Fichier -eq $Null) 
  { write-Warning "Aucun fichier d'erreur trouvé dans '$path'" } 
  else
  {
    Write-Host "Chargement du dernier fichier d'erreur généré :" -Fore Green -Back Black -NoNewLine
    Write-Host " $Fichier" -Fore Black -Back green 
    $Fichier|Import-Clixml
  }
}#Get-LastError

$sbTraitement={
  throw "Simule une erreur imprévue."
}#$sbInventory

 #Nettoie la collection d'erreurs avant l'exécution du traitement
$Error.Clear()
Invoke-CommandWithUnhandledExceptions 'TraitementDeTest' "$scriptPath\Logs" $sbTraitement

Get-LastError "$scriptPath\Logs"

  