#Partie 1/2
#Démo de surveillance synchrone de 3 types d'événement WMI
#Cette démo nécessite 2 instance du process PowerShell.exe

Function TestWMIEvents
{ 
  function ConvertTo-WindowsPath([string]$WMIPathName)
  {  #convertit un nom de fichier au format WMI en 
     #un nom de fichier au format Windows
    $WMIPathName.Replace('\\','\')
  }#ConvertTo-WindowsPath

  function ConvertTo-WMIPath([string]$WindowsPathName)
  {  #convertit un nom de fichier au format Windows en 
     #un nom de fichier au format WMI, les caractères '\' y sont dupliqués. 
    $WindowsPathName.Replace("\", "\\")
  }#ConvertTo-WMIPath
  
  function ConvertTo-WQLPath([string]$WindowsPathName)
  {  #convertit un nom de fichier au format Windows en 
     #un nom de fichier au format WQL.
     #
     #   $Path=ConvertTo-WQLPath "C:\Temp" 
     #   $Wql=("Targetinstance ISA 'CIM_DirectoryContainsFile' and TargetInstance.GroupComponent='Win32_Directory.Name=`"{0}`"'" -F $Path) 
    $WindowsPathName.Replace("\", "\\\\")
  }#ConvertTo-WQLPath
   
  function Get-OwnerOfFile([string]$FullPathName)
  {  #Retrouve le propriétaire d'un fichier/directory au Format WMI. 
    if (Test-Path (ConvertTo-WindowsPath $FullPathName))
     { gwmi -query "ASSOCIATORS OF {Win32_LogicalFileSecuritySetting=`"$FullPathName`"} WHERE AssocClass=Win32_LogicalFileOwner ResultRole=Owner" }
    else { $null }
  }#Get-OwnerOfFile
  
  function Pause ($Message="Pressez une touche pour continuer...")
  {
   Write-Host -NoNewLine $Message
   $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   Write-Host ""
  }#Pause

  function StopWatching
  {
     Write-Warning "Arrêt complet de la surveillance."
     $watchPoshEvent,$watchProcess,$watchEventLog,$watchTempDir|
      Where {$_ -ne $null}|
      Foreach {
        Write-Debug "Arrêt de l'eventwatcher $($_.VariableName)"
        $_.Stop()
        $_.Dispose()
      }

  }#StopWatching

  function New-EventWatcher($Query,$VariableName,$Path="root\cimv2",[switch]$EnablePrivileges,[switch]$Start)
  {  #Crée un eventwatcher avec une requête d'événement
    write-Debug "création de l'eventwatcher $VariableName"
    $scope = New-Object System.Management.ManagementScope $Path
    $Evntwatcher = New-Object System.Management.ManagementEventWatcher $scope,$query
    $options = New-Object System.Management.EventWatcherOptions
     # La surveillance s'arrête au bout d'une seconde 
    $options.TimeOut = [TimeSpan]"0:0:1"
    $Evntwatcher.Options = $Options
    if ($EnablePrivileges)
       #Certaines classes WMI nécessitent plus de droits 
     {$Evntwatcher.Scope.Options.EnablePrivileges = $true}
    if ($Start)
      # L'appel à start ne déclenche pas la mise en tampon des événements
     {
       write-Debug "Démarre la surveillance"
       $Evntwatcher.Start()
    }
     #Ajoute le nom de la variable pour tracer l'arrêt de la surveillance 
    $Evntwatcher=$Evntwatcher|add-member NoteProperty VariableName $VariableName -pass
    $Evntwatcher
  }#New-EventWatcher
  
   #Gestion de la touche escape ou 'Q' du clavier
  $ESCkey = 27
  $Qkey = 81
   Write-Host "Démo de surveillance.Touche Q ou Escape pour l'annuler."  
   #Surveille les événement WMI dotnet
  $Query=New-object System.Management.WqlEventQuery("PoshOperationEvent", [TimeSpan]"0:0:1")
  $watchPoshEvent=New-EventWatcher $Query "WatchPoshEvent" "Root\Default" -Start
  
   #Il est préférable que la clause WITHIN ([TimeSpan]"0:0:1") ait la même valeur pour les 3 EventWatchers
  $Query=New-object System.Management.WqlEventQuery("__InstanceCreationEvent", [TimeSpan]"0:0:1",'TargetInstance isa "Win32_Process" and TargetInstance.Name = "notepad.exe"')
  $watchProcess=New-EventWatcher $Query "WatchProcess" -Start

  $Query = New-object System.Management.WqlEventQuery("__InstanceCreationEvent", [TimeSpan]"0:0:1",'TargetInstance isa "Win32_NTLogEvent"')
  $watchEventLog=New-EventWatcher $Query "WatchEventLog" -EnablePrivileges -Start 

   $RepAMonitorer=ConvertTo-WQLPath "C:\Temp" 
   $WhereClause=("Targetinstance ISA 'CIM_DirectoryContainsFile' and TargetInstance.GroupComponent='Win32_Directory.Name=`"{0}`"'" -F $RepAMonitorer)
  $Query = New-object System.Management.WqlEventQuery("__InstanceCreationEvent", [TimeSpan]"0:0:1",$WhereClause)
  $watchTempDir=New-EventWatcher $Query "WatchTempDir" -Start
  
  $Watching=$true
  while ($Watching) {
    trap [System.Management.ManagementException] {continue}
    $PoshEvent=$watchPoshEvent.WaitForNextEvent()
    if ($watchProcess -ne $null)
     {$e=$watchProcess.WaitForNextEvent()}

    if ($watchTempDir -ne $null)
     {$e2=$watchTempDir.WaitForNextEvent()}
    
    if ($watchEventLog -ne $null)
     {$e3=$watchEventLog.WaitForNextEvent()}
    

    if ($PoshEvent -ne $null) 
     { 
       write-Debug "Classe d'événement : $($PoshEvent.__Class)"
       write-Debug "Evénement name : $($PoshEvent.Eventname) "
       switch ($PoshEvent.__Class)
       { 
         "PoshStopWatchingEvent" {
               switch -regex ($PoshEvent.Eventname)
               {
                  "^Process$" 
                   {
                     if ($watchProcess -ne $null)
                     {
                       $watchProcess.Stop()
                       $watchProcess.Dispose()
                       $watchProcess=$null
                       Write-Warning "Arrêt de la surveillance du process Notepad."
                     }
                     Else 
                     { 
                       Write-host "L'événement PoshOperationEvent:$($PoshEvent.Eventname) n'est plus géré." -fore magenta
                        #Comme dans ce script aucune variable ne porte cet état( $PoshEvent.Eventname n'est plus géré)
                        #vérifiez bien que la précédente instance de la variable $PoshEvent a été libérée.
                     }
#** Instructions IMPERATIVE : $PoshEvent=$null **
                     #Annule l'événement
                     #Pour tester le rôle de cette ligne vous pouvez la commenter provisoirement.
                    $PoshEvent=$null                  
                   }#StopWatching Process
                "^AllWatching$" 
                  {
                      write-Debug "Evénement PoshStopWatchingEvent [$($PoshEvent.Eventname)] reçu"
                       #Ici on peut ne pas tenir compte du contenu de la propriété $PoshEvent.Eventname
                      StopWatching
                      $Watching=$false
                      Continue # On arrête le traitement des événements, 
                               #S'il reste des Events, gérés ici, dans la queue WMI, WMI la videra.
                  }#StopAllWatching

              }#switch
             }#PoshJobCompletedEvent
             
         "PoshOperationEvent" { 
               if ($PoshEvent.Eventname -match "^StartWatching Process$" )
                {  
                  if ($watchProcess -ne $null)
                   { Write-Warning "La surveillance du process Notepad est toujours active."}
                  else
                   { 
                     $Query=New-object System.Management.WqlEventQuery("__InstanceCreationEvent", [TimeSpan]"0:0:1",'TargetInstance isa "Win32_Process" and TargetInstance.Name = "notepad.exe"')
                     $watchProcess=New-EventWatcher $Query "WatchProcess" -Start
                     Write-Warning "Redémarrage de la surveillance du process Notepad."
                   }
               }
              else 
               {Write-Warning "L'événement `"$($PoshEvent.Eventname)`" n'est pas géré."}
#** Instructions IMPERATIVE : $PoshEvent=$null **
               #Annule l'événement
               #Pour tester le rôle de cette ligne vous pouvez la commenter provisoirement.
              #$PoshEvent=$null
            }#PoshStopWatchingEvent
         default {Write-Warning "Cette classe n'est pas gérée : $($PoshEvent.__Class)"}  
      }#switch
     }#if PoshEvent  

    if ($e -ne $null)
     {
       write-host ("Le process {0} a été crée, son chemin est : {1}" -F $e.TargetInstance.Name,$e.TargetInstance.ExecutablePath)
       $e=$null
     }

    if ($e2 -ne $null)
     {
       if ($e2.TargetInstance.PartComponent -match '^(.*)="(.*)\"$')
       {
           #Nom de fichier complet normé WMI
         $WMIFullName=$matches[2]
          #Nom de fichier complet normé Windows
         $FullName=ConvertTo-WindowsPath $WMIFullName
          #Nom de fichier uniquement
         $FileName=Split-Path $FullName -Leaf

         $OwnerOfFile=Get-OwnerOfFile $WMIFullName
         if ($OwnerOfFile -ne $null)
          {$AccountName=$OwnerOfFile.AccountName}
         else {$AccountName="(Unknown)"}

         Write-Host ("Le compte {0} a créé le fichier : {1}" -f $AccountName,$FileName)
       }  
       $e2=$null
     }
    
    if ($e3 -ne $null)
     {
       write-host "Eventlog détecté: $($e3.targetInstance.Message)"
       $e3=$null
     }
    
    if ($host.ui.RawUi.KeyAvailable)
    { 
      $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
      if (($key.VirtualKeyCode -eq $ESCkey) -OR ($key.VirtualKeyCode -eq $Qkey)) 
       {
         StopWatching 
         $Watching=$false # On arrête la surveillance des événements, WMI videra le tampon
       }
    }#if KeyAvailable
  }#while
}
$DebugPreference="Continue"
TestWMIEvents
