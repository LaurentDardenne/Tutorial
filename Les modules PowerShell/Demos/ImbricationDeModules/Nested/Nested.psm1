#Une erreur dans un des modules imbriqu�s stoppera le chargement du module appelant 

#Throw "Erreur lors du chargement de module imbriqu� Nested."

$s="Nested"

Function Get-Files{
 Write-host '[Module Nested] Get-Files'
 Dir C:\Windows
}
function OnRemoveNested {
  Write-Host "Finalise le module imbriqu� Nested" �fore Green
}
 #Le code de la propri�t� 'OnRemove' est appel� lors de 
#la suppression du module. 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveNested }  

#Write-Host "Charge le module imbriqu� (Nested)" �fore Green
"Charge le module imbriqu� (Nested)"|Out-Host
export-Modulemember -variable S