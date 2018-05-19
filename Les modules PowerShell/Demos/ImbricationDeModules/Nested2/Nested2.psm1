$s="Nested2"

Function Get-Files{
 Write-host '[Module Nested2] Get-Files'
 Dir C:\Windows
}
function OnRemoveNested {
  Write-Host "Finalise le module imbriqué Nested2" –fore Green
}
 #Le code de la propriété 'OnRemove' est appelé lors de 
#la suppression du module. 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveNested }  

#Write-Host "Charge le module imbriqué (Nested)" –fore Green
"Charge le module imbriqué (Nested2)"|Out-Host
export-Modulemember -variable S