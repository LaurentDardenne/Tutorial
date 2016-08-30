#Requires -Version 5.0
Describe "IPMO versionning -PS v5 FullyQualifiedName - structure V5" {
   AfterEach {
     Remove-Module -Name Computer -EA SilentlyContinue
     $env:PSModulePath=$oldPSModulePath
   }         

   $testCasesMinimum = @(
       @{ First='MyModule' ; PSModulePath=";$MyPath;$FabrikamPath"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule' ; PSModulePath=";$FabrikamPath;$MyPath"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
   )

   $testCasesRequired = @(
       @{ First='MyModule' ; PSModulePath=";$MyPath;$FabrikamPath"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule' ; PSModulePath=";$FabrikamPath;$MyPath"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
   )
  
 Context "Par -FullyQualifiedName : clé 'ModuleVersion'. version demandée 1.0 . Gestion des doublons" {
  It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesMinimum {
      param ( 
        [string] $PSModulePath,
        [Version] $Version,
        [Guid] $Guid,
        [string] $Auteur      
      )

      try{

          $FQN=@{
            ModuleName = 'Computer'
            ModuleVersion = '1.0'
            GUID = $Guid
          }
          $env:PSModulePath +=$PSModulePath
          $ModuleInfo=Import-Module –FullyQualifiedName $FQN -EA STOP -pass
          #Write-host "Version = $version VModule=$($ModuleInfo.Version) guid=$($ModuleInfo.GUID)" 
          $result =($ModuleInfo.Version -eq $Version) -and ($Guid -eq $ModuleInfo.GUID)  
      }catch{
          Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
          $result=$false
      }
      $result | should be ($true)
  }
 }

 Context "Par -FullyQualifiedName : clé 'RequiredVersion'. version demandée 1.0 . Gestion des doublons" {
  It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesRequired {
      param ( 
        [string] $PSModulePath,
        [Version] $Version,
        [Guid] $Guid,
        [string] $Auteur      
      )

      try{

          $FQN=@{
            ModuleName = 'Computer'
            RequiredVersion = '1.0'
            GUID = $Guid
          }
          $env:PSModulePath +=$PSModulePath
          $ModuleInfo=Import-Module –FullyQualifiedName $FQN -EA STOP -pass
          $result =($ModuleInfo.Version -eq $Version) -and ($Guid -eq $ModuleInfo.GUID)  
      }catch{
          Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
          $result=$false
      }
      $result | should be ($true)
  }
 }
}
