#Partie 1/2
Function TestWMIEvents
{ #Surveille trois événements WMI :
  # 1-la création de process
  # 2-la création d'une entrée dans un eventlog
  # 3-la création de fichier dans le répertoire c:\temp
  
  function Get-OwnerOfFile([string]$FullPathName)
  { #Retrouve le propriétaire d'un fichier/directory. 
    #La syntaxe du nom de fichier est celle de WMI, 
    #les caractères '\' y sont dupliqués. 
   gwmi -query "ASSOCIATORS OF {Win32_LogicalFileSecuritySetting=`"$FullPathName`"} WHERE AssocClass=Win32_LogicalFileOwner ResultRole=Owner"
  }
  
  
  function Pause ($Message="Pressez une touche pour continuer...")
  {
   Write-Host -NoNewLine $Message
   $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   Write-Host ""
  }

  
  function New-EventWatcher($Query,$Path="root\cimv2",[switch]$EnablePrivileges,[switch]$Start)
  {  #Crée un eventwatcher avec une requête d'événement
  
    $scope = New-Object System.Management.ManagementScope $Path
    $Evntwatcher = New-Object System.Management.ManagementEventWatcher $scope,$query
    $options = New-Object System.Management.EventWatcherOptions
     # La surveillance s'arrête au bout d'une seconde 
    $options.TimeOut = [TimeSpan]"0.0:0:1"
    $Evntwatcher.Options = $Options
    if ($EnablePrivileges)
       #Certaines classes WMI nécessitent plus de droits 
     {$Evntwatcher.Scope.Options.EnablePrivileges = $true}
    if ($Start)
      #Démarre la surveillance
      # L'appel à start ne déclenche pas la mise en tampon des événements
     {$Evntwatcher.Start()}
    $Evntwatcher
  }
   #Gestion de la touche escape ou 'Q' du clavier
  $ESCkey = 27
  $Qkey = 81
  Write-Host "Démo de surveillance.Touche Q ou Escape pour l'annuler."
  
   #Il est préférable que la clause WITHIN ([TimeSpan]"0:0:1") ait la même valeur
  $Query=New-object System.Management.WqlEventQuery("__InstanceCreationEvent", [TimeSpan]"0:0:1",'TargetInstance isa "Win32_Process" and TargetInstance.Name = "notepad.exe"')
  $watchProcess=New-EventWatcher $Query -Start
  
  $Query = New-object System.Management.WqlEventQuery("__InstanceCreationEvent", [TimeSpan]"0:0:1",'TargetInstance isa "Win32_NTLogEvent"')
  $watchEventLog=New-EventWatcher $Query -EnablePrivileges -Start 

   $RepAMonitorer =  "C:\Temp".Replace("\", "\\\\") 
   $WhereClause=("Targetinstance ISA 'CIM_DirectoryContainsFile' and TargetInstance.GroupComponent='Win32_Directory.Name=`"{0}`"'" -F $RepAMonitorer)
  $Query = New-object System.Management.WqlEventQuery("__InstanceCreationEvent", [TimeSpan]"0:0:1",$WhereClause)
  $watchTempDir=New-EventWatcher $Query -Start

  while ($true) {
    trap [System.Management.ManagementException] {continue}
    $e=$watchProcess.WaitForNextEvent()
    $e2=$watchTempDir.WaitForNextEvent()
    $e3=$watchEventLog.WaitForNextEvent()

     #Si aucun événement n'est délivré on reçoit $null
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
         $FullName=$WMIFullName.Replace('\\','\')
          #Nom de fichier uniquement
         $FileName=Split-Path $FullName -Leaf
         $AccountName=(Get-OwnerOfFile $WMIFullName).AccountName
         Write-Host ("Le compte {0} a créé le fichier : {1}" -f $AccountName,$FileName)
       }  
       $e2=$null
     }
    
    if ($e3 -ne $null)
     {
       write-host "Eventlog détecté: $($e3.targetInstance.Message)"
       $e3=$null
     }

     #Permet de constater la mémorisation des événements 
    #start-sleep 2
    
     #Si on recoit des événements désynchronisés et par rafale, 
     #le délai de 200 ms permet de les "resynchroniser", à-peu-prés.
    #start-sleep -m 200
    #start-sleep -s 2 les "resynchronise" complètement

    if ($host.ui.RawUi.KeyAvailable)
    { 
       #On gére la touche escape, 
       #la combinaison "Control-C" ne peut être trappée 
      $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
      if (($key.VirtualKeyCode -eq $ESCkey) -OR ($key.VirtualKeyCode -eq $Qkey)) 
       {
         Write-host "Arrêt de la surveillance et finalisation"
         $watchProcess.Stop()
         $watchTempDir.Stop()
         $watchEventLog.Stop()
           #On libére les ressources .NET et WMI sinon possible 
           #erreur WBEM_E_QUOTA_VIOLATION (0x8004106C ) lors de 
           #l'appel à Start() 
         $watchProcess.Dispose()
         $watchTempDir.Dispose()
         $watchEventLog.Dispose()
         break
       }
    }#if KeyAvailable
  }#while
}

TestWMIEvents
