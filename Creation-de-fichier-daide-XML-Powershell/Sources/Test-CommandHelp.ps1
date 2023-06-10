Function Test-CommandHelp {
  param (
   [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
   [ValidateNotNullOrEmpty()]
  [string]$CommandName,
  
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string]$ModuleName,
  
    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string] $TargetDirectory
 )
 
  Write-Host "test"

}#Test-CommandHelp