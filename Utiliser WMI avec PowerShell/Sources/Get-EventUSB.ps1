 # Get-EventUSB.ps1
 # note : Device Identifier Formats -> STORAGE_DEVICE_DESCRIPTOR
  #D�tecte l'insertion d'un nouveau disque (USB, Net Use) 

#La classe Win32_PnPEntity concerne tous les �l�ments Plug and Play.
$query =New-object System.Management.WqlEventQuery(
           "__InstanceOperationEvent",
        [TimeSpan]"0:0:1",
       '(__CLASS="__InstanceCreationEvent" or
         __CLASS="__InstanceDeletionEvent") and
        TargetInstance isa "Win32_PnPEntity" and TargetInstance.Service="USBSTOR"')

$watcher =new-object System.Management.ManagementEventWatcher
$watcher.Query = $query
 #Gestion d'�v�nement synchrone
$evenement = $watcher.WaitForNextEvent()
 #D�termine le type d'�v�nement
switch ($evenement.__Class)
{
    #Une nouvelle instance de la classe recherch�e a �t� cr��e
   "__InstanceCreationEvent"   
      {Write-Warning ("Nouvel �l�ment Plug and Play d�tect�.")
        #On cr�� une instance de la classe
        #r�f�renc�e par la propri�t� TargetInstance
        #N�cessaire si on souhaite retrouver ses associations 
       $I=[wmi]"$($evenement.TargetInstance.__relpath)"
       $I
      }
    #Une instance de la classe recherch�e vient d'�tre supprim�e
   "__InstanceDeletionEvent"  {
      Write-Warning ("Un �l�ment Plug and Play a �t� retir�.")
       #L'instance r�f�renc�e n'existe plus dans le r�f�rentiel, mais 
       #seulement comme copie dans la propri�t� TargetInstance.
       #Difficile de retrouver les associations d'un objet inexistant...
      $evenement.TargetInstance
     }
   default {Write-Warning "La classe d'�v�nement __InstanceModificationEvent n'est pas g�r�e."} 
} #Switch

 #Lib�re les ressources
$Watcher.Dispose()

# Traitement n�cessitant le device PnP
