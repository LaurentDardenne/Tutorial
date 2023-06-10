#adapte ce code
#http://powershell-scripting.com/index.php?option=com_joomlaboard&Itemid=76&func=view&id=2873&catid=6#2873
Import-Module PSObjectHelper

Function New-Disk{
 param(
     [Parameter(Mandatory=$True,position=0)]
    $DeviceID,
     [Parameter(Mandatory=$True,position=1)]
    $Status,
     [Parameter(Mandatory=$True,position=2)]
    $Partition,
     [Parameter(Mandatory=$True,position=3)]
    $TotalSize
 )

 $O=New-Object PSObject 
 $O.PsObject.TypeNames.Insert(0,"Disk")
 
 $Collection=New-Object System.Collections.ArrayList(2)

 $PSBoundParameters.GetEnumerator()|
  Foreach {
    $O.PSObject.Properties.Add( (New-PSVariableProperty $_.Key $_.Value -ReadOnly) ) 
  }
 $O.PSObject.Properties.Add( (New-PSVariableProperty 'LogicalDisks' $Collection -ReadOnly))
 $O
}# New-Disk

Function New-LogicalDisk{
  param(
     [Parameter(Mandatory=$True,position=0)]
    $Size,
     [Parameter(Mandatory=$True,position=1)]
    $FreeSpace,
     [Parameter(Mandatory=$True,position=2)]
    $DriveType,
     [Parameter(Mandatory=$True,position=3)]
    $MediaType,
     [Parameter(Mandatory=$True,position=4)]
    $VolumeName,
     [Parameter(Mandatory=$True,position=5)]
    $DeviceID,
    [Parameter(Mandatory=$True,position=6)]
    $Number
  )
 $O=New-Object PSObject 
 $O.PsObject.TypeNames.Insert(0,"LogicalDisk")
 
 $PSBoundParameters.GetEnumerator()|
  Foreach {
    $O.PSObject.Properties.Add( (New-PSVariableProperty $_.Key $_.Value -ReadOnly) ) 
  }
 $O
}# New-LogicalDisk

function Get-DiskDrive{
 param()

  $DiskDrives = @(Get-WMIObject -CL Win32_DiskDrive)
  $diskID = 0 
  $Devices=New-Object PSObject
  $Devices.PsObject.TypeNames.Insert(0,"DiskDrive")
  
  foreach($DiskDrive in $DiskDrives){
      $strDriveDeviceID = [string]$DiskDrive.deviceid
      $Disk=@{}

      $query1 = "Associators of {Win32_DiskDrive.DeviceID='$strDriveDeviceID'} where AssocClass=Win32_DiskDriveToDiskPartition"
      $Partitions = @(Get-WMIObject -query $query1)

      $Disk.DeviceID=$strDriveDeviceID
      $Disk.Status="NONE"
      $Disk.TotalSize=[string]$DiskDrive.Size /1GB

      if($Partitions.Count -eq 0)
      {
         Write-Warning "DiskDrive $strDriveDeviceID has no partitions."
         $Disk.Partition=0
      }
      else
      { $Disk.Partition=$Partitions.Count }
      
      $NewDisk= New-Disk @Disk
      $Devices.PSObject.Properties.Add( (New-PSVariableProperty "Disk$diskID" $NewDisk -ReadOnly) )
    
      foreach($Partition in $Partitions) {    
         $strPartitionDeviceID = [string]$Partition.DeviceID
         $query2 = "Associators of {Win32_DiskPartition.DeviceID='$strPartitionDeviceID'} where AssocClass=Win32_LogicalDiskToPartition"
         $LogicalDisks = @(Get-WmiObject -query $query2)
         
         if($LogicalDisks.Count -gt 0){
            $i = 0
            foreach($LogicalDisk in $LogicalDisks){
                $CurrentLD = @{}
                $CurrentLD.Number="$i"
                Write-host "Disk Size: "($DiskDrive.Size /1GB)
                Write-host "SCSILogicalUnit: "$DiskDrive.SCSILogicalUnit
                Write-host "SCSITargetId: "$DiskDrive.SCSITargetId
                Write-host "Partitions: "$DiskDrive.Partitions
                Write-host "DiskID: "$diskID " has "$DiskDrive.Partitions " partition(s)" 
                Write-host "Physical Disk:"  $DiskDrive.caption  " -- "  $DiskDrive.deviceid
                Write-host "Disk Partition: " $Partition.DeviceID
                Write-host "DriveType: "$LogicalDisk.DriveType
                Write-host "MediaType: "$LogicalDisk.MediaType
                Write-host "VolumeName: "$LogicalDisk.VolumeName
                Write-host "Logical Disk: " $LogicalDisk.deviceid
                Write-host "FreeSpace: " ($LogicalDisk.FreeSpace /1GB)
                Write-host "Logical Size:" ($LogicalDisk.Size /1GB)
                Write-host
                $CurrentLD.Size=$LogicalDisk.Size /1GB
                $CurrentLD.FreeSpace=[string]$LogicalDisk.FreeSpace
                $CurrentLD.DriveType=[string]$LogicalDisk.DriveType
                $CurrentLD.MediaType=[string]$LogicalDisk.MediaType
                $CurrentLD.VolumeName=$LogicalDisk.VolumeName
                $CurrentLD.DeviceID=[string]$LogicalDisk.deviceid
                $i++
            }
            $null=$Devices."Disk$diskID".LogicalDisks.Add( (New-LogicalDisk @CurrentLD)) 
        }
      }
  $diskID++
  }
  return $devices
}    

$HD=Get-DiskDrive
