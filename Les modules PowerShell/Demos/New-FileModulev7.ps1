#Cr�e un module nomm�  MyModule.psm1 
#dans le sous r�pertoire MyModule du r�pertoire $PathModule

#Affiche dynamiquement le nom du chemin de chargement du module
#Impl�mente la propri�te OnRemove
#Localise, � l'aide d'un fichier de donn�es, les messages utilis�s dans le code du module

$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le r�pertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
#Initialisation
  Import-LocalizedData -BindingVariable MessageTable -Filename MyModuleLocalizedData.psd1 -EA Stop
 `$Name=`$MyInvocation.MyCommand.ScriptBlock.Module.Name
 Write-Host (`$MessageTable.MsgInitialise -F `$Name,`$PSScriptRoot)

function Priv�e {
  Write-Host "Fonction interne`$MessageTable.MsgMsgFinalise -F `$Name) �fore Green
}

#Finalisation
function OnRemoveMyModule {
  Write-Host (`$MessageTable.MsgMsgFinalise -F `$Name) �fore Green
}
 #Le code de la propri�t� 'OnRemove' est appel� lors de 
#la suppression du module. 
`$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveMyModule }  
"@ > "$PathModule\MyModule.psm1"
