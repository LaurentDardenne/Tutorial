#Module de test
#
#Ces fonctions ne font rien, 
#elles servent juste à démontrer la construction du fichier d'aide XML
#des fonctions de ce module.  

Function Test-CommandHelp {
 # .ExternalHelp TestHelps-Help.xml         
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

Function Get-CommandHelp {
 # .ExternalHelp TestHelps-Help.xml
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
 
 Function Set-CommandHelp {
 # les fonctions privées ne sont pas déclarées dans le fichier d'aide
 param (
   [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
  [string]$Truc,
  
    [Parameter(Position=0,Mandatory=$true)]
  [string]$Machin,
  
    [Parameter(Position=1,Mandatory=$true)]
  [string] $Bidule
 )
  Write-Host "test"
 }#Set-CommandHelp
 
 Export-ModuleMember -function Get-CommandHelp,Test-CommandHelp