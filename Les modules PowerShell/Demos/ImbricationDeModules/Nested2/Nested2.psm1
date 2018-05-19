$s="Nested2"

Function Get-Files{
 Write-host '[Module Nested2] Get-Files'
 Dir C:\Windows
}
function OnRemoveNested {
  Write-Host "Finalise le module imbriqu� Nested2" �fore Green
}
 #Le code de la propri�t� 'OnRemove' est appel� lors de 
#la suppression du module. 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveNested }  

#Write-Host "Charge le module imbriqu� (Nested)" �fore Green
"Charge le module imbriqu� (Nested2)"|Out-Host
export-Modulemember -variable S