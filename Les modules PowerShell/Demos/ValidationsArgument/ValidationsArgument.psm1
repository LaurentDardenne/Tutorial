#Module ValidationsArguments
#Les fonctions sont d�clar�es dans le corps du module
 
  Import-LocalizedData -BindingVariable MessageTable -Filename ValidationsArgumentLocalizedData.psd1 -EA Stop

  $Frmt=" : $($MyInvocation.MyCommand.ScriptBlock.Module.Name).{0}"
  $FrmtCall="Call$Frmt"
  $FrmtBegin="Begin$Frmt"
  $FrmtProcess="Process$Frmt"
  $FrmtEnd="End$Frmt"
  
  Write-Debug ("Call module : {0}" -F $MyInvocation.MyCommand.ScriptBlock.Module.Name)
  Write-Debug ("PSScriptRoot : {0}" -F $PSScriptRoot)
  Write-Debug "Contenu du message EVAGlobbing : $($MessageTable.EVAGlobbing)"
  
  #Le type [System.Management.Automation.TypeAccelerators] n'�tant pas public
  # $T= [System.Management.Automation.TypeAccelerators] # Renvoi une erreur
  #L'usage suivant ne fonctionne pas :
  # [System.Management.Automation.TypeAccelerators]::Add
  
  #Le type n'est pas public mais certaines de ses m�thodes le sont :
  # $T= [psobject].assembly.gettype("System.Management.Automation.TypeAccelerators")
  # $T.GetMembers()|select name,membertype,ispublic,isstatic
  # $T.GetConstructors() #Aucun constructeur public 
  
  #On doit donc obtenir une r�f�rence sur ce type :
  # $T= [psobject].assembly.gettype("System.Management.Automation.TypeAccelerators") 
  # Puis l'utiliser pour adresser la m�thode publique :
  # $T::Add($_.Key,$_.Value)
  
 $acceleratorsType= [psobject].assembly.gettype("System.Management.Automation.TypeAccelerators")   
  
  # Ajoute un acc�l�rateur locale pour la classe d'exception    
 $ValidationsArgumentShortCut=@{"VMException"=[System.Management.Automation.ValidationMetadataException]}
 $ValidationsArgumentShortCut.GetEnumerator()|  
    Foreach {
     Try {
       Write-debug "Add TypeAccelerators $($_.Key) =$($_.Value)"
       $AcceleratorsType::Add($_.Key,$_.Value)
     } Catch [System.Management.Automation.MethodInvocationException]{
       write-Error $_.Exception.Message 
     }
   } 
 
 #N�cessaire � la fonction de validation Test-ServiceStatus
Add-Type -AssemblyName "System.ServiceProcess"

function New-ValidationFunction {
#Cr�e dans un fichier, le squelette d'une fonction de validation         
 param(         
   [ValidateScript( {Test-PathMustexist })]
   [Parameter(Mandatory = $true)]
  [String] $Path,
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
  [String] $FunctionName
 )

 $FName=Join-path $Path "Test-${FunctionName}.ps1"

 $Code1="function Test-$FunctionName {"
 $code2=@'

 #r�gle de validation d'argument :
 [CmdletBinding()]    
 param () 
  Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
  $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value

  $true # La valeur est valide
  
<#
.SYNOPSIS
     R�gle de validation 
     todo
    
.DESCRIPTION

      R�f�rence en interne le contenu de la variable $_ d�clar�e dans la port�e de l'appelant.
    
.PARAMETER  
      
    

.EXAMPLE
      todo code...
     
     Description
     -----------
     todo 
      
     
.INPUTS  

.OUTPUTS  
     Une valeur bool�enne, true indiquant que la validation a r�ussie.
     
.FUNCTIONALITY
     ValidationArgument
      
.COMPONENT  
     PowerShell
     
.ROLE   
     SoftwareDeveloper
     
.LINK
     
#>
}
'@ 

 $code1,$code2 > "$FName"
 Write-verbose "Fonction cr�� : $FName"        
}#New-ValidationFunction

Function Test-PathMustExist{
# .ExternalHelp ValidationsArgument-Help.xml         
 [CmdletBinding()]    
 param () 
 
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
 $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value
 
 if ([string]::IsNullOrEmpty($PipelineObjectInScopeOfCaller))
  { throw (new-object VMException $MessageTable.PathMustExistNullOrEmpty)}
 if (!(Test-Path $PipelineObjectInScopeOfCaller) )
  { throw (new-object VMException ($MessageTable.PathMustExist -F $PipelineObjectInScopeOfCaller)) }
 $true

} #Test-PathMustExist

function Test-IsImplementingInterface{
# .ExternalHelp ValidationsArgument-Help.xml
 [CmdletBinding()]    
 param (
   [Parameter(Mandatory = $true,Position=0,
              HelpMessage="The name of the interface type to validate.")]
  [Type] $Interface) 
 
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
 $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value

 $Type=$PipelineObjectInScopeOfCaller.GetType()
 if (!$Interface.IsInterface)
  { Throw ($MessageTable.IsImplementingInterfaceIsNotAnInterface -F $Interface)}
 if (!$Interface.IsAssignableFrom($Type)) 
  { Throw ($MessageTable.IsImplementingInterface -F $Type,$Interface)} 
 $true
}#Test-IsImplementingInterface

function Test-IsWMIClass{
# .ExternalHelp ValidationsArgument-Help.xml
 [CmdletBinding()]    
 param (
   [Parameter(Mandatory = $true,Position=0,
              HelpMessage="The name of the WMI class to validate.")]
  [String] $ClassName) 
 
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
 $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value
 
 $Type=$PipelineObjectInScopeOfCaller.GetType()
 if (!$Type.IsSubclassOf([System.Management.ManagementBaseObject]))
    { Throw ($MessageTable.IsWMIClassIsSubClassOf -F $Type)}
 if ($PipelineObjectInScopeOfCaller.__CLASS -ne $ClassName)  
  {Throw ($MessageTable.IsWMIClass -F $Classname)}
 $true
}#Test-IsWMIClass

function Test-IsSubClassOf{
# .ExternalHelp ValidationsArgument-Help.xml
 [CmdletBinding()]    
 param (
  [Parameter(Mandatory = $true,Position=0,
             HelpMessage="The name of the class to validate.")]
  [Type] $Class) 
 
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
 $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value
 
 $Type=$PipelineObjectInScopeOfCaller.GetType()
 if (!$Type.IsSubclassOf($Class)) 
{ Throw ($MessageTable.IsSubClassOf -F $Type,$class)} 
 $true
}

Function Test-ContainsWildcardCharacters{
# .ExternalHelp ValidationsArgument-Help.xml
 [CmdletBinding()]    
 param () 
  Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)

  $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value
  If ([Management.Automation.WildcardPattern]::ContainsWildcardCharacters($PipelineObjectInScopeOfCaller))
  { throw (new-object VMException ($MessageTable.EVAGlobbing -F $PipelineObjectInScopeOfCaller)) }
 $true 
} #Test-ContainsWildcardCharacters

Function Test-ProviderConstraint{
# .ExternalHelp ValidationsArgument-Help.xml
 [CmdletBinding()]    
 Param (
   [Parameter(Mandatory = $true,Position=0,
              HelpMessage="The name of the provider to validate.")]
  [string] $Providername) 
 
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
 $PipelineObjectInScopeOfCaller=$PSCmdlet.SessionState.PSVariable.Get("_").Value
 
 if (!(Test-Path Variable:AddLib))
  { throw (new-object VMException $MessageTable.ProviderConstraintRequiereAddLib) }
 If (!(Test-PSProviderPath $PipelineObjectInScopeOfCaller $ProviderName))  
  { throw (new-object VMException ($MessageTable.ProviderConstraint -F $ProviderName,$PipelineObjectInScopeOfCaller))  }
 
 $true
} #Test-ProviderConstraint

function Test-ScopedItemOptions{
# .ExternalHelp ValidationsArgument-Help.xml
  #r�gle de validation d'argument : la valeur d'une propri�t� de type ScopedItemOptions doit respecter une coh�rence. 
 [CmdletBinding()]    
 param () 

 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
 $value=[int]$PSCmdlet.SessionState.PSVariable.Get("_").Value

    #On s'assure que les valeurs sont coh�rentes.
      #AllScope(8) xor Private(4) 
  if (($value -bor 12) -eq 12)
    { throw (new-object VMException ($MessageTable.ScopedItemOptions -F "AllScope","Private")) }
    #Constant(2) xor ReadOnly(1)   (None=0) 
  if ((value -bor 3) -eq 3)
    { throw (new-object VMException ($MessageTable.ScopedItemOptions -F "Constant","ReadOnly")) }
 $true
} #Test-ScopedItemOptions

function Test-ServiceStatus{
# .ExternalHelp ValidationsArgument-Help.xml         
 [CmdletBinding()]    
 param (
    [Parameter(Mandatory = $true,Position=0,
               HelpMessage="The name of the service to check.")]
   [string]$InputObject,
    [Parameter(Mandatory = $true,Position=1,
               HelpMessage="The status name to check.")]
   [System.ServiceProcess.ServiceControllerStatus] $Status)
 
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
  #Test le statut du service
 $Service=Get-Service -Name $InputObject -EA SilentlyContinue
 if (!$?)
  {Throw ($MessageTable.ServiceStatusUnknown -F $InputObject)}
 if ($Service.Status -ne $Status)
  {Throw ($MessageTable.ServiceStatus -F $Service.DisplayName,$Service.Name,$Status)}
 $true
}

# ----------- Finalisation du module ---------------------------------------------------------
function OnRemoveValidationsArgument {
  Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
    #Remove shortcuts
  $ValidationsArgumentShortCut.GetEnumerator()|
   Foreach {
     Try {
       Write-debug "Remove TypeAccelerators $($_.Key)"
       [void]$AcceleratorsType::Remove($_.Key)
     } Catch {
       write-Error $_.Exception.Message
     }
   }
}
 #Le d�l�gu� de l'�v�nement 'OnRemove' est appel� lors de la suppression du module. 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveValidationArgument } 

Export-ModuleMember -Function New-ValidationFunction,
                              Test-PathMustExist,
                              Test-IsImplementingInterface,
                              Test-IsWMIClass,
                              Test-IsSubClassOf,
                              Test-ContainsWildcardCharacters,
                              Test-ProviderConstraint,
                              Test-ScopedItemOptions,
                              Test-ServiceStatus
