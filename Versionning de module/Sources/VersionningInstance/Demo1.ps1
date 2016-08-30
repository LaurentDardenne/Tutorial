#Demo1 : Une seule version d'un module
#Requires -Version 5.0

$Path=$PSScriptRoot
$oldPSModulePath=$env:PSModulePath

$env:PSModulePath +=";$Path\Modules"

# Local : Session courante
$DebugPreference='Continue'
#$verbosePreference='Continue'

 #charge les prérequis et la classe
ipmo ToolsClass, Computer -force

 #retrouve le type nécessaire à la création d'une instance de Computer
 #Ce type sera utilisé pour réhydrater l'instance distante.
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
   ipmo ToolsClass,Computer -force
   $Type=Get-Module Computer | Get-Class -ClassName 'Computer'
   $Type::New()
} | 
 Wait-Job|
 Receive-job -AutoRemoveJob -Wait

$LocalComputerModuleSpecification=$LocalComputer.ModuleSpecification.ToString()

$DistantComputerModuleSpecification=$Object.ModuleSpecification.ToString()
Write-Warning  "Local   : $LocalComputerModuleSpecification"
Write-Warning  "Distant : $DistantComputerModuleSpecification"
if ($LocalComputerModuleSpecification -ne $DistantComputerModuleSpecification)
{
  $Message="Les versions de module associées aux objets sont différentes."
  $Message +=("`r`n Local : '{0}' Distant '{1}'" -F $LocalComputerModuleSpecification,$DistantComputerModuleSpecification)
  Throw $Message
}

Write-host 'Les numéros de versions des module associées aux objets sont identiques.' -for green
#On peut réhydrater l'instance désérialisée car le module est déjà chargé
# $DistantComputer est un objet du type [Computer] 
$DistantComputer=[System.Management.Automation.LanguagePrimitives]::ConvertTo($Object,$Type,[System.Globalization.CultureInfo]::InvariantCulture)
$isTypeEqual=$LocalComputer.GetType() -eq $DistantComputer.GetType()

Write-host "Le type des objets est identique : $isTypeEqual" -for green

$env:PSModulePath=$oldPSModulePath