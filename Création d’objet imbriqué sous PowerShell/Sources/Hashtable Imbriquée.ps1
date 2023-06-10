#http://powershell-scripting.com/index.php?option=com_joomlaboard&Itemid=76&func=view&id=2873&catid=6#2873

#Construit la liste
# Name                           Value
# ----                           -----
# 0                              {LogicalDisks, type, Partition, Status...}
# 1                              {LogicalDisks, type, Partition, Status...}
 
function ReadFileSystem()
{
    $AllDiskDrive = Get-WMIObject -CL Win32_DiskDrive
    $diskID = 0 
    [hashtable]$Devices =@{}
    
    foreach($diskDrive in $AllDiskDrive){
        $strDriveDeviceID = [string]$diskDrive.deviceid
        $Devices."$diskID" = @{DeviceID="";Status="";Partition="";LogicalDisks=""}
        $Devices."$diskID".DeviceID=$strDriveDeviceID
        $Devices."$diskID".Status="NONE"
        $Devices."$diskID".TotalSize=[string]$diskDrive.Size /1GB
        
        $query1 = "Associators of {Win32_DiskDrive.DeviceID='$strDriveDeviceID'} where AssocClass=Win32_DiskDriveToDiskPartition"
        $colPartitions = gwmi -query $query1
        
        if($colPartitions -eq $NULL){
            Write-host -f red "No partitions"
            $Devices."$diskID".Partition=0
        }
        else
        {        
          $Devices."$diskID".Partition=$colPartitions.Count
        }
            
        foreach($colPart in $colPartitions) {    
           $strPartitionDeviceID = [string]$colPart.DeviceID
           $query2 = "Associators of {Win32_DiskPartition.DeviceID='$strPartitionDeviceID'} where AssocClass=Win32_LogicalDiskToPartition"
           $colLogicalDisks = Get-WmiObject -query $query2
           if($colLogicalDisks){
              [hashtable]$LogicalDisks = @{}
              $i = 0
              foreach($colLogicalDisk in $colLogicalDisks){
                 $LogicalDisks."$i" = @{Type="";Size="";FreeSpace="";DriveType="";MediaType="";VolumeName="";DeviceID="";}
                  Write-host "Disk Size: "($diskDrive.Size /1GB)
                  Write-host "SCSILogicalUnit: "$diskDrive.SCSILogicalUnit
                  Write-host "SCSITargetId: "$diskDrive.SCSITargetId
                  Write-host "Partitions: "$diskDrive.Partitions
                  Write-host "DiskID: "$diskID " has "$diskDrive.Partitions " partition(s)" 
                  Write-host "Physical Disk:"  $diskDrive.caption  " -- "  $diskDrive.deviceid
                  Write-host "Disk Partition: " $colPart.DeviceID
                  Write-host "DriveType: "$colLogicalDisk.DriveType
                  Write-host "MediaType: "$colLogicalDisk.MediaType
                  Write-host "VolumeName: "$colLogicalDisk.VolumeName
                  Write-host "Logical Disk: " $colLogicalDisk.deviceid
                  Write-host "FreeSpace: " ($colLogicalDisk.FreeSpace /1GB)
                  Write-host "Logical Size:" ($colLogicalDisk.Size /1GB)
                  Write-host
                  [string]$var = $colLogicalDisk.Size /1GB
                  $LogicalDisks."$i".Size=$var
                  $LogicalDisks."$i".FreeSpace=[string]$colLogicalDisk.FreeSpace
                  $LogicalDisks."$i".DriveType=[string]$colLogicalDisk.DriveType
                  $LogicalDisks."$i".MediaType=[string]$colLogicalDisk.MediaType
                  $LogicalDisks."$i".VolumeName=$colLogicalDisk.VolumeName
                  $LogicalDisks."$i".DeviceID=[string]$colLogicalDisk.deviceid
                  $i++
              }
              $Devices."$diskID".LogicalDisks=$LogicalDisks
          }
        }
    $diskID++
    }
  $devices
}    

$HD=ReadFileSystem

$hd
# Name                           Value
# ----                           -----
# 0                              {LogicalDisks, type, Partition, Status...}
# 1                              {LogicalDisks, type, Partition, Status...}


 $hd."0"
# Name                           Value
# ----                           -----
# LogicalDisks                   {0}
# type
# Partition
# Status                         NONE
# DeviceID                       \\.\PHYSICALDRIVE1
# TotalSize                      149,048187732697
# 

$hd."0".logicalDisks."0"
# Name                           Value
# ----                           -----
# Size                           149.048156738281
# VolumeName                     Secondaire
# Type
# FreeSpace                      34208002048
# MediaType                      12
# DriveType                      3
# DeviceID                       G:

$hd."0".logicalDisks."0".VolumeName
#Secondaire


 
  #récupère les infos, en les dupliquant, de la partition 1 : clé 0
$P=($hd."0".logicalDisks."0").Clone()
# avec $P=$hd."0".logicalDisks."0" on récupére la même référence de hashtable
$p.VolumeName="Test"
 #l'ajoute à la HT logicalDisks avec une nouvelle clé nommé "1"
$hd."0".logicalDisks."1"=$p
$hd."0".logicalDisks
# Name                           Value
# ----                           -----
# 0                              {Size, VolumeName, Type, FreeSpace...}
# 1                              {Size, VolumeName, Type, FreeSpace...}
$hd."0".logicalDisks."0".VolumeName
#Secondaire
$hd."0".logicalDisks."1".VolumeName
#Test
 #Test l'affectation de hashtable
$Ld=$hd."0".logicalDisks
$hd."0".logicalDisks=$null
$hd."0".logicalDisks
#Vide
$hd."0".logicalDisks=$Ld
$hd."0".logicalDisks

# Name                           Value
# ----                           -----
# 0                              {Size, VolumeName, Type, FreeSpace...}
# 1                              {Size, VolumeName, Type, FreeSpace...}
#Vérification
$hd."0".logicalDisks."0".VolumeName
#Secondaire
$hd."0".logicalDisks."1".VolumeName
#Test
