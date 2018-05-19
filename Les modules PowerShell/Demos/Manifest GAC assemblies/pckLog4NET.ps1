# ------------- Configuration ----------------------------------------------------------------------------
#Notes : 
#     Toutes les fonctions utilisant le pipeline ne renverront rien si on ne précise aucun paramètre. Voir leur bloc End
#     Il n'y a pas de fonction pour créer des objets Hierarchy et Repository (un par AppDomain), on utilise ceux par défaut.
#     On accédera a ces objets par l'intermédiaire d'un objet Logger.  
#    
#     !!!! Ces scripts utilisent les droits du compte ayant exécuté la session PowerShell et n'utilisent pas 
#     !!!! la propriété SecurityContext (Delegation) des Appenders.

 #J'ai préféré ajouter le préfixe LOG dans la partie name d'un nom de fonction, l'usage d'alias facilitera la saisie. 
 #Ainsi en cas de duplication de nom de function, la modification de l'alias n'implique pas de modifier le source du wrapper. 
Set-Alias -Scope Global -name Set-BasicConfigurator -value Set-LogBasicConfigurator 
Set-Alias -Scope Global -name slbcfg -value Set-LogBasicConfigurator  

function global:Set-LogBasicConfigurator([log4net.Appender.AppenderSkeleton] $Appender,
                                         [Switch] $Default) {
 #Configure le Framework, le root pointera sur $Appender 
  begin
   { 
      #En créant une fonction locale au contexte du pipeline on évite, dans le bloc PROCESS, 
      #la duplication de code de validation du paramètre $Appender qui peut provenir 
      # soit du pipeline par $_  
      # soit de la ligne de commande par $Appender
     Function BasicConfigurator([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Set-LogBasicConfigurator","Appender")),
                                [Switch] $Default){
       Stop-Log #Sinon on ajoute la nouvelle configuration à l'existante
       if ($Default) 
        {  if ($Appender -ne $null ) 
             {Throw  $LogDatas.Get("ConflictDetected","Set-LogBasicConfigurator","Appender","Default")}  
           else { [log4net.Config.BasicConfigurator]::Configure() }
        } 
       else 
        { [log4net.Config.BasicConfigurator]::Configure($Appender) }
     }
   }
  process #Gestion du pipeline  
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}
     if ($_)
     { 
      Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
      BasicConfigurator $_ -Default:$Default
       #réémet l'objet
	  $_
     }
  }
  end #Gestion de la ligne de commande
  { 
    if ($Appender -or $Default) 
     { 
       Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
       BasicConfigurator $Appender -Default:$Default 
     } 
  }
}


Set-Alias -Scope Global -name Set-XMLConfigurator -value Set-LogXMLConfigurator
Set-Alias -Scope Global -name slxmlcfg -value Set-LogXMLConfigurator
 
function global:Set-LogXMLConfigurator([String] $FileName=$(Throw $LogDatas.Get("NecessaryParameter","Set-LogXMLConfigurator","FileName")),
                                       [switch] $Watch) {
  #Configure log4net à partir d'un fichier de configuration XML : "C:\MonScript\PSLog.App.Config"
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 if (Test-path $FileName) #On teste l'existence d'un nom, mais avec la notion de provider PS "hklm:" est valide
 {
   Stop-Log #Sinon on ajoute la nouvelle configuration à l'existante
   $FileInfo=new-object System.IO.FileInfo $FileName
    #Si le fichier xml est erroné on ne peut pas le détecter, mais on peut visualiser les erreurs si le Framework est en mode debug.
    #Si le fichier xml est erroné les logs ne fonctionnent pas.
   if ($Watch) 
    {[log4net.Config.XmlConfigurator]::ConfigureAndWatch($FileInfo)}
   else 
   {[log4net.Config.XmlConfigurator]::Configure($FileInfo)}
  }
 else { throw $LogDatas.Get("XMLFileDontExist","Set-LogXMLConfigurator",$FileName)} 
}



# -------------  Level  ----------------------------------------------------------------------------
Set-Alias -Scope Global -name tstlvl -value Test-LogLevel

function global:Test-LogLevel([string] $LevelName=$(Throw $LogDatas.Get("NecessaryParameter","Test-LogLevel","LevelName")),
                              [log4net.Repository.ILoggerRepository] $Repository){
 #Test l'existence d'un nom de niveau dans la liste des niveaux référencés. S'il existe on renvoi l'objet level correspondant

  #Le niveau à tester peut ne pas être dans [log4net.Core.Level]
  #Mais tous les niveaux déclarés sont dans $Repository.LevelMap.AllLevels
 $ParentInvocation = (Get-Variable MyInvocation -Scope 1).Value 
 $CS="{0}.{1}" -F $ParentInvocation.MyCommand,$MyInvocation.MyCommand
 if ($Repository -eq $null)
  { Throw $LogDatas.Get("NullParameter",$CS,"Repository")}
 $Result=$Repository.LevelMap.AllLevels|Where {$_.Name -eq $LevelName}
 if ($Result -eq $null)
  { Throw $LogDatas.Get("UnknownLevelName",$CS,$LevelName,$($Repository.Name))}
 $Result
}


Set-Alias -Scope Global -name New-LevelEvaluator -value New-LogLevelEvaluator
Set-Alias -Scope Global -name nllvleval -value New-LogLevelEvaluator

function global:New-LogLevelEvaluator([string] $LevelName=$(Throw $LogDatas.Get("NecessaryParameter","New-LogLevelEvaluator","LevelName")),
                               [log4net.Repository.ILoggerRepository] $Repository) {
  if ($Repository -eq $null)
   { $Repository=Get-LogRepository -Default  }
   #Crée un objet évaluateur pour l'appender SMTP
  New-object log4net.Core.LevelEvaluator (Test-LogLevel $LevelName $Repository)
}




# ------------- Appender --------------------------------------------------------------------------
   # ---------- Appender:Création  --------------------------------------------------------------------------
Set-Alias -Scope Global -name Enable-Appender -value Enable-LogAppender
Set-Alias -Scope Global -name elapdr -value Enable-LogAppender   

function global:Enable-LogAppender([log4net.Appender.AppenderSkeleton] $Appender) {
  #Active les propriétés de l'appender par l'appel à ActiveOptions()
     
  begin
  {
    function EnableAppender([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Enable-LogAppender","Appender"))) {
        $Appender.ActivateOptions()
    }
  }
  process
  {
     
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}
    
     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        EnableAppender -Appender $_ 
        $_ 
     }
  }
  end
  {
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        EnableAppender -Appender $Appender
      }
  } 
}



Set-Alias -Scope Global -name New-Appender -value New-LogAppender
Set-Alias -Scope Global -name nlapdr -value New-LogAppender

function global:New-LogAppender([Type] $Class=$(Throw $LogDatas.Get("NecessaryParameter","New-LogAppender","Class")), 
                                [String] $LayoutPattern,
                                [String] $Name,
                                [Switch] $Activate) {
  #Crée un Appender de la classe $Classe
   #Il n'y a pas de prise en charge du pipe, impose que le premier segment de pipeline doit être un appel à new-LogXXXXAppender

   #On utilise [Type] $Class au lieu de  [log4net.Appender.AppenderSkeleton] $Class car 
   #le typage du paramètre force le cast  :/
   # ex: New-LogAppender ([log4net.Appender.ColoredConsoleAppender])
   
   # Activate : Appel ActivateOption sur l'appender créé, sinon c'est l'appelant qui s'en charge après 
   #            avoir renseigné d'autres champs.
     
   Write-Debug ("Call {0}" -F $MyInvocation.InvocationName)
   #"Class","LayoutPattern","Name","Activate"|% {$V=gv $_;Write-Debug ("{0} : {1}" -F $V.Name,$V.Value)}

                     
 if ($Class -eq $Null) 
   { Throw $LogDatas.Get("NullParameter","New-LogAppender","Class")} 
 if (!$Class.IsSubclassOf([log4net.Appender.AppenderSkeleton])) 
   { Throw $LogDatas.Get("NotDerivedClass","New-LogAppender", $Class,"AppenderSkeleton")}
 $Appender = new-object $Class
 if ($Name -eq [string]::Empty) 
  {$Name=[System.Guid]::NewGuid().ToString()}
 $Appender.Name=$Name
 &{
    trap {Throw "New-LogAppender.$($_.Exception.message)"}
    if ( ($LayoutPattern -ne $null) -And ($LayoutPattern -ne [String]::Empty) ) 
     {$Appender.Layout=New-LogLayout $LayoutPattern }
    else
     #default layout = "Info - message" 
    {$Appender.Layout=new-object log4net.Layout.SimpleLayout}
  } 
 if ($Activate) 
   {$Appender.ActivateOptions() }
  #émet le nouvel objet Appender dans le pipeline
 $Appender
}



Set-Alias -Scope Global -name New-ConsoleAppender -value New-LogConsoleAppender
Set-Alias -Scope Global -name nlcapdr -value New-LogConsoleAppender

function global:New-LogConsoleAppender([String] $LayoutPattern,
                                       [String] $Name,
                                       [Switch] $Activate) {
  #Crée un Appender permettant de loguer dans la console
  
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName) 
  #Pour cet appender il n'y a pas de configuration supplémentaire, on propage la décision d'activation des options
 New-LogAppender log4net.Appender.ConsoleAppender $LayoutPattern $Name  -Activate:$Activate 
 #New-LogAppender émet le nouvel objet dans le pipeline
}



Set-Alias -Scope Global -name New-ColoredAppender -value New-LogColoredConsoleAppender
Set-Alias -Scope Global -name nlclrapdr -value New-LogColoredConsoleAppender

function global:New-LogColoredConsoleAppender([System.Collections.Hashtable[]] $Colors,
                                              [String] $LayoutPattern,
                                              [String] $Name,
                                              [Switch] $Activate) {
  #Crée un appender de type console colorisée permettant de loguer dans la console
  
 Write-Debug ("Call {0}" -F $MyInvocation.InvocationName)
  #Pour cet appender il y a une configuration supplémentaire, on ne propage pas la décision d'activation des options
 $Appender=New-LogAppender log4net.Appender.ColoredConsoleAppender $LayoutPattern $Name  
 if ($Colors -ne $null )
  {$null=Add-LogMappingColors $Appender $Colors}
 if ($Activate) 
   {$Appender.ActivateOptions() }
 #else   Les segments de pipeline suivants peuvent modifier les options de cet appender
 #       Dans ce cas on devra appeler, en fin de configuration de cet appender, la fonction Enable-LogAppender.
 
 #Réémet le nouvel appender dans le pipeline 
 $Appender  
}


Set-Alias -Scope Global -name New-DebugAppender -value New-LogDebugAppender
Set-Alias -Scope Global -name nldbgapdr -value New-LogDebugAppender

function global:New-LogDebugAppender([String] $LayoutPattern,
                                     [String] $Name,
                                     [Switch] $Activate) {
  #Crée un OutputDebugStringAppender permettant de loguer dans un debugger
  #Utilise directement l'API Win32 OutputDebugString
  
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 New-LogAppender log4net.Appender.OutputDebugStringAppender $LayoutPattern $Name -Activate:$Activate
}


Set-Alias -Scope Global -name New-TraceAppender -value New-LogTraceAppender
Set-Alias -Scope Global -name nltrcapdr -value New-LogTraceAppender

function global:New-LogTraceAppender([String] $LayoutPattern,
                                     [String] $Name,
                                     [Switch] $Activate) {
  #Crée une TraceAppender permettant de loguer dans un debugger
  #Utilise le listener de .NET : System.Diagnostics.Trace.Write(string,string)
  #MSDN : "Écrit la sortie vers la fonction OutputDebugString et la méthode Debugger.Log."
  
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 New-LogAppender log4net.Appender.TraceAppender $LayoutPattern $Name -Activate:$Activate
}


Set-Alias -Scope Global -name New-FileAppender -value New-LogFileAppender
Set-Alias -Scope Global -name nlfapdr -value New-LogFileAppender

function global:New-LogFileAppender([String] $FileName,
                                    [String] $LayoutPattern,
                                    [String] $Name,
                                    [System.Text.Encoding] $Encoding=[System.Text.Encoding]::Unicode,
                                    [Switch] $NotImmediateFlush, 
                                    [Switch] $AppendToFile, 
                                    [Switch] $MinimalLock,
                                    [Switch] $Activate) {
 
   #Crée un FileAppender permettant de loguer dans un fichier
   #Les valeurs par défaut si les switchs ne sont pas précisés :
   #    ImmediateFlush  : $True, on écrit tout de suite l'événement de log dans le fichier
   #    AppendToFile    : $False, on écrase le fichier s'il existe
   #    MinimalLock     : Par défaut le fichier est verrouillé par FileAppender.ExclusiveLock
   #    Activate        : $False, on retarde l'activation de l'appender courant
  
  Write-Debug ("Call {0}" -F $MyInvocation.InvocationName)
  $Appender=New-LogAppender log4net.Appender.FileAppender $LayoutPattern $Name

  if ($FileName -eq [String]::Empty)
   { Throw $LogDatas.Get("EmptyStringParameter","New-LogFileAppender","FileName")}
  if (!(Test-path $FileName -isValid))  { throw  $LogDatas.Get("AppenderInvalidFileName","New-LogFileAppender",$FileName)} 
   #Test-Path renvoie true pour "Hklm:", dans ce cas ActivateOptions lévera une exception

  $Appender.File=$FileName
   #Par défaut PS utilise l'Unicode
  $Appender.Encoding=$Encoding
      
      #Si $AppendToFile n'est pas renseigné dans ce cas on affecte la valeur $false  
  $Appender.AppendToFile= [Boolean]$AppendToFile
     #$True est la valeur par défaut, on inverse la valeur du switch 
  $Appender.ImmediateFlush=!([Boolean]$NotImmediateFlush)
  
  if ($MinimalLock) 
   {$Appender.LockingModel=New-object log4net.Appender.FileAppender+MinimalLock}
  if ($Activate) 
   {$Appender.ActivateOptions() }
  $Appender
}

Set-Alias -Scope Global -name New-RollingFileAppender -value New-LogRollingFileAppender
Set-Alias -Scope Global -name nlrlngfapdr -value New-LogRollingFileAppender

function global:New-LogRollingFileAppender([String] $FileName,
                                           [String] $LayoutPattern,
                                           [String] $Name, 
                                           [String] $DatePattern=".yyyy-MM-dd",
                                           [Long]   $MaxFileSize=10MB,
                                            #Suffixes supportés : "KB", "MB" ou "GB"
                                           [String] $MaximumFileSize="10MB", 
                                           [int]    $MaxSizeRollBackups=0,
                                           [log4net.Appender.RollingFileAppender+RollingMode] $RollingStyle=
                                                    [log4net.Appender.RollingFileAppender+RollingMode]::Composite, 
                                           [Boolean] $StaticLogFileName=$True,
                                           [Int32]   $CountDirection=-1,
                                           [System.Text.Encoding] $Encoding=[System.Text.Encoding]::Unicode,
                                           [Switch] $NotImmediateFlush,
                                           [Switch] $AppendToFile, 
                                           [Switch] $MinimalLock,
                                           [Switch] $Activate) {
   #Crée un RoolingFileAppender permettant de loguer dans un fichier
   #Possibilité de log sur plusieurs fichiers en fonction de la date et de l'heure.
   #Il s'agit d'un mécanisme de séquence, cyclique ou non, autour d'un nom de fichier.
   #
   #Attention 
   # Changing StaticLogFileName or CountDirection without clearing the log file directory of 
   # backup files will cause unexpected and unwanted side effects. 
   # A maximum number of backup files when rolling on date/time boundaries is not supported. 
   #
   #Format de date : 
   #  http://msdn.microsoft.com/en-us/library/97x6twsz(VS.80).aspx
   #  http://msdn.microsoft.com/fr-fr/library/97x6twsz(VS.80).aspx

  Write-Debug ("Call {0}" -F $MyInvocation.InvocationName)
  $Appender=New-LogAppender log4net.Appender.RollingFileAppender $LayoutPattern $Name 

  if ($FileName -eq [String]::Empty)
   { Throw $LogDatas.Get("EmptyStringParameter","New-LogFileAppender","FileName")}
  if (!(Test-path $FileName -isValid))  { throw $LogDatas.Get("AppenderInvalidFileName","New-LogRollingFileAppender",$FileName)} 
   #Test-Path renvoie true pour "Hklm:", dans ce cas ActivateOptions lévera une exception

  $Appender.File=$FileName
     #Par défaut PS utilise l'Unicode
  $Appender.Encoding=$Encoding
      #Si $AppendToFile n'est pas renseigné, la valeur assignée = $false dans ce cas 
      #on écrase le fichier s'il existe
  $Appender.AppendToFile= [Boolean]$AppendToFile

       #$True est la valeur par défaut, on inverse la valeur du switch 
  $Appender.ImmediateFlush=!([Boolean]$NotImmediateFlush)
  
  if ($MinimalLock) 
   {$Appender.LockingModel=New-object log4net.Appender.FileAppender+MinimalLock}

  $Appender.DatePattern=$DatePattern
  $Appender.MaxFileSize=$MaxFileSize
  $Appender.MaximumFileSize=$MaximumFileSize 
  $Appender.MaxSizeRollBackups=$MaxSizeRollBackups
  $Appender.RollingStyle=$RollingStyle 
  $Appender.StaticLogFileName=$StaticLogFileName
  $Appender.CountDirection=$CountDirection
  
  if ($Activate) 
   {$Appender.ActivateOptions() }
  $Appender
}


Set-Alias -Scope Global -name nlevtapdr -value New-EventLogAppender

function global:New-LogEventLogAppender([string] $EventLogName=$(Throw $LogDatas.Get("NecessaryParameter","New-LogEventLogAppender","EventLogName")),
                                     [String] $LayoutPattern,
                                     [String] $Name,
                                     [Switch] $Activate){
   #Crée un EventLogAppender permettant de loguer dans un journal d'événement.
    #Si l'eventlog n'existe pas il est créé par le constructeur de l'appender mais vous devez avoir la permission d'administrateur local 
    #pour crée ce journal d'événement.
    #Il n'est pas nécessaire d'avoir la permission d'administrateur pour écrire dans le journal d'événement précisé mais il doit exister.
  Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)                                       
  $Appender=New-LogAppender log4net.Appender.EventLogAppender $LayoutPattern $Name  
 
  if ($EventLogName -eq [String]::Empty)
   { Throw $LogDatas.Get("EmptyStringParameter","New-LogEventLogAppender","EventLogName")} 
    #Nom du journal de log : Appplication, Systeme...
  $Appender.LogName=$EventLogName
  if ($Activate) 
   {$Appender.ActivateOptions() }
  $Appender
}

Set-Alias -Scope Global -name New-SmtpAppender -value New-LogSmtpAppender
Set-Alias -Scope Global -name nlSmtpapdr -value New-LogSmtpAppender

function global:New-LogSmtpAppender( [String] $LayoutPattern,
                                     [string] $Name,
                                     [log4net.Core.ITriggeringEventEvaluator] $Evaluator,
                                       #the e-mail address of the sender.
                                     [String] $From=$(Throw $LogDatas.Get("NecessaryParameter","New-LogSmtpAppender","From")),
                                     [String] $Subject, 
                                       #a semicolon-delimited list of recipient e-mail addresses.
                                     [String] $To=$(Throw $LogDatas.Get("NecessaryParameter","New-LogSmtpAppender","To")),
                                     [String] $Username=[String]::Empty,                                     
                                     [String] $Password=[String]::Empty,
                                       #Size of event number
                                     [Int32] $BufferSize=512,
                                     [int32] $Port=25, 
                                     [System.Net.Mail.MailPriority] $Priority=[System.Net.Mail.MailPriority]::Normal, 
                                     [String] $SmtpHost=$(Throw $LogDatas.Get("NecessaryParameter","New-LogSmtpAppender","SmtpHost")), 
                                     [log4net.Appender.SmtpAppender+SmtpAuthentication] $Authentication=
                                     [log4net.Appender.SmtpAppender+SmtpAuthentication]::None){

  Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)                                       
  $Appender=New-LogAppender log4net.Appender.SmtpAppender $LayoutPattern $Name  
  
  if ($Evaluator -eq $null)
   {Throw $LogDatas.Get("NullParameter","New-LogSmtpAppender","Evaluator")}
  if ($Evaluator -isnot [log4net.Core.ITriggeringEventEvaluator])
   {Throw $LogDatas.Get("NotImplementInterface","New-LogSmtpAppender","Evaluator","ITriggeringEventEvaluator")}
  $Appender.Evaluator=$Evaluator
  
  if ($From -eq [String]::Empty)
   { Throw $LogDatas.Get("EmptyStringParameter","New-LogSmtpAppender","From")} 
  
  if ($To -eq [String]::Empty)
   { Throw $LogDatas.Get("EmptyStringParameter","New-LogSmtpAppender","To")}
  
  if ($SmtpHost -eq [String]::Empty)
   { Throw $LogDatas.Get("EmptyStringParameter","New-LogSmtpAppender","SmtpHost")}
  
  $Appender.From=$From
  $Appender.To=$To
  $Appender.SmtpHost=$SmtpHost
  
  $Appender.Name=$Name
  
  $Appender.Subject=$Subject 
  $Appender.Username=$Username,
  $Appender.Password=$Password
  $Appender.BufferSize=$BufferSize
  $Appender.Port=$Port 
  $Appender.Priority=$Priority 
  
  if ($Activate) 
   {$Appender.ActivateOptions() }
  $Appender  
}


   # -------------Appender:Function diverses --------------------------------------------------------------------------
Set-Alias -Scope Global -name Add-Appender -value Add-LogAppender
Set-Alias -Scope Global -name alapdr -value Add-LogAppender

function global:Add-LogAppender([log4net.Appender.AppenderSkeleton] $Appender,
                                $Logger,
                                [Switch] $Activate){
 #Ajoute un appender au logger spécifié, on recoit dans le pipe un objet appender 
  begin
  {
    function AddLogAppender([log4net.Appender.AppenderSkeleton] $Appender=$(Throw  $LogDatas.Get("NecessaryParameter","Add-LogAppender","Appender")),
                             $Logger=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogAppender","Logger")),
                             [Switch] $Activate){
     if ($Logger -eq $null)
       {Throw $LogDatas.Get("NullParameter","Add-LogAppender","Logger")}
     if ($Logger -isnot [log4net.Core.ILoggerWrapper])
       {Throw $LogDatas.Get("NotImplementInterface","Add-LogAppender","Logger","ILoggerWrapper")}

     if ($Appender -eq $null ) 
      {Throw $LogDatas.Get("NullParameter","Add-LogAppender","Appender")}                        

     if ($Activate) 
      {$Appender.ActivateOptions() }
     $Logger.logger.AddAppender($Appender)
    }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}
         
     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        AddLogAppender -Appender $_ -L $Logger -Activate:$Activate
         #réémet un appender
		    $_ 
     }
  }
  end
  {
     if ($Appender)
      {  
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        AddLogAppender -Appender $_ -L $Logger -Activate:$Activate
      }
  }
}



Set-Alias -Scope Global -name Get-LoggerAppender -value Get-LogLoggerAppender
Set-Alias -Scope Global -name gllgrapdr -value Get-LogLoggerAppender

function global:Get-LogLoggerAppender($Logger,
                                      [String] $AppenderName){
 #A partir d'un logger, récupère un appender d'après son nom
                           
  begin
  {
    function GetLoggerAppender($Logger=$(Throw $LogDatas.Get("NecessaryParameter","Get-LogLoggerAppender","Logger")),
                               [String] $AppenderName=$(Throw $LogDatas.Get("NecessaryParameter","Get-LogLoggerAppender","AppenderName"))){
       
       if ($Logger -eq $null)
        {Throw $LogDatas.Get("NullParameter","Get-LogLoggerAppender","Logger")}
       if ($Logger -isnot [log4net.Core.ILoggerWrapper])
        {Throw $LogDatas.Get("NotImplementInterface","Get-LogLoggerAppender","Logger","ILoggerWrapper")}
      
       if ($AppenderName -eq [String]::Empty) 
        { Throw $LogDatas.Get("EmptyStringParameter","Get-LogLoggerAppender","AppenderName")} 
        #Récupère l'appender de nom $AppenderName
       $Appender=$Logger.logger.Appenders|Where {$_.name -eq $AppenderName} 
       if ($Appender -eq $null) { Throw $LogDatas.Get("AppenderDontExist","Get-LogLoggerAppender",$AppenderName)}
        #On recoit un logger mais on réémet un appender
  	   $Appender  
    }
  }
  process
  {
    if ($Logger -and $_) 
     {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Logger"}
    if ($_)
    {   
      Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
      GetLoggerAppender -Logger $_ -A $AppenderName -Default:$Default
      #on réémet un appender
    }
  }
  end
  {
    if ($Logger)
    {    
     Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
     GetLoggerAppender -Logger $Logger -A $AppenderName -Default:$Default
    }
  } 
}



Set-Alias -Scope Global -name Add-LoggerAppender -value Add-LogLoggerAppender
Set-Alias -Scope Global -name allgapdr -value Add-LogLoggerAppender

function global:Add-LogLoggerAppender($Logger,
                                      [log4net.Appender.AppenderSkeleton] $Appender){

 #Ajoute un appender au logger spécifié, on recoit dans le pipe un objet Logger
  begin 
  {
    function AddLoggerAppender($Logger=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogLoggerAppender","Logger")),
                               [log4net.Appender.AppenderSkeleton] $Appender=
                                 $(Throw $LogDatas.Get("NecessaryParameter","Add-LogLoggerAppender","Appender"))){
     if ($Logger -eq $null)
       {Throw $LogDatas.Get("NullParameter","Add-LogLoggerAppender","Logger")}
     if ($Logger -isnot [log4net.Core.ILoggerWrapper])
       {Throw $LogDatas.Get("NotImplementInterface","Add-LogLoggerAppender","Logger","ILoggerWrapper")}
     
     if ($Appender -eq $null) { Throw $LogDatas.Get("NullParameter","Add-LogLoggerAppender","Appender")}
     $Logger.Logger.AddAppender($Appender)  
    }
  }
  process
  {
    if ($Logger -and $_) 
     {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Logger"}
    
    if ($_)
    {   
      Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
      AddLoggerAppender -Logger $_ -Appender $Appender
       #réémet un logger
      $_ 
    }
  }
  end
  {
    if ($Logger)
    {
     Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
     AddLoggerAppender -Logger $Logger -Appender $Appender
    }
  } 
}



# -------------  LevelColors ----------------------------------------------------------------------------
Set-Alias -Scope Global -name almapclr -value Add-LogMappingColors

function global:Add-LogMappingColors([log4net.Appender.ColoredConsoleAppender] $ColoredConsole=$(
                                     Throw $LogDatas.Get("NecessaryParameter","Add-LogMappingColors","ColoredConsole")),
                                   [System.Collections.Hashtable[]] $Colors=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogMappingColors","Colors")),
                                   $Repository,
                                   [switch] $Force){
                                     
  #Configure le mappage des couleurs selon les niveaux de log

  # Association niveau de log-couleur d'affichage dans un tableau de hashtable
  # [System.Collections.Hashtable[]] $Colors1=@(
  #   @{Level="Warn";FColor="Yellow";BColor=""},
  #   @{Level="Info";FColor="Cyan";BColor=""},
  #   @{Level="Debug";FColor="Green";BColor=""},
  #   @{Level="Error";FColor="Red";BColor=""}
  #  )
  # [System.Collections.Hashtable[]] $Colors2=@(
  #   @{Level="Critical";FColor="Yellow";BColor=""},
  #   @{Level="Info";FColor="Cyan";BColor=""},
  #   @{Level="Debug";FColor="Green";BColor=""},
  #   @{Level="Fatal";FColor="Red";BColor=""}
  #  )
  
  # [System.Collections.Hashtable]={Normal=$Colors1;Test=$Colors2}
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 if ($ColoredConsole -eq $Null) { Throw $LogDatas.Get("NullParameter","Add-LogMappingColors","ColoredConsole")}

 if ($Repository -eq $null)
  { #Dans ce cas on ne recherche qu'une seule fois le repository 
   $Repository=Get-LogRepository -Default
  }

 $Colors|% { 
  trap [System.Management.Automation.PSInvalidCastException] 
   {Throw $LogDatas.Get("MappingColorError","Add-LogMappingColors",$CurrentColor,$Field)}
  trap [System.ArgumentNullException] {Throw "$($_.Exception.Message)"} #Provenant de : Test-Log $_.Level
  trap [System.Management.Automation.RuntimeException] {break} #Provenant de : foreach: AddMapping ($_.Level)
   
    #Contrôle la présence des clés dans la Hashtable courante
  $Ht=$_
  "Level","FColor","BColor"|`
    Where {!$ht.ContainsKey($_)}|`
     #Aide au debug. Si une des trois clé manque, le traitement du mapping des couleurs lévera une exception
    Foreach {
       $S=$ht.getEnumerator()|%{"{0}={1}" -F $_.Key,$_.Value};
       $LogDatas.Get("UnknownHashKeyName",$_,$S)
       }| Write-Warning

   #Valide le nom des couleurs avant de les 'mapper'
  $LevelColors = new-object log4net.Appender.ColoredConsoleAppender+LevelColors
  $Field="FColor"
  $CurrentColor=$_.FColor
  $LevelColors.ForeColor=[log4net.Appender.ColoredConsoleAppender+Colors]$($_.FColor)
  if ($($_.BColor) -ne [String]::Empty)
   {
    $Field="BColor"
    $CurrentColor=$_.BColor 
    $LevelColors.BackColor=[log4net.Appender.ColoredConsoleAppender+Colors]$($_.BColor)
   }
  $CurrentLevel=$_.Level
  $LevelColors.Level=Test-LogLevel $_.Level $Repository
  $ColoredConsole.AddMapping($LevelColors)
 }
 $ColoredConsole
}




# -------------  Layout ----------------------------------------------------------------------------
Set-Alias -Scope Global -name nllyt -value New-LogLayout

function global:New-LogLayout([String] $LogPattern=$(Throw $LogDatas.Get("NecessaryParameter","New-LogLayout","LogPattern")),
                              [String] $Footer,
                              [String] $Header) {
 #Crée un layout utilisé pour formater le texte du message de log
 #Un layout est une indication de mise en page d'une chaîne de caractères
  Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
  if ($LogPattern -eq [String]::Empty) { Throw $LogDatas.Get("EmptyStringParameter","New-LogLayout","LogPattern")} 
  $Layout=new-object log4net.Layout.PatternLayout($Logpattern)
  $Layout.Footer=$Footer
  $Layout.Header=$Header
  $Layout.ActivateOptions()
  $Layout
}



Set-Alias -Scope Global -name Add-Layout -value Add-LogLayout
Set-Alias -Scope Global -name allyt -value Add-LogLayout

function global:Add-LogLayout([log4net.Appender.AppenderSkeleton] $Appender,
                              [String] $LogPattern,
                              [String] $Footer,
                              [String] $Header){
  begin
  {
    function AddLayout([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogLayout","Appender")),
                       [String] $LogPattern,
                       [String] $Footer,
                       [String] $Header){
       if ($Appender -eq $null ) 
           {Throw $LogDatas.Get("NullParameter","Add-LogLayout","Appender")}                        
       $Appender.Layout=New-LogLayout $LogPattern $Footer $Header
    }
  }
  process
  {
    if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

    if ($_)
    {   
      Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
      AddLayout -Appender $_ -L $LogPattern -F $Footer -H $Header
      $_ 
    }
  }
  end
  {
    if ($Appender)
    {    
      Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
      AddLayout -Appender $Appender -L $LogPattern -F $Footer -H $Header
    }
  }
}



Set-Alias -Scope Global -name Update-Layout -value Update-LogLayout
Set-Alias -Scope Global -name ullyt -value Update-LogLayout

function global:Update-LogLayout([log4net.Appender.AppenderSkeleton] $Appender,
                                 [String] $LogPattern,
                                 [String] $Footer,
                                 [String] $Header,
                                 [Switch] $Force) {
  begin
  {
    function UpdateLayout([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Update-LogLayout","Appender")),
                          [String] $LogPattern=$(Throw $LogDatas.Get("NecessaryParameter","Update-LogLayout","LogPattern")),
                          [String] $Footer,
                          [String] $Header,
                          [Switch] $Force) {
       #Force : Efface le contenu des propriétés $Footer et $Header si elles ne sont pas renseignées 
       #        ou si elles contiennent une chaîne vide :
       #           Update-LogLayout $MyAppender "%-5level [%thread]: %message%newline" -Force
       #        Il reste donc possible de ne modifier que le paramètre ConversionPattern : 
       #           Update-LogLayout $MyAppender "%-5level [%thread]: %message%newline"
       #        Ou de modifier ces propriétés avec une des combinaisons suivantes :
       #           Update-LogLayout $MyAppender "%-5level [%thread]: %message%newline" "MyFooter"                                 
       #           Update-LogLayout $MyAppender "%-5level [%thread]: %message%newline" -H "MyHeader"
       #           Update-LogLayout $MyAppender "%-5level [%thread]: %message%newline" "MyFooter" "MyHeader"
       #           Update-LogLayout $MyAppender "%-5level [%thread]: %message%newline" -H "MyHeader" -For 
       if ($LogPattern -eq [String]::Empty) 
        { Throw $LogDatas.Get("EmptyStringParameter","Update-LogLayout","LogPattern")}
       $Appender.Layout.ConversionPattern=$LogPattern
       if ($Force -or ($Footer -ne [String]::Empty))
        { $Appender.Layout.Footer=$Footer }
        if ($Force -or ($Header -ne [String]::Empty))
         {$Appender.Layout.Footer=$Header}
        $Appender.Layout.ActivateOptions()
    }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        UpdateLayout -Appender $_ -L $LogPattern -Foo $Footer -H $Header -Force:$Force
        $_ 
     }
  }
  end
  {
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)      
        UpdateLayout -Appender $Appender -L $LogPattern -Foo $Footer -H $Header -Force:$Force
      }
  } 
}





# -------------  Repository ----------------------------------------------------------------------------
Set-Alias -Scope Global -name Get-Repository -value Get-LogRepository
Set-Alias -Scope Global -name glrpy -value Get-LogRepository

function global:Get-LogRepository([String] $Name,
                                  [Switch] $Default){
 
  begin
  {
    Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
    function GetRepository([String] $Name,
                           [Switch] $Default){
          #Nom de repository inexistant
        trap [log4net.Core.LogException] {Throw "Get-LogRepository : $($_.Exception.Message)."}                            
        if ($Default) 
        {  if (($Name -ne $null ) -and ($Name -ne [String]::Empty))  
             {Throw $LogDatas.Get("ConflictDetected","Get-LogRepository","Name","Default")}  
           else { [log4net.LogManager]::GetRepository() }
        } 
        else 
        { [log4net.LogManager]::GetRepository($Name) }
    }
  }
  process
  {
    if ($Name -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Name"}

    if ($_)
    {   
      Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
      GetRepository $_ -Default:$Default
      #Emet un repository
    }
  }
  end
  {
    if ($Name -or $Default) 
    {    
     Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
     GetRepository $Name -Default:$Default
    }
  } 
}



Set-Alias -Scope Global -name Get-Repositories -value Get-LogRepositories
Set-Alias -Scope Global -name glrpys -value Get-LogRepositories

function global:Get-LogRepositories{
  #Renvoie la liste de tous les repositories existant
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName) 
 [log4net.LogManager]::GetAllRepositories()
}



# -------------  NDC : Context ----------------------------------------------------------------------------
Set-Alias -Scope Global -name Push-ThreadContext -value Push-LogThreadContext
Set-Alias -Scope Global -name pushlthctx -value Push-LogThreadContext

function global:Push-LogThreadContext([String] $PropertyName=$(Throw $LogDatas.Get("NecessaryParameter","Push-LogThreadContext","PropertyName")),
                                      $Object=$(Throw $LogDatas.Get("NecessaryParameter","Push-LogThreadContext","Object"))){
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 [log4net.ThreadContext]::Stacks[$PropertyName].Push($Object)
}



Set-Alias -Scope Global -name Pop-ThreadContext -value Pop-LogThreadContext
Set-Alias -Scope Global -name poplthctx -value Pop-LogThreadContext

function global:Pop-LogThreadContext([String] $PropertyName=$(Throw $LogDatas.Get("NecessaryParameter","Pop-LogThreadContext","PropertyName"))){
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 [log4net.ThreadContext]::Stacks[$PropertyName].Pop()
}



Set-Alias -Scope Global -name Set-GlobalProperty -value Set-LogGlobalProperty
Set-Alias -Scope Global -name slgblpty -value Set-LogGlobalProperty

function global:Set-LogGlobalProperty([String] $PropertyName=$(Throw $LogDatas.Get("NecessaryParameter","Set-LogGlobalProperty","PropertyName")),
                                      $Object=$(Throw $LogDatas.Get("NecessaryParameter","Set-LogGlobalProperty","Object"))){
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 [log4net.GlobalContext]::Properties[$PropertyName]=$Object
}



Set-Alias -Scope Global -name Get-GlobalProperty -value Get-LogGlobalProperty
Set-Alias -Scope Global -name glgblpty -value Get-LogGlobalProperty

function global:Get-LogGlobalProperty([String] $PropertyName=$(Throw $LogDatas.Get("NecessaryParameter","Get-LogGlobalProperty","PropertyName"))){
 #Renvoie une propriété globale
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 [log4net.GlobalContext]::Properties[$PropertyName]
}


Set-Alias -Scope Global -name Get-GlobalPropertyScript -value Get-LogGlobalPropertyScript
Set-Alias -Scope Global -name glgblptyscp -value Get-LogGlobalPropertyScript

function global:Get-LogGlobalPropertyScript([String] $PropertyName){
  #Renvoie le code de la méthode toString d'un propriété globale de type PSObject
 
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 $Result=(Get-LogGlobalProperty $PropertyName).PsObject.Methods|Where {$_.Name -eq "ToString"}|Foreach {$_.Script}
 if ($Result -eq $null) {Throw $LogDatas.Get("ToStringNotOverrided","Get-LogGlobalPropertyScript",$PropertyName) }
 $Result
}



Set-Alias -Scope Global -name Set-ActiveProperty -value Set-LogActiveProperty
Set-Alias -Scope Global -name slatvpty -value Set-LogActiveProperty

function global:Set-LogActiveProperty([String] $Name=$(Throw $LogDatas.Get("NecessaryParameter","Set-LogActiveProperty","Name")),
                                      [ScriptBlock] $Script=$(Throw $LogDatas.Get("NecessaryParameter","Set-LogActiveProperty","Script"))){
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 $Obj = new-object System.Management.Automation.PSObject
 $Obj|Add-Member -Force -MemberType ScriptMethod ToString $Script
 [log4net.GlobalContext]::Properties[$Name]=$Obj
}




# -------------  Debug interne au framework log4Net --------------------------------------------------------------------
Set-Alias -Scope Global -name sldbg -value Set-LogDebugging

function global:Set-LogDebugging([Boolean] $State=$(Throw $LogDatas.Get("NecessaryParameter","Set-LogDebugging","State"))){
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)  
 [log4net.Util.LogLog]::InternalDebugging=$State
 #todo add [System.Diagnostics.Trace]::Listeners ....
}

Set-Alias -Scope Global -name  gldbg -value Get-LogDebugging

function global:Get-LogDebugging{
 Write-Debug ("Call : {0}" -F $MyInvocation.InvocationName)
 [log4net.Util.LogLog]::InternalDebugging
}




# ------------------------------- Filters ----------------------------------------------------------------------------
Set-Alias -Scope Global -name New-Filter -value New-LogFilter
Set-Alias -Scope Global -name nlfltr -value New-LogFilter

function global:New-LogFilter([Type] $Class=$(Throw $LogDatas.Get("NecessaryParameter","New-LogFilter","Class")), 
                              [ScriptBlock] $sbInitProperties) {
  #Crée un Filtre de la classe $Classe
 Write-Debug ("Call {0}" -F $MyInvocation.InvocationName)
 "Class","sbInitProperties"|% {$V=gv $_;Write-Debug ("{0} : {1}" -F $V.Name,$V.Value)}
                       
 if ($Class -eq $Null) 
   { Throw $LogDatas.Get("NullParameter","New-LogFilter","Class")} 
 if (!$Class.IsSubclassOf([log4net.Filter.FilterSkeleton])) 
   { Throw $LogDatas.Get("NotDerivedClass","New-LogFilter",$Class,"Filter")}
 $Filter = new-object $Class
  #Initialise les propriétés spécifiques à la classe courante 
 Write-Debug "$($sbInitProperties)"
 if ($sbInitProperties -ne $Null) 
 {  #Peut contenir des variables déclarées dans les portées parentes
    #Seule la méthode appelant, créant un filtre d'un type particulier, connait 
    #les champs supplémentaires à initialiser.
   &$sbInitProperties
 }
 $Filter.ActivateOptions()
 $Filter
}



Set-Alias -Scope Global -name New-RangeFilter -value New-LogRangeFilter
Set-Alias -Scope Global -name nlrgfltr -value New-LogRangeFilter

function global:New-LogRangeFilter([log4net.Appender.AppenderSkeleton] $Appender,
                                   [string] $MinLevel, 
                                   [string] $MaxLevel,
                                   $Repository){
 #Crée un filtre sur une étendue. Log seulement les événements compris entre $MinLevel et $MaxLevel.
  begin
  {
     if ($Repository -eq $null)
      { #Dans ce cas on ne recherche qu'une seule fois le repository 
       $Repository=Get-LogRepository -Default
      }

     function NewRangeFilter([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","New-LogRangeFilter","Appender")),
                            [string] $MinLevel=$(Throw $LogDatas.Get("NecessaryParameter","New-LogRangeFilter","MinLevel")), 
                            [string] $MaxLevel=$(Throw $LogDatas.Get("NecessaryParameter","New-LogRangeFilter","MaxLevel"))){
       Write-Debug "Before MinLevel :$MinLevel `r`nBefore MaxLevel :$MaxLevel"
        #Transforme une string en une instance de level 
       [log4net.Core.Level] $MinLevel=Test-LogLevel $MinLevel $Repository
       [log4net.Core.Level] $MaxLevel=Test-LogLevel $MaxLevel $Repository
       Write-Debug "After MinLevel :$MinLevel`r`nAfter MaxLevel :$MaxLevel"
        
        #Le scriptblock suivant est exécuté dans la function New-LogFilter
       $SbProperties={
        $Filter.LevelMin = $MinLevel
        $Filter.LevelMax = $MaxLevel
       }
       Write-Debug "$($SbProperties)"
       $Filter=New-LogFilter log4net.Filter.LevelRangeFilter $SbProperties
       $Filter
    }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        NewRangeFilter -Appender $_ -Min $MinLevel -Max $MaxLevel -R $Repository
        #On émet un filtre
     }
  }
  end
  {
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        NewRangeFilter -Appender $Appender -Min $MinLevel -Max $MaxLevel -R $Repository
      }
  }
}



Set-Alias -Scope Global -name New-StringFilter -value New-LogStringFilter
Set-Alias -Scope Global -name nlstrfltr -value New-LogStringFilter

function global:New-LogStringFilter([log4net.Appender.AppenderSkeleton] $Appender,
                                    [String] $Regex, 
                                    [String] $MatchStr,
                                    [Switch] $Inverse){
 #Filtre sur une chaîne ou une expression réguliére ou les deux.
  begin
  {
    function NewStringFilter([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","New-LogStringFilter","Appender")),
                             [String] $Regex, 
                             [String] $MatchStr,
                             [Switch] $Inverse){
       $SbProperties={
         $Filter.RegexToMatch =$RegEx
         $Filter.StringToMatch=$MatchStr
          #Inverse la condition du test du filtre
         if ($Inverse) {$Filter.AcceptOnMatch=$False }
       }
       Write-Debug "$($SbProperties)"
       $Filter=New-LogFilter log4net.Filter.StringMatchFilter $SbProperties
       $Filter
    }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        NewStringFilter -Appender $_ -Reg $Regex -MatchStr $MatchStr -Inverse:$Inverse
        #On émet un filtre
     }
  }
  end
  {
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        NewStringFilter -Appender $Appender -Reg $Regex -MatchStr $MatchStr -Inverse:$Inverse 
      }
  }
}



# New-LogDenyAllFilter -> New-LogFilter log4net.Filter.DenyAllFilter $Null

Set-Alias -Scope Global -name Get-Filters -value Get-LogFilters
Set-Alias -Scope Global -name glfltrs -value Get-LogFilters

