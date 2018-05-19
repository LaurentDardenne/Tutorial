#Write-Host "Charge le module primaire(Test)" –fore Green
"Charge le module primaire(Test)"|Out-host
                              
Function Get-Files{
Write-host '[Module Test] Get-Files'
 Dir C:\Windows
}

function OnRemoveTest {
  Write-Host "Finalise le module primaire Test" –fore Green
}
 #Le code de la propriété 'OnRemove' est appelé lors de 
#la suppression du module. 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveTest }  

New-Alias glf Get-Files 
export-modulemember -alias glf 

