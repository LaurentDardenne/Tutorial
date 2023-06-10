 #---- Initialisation du script principal
Import-Module Log4Posh 

 #Configure les loggers pour ce script
 #Le chemin du FileAppender nomm� 'FileExternal' est redirig�
 #L'appenders Console est activ�s
 #Les variables logger sont cr��es dans la port�e de l'appelant de ce script
Initialize-Log4NetScript -FileExternal "C:\Temp\Main.log" -Console All

#Affiche les fichiers de logs 
'log4net-default-repository'|
 Get-Log4NetRepository|
 Get-Log4NetFileAppender -All|
 Select Name,File,LockingModel,RepositoryName|fl -GroupBy RepositoryName

 #R�cup�re l'objet repository de ce script,
 #puis r�cup�re le logger 'Console' a fin d'activer les 
 # logs sur la console tout en modifiant le niveau de log
[Log4net.LogManager]::GetRepository()|
  Get-Log4NetLogger -Name 'InfoLogger','DebugLogger'| 
  Set-Log4NetAppenderThreshold -AppenderName 'Console' -Level Debug 
  
$InfoLogger.PSInfo("Logger info ready.")
$DebugLogger.PSDebug("Logger not debug ready.")

 #Configure une variable utilis�e dans le fichier de configuration XML :
 #
 #     <layout type="log4net.Layout.PatternLayout">
 #       <param name="ConversionPattern" value="[PID:%property{Owner}] [%property{LogJobName}] %-5level %d{yyyy-MM-dd hh:mm:ss} � %message%newline"/>
$LogJobName.Value="Script_Principal"
$InfoLogger.PSInfo("Modification de la propri�t� LogJobName.")
 
Type "C:\Temp\Main.log" 

#---- Usage de log4Posh dans un job
$action={
  param($Server,$JobName)
     #Initialisation du code du job 
   Import-Module Log4Posh
    #Dans un job, Log4Posh ne peut �crire sur la console, 
    #car l'objet ConsoleAppender utilise les APIs dotnet et pas celles de PS.
    #on fait pointer les traces dans le m�me fichier que le script principal
   Initialize-Log4NetScript -FileExternal "C:\Temp\Main.log" -Console None
   
   $InfoLogger.PSInfo("[$Server] Traitement")
   $LogJobName.Value=$JobName
   $InfoLogger.PSInfo("Modification de la propri�t� LogJobName.")
   $InfoLogger.PSDebug("Le niveau debug est d�sactiv�") 
   
    #Modifie le niveau de log
   $InfoLogger.Logger.Level=[log4net.Core.Level]::Debug
   $InfoLogger.PSDebug("[$Server]  JobName=$($LogJobName.Value)")
    #Arr�te les logs proprement
   Stop-Log4Net 
 }

start-job -Name 'Job1' -ArgumentList 'Server1','Job1' -ScriptBlock $action 
start-job -Name 'Job2' -ArgumentList 'Server2','Job2' -ScriptBlock $action

Sleep -s 4
Type "C:\Temp\Main.log"

 #Liste les appenders du logger fonctionnel
$InfoLogger.Logger.Appenders.Name

 #Liste les appenders du logger technique
$DebugLogger.Logger.Appenders.Name

$InfoLogger.PSDebug("Le niveau debug est d�sactiv�")
$InfoLogger.Logger.Level 

$InfoLogger.Logger.Level=[log4net.Core.Level]::Debug
$InfoLogger.PSDebug("Le niveau debug est activ�")