Function global:Get-LogFilters([log4net.Appender.AppenderSkeleton] $Appender){
 #Parcourt la liste chaînée des filtres d'un appender
  begin
  {
    function GetFilters([log4net.Appender.AppenderSkeleton] $Appender=$(Throw  $LogDatas.Get("NecessaryParameter","Get-LogFilters","Appender"))){
      $CurrentFilter=$Appender.FilterHead  
      if ($CurrentFilter -eq $null) 
           #force à 0 si l'appender ne contient aucun filtre : ($Appender|Get-LogFilters).count ; (Get-LogFilters $Appender) -eq $null
       {,@()}
      While ($CurrentFilter -ne $null) 
      {
        #On émet n filtres
       $CurrentFilter
       $CurrentFilter=$CurrentFilter.Next
      }
    }
  }
  process
  {  
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
       Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
       GetFilters $_
     }
  }
  end
  {  
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        GetFilters $Appender
      }
  }
}



Set-Alias -Scope Global -name Remove-Filters -value Remove-LogFilters
Set-Alias -Scope Global -name rmvlfltrs -value Remove-LogFilters

function global:Remove-LogFilters([log4net.Appender.AppenderSkeleton] $Appender,
                                  [ScriptBlock] $Search,
                                  [switch] $All) {
                                
 #Supprime un filtre de la liste des filtres, la liste chainée n'est pas rompue.
  begin
  {
    function RemoveFilter([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Remove-LogFilters","Appender")),
                          [ScriptBlock] $Search=$(Throw $LogDatas.Get("NecessaryParameter","Remove-LogFilters","Search")),
                          [switch] $All){
      
      $CurrentFilter=$Appender.FilterHead
      if (!$CurrentFilter) 
       { Write-Debug "No filters .";Return}   
      $Predecessor=$null
      do 
      {
        if (&$Search $Appender)
        {
           Write-Debug ("Success : {0}" -F $CurrentFilter.GetType())
           Write-Debug ("Search : {0}" -F $Search)
           if ($Predecessor -eq $null)
           {  #On supprime le premier
              
             Write-Debug "First Item Before (Debugger only)"
             
              #La propriété $Appender.FilterHead étant en Read Only
              #on ne peut pas la mettre à jour lors de la reconstruction du chaînage
              # On est obligé de reconstruire le tableau afin que le Framework LG4N reconstruise le chaînage correctement 
             $AllFilters=Get-LogFilters $Appender
             $Appender.ClearFilters()
             for ($i=1;$i -lt $AllFilters.Count;$i++) 
               { 
                 $AllFilters[$i].Next=$null
                 $Appender.AddFilter($AllFilters[$i])
               }
             $CurrentFilter=$Appender.FilterHead
             Write-Debug "First Item After (Debugger only)"
             
              #Si $All on supprime tous les éléments répondant aux critéres de recherche
              # sinon on ne supprime que le premier élément trouvé
             if (!$All) 
              {return}
   
           }
           else 
           { 
             $Predecessor.Next=$CurrentFilter.Next
             $Predecessor.ActivateOptions()
             $CurrentFilter= $Predecessor.Next
             Write-Debug "Item n"

             if (!$All) 
              {return}
           }
        }
       else  
        {
         $Predecessor=$CurrentFilter
         $CurrentFilter=$CurrentFilter.Next
        }
      }
      While ($CurrentFilter -ne $null)
    }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        RemoveFilter -Appender $_ -Search $Search -All:$All
        $_ 
     }
  }
  end
  {
     if ($Appender)
      { 
         Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
         RemoveFilter -Appender $Appender -Search $Search -All:$All
      }
  }
}



Set-Alias -Scope Global -name Add-RangeFilter -value Add-LogRangeFilter
Set-Alias -Scope Global -name alrgfltr -value Add-LogRangeFilter

function global:Add-LogRangeFilter([log4net.Appender.AppenderSkeleton] $Appender,
                                   [string] $MinLevel, 
                                   [string] $MaxLevel,
                                   $Repository){
 #Filtre sur une étendue. Log seulement les événements compris entre $MinLevel et $MaxLevel.
  begin
  {
     function AddRangeFilter([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogRangeFilter","Appender")),
                             [string] $MinLevel=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogRangeFilter","MinLevel")), 
                             [string] $MaxLevel=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogRangeFilter","MaxLevel"))){
       
       $Filter=New-LogRangeFilter -Appender $Appender -Min $MinLevel -Max $MaxLevel -R $Repository 
       $Appender.AddFilter($Filter)
    }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        AddRangeFilter -Appender $_ -Min $MinLevel -Max $MaxLevel -R $Repository
        $_ 
     }
  }
  end
  {
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        AddRangeFilter -Appender $Appender -Min $MinLevel -Max $MaxLevel -R $Repository
      }
  }
}




Set-Alias -Scope Global -name Add-StringFilter -value Add-LogStringFilter
Set-Alias -Scope Global -name alstrfltr -value Add-LogStringFilter

function global:Add-LogStringFilter([log4net.Appender.AppenderSkeleton] $Appender,
                                    [String] $Regex, 
                                    [String] $MatchStr,
                                    [Switch] $Inverse){
 #Filtre sur une chaîne ou une expression réguliére ou les deux.
  begin
  {
    function AddStringFilter([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogStringFilter","Appender")),
                             [String] $Regex, 
                             [String] $MatchStr,
                             [Switch] $Inverse){
       $Filter=New-LogStringFilter -Appender $Appender -Reg $Regex -MatchStr $MatchStr -Inverse:$Inverse
       $Appender.AddFilter($Filter)
    }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        AddStringFilter -Appender $_ -Reg $Regex -MatchStr $MatchStr -Inverse:$Inverse
        $_ 
     }
  }
  end
  {
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        AddStringFilter -Appender $Appender -Reg $Regex -MatchStr $MatchStr -Inverse:$Inverse 
      }
  }
}



Set-Alias -Scope Global -name Add-DenyFilter -value Add-LogDenyAllFilter
Set-Alias -Scope Global -name alDenyfltr -value Add-LogDenyAllFilter

function global:Add-LogDenyAllFilter([log4net.Appender.AppenderSkeleton] $Appender){
 #Filtre tous les événements
  begin
  {
    function AddDenyAllFilter([log4net.Appender.AppenderSkeleton] $Appender=$(Throw $LogDatas.Get("NecessaryParameter","Add-LogDenyAllFilter","Appender"))){
      $Filter=New-LogFilter log4net.Filter.DenyAllFilter $Null
      $Appender.AddFilter($Filter)
     }
  }
  process
  {
     if ($Appender -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$Appender"}

     if ($_)
     {   
        Write-Debug ("Process : {0}" -F $MyInvocation.InvocationName)
        AddDenyAllFilter -Appender $_ 
        $_ 
     }
  }
  end
  {
     if ($Appender)
      { 
        Write-Debug ("End : {0}" -F $MyInvocation.InvocationName)
        AddDenyAllFilter -Appender $Appender
      }
  } 
}

