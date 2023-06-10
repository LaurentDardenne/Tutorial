Function Out-Debuger{
  #Envoi $Message vers un debuger actif
  #Si aucun debugger n'existe au moment de l'ex�cution de ce code, il 
  # n'y aura aucune erreur de d�clench�e, car l'appel ne fait rien.
  #Le pr�fix permet de faciliter le filtrage des lignes dans DebugView.
  #N'est actif que si le code est ex�cut� dans la m�me session que celle
  #l'appelant. 
  #par exemple un script ex�cut� par un service ne pourra afficher des 
  #traces dans une instance de debugview ex�cut� dans la session d'un 
  #d�vellopeur/se 
 
 param (
  $Message,
  $PrefixFilter="[Orchestrator]"
 )
  [System.Diagnostics.Debug]::Write("$PrefixFilter $Message")   
}#Out-Debuger  

function New-Exception($Exception,$Message=$null) {
#Cr�e et renvoi un objet exception pour l'utiliser avec $PSCmdlet.WriteError()

   #Le constructeur de la classe de l'exception trapp�e est inaccessible  
  if ($Exception.GetType().IsNotPublic)
   {
     $ExceptionClassName="System.Exception"
      #On m�morise l'exception courante. 
     $InnerException=$Exception
   }
  else
   { 
     $ExceptionClassName=$Exception.GetType().FullName
     $InnerException=$Null
   }
  if ($Message -eq $null)
   {$Message=$Exception.Message}
    
   #Recr�e l'exception trapp�e avec un message personnalis� 
	New-Object $ExceptionClassName($Message,$InnerException)       
} #New-Exception

Function Invoke-CommandWithUnhandledException {
 #Cette fonction ex�cute du code Powershell, en cas d'erreur 
 #elle s�rialise la collection $Error dans un fichier XML. 
  param ( 
     [Parameter(Position=0, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
      #Nom de l'activit� utilis� pour construire le nom du fichier d'erreur
    [String] $ActivityName,
     
     [Parameter(Position=1, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
      #Chemin du fichier de log.
    [String] $Path,     
     
     [Parameter(Position=2, Mandatory=$true)]
     [ValidateNotNull()]
     [ValidateScript( {$_.ToString().Trim() -ne [string]::Empty} )]
      #Code Powershell 
    [ScriptBlock]$Command,
    
     #Si usage simultan� du module Log4Posh
    [switch] $StopLog4NET
  )
 
  $isStopException=$False
  $CatchedException=$null
  try {
    Out-Debuger "Run Command"
      #Ex�cute le code dans la port�e courante
    . $Command
  } 
  catch  #Trappe toutes les erreurs
  {
      $ex=$_.Exception
      if ($StopLog4Net) 
      { $Logger.Fatal('UnhandledExceptions',$ex) }
       #on enregistre la collection erreur
      $isStopException=$true
      $CatchedException=New-Exception $Ex 
  } #catch all exceptions
  
  Finally {  #Enregistre la collection $Error si demand�
    try {
      $FileName="$Path\{0}-{1:dd-MM-yyyy-HH-mm-ss}-{2}.xml" -F $env:Computername,[DateTime]::Now,$ActivityName
      if ($isStopException)
      { 
        try {
         Write-host "$ActivityName : unhandled exception $_"  
         Write-host "File error log = $FileName"
        } 
        catch 
        {} #Si le host ne permet pas l'appel � write-host. Exceptions inconnues !!
        
        if ($StopLog4Net) 
        { $Logger.Fatal("Detail into $FileName") }
         #On clone la collection afin d'�viter l'exception InvalidOperationException
         # http://msdn.microsoft.com/en-us/library/system.collections.ienumerator.movenext%28v=vs.80%29.aspx
        $CpError=$Global:Error.Clone()
        $CpError|Export-clixml $FileName
      }
    }catch {
       Out-Debuger "catch : '$_'"
       $_|set-content $FileName
     }
    finally {
      if ($StopLog4Net) 
      { Stop-Log4Net } 
       #On red�clenche l'exception, l'appelant est avertie
      if ($CatchedException -ne $null) 
      { throw $CatchedException } 
    }
  }#Finally
} #Invoke-CommandWithUnhandledException


function Get-LastError{
  param (
     [Parameter(Position=1, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
      #Chemin contenant les fichiers de log g�n�r�s
      # par la fonction Invoke-CommandWithUnhandledExceptions
    [String] $Path
  )     
 if (-not (Test-Path $Path)) 
 { Throw "Le r�pertoire n'existe pas :$path" }           
 $Fichier=
   Dir "$Path\*.xml"|
   Sort LastWriteTime -Desc|
   Select -First 1
  
  If ($Fichier -eq $Null) 
  { write-Warning "Aucun fichier d'erreur trouv� dans '$path'" } 
  else
  {
    Write-Host "Chargement du dernier fichier d'erreur g�n�r� :" -Fore Green -Back Black -NoNewLine
    Write-Host " $Fichier" -Fore Black -Back green 
    $Fichier|Import-Clixml
  }
}#Get-LastError
