 # Get-EventUSB.ps1
 # note : Device Identifier Formats -> STORAGE_DEVICE_DESCRIPTOR
  #Détecte l'insertion d'un nouveau disque (USB, Net Use) 

#La classe Win32_PnPEntity concerne tous les éléments Plug and Play.
$query =New-object System.Management.WqlEventQuery(
           "__InstanceOperationEvent",
        [TimeSpan]"0:0:1",
       '(__CLASS="__InstanceCreationEvent" or
         __CLASS="__InstanceDeletionEvent") and
        TargetInstance isa "Win32_PnPEntity" and TargetInstance.Service="USBSTOR"')

$watcher =new-object System.Management.ManagementEventWatcher
$watcher.Query = $query
 #Gestion d'événement synchrone
$evenement = $watcher.WaitForNextEvent()
 #Détermine le type d'événement
switch ($evenement.__Class)
{
    #Une nouvelle instance de la classe recherchée a été créée
   "__InstanceCreationEvent"   
      {Write-Warning ("Nouvel élément Plug and Play détecté.")
        #On créé une instance de la classe
        #référencée par la propriété TargetInstance
        #Nécessaire si on souhaite retrouver ses associations 
       $I=[wmi]"$($evenement.TargetInstance.__relpath)"
       $I
      }
    #Une instance de la classe recherchée vient d'être supprimée
   "__InstanceDeletionEvent"  {
      Write-Warning ("Un élément Plug and Play a été retiré.")
       #L'instance référencée n'existe plus dans le référentiel, mais 
       #seulement comme copie dans la propriété TargetInstance.
       #Difficile de retrouver les associations d'un objet inexistant...
      $evenement.TargetInstance
     }
   default {Write-Warning "La classe d'événement __InstanceModificationEvent n'est pas gérée."} 
} #Switch

 #Libére les ressources
$Watcher.Dispose()

# Traitement nécessitant le device PnP
