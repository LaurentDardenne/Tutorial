#
# Manifeste de module pour le module "Log4Posh"
#
# Généré le : 10/02/2010
#

@{
#AliasesToExport=""
Author="Laurent Dardenne"
#CmdletsToExport=""
CompanyName="http://laurent-dardenne.developpez.com/"
Copyright="© 2010, Laurent Dardenne, released under Copyleft"
Description="A log4net wrapper for PowerShell"
CLRVersion="2.0"
#FileList=""
#FunctionsToExport=""
GUID = 'f796dd07-541c-4ad8-bfac-a6f15c4b06a0'
ModuleToProcess="Log4Posh.psm1" 
#NestedModules=""
ModuleVersion="1.0.0.0"
PowerShellVersion="2.0"
  # StopLog indique si on on arrête le Framework de Log
  #lors du déchargement du module.
PrivateData = @{StopLog = $True}
 ##La dll est chargée dans le domaine d'application de PowerShell.
#RequiredAssemblies="log4net, Version=1.2.10.0, Culture=neutral, PublicKeyToken=1b44e1d426115821"
#RequiredAssemblies="log4net"
RequiredAssemblies="log4net, Version=1.2.11.0, Culture=neutral, PublicKeyToken=669e0ddf0bb1aa2a
#ScriptsToProcess=
#RequiredModules=
#ExportedVariables=
}
