#Requires -Version 5.0
Describe "IPMO versionning - Directory structure PS V5" {                                                                                 
   AfterEach {
     Remove-Module -Name Computer -EA SilentlyContinue
     $env:PSModulePath=$oldPSModulePath
   }         

   $testCasesMinimum = @(
       @{ First='MyModule' ; PSModulePath=";$MyPath;$FabrikamPath"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule' ; PSModulePath=";$FabrikamPath;$MyPath"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
   )


 Context "Par -Name" {
   It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesMinimum {
      param (
       [string] $PSModulePath, 
       [Version] $Version,
       [Guid] $Guid,
       [string] $Auteur 
      )

      $env:PSModulePath +=$PSModulePath
      try{
          $ModuleInfo=Import-Module -Name Computer -EA STOP -pass
          $result =($ModuleInfo.Version -eq $Version) -and ($Guid -eq $ModuleInfo.GUID)
      }catch{
          Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
          $result=$false
      }
      $result | should be ($true)
   }
 } 
 
 Context "Par -MinimumVersion" {
   It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesMinimum {
      param (
       [string] $PSModulePath, 
       [Version] $Version,
       [Guid] $Guid,
       [string] $Auteur 
      )

      try{
          $env:PSModulePath +=$PSModulePath
          $ModuleInfo=Import-Module -Name Computer -Version $Version -EA STOP -pass
          $result =($ModuleInfo.Version -eq $Version) -and ($Guid -eq $ModuleInfo.GUID) 
      }catch{
          Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
          $result=$false
      }
      $result | should be ($true)
  }
 }  
 Context "Par -RequiredVersion. Pas de gestion des doublons" {
  It 'Le premier chemin est "<First>". La version chargée : "1.0" de l''auteur "<Auteur>"' -TestCases $testCasesMinimum {
      param ( 
       [string] $PSModulePath,
       [Guid] $Guid,
       [string]$Auteur 
      )

      try{
          $env:PSModulePath +=$PSModulePath
          $ModuleInfo=Import-Module -Name Computer -RequiredVersion 1.0 -EA STOP -pass
          $result =($ModuleInfo.Version -eq '1.0') -and ($Guid -eq $ModuleInfo.GUID) 
      }catch{
          #Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
          $result=$false
      }
      $result | should be ($true)
  }
 }
}