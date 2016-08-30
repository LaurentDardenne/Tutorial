#Ajoute les chemins des modules versionnée

#Vous pouvez tester les différents comportement du chargement de module en modifiant la déclaration du path



#ordre croissant: v1,v2,v3
#La plus ancienne version est déclarée en premier
  $env:PSModulePath += ";$PSScriptRoot\Computer1.0;$PSScriptRoot\Computer2.0;$PSScriptRoot\Computer3.0"

#Désordonné
  #$env:PSModulePath += ";$PSScriptRoot\Computer1.0;$PSScriptRoot\Computer3.0;$PSScriptRoot\Computer2.0"

#ordre décroissant: v3,v2,v1
#La plus récente version est déclarée en premier  
  #$env:PSModulePath += ";$PSScriptRoot\Computer3.0;$PSScriptRoot\Computer2.0;$PSScriptRoot\Computer1.0;"

