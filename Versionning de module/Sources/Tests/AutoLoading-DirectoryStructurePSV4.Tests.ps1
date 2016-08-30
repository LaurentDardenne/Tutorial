#IPMO-DirectoryStructurePSV4.ps1

Describe "Auto Loading  versionning - Directory structure PS V4" {                                                                                 
   AfterEach {
     Remove-Module -Name Computer -EA SilentlyContinue
     $env:PSModulePath=$oldPSModulePath
   }         

   $testCases = @(
      #$MyModule path first
       @{ First='MyModule\Computer1.0' ; PSModulePath=";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0" ; Version='1.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer2.0' ; PSModulePath=";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"+
                                                      ";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"; Version='2.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='MyModule\Computer3.0' ; PSModulePath=";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"+
                                                      ";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }

      #$FabrikamModule path first
       @{ First='FabrikamModule\Computer1.0' ; PSModulePath=";$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer1.0;$MyPath\Computer2.0;$MyPath\Computer3.0" ; Version='1.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer2.0' ; PSModulePath=";$FabrikamPath\Computer2.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer3.0"+
                                                            ";$MyPath\Computer2.0;$MyPath\Computer1.0;$MyPath\Computer3.0"; Version='2.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
       @{ First='FabrikamModule\Computer3.0' ; PSModulePath=";$FabrikamPath\Computer3.0;$FabrikamPath\Computer1.0;$FabrikamPath\Computer2.0"+
                                                            ";$MyPath\Computer3.0;$MyPath\Computer1.0;$MyPath\Computer2.0"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
   )

 Context "Call Get-ComputerVersion function" {
   It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCases {
      param (
       [string] $PSModulePath, 
       [Version] $Version,
       [Guid] $Guid,
       [string] $Auteur 
      )

      $env:PSModulePath +=$PSModulePath
       
      try{
          Get-ComputerVersion
          $ModuleInfo=Get-Module -Name Computer -EA STOP
          $result =($ModuleInfo.Version -eq $Version) -and ($Guid -eq $ModuleInfo.GUID)
      }catch{
          Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
          $result=$false
      }
      $result | should be ($true)
   }
 } 
}