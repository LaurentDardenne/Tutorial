function Get-DiskToPartition
{ #Auteurs : Laurent Dardenne, Tartar (www.PowerShell-Scripting.com)
  #Ce code permet de lister les disques dur et leurs partitions
   
  #Pour la construction de structures imbriqu�es voir le chapitre 6.3 "Imbrication de structure" 
  #tutoriel suivant : 
  #  http://laurent-dardenne.developpez.com/articles/Windows/PowerShell/StructuresDeDonneesSousPowerShell/

 function Test-ItemInPipeLine([switch] $PassThru)
 { #Calcule le nombre d'�l�ment re�u dans le pipe
    $i=0
     #La variable automatique $Input est renseign�e seulement si le bloc end est pr�sent
     #Par d�faut une fonction d�clare uniquement ce bloc
    while ($Input.MoveNext()) {$i++}
    if ($i -gt 0)
     { 
       if ($PassThru)
         #On �met le nombre d'�l�ment
        {$i}
    }
 }  
    
     #Num�ro du disque courant, est utilis� comme nom de cl� dans la hashtable suivante
    $diskID = 0 
     #Contient la liste des disques et les d�tails associ�s
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
         #On construit dynamiquement la requ�te 
        gwmi -query "Associators of {Win32_DiskDrive.DeviceID='$DriveID'} where AssocClass=Win32_DiskDriveToDiskPartition"|`
         Foreach-Object  {
             #R�initialise le num�ro de la partition courante    
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
                $_ #r��mission pour g�rer l'affichage du no partitions dans isNoData
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
 #D�tail du premier disque
$Hds["0"]
 #Liste des partitions du premier disque
$Hds["0"].LogicalDisks
#D�tail de la premi�re partition du premier disque
$Hds["0"].LogicalDisks["0"]
