#Crée un module nommé  MyModule.psm1 
#dans le sous répertoire MyModule du répertoire $PathModule

#Affiche dynamiquement le nom du chemin de chargement du module
#Implémente la propriéte OnRemove
#Localise, à l'aide d'un fichier de données, les messages utilisés dans le code du module

$myPath="C:\Temp"
if (-not (Test-Path  $myPath)) 
{ throw "Le répertoire n'existe pas: $myPath" }

$PathModule="$myPath\MyModule"
md $PathModule -ErrorAction SilentlyContinue 

@"
#Initialisation
  Import-LocalizedData -BindingVariable MessageTable -Filename MyModuleLocalizedData.psd1 -EA Stop
 `$Name=`$MyInvocation.MyCommand.ScriptBlock.Module.Name
 Write-Host (`$MessageTable.MsgInitialise -F `$Name,`$PSScriptRoot)

function Privée {
  Write-Host "Fonction interne`$MessageTable.MsgMsgFinalise -F `$Name) –fore Green
}

#Finalisation
function OnRemoveMyModule {
  Write-Host (`$MessageTable.MsgMsgFinalise -F `$Name) –fore Green
}
 #Le code de la propriété 'OnRemove' est appelé lors de 
#la suppression du module. 
`$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveMyModule }  
"@ > "$PathModule\MyModule.psm1"
