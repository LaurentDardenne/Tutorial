#To call with dotsource
Add-Type -path "$PSScriptRoot\Adapters.dll"

$TypeFile="$PSScriptRoot\Adapters.ps1xml"
 # Local scope !!!
Update-TypeData -PrependPath $TypeFile

Start-job { 
 param ([string] $Source)      
  Add-Type -path "$Source\Adapters.dll"
  Update-TypeData -PrependPath "$Source\Adapters.ps1xml"
  
  Function New-Server {
      <#
      .SYNOPSIS
          Create a new GetAdmin.Server object
      .PARAMETER Name
          Server Name
      .PARAMETER Network
          Detailed per interfave network information
      .EXAMPLE
          Get-NavFiler
      .Outputs
          Netapp.SDK.NavFiler[]
      #>
      [CmdletBinding()]
      param(
          [Parameter(ValueFromPipelineByPropertyName=$TRUE)]
          [string]
          $Name,
   
          [Parameter()]
          [GetAdmin.Net[]]
          $Network
      )
      Process {
          return New-Object GetAdmin.Server -ArgumentList @($Name, $network)
      }
  }
 New-Server –Name Server1 –Network "ns0,192.168.1.1,255.255.255.0", "ns0,192.168.1.2,255.255.255.0", "ns0,192.168.1.3,255.255.255.0"
} -ArgumentList $PSScriptRoot |Receive-Job -Wait -AutoRemoveJob
