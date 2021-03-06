#
# Manifeste de module pour le module "Log4Posh"
#
# Généré le : 12/08/2012
#

@{
#AliasesToExport=""
Author="Laurent Dardenne"
#CmdletsToExport=""
CompanyName="http://laurent-dardenne.developpez.com/"
Copyright="© 2012, Laurent Dardenne, released under Copyleft"
Description="A log4net wrapper for PowerShell"
CLRVersion="2.0"
#FileList=""
#FunctionsToExport=""
GUID = '23e26819-38ff-4600-9c56-5d2a59fa0cf0'
ModuleToProcess="Log4Poshv2.psm1" 
#NestedModules=""
ModuleVersion="2.0.0.0"
PowerShellVersion="2.0"
  # StopLog indique si on on arrête le Framework de Log
  #lors du déchargement du module.
PrivateData = @{StopLog = $True}

 #La dll est chargée dans le domaine d'application de PowerShell.
 # Si plusieurs version existe PS charge la dll ayant le numéro de version le plus grand
#RequiredAssemblies="log4net"
 # Charge la dll en précisant son numéro de version
RequiredAssemblies="log4net, Version=1.2.11.0, Culture=neutral, PublicKeyToken=669e0ddf0bb1aa2a"
#ScriptsToProcess=
#RequiredModules=
#ExportedVariables=
}
