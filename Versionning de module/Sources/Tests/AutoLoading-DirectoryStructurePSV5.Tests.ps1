#Requires -Version 5.0
Describe "Auto Loading versionning - Directory structure PS V5" {                                                                                 
   AfterEach {
     Remove-Module -Name Computer -EA SilentlyContinue
     $env:PSModulePath=$oldPSModulePath
   }         

   $testCasesMinimum = @(
       @{ First='MyModule' ; PSModulePath=";$MyPath;$FabrikamPath"; Version='3.0'; GUID=$MyGuidModule;Auteur='Laurent Dardenne' }
       @{ First='FabrikamModule' ; PSModulePath=";$FabrikamPath;$MyPath"; Version='3.0'; GUID=$FabrikamGuidModule;Auteur='Fabrikam' }
   )


 Context "Call Get-ComputerVersion function" {
   It 'Le premier chemin est "<First>". La version chargée : "<Version>" de l''auteur "<Auteur>"' -TestCases $testCasesMinimum {
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