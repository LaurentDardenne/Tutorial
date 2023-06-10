#Partie 1/2
Function TestWMIEvents
{ #Surveille trois �v�nements WMI :
  # 1-la cr�ation de process
  # 2-la cr�ation d'une entr�e dans un eventlog
  # 3-la cr�ation de fichier dans le r�pertoire c:\temp
  
  function Get-OwnerOfFile([string]$FullPathName)
  { #Retrouve le propri�taire d'un fichier/directory. 
    #La syntaxe du nom de fichier est celle de WMI, 
    #les caract�res '\' y sont dupliqu�s. 
   gwmi -query "ASSOCIATORS OF {Win32_LogicalFileSecuritySetting=`"$FullPathName`"} WHERE AssocClass=Win32_LogicalFileOwner ResultRole=Owner"
  }
  
  
  function Pause ($Message="Pressez une touche pour continuer...")
  {
   Write-Host -NoNewLine $Message
   $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   Write-Host ""
  }

  
  function New-EventWatcher($Query,$Path="root\cimv2",[switch]$EnablePrivileges,[switch]$Start)
  {  #Cr�e un eventwatcher avec une requ�te d'�v�nement
  
    $scope = New-Object System.Management.ManagementScope $Path
    $Evntwatcher = New-Object System.Management.ManagementEventWatcher $scope,$query
    $options = New-Object System.Management.EventWatcherOptions
     # La surveillance s'arr�te au bout d'une seconde 
    $options.TimeOut = [TimeSpan]"0.0:0:1"
    $Evntwatcher.Options = $Options
    if ($EnablePrivileges)
       #Certaines classes WMI n�cessitent plus de droits 
     {$Evntwatcher.Scope.Options.EnablePrivileges = $true}
    if ($Start)
      #D�marre la surveillance
      # L'appel � start ne d�clenche pas la mise en tampon des �v�nements
     {$Evntwatcher.Start()}
    $Evntwatcher
  }
   #Gestion de la touche escape ou 'Q' du clavier
  $ESCkey = 27
  $Qkey = 81
  Write-Host "D�mo de surveillance.Touche Q ou Escape pour l'annuler."
  
   #Il est pr�f�rable que la clause WITHIN ([TimeSpan]"0:0:1") ait la m�me valeur
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

     #Si aucun �v�nement n'est d�livr� on re�oit $null
    if ($e -ne $null)
     {
        write-host ("Le process {0} a �t� cr�e, son chemin est : {1}" -F $e.TargetInstance.Name,$e.TargetInstance.ExecutablePath)
       $e=$null
     }

    if ($e2 -ne $null)
     {
       if ($e2.TargetInstance.PartComponent -match '^(.*)="(.*)\"$')
       {
           #Nom de fichier complet norm� WMI
         $WMIFullName=$matches[2]
          #Nom de fichier complet norm� Windows
         $FullName=$WMIFullName.Replace('\\','\')
          #Nom de fichier uniquement
         $FileName=Split-Path $FullName -Leaf
         $AccountName=(Get-OwnerOfFile $WMIFullName).AccountName
         Write-Host ("Le compte {0} a cr�� le fichier : {1}" -f $AccountName,$FileName)
       }  
       $e2=$null
     }
    
    if ($e3 -ne $null)
     {
       write-host "Eventlog d�tect�: $($e3.targetInstance.Message)"
       $e3=$null
     }

     #Permet de constater la m�morisation des �v�nements 
    #start-sleep 2
    
     #Si on recoit des �v�nements d�synchronis�s et par rafale, 
     #le d�lai de 200 ms permet de les "resynchroniser", �-peu-pr�s.
    #start-sleep -m 200
    #start-sleep -s 2 les "resynchronise" compl�tement

    if ($host.ui.RawUi.KeyAvailable)
    { 
       #On g�re la touche escape, 
       #la combinaison "Control-C" ne peut �tre trapp�e 
      $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp")
      if (($key.VirtualKeyCode -eq $ESCkey) -OR ($key.VirtualKeyCode -eq $Qkey)) 
       {
         Write-host "Arr�t de la surveillance et finalisation"
         $watchProcess.Stop()
         $watchTempDir.Stop()
         $watchEventLog.Stop()
           #On lib�re les ressources .NET et WMI sinon possible 
           #erreur WBEM_E_QUOTA_VIOLATION (0x8004106C ) lors de 
           #l'appel � Start() 
         $watchProcess.Dispose()
         $watchTempDir.Dispose()
         $watchEventLog.Dispose()
         break
       }
    }#if KeyAvailable
  }#while
}

TestWMIEvents
