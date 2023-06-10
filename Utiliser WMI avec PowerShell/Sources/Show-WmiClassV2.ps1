############################################################################
# Show-WmiClassV2 - Show WMI classes
# Author: Microsoft
# Version: 1.0
# NOTE: Notice that this is uses the verb SHOW vs GET. That is because it
# combines a Getter with a format. SHOW was added as a new "official
# verb to deal with just this case.
#
# Example :
#  
# show-wmiclass account
# show-wmiclass account -namespace root\cimv2\terminalservices
# show-wmiclass -namespace root\cimv2\terminalservices

# show-wmiClass -refresh -derivation "__event"
# show-wmiClass -refresh -namespace "root\subscription" -derivation "__EventConsumer"

############################################################################
Function Show-WmiClass($Name = ".",
                       $NameSpace = "root\cimv2",
                       [Switch]$Refresh=$false,
                       $Derivation=""
                      )
{ 
  # Getting a list of classes can be expensive and the list changes infrequently. 
  # This makes it a good candidate for caching.
  
  $CacheDir = Join-path $env:Temp "WMIClasses"
  $CacheFile = Join-Path $CacheDir ($Namespace.Replace("\","-") + ".csv")
  if (!(Test-Path $CacheDir))
  {
   $null = New-Item -Type Directory -Force $CacheDir
  }
  
  if (!(Test-Path $CacheFile) -Or $Refresh)
  {
    Get-WmiObject -List -Namespace:$Namespace |
    foreach {
       if ($Derivation -eq [String]::Empty) 
         {$_} #emit
       elseif ($_.__Derivation -contains $Derivation)
            {$_} #emit
    } |
    Sort -Property Name |
    Select -Property Name |
    Export-csv -Path $CacheFile -Force
  }
  
  Import-csv -Path $CacheFile | 
   where {$_.Name -match $Name} |
   Format-Wide -AutoSize
}
