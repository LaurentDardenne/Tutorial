#Add-Type -path "$PSScriptRoot\Adapters.cs" -OutputAssembly "$PSScriptRoot\Adapters.dll" -OutputType Library  
Add-Type -path "$PSScriptRoot\Adapters.dll"


Start-job {
 param ([string] $Source)              
  Add-Type -path "$Source\Adapters.dll"
  
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
 $Network = 1..3 | 
  Foreach {
    New-Object GetAdmin.Net("ns0", "192.168.1.$_", "255.255.255.0")
  }
 New-Server -Name Server1 -Network $Network
}  -ArgumentList $PSScriptRoot |Receive-Job -Wait -AutoRemoveJob
