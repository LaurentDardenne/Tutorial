#Requires -Version 5.0
Describe "IPMO versionning - PS v5 FullyQualifiedName - structure V4" {
   AfterEach {
     Remove-Module -Name Computer -EA SilentlyContinue
     $env:PSModulePath=$oldPSModulePath
   }         
   $testCasesMIN = @(
      #$MyModule path first
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"+
                                             ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"+
                                             ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"; Version='2.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"+
                                             ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
      #$FabrikamModule path first
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"+
                                              ";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"+
                                             ";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"; Version='2.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"+
                                             ";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
   )

   $testCasesALL = @(
      #$MyModule path first
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0" ; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer3.0;$MyPath\Computer2.0"+
                                                      ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"; Version='2.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer3.0;$MyPath\Computer1.0"+
                                                      ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0"; Version='2.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"+
                                                      ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer2.0;$MyPath\Computer1.0"+
                                                      ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }

      #$FabrikamModule path first
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0" ; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0"+
                                                            ";$MyPath\Computer1.0;$MyPath\Computer3.0;$MyPath\Computer2.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"; Version='2.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0"+
                                                            ";$MyPath\Computer2.0;$MyPath\Computer3.0;$MyPath\Computer1.0"; Version='2.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"+
                                                            ";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0"+
                                                            ";$MyPath\Computer3.0;$MyPath\Computer2.0;$MyPath\Computer1.0"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
   )

   $testCasesALLRequired = @(
      #$MyModule path first
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0" ; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer3.0;$MyPath\Computer2.0"+
                                                      ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer3.0;$MyPath\Computer1.0"+
                                                      ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"+
                                                      ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer2.0;$MyPath\Computer1.0"+
                                                      ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0"; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }

      #$FabrikamModule path first
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0" ; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0"+
                                                            ";$MyPath\Computer1.0;$MyPath\Computer3.0;$MyPath\Computer2.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0"+
                                                            ";$MyPath\Computer2.0;$MyPath\Computer3.0;$MyPath\Computer1.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"+
                                                            ";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0"+
                                                            ";$MyPath\Computer3.0;$MyPath\Computer2.0;$MyPath\Computer1.0"; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
   )   
   
 
 Context "Par -FullyQualifiedName : clé 'ModuleVersion'. version demandée 1.0 . Gestion des doublons" {
  It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesALL {
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
  It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesALLRequired {
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