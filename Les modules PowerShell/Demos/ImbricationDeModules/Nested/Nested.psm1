#Une erreur dans un des modules imbriqués stoppera le chargement du module appelant 

#Throw "Erreur lors du chargement de module imbriqué Nested."

$s="Nested"

Function Get-Files{
 Write-host '[Module Nested] Get-Files'
 Dir C:\Windows
}
function OnRemoveNested {
  Write-Host "Finalise le module imbriqué Nested" –fore Green
}
 #Le code de la propriété 'OnRemove' est appelé lors de 
#la suppression du module. 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveNested }  

#Write-Host "Charge le module imbriqué (Nested)" –fore Green
"Charge le module imbriqué (Nested)"|Out-Host
export-Modulemember -variable S