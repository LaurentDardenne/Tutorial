#IPMO-DirectoryStructurePSV4.ps1

Describe "IPMO versionning - Directory structure PS V4" {                                                                                 
   AfterEach {
     Remove-Module -Name Computer -EA SilentlyContinue
     $env:PSModulePath=$oldPSModulePath
   }         
   $testCasesMinimum = @(
      #$MyModule path first       
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"+
                                             ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"+
                                             ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"; Version='2.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"+
                                             ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
      #$FabrikamModule path first
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"+
                                              ";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"+
                                             ";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"; Version='2.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"+
                                             ";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
   )

   $testCasesALL = @(
      #$MyModule path first
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0" ; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer3.0;$MyPath\Computer2.0"+
                                                      ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"; Version='2.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer3.0;$MyPath\Computer1.0"+
                                                      ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0"; Version='2.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"+
                                                      ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer2.0;$MyPath\Computer1.0"+
                                                      ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }

      #$FabrikamModule path first
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0" ; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0"+
                                                            ";$MyPath\Computer1.0;$MyPath\Computer3.0;$MyPath\Computer2.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"; Version='2.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0"+
                                                            ";$MyPath\Computer2.0;$MyPath\Computer3.0;$MyPath\Computer1.0"; Version='2.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"+
                                                            ";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0"+
                                                            ";$MyPath\Computer3.0;$MyPath\Computer2.0;$MyPath\Computer1.0"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
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
   It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesAll {
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
  It 'Le premier chemin est "<First>". La version chargée : "1.0" de l''auteur "<Auteur>"' -TestCases $testCasesALl {
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
          Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
          $result=$false
      }
      $result | should be ($true)
  }
 }
}