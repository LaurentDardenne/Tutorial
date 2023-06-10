function Get-DiskToPartition
{ #Auteurs : Laurent Dardenne, Tartar (www.PowerShell-Scripting.com)
  #Ce code permet de lister les disques dur et leurs partitions
   
  #Pour la construction de structures imbriquées voir le chapitre 6.3 "Imbrication de structure" 
  #tutoriel suivant : 
  #  http://laurent-dardenne.developpez.com/articles/Windows/PowerShell/StructuresDeDonneesSousPowerShell/

 function Test-ItemInPipeLine([switch] $PassThru)
 { #Calcule le nombre d'élément reçu dans le pipe
    $i=0
     #La variable automatique $Input est renseignée seulement si le bloc end est présent
     #Par défaut une fonction déclare uniquement ce bloc
    while ($Input.MoveNext()) {$i++}
    if ($i -gt 0)
     { 
       if ($PassThru)
         #On émet le nombre d'élément
        {$i}
    }
 }  
    
     #Numéro du disque courant, est utilisé comme nom de clé dans la hashtable suivante
    $diskID = 0 
     #Contient la liste des disques et les détails associés
    $Disques =@{}
     
     #gwmi est un alias pour Get-WmiObject
    gwmi Win32_DiskDrive| `
     Foreach-Object {
        $DriveID = $_.DeviceID
        $Disques."$diskID" = @{
             DeviceID=$DriveID;
             Status="NONE";
             Partition=$_.Partitions
             type=$_.interfacetype;
             LogicalDisks="";
             TotalSize=$_.Size /1GB
        } #HashTable $Disques."$diskID"
         #On construit dynamiquement la requête 
        gwmi -query "Associators of {Win32_DiskDrive.DeviceID='$DriveID'} where AssocClass=Win32_DiskDriveToDiskPartition"|`
         Foreach-Object  {
             #Réinitialise le numéro de la partition courante    
            $PartitionID = 0
            $LogicalDisks = @{}
            gwmi  -query "Associators of {Win32_DiskPartition.DeviceID='$($_.DeviceID)'} where AssocClass=Win32_LogicalDiskToPartition"|`
             Foreach-Object  {
                $LogicalDisks."$PartitionID" = @{
                    Size=$_.Size /1GB
                    FreeSpace=$_.FreeSpace
                    DriveType=$_.DriveType
                    MediaType=[string]$_.MediaType
                    VolumeName=$_.VolumeName
                    DeviceID=$_.deviceid
                    FileSystem=$_.FileSystem
                } #HashTable $LogicalDisks."$PartitionID"
                $PartitionID++
                $_ #réémission pour gérer l'affichage du no partitions dans isNoData
             }|Test-ItemInPipeLine|Foreach {Write-host -f red "No partitions" }  #foreach query LogicalDiskToPartition 
            $Disques."$diskID".LogicalDisks=$LogicalDisks
         }#foreach query DiskDriveToDiskPartition  
        $diskID++
     } #foreach Win32_DiskDrive
     #Emet l'objet dans le pipeline
    $Disques
}#Get-DiskToPartition    

$HDs=Get-DiskToPartition
 #Liste des disques
$Hds
 #Détail du premier disque
$Hds["0"]
 #Liste des partitions du premier disque
$Hds["0"].LogicalDisks
#Détail de la première partition du premier disque
$Hds["0"].LogicalDisks["0"]
