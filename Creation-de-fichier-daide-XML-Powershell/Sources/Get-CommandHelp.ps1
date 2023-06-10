Function Get-CommandHelp {
 # .ExternalHelp Test-CommandHelp-Help.xml
 param (
   [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
   [ValidateNotNullOrEmpty()]
  [string]$Name,
  
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string]$Fonction,
  
    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string] $Source
 )
  Write-Host "test"
 }#Get-CommandHelp