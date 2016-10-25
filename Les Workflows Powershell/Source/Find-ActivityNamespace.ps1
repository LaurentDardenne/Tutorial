#requires 4.0
 #recherche dans les assemblies des activités PS, les 'wrapper' de cmdlets
#v3 $Classes=dir $env:windir\Assembly\NativeImages_v4.0.30319_64\Microsoft.PowerShell.*activities*.dll -Recurse|

Import-Module PSWorkflow
$ClassesNative=dir $env:windir\Microsoft.Net\Assembly\GAC_MSIL -inc Microsoft.PowerShell.*activities.dll,Microsoft.WSMan.Management.*activities.dll -Recurse|
Foreach {
  $Assembly=Add-Type -path $_.Fullname -pass
  $Assembly|Where {$_.isSubclassOf([System.Activities.NativeActivity]) -or $_.isSubclassOf([System.Activities.Activity])}
}

$Classes=$ClassesNative|Where {$_.isSubclassOf([Microsoft.PowerShell.Activities.PSActivity])}

$List=$Classes|
 Select Name,@{Name='Namespace';Expression={$_.Assembly.FullName}}|
 Sort Name

$List 
 #Recherche les classes qui ne sont pas dérivées de PSActivity
Compare-Object $Classes $ClassesNative -Property name
