function Get-DiskToPartition
{ #Pour la construction de structures imbriquées voir le chapitre 6.3 "Imbrication de structure" 
  #tutoriel suivant : 
  #  http://laurent-dardenne.developpez.com/articles/Windows/PowerShell/StructuresDeDonneesSousPowerShell/
  
    $AllDiskDrive = GWMI -CL Win32_DiskDrive
    $diskID = 0 
    [hashtable]$Devices =@{}
    
    foreach($diskDrive in $AllDiskDrive){
        $strDriveDeviceID = [string]$diskDrive.deviceid
        $Devices."$diskID" = @{DeviceID="";Status="";Partition="";type="";LogicalDisks=""}
        $Devices."$diskID".DeviceID=$strDriveDeviceID
        $Devices."$diskID".Status="NONE"
        $Devices."$diskID".TotalSize=[string]$diskDrive.Size /1GB
        $Devices."$diskID".Type=[string]$diskDrive.interfacetype
        
        $query1 = "Associators of {Win32_DiskDrive.DeviceID='$strDriveDeviceID'} where AssocClass=Win32_DiskDriveToDiskPartition"
        $colPartitions =,(get-wmiobject -query $query1)
        $Devices."$diskID".Partition=$diskDrive.Partitions

        if($diskDrive.Partitions -eq 0)
         { Write-host -f red "No partitions" }
            
        foreach($colPart in $colPartitions) {    
           $strPartitionDeviceID = [string]$colPart.DeviceID
           $query2 = "Associators of {Win32_DiskPartition.DeviceID='$strPartitionDeviceID'} where AssocClass=Win32_LogicalDiskToPartition"
           $colLogicalDisks = Get-WmiObject -query $query2
           if($colLogicalDisks){
              [hashtable]$LogicalDisks = @{}
              $i = 0
              foreach($colLogicalDisk in $colLogicalDisks){
                 $LogicalDisks."$i" = @{Size="";FreeSpace="";DriveType="";MediaType="";VolumeName="";DeviceID="";FileSystem=""}
                  [string]$var = $colLogicalDisk.Size /1GB
                  $LogicalDisks."$i".Size=$var
                  $LogicalDisks."$i".FreeSpace=[string]$colLogicalDisk.FreeSpace
                  $LogicalDisks."$i".DriveType=[string]$colLogicalDisk.DriveType
                  $LogicalDisks."$i".MediaType=[string]$colLogicalDisk.MediaType
                  $LogicalDisks."$i".VolumeName=$colLogicalDisk.VolumeName
                  $LogicalDisks."$i".DeviceID=[string]$colLogicalDisk.deviceid
                  $LogicalDisks."$i".FileSystem=[string]$colLogicalDisk.FileSystem 
                  $i++
              }
              $Devices."$diskID".LogicalDisks=$LogicalDisks
          }
        }
    $diskID++
    }
  $devices
}    

$HDs=Get-DiskToPartition
 #Liste des disques
$Hds
 #Détail du premier disque
$Hds["0"]
 #Liste des partitions du premier disque
$Hds["0"].LogicalDisks
#Détail de la première partition du premier disque
$Hds["0"].LogicalDisks["0"]
