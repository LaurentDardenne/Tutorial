#Demo3 : Charge un module à la réception d'un objet distant  afin de réhydrater l'objet dans son contexte
#Requires -Version 5.0

$Path=$PSScriptRoot
$oldPSModulePath=$env:PSModulePath

$env:PSModulePath +=";$Path\Modules"

Write-host 'Attend la fin d''un job ...' -for green

$Object=Start-job { 
   #Emet une instance d'une classe
   #issu d'un module versionné
   ipmo ToolsClass,Computer -force
   $Type=Get-Module Computer | Get-Class -ClassName 'Computer'
   $Type::New()
} | 
 Wait-Job|
 Receive-job -AutoRemoveJob -Wait

Write-host "Type de l'instance désérialisée : $($Object.PSTypeNames[0])" -for green


$LoadedModules=@(
 Get-module -Name $Object.ModuleSpecification.Name |
  Where Guid -eq $Object.ModuleSpecification.Guid
)

if ($LoadedModules.Count -ge 2)
{ throw "Le side by side de module n'est pas géré."}
if ($LoadedModules.Count -eq 1) 
{ 
   #vérifie le version du module déjà chargé
  $Current=ConvertTo-ModuleSpecification -Data ([System.IO.Path]::ChangeExtension($LoadedModules.Path,'psd1')) 
  if ("$Current" -ne "$($Object.ModuleSpecification)")
   { Throw "Version de module différent : $Current"} 
}

#Aucun module n'est chargé ou celui en mémoire correspond

Write-host "Charge le module nécessaire à la création de l'instance" -for green
ipmo ToolsClass # NECESSITE de connaitre les prérequis
 #Charge le module d'après les infos portées par l'instance désérialisée
Import-Module -FullyQualifiedName $Object.ModuleSpecification
 #récupére le module, puis la classe
$Type=Get-Module $Object.ModuleSpecification.Name | Get-Class -ClassName 'Computer'
 #Réhydrate la classe
$DistantComputer=[System.Management.Automation.LanguagePrimitives]::ConvertTo($Object,$Type,[System.Globalization.CultureInfo]::InvariantCulture)

Write-host "Type de l'instance réhydratée : $($DistantComputer.PSTypeNames[0])" -for green
$env:PSModulePath=$oldPSModulePath