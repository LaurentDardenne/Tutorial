#ToolsClass.psm1

#** ATTENTION Ce module reste à tester pour un usage en production **

New-Variable -Name ManifestExtension -Value '.psd1' -Option ReadOnly -Force
New-Variable -Name ScriptModuleExtension -Value '.psm1' -Option ReadOnly -Force
$DeserializationTypeNamePrefix = 'Deserialized.'

Function Test-ModuleType{
 param(
    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNull()]
  [System.Management.Automation.PSModuleInfo] $ModuleInfo,
  
   [Parameter(Position=2,Mandatory=$true)]
  [System.Management.Automation.ModuleType] $ModuleType,
  
  [Switch] $Strict
 )
  #si psm1 chargé directement moduletype='script', si chargé via un manifest .psd1 moduletype='manifest'.
 $result=$ModuleInfo.ModuleType -eq $ModuleType
 if (-not $Result -and $Strict)
 {
    $Exception=New-Object System.ArgumentException("Le module doit être du type $Type.",'ModuleType')
    throw $Exception 
 }
 return $result 
}

Function Get-InterfaceSignature{
#Affiche les signatures des membres d'une interface         
 param (
    [Parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNull()]
  [string] $TypeName
 ) 

 process {
  #todo interface sans propriété ni méthode juste un event
  [System.Type]$Type=$null
  if (-not [System.Management.Automation.LanguagePrimitives]::TryConvertTo($TypeName,[Type],[ref] $Type))
  {
    $Exception=New-Object System.ArgumentException('Le type est inconnu.','TypeName')
    Write-Error -Exception $Exception 
    return
  } 
  if (-not $Type.isInterface)
  {
    Write-Warning "Le type $Type n'est pas une interface."
    return
  }
  $Members=$Type.GetMembers()
  $isContainsEvent=@($Members|Where {$_.membertype -eq 'Event'}|Select -First 1).Count -ne 0
  
  if ((-not $isContainsEvent))
  {
    #Pour les propriétées d'interfaces,
    #les méthodes suffisent à l'implémentation de la propriété
    #todo setter R/O
   $Members=$Members|Group-object MemberType -AsHashTable -AsString
   $body="`tthrow 'Not implemented'"
    #Recherche les propriété indexées
   Foreach($PropertiesGroup in $Members.Property|Group Name){
    Foreach($Property in $PropertiesGroup.Group){
       $Indexers=$Property.GetIndexParameters()
       $isIndexers=$Indexers.Count -gt 0
       if ($isIndexers)
       {  
         Write-Output "#TODO [System.Reflection.DefaultMember('$($Property.Name)')]"
         #todo une classe VB.Net peut avoir + indexers ?
         #http://blogs.msdn.com/b/jaybaz_ms/archive/2004/07/21/189981.aspx
         Break 
       }
    }    
   }
   Foreach($Method in $Members.Method){
      $Ofs=",`r`n"
      $Parameters="$(
         Foreach ($Parameter in $Method.GetParameters()) 
         {
            Write-Output ('[{0}] ${1}' -f $Parameter.ParameterType,$Parameter.Name)
         }
      )"
    
      Write-Output ("[{0}] {1}($Parameters){{`r`n$Body`r`n}}`r`n" -f $Method.ReturnType,$Method.Name)
   }
  }
  Else
  {
   Write-Error "L’interface [$Type] contient un ou des événements. Son implémentation est impossible sous Powershell."
  }
 }
} #Get-InterfaceSignature

function Get-Class {
#Renvoi le type d'une classe PS hébergée dans un module   
  [CmdletBinding()]
  param
  (
      [Parameter(Mandatory,ValueFromPipeline)]
      [System.Management.Automation.PSModuleInfo]
      $Module,

      [Parameter(Mandatory)]
      [ValidateNotNullOrEmpty()]
      [string] 
      $ClassName,
 
      [Switch] $Strict
  )
Process {
   $Result=@(
    $Module.ImplementingAssembly.DefinedTypes|
     Where {$_.isPublic -and $_.Name -eq $ClassName}
   )
   
   if ($Result.Count -eq 0) 
   { 
     $Exception=New-Object System.ArgumentException("Type inconnu.",'ClassName')
     If (!$Strict) 
     { 
      $PSCmdlet.WriteError(
        (New-Object System.Management.Automation.ErrorRecord(
          $Exception, 
          "PowerShellClassNotFound", 
          "ObjectNotFound",
          ("[{0}]" -f $ClassName)
         )  
        )
      )
     }
     else 
     { throw $Exception }
   }
   else {$Result}
 }
}#Get-Class

function New-Class {
#Crée une instance de classe dans le contexte d'un module 
#La classe doit proposer un constructeur sans paramètre         
  param
  (
      [Parameter(Mandatory)]
      [System.Management.Automation.PSModuleInfo] $module,

      [Parameter(Mandatory)]
      [ValidateNotNullOrEmpty()]
      [string] $className
  )

  $scriptblock = [ScriptBlock]::Create("[$className]::new()")

  $command = &($module) $scriptblock
  return $command
}

function Test-PowershellDynamicClass {
#Teste si le type est une classe PS dynamique
#requiert PS v5
# Test-PowershellDynamicClass Psobject
# Test-PowershellDynamicClass MyClass 
# extrait et adapté de  https://github.com/PowerShell/PowerShell-Tests


 Param (
   [ValidateNotNullOrEmpty()]
   [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)] 
  [type] $Type
 )

 Process { 
   $attrs = @($Type.Assembly.GetCustomAttributes($true))
     $result = @($attrs | Where { $_  -is [System.Management.Automation.DynamicClassImplementationAssemblyAttribute] })
     return ($result.Count -eq 1)
 }
}

Function Import-RequiredModule{
# Renvoi les informations d'un module.
# Si celui-ci n'est pas chargé on l'importe via le paramètre -FullyQualifiedName
 param (
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [Microsoft.PowerShell.Commands.ModuleSpecification] $ModuleSpecification
 ) 
  #[string] $Module=$ModuleSpecification
  Write-debug "Try to retrieve the module $ModuleSpecification"
   #todo scenario: le module recherché est-il chargé dans le module ou en Global ? Difficile à savoir avec PS :/
  $RequiredModule=Get-Module -FullyQualifiedName $ModuleSpecification
  if ($null -eq $RequiredModule)
  {
     Write-debug "`tTry to import this module."
      #le module doit être chargé en Global. valable pour une fonction d'un module ou une méthode d'une classe dans un module
     $RequiredModule=Import-Module -FullyQualifiedName $ModuleSpecification -Global -Passthru   #todo erreur
  }
 return $RequiredModule
}#Import-RequiredModule


Function Get-ClassFromRequiredModule{
#Renvoi le type d'une classe PS hébergée dans un module.
# Si celui-ci n'est pas chargé on l'importe via le paramètre -FullyQualifiedName
 param (
  [Microsoft.PowerShell.Commands.ModuleSpecification] $ModuleSpecification,

  [String] $ClassName, #todo plusieurs classes ?

  [Switch] $Strict
 ) 


 $RequiredModule=Import-RequiredModule $ModuleSpecification
 if ($null -ne $RequiredModule) 
 { Get-Class $RequiredModule $ClassName -Strict:$Strict } 
 else 
 { return $null }
}#Get-ClassFromRequiredModule


function Import-ManifestData{ 
# Requires PS version 4.0
#Lit un manifest de module et renvoi une hashtable contenant uniqument les clés qui y sont renseignés
#from http://stackoverflow.com/questions/25408815/how-to-read-powershell-psd1-files-safely
#Gére les clés ModuleToProcess (v4) ou RootModule (v5) 
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        [hashtable] $data
    )
    return $data
}#Import-ManifestData

function getModuleName {
  param ([hashtable] $DatasManifest)

$keyName='ModuleToProcess'
if (-not $DatasManifest.Contains($KeyName)) #v4
{
  write-debug 'Read key RootModule'
  $keyName='RootModule' 
}
 return ($DatasManifest.$keyName -Replace "${ScriptModuleExtension}$")
} 

Function ConvertTo-ModuleSpecification {
# Requires PS version 4.0
#             version 5.0 pour la clé RequiredVersion  
#Renvoi une instance de [Microsoft.PowerShell.Commands.ModuleSpecification] soit
# -via la lecture d'un manifest de module, 
# -à partir d'une instance de type PSModuleInfo
           
    [CmdletBinding(DefaultParameterSetName = "psd1")]
    Param (
         #ArgumentTransformationAttribute : transforme l'argument du paramètre $Data avant de la lier à $Data
         #$Data peut donc être une string, un fileinfo
        [Parameter(Mandatory = $true,ParameterSetName="psd1")]
        [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
        $Data,
        
        [Parameter(Mandatory = $true,ParameterSetName="Moduleinfo")]
        [System.Management.Automation.PSModuleInfo]
        $ModuleInfo
    )
  if ($PSVersionTable.PSVersion -ge '5.0')
  { 
    write-debug 'PS v5 -New ModuleSpecification with RequiredVersion '
    if ($PsCmdlet.ParameterSetName -eq "psd1")
    {
      return [Microsoft.PowerShell.Commands.ModuleSpecification]@{
               ModuleName=(GetModuleName $Data)
               RequiredVersion =$Data.ModuleVersion
               GUID=$Data.Guid 
             }
    }
    else
    {
      return [Microsoft.PowerShell.Commands.ModuleSpecification]@{
               ModuleName=  $ModuleInfo.Name
               RequiredVersion =$ModuleInfo.Version
               GUID=$ModuleInfo.Guid 
             }
     
    }
 }
 else
 {
    write-debug 'PS v4 -New ModuleSpecification with ModuleVersion'
    if ($PsCmdlet.ParameterSetName -eq "psd1")
    {      
      return [Microsoft.PowerShell.Commands.ModuleSpecification]@{
             ModuleName=(GetModuleName $Data)
             ModuleVersion =$Data.ModuleVersion
             GUID=$Data.Guid 
           }
    }
    else
    {
      return [Microsoft.PowerShell.Commands.ModuleSpecification]@{
             ModuleName=$ModuleInfo.Name
             ModuleVersion =$ModuleInfo.Version
             GUID=$ModuleInfo.Guid 
           }     
    } 
 }
}#ConvertTo-ModuleSpecification

Function New-ModuleSpecificationMemberTypeData{
#Renvoi un texte représentant une structure XML à insérer dans un fichier .ps1xml
 param( 
    [ValidateNotNull()]
    [Parameter(Position=0, Mandatory=$true,ValueFromPipeline = $true)]
    [string[]] $TypeName, #todo from [type]
  
    [ValidateNotNull()]
    [Parameter(Mandatory = $true)]
    [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
    $Data
 ) 

begin {
$ModuleName=$Data.RootModule -Replace "${ScriptModuleExtension}$"
$private:Members=@"                                                               
    <ScriptProperty>
     <Name>ModuleSpecification</Name>
     <GetScriptBlock>
      [Microsoft.PowerShell.Commands.ModuleSpecification]@{
        ModuleName='$(GetModuleName $Data)'
        RequiredVersion ='$($Data.ModuleVersion)'
        GUID='$($Data.Guid)' 
      } 
    </GetScriptBlock>
    <SetScriptBlock>
      Throw 'ModuleSpecification is a read only property.'
    </SetScriptBlock>
   </ScriptProperty>
"@
}

process {
 @"
<?xml version="1.0" encoding="utf-8"?>
<Types>
"@
 foreach ($Current in $TypeName) {
  @"
  <Type>
   <Name>$Current</Name>
   <Members>
 $private:Members
   </Members>
  </Type>
"@
 }#for
 "</Types>"
}#process 
} #New-ModuleSpecificationMemberTypeData


Export-ModuleMember -Variable ManifestExtension,ScriptModuleExtension `
                    -Function Test-ModuleType,
                              Get-InterfaceSignature,
                              Get-Class,
                              New-Class,
                              Test-PowershellDynamicClass,
                              Import-RequiredModule,
                              Get-ClassFromRequiredModule,
                              Import-ManifestData,
                              ConvertTo-ModuleSpecification,
                              New-ModuleSpecificationMemberTypeData 