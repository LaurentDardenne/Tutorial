#Demo2 : Deux version d'un module
#Requires -Version 5.0

$Path=$PSScriptRoot
$oldPSModulePath=$env:PSModulePath

$env:PSModulePath +=";$Path\Modules"

# Local : Session courante
$DebugPreference='Continue'
#$verbosePreference='Continue'

 #charge les prérequis et la classe
ipmo ToolsClass
 #charge le module de version 2.0
ipmo  -FullyQualifiedName @{ModuleName="Computer"; RequiredVersion ='2.0'; GUID='4b25a895-addd-45fd-82bc-b7b0ed80d3a6'}

 #retrouve le type nécessaire à la création d'une instance de Computer
$Type=Get-Module Computer | Get-Class -ClassName 'Computer'

 #Puis cré l'instance de Computer
$LocalComputer=$Type::New()
$LocalComputer

Write-host 'Attend la fin d''un job ...' -for green

# Distant : session remote ou dans un job (local ou distant)
# $Object est un objet désérialisé du type [Deserialized.Computer]
# Sa propriété ModuleSpecification est réhydraté par Powershell,
# son contenu n'est pas modifié. 
$Object=Start-job { 
    
    #!!!! Le job local pointe sur la déclaration env:PSModulePath du process parent 
    #Pour un serveur distant on doit ajouter la modification du path
   
   Write-Host "`$env:PSModulePath = $env:PSModulePath" 
   ipmo ToolsClass 
    #charge le module de version 1.0
   ipmo -FullyQualifiedName @{ModuleName="Computer"; RequiredVersion ='1.0'; GUID='4b25a895-addd-45fd-82bc-b7b0ed80d3a6'}

   $Type=Get-Module Computer | Get-Class -ClassName 'Computer'
   $Type::New()
} | 
 Wait-Job|
 Receive-job -AutoRemoveJob -Wait

$LocalComputerModuleSpecification=$LocalComputer.ModuleSpecification.ToString()

$DistantComputerModuleSpecification=$Object.ModuleSpecification.ToString()
Write-Warning  "Local   : $LocalComputerModuleSpecification"
Write-Warning  "Distant : $DistantComputerModuleSpecification"

#Erreur !!!
if ($LocalComputerModuleSpecification -ne $DistantComputerModuleSpecification)
{
  #Erreur la version du module utilisée dans les script
  #est différente de celle utilisée dans le job
  
  #On ne réhydrate pas l'instance désérialisé
  #A moins que le module supporte le side by side (SXS)

  #Si ici on charge une autre version du module 'Computer'
  # son import échoue car le membre ETS 'ModuleSpecification' est déjà référencé.
  $Message="Les versions de module associées aux objets sont différentes."
  $Message +=("`r`n Local   : '{0}'`r`n Distant : '{1}'" -F $LocalComputerModuleSpecification,$DistantComputerModuleSpecification)
  $env:PSModulePath=$oldPSModulePath
  Throw $Message
}




