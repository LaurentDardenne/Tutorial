#Exporté des métadatas du module Cim_DataProcess.cdxml.
#Le fichier Cim_DataProcess.cdxml est transformé en code PS lors de l'Import-module 

#requires -version 3.0

if ($(Microsoft.PowerShell.Core\Get-Command Set-StrictMode -Module Microsoft.PowerShell.Core)) { Microsoft.PowerShell.Core\Set-StrictMode -Off }

$script:MyModule = $MyInvocation.MyCommand.ScriptBlock.Module

$script:ClassName = 'ROOT\cimv2\CIM_Process'
$script:ClassVersion = ''
$script:ModuleVersion = '1.0'
$script:ObjectModelWrapper = 'Microsoft.PowerShell.Cmdletization.Cim.CimCmdletAdapter'

$script:PrivateData = Microsoft.PowerShell.Utility\New-Object 'System.Collections.Generic.Dictionary[string,string]'

Microsoft.PowerShell.Core\Export-ModuleMember -Function @()
        

function __cmdletization_BindCommonParameters
{
    param(
        $__cmdletization_objectModelWrapper,
        $myPSBoundParameters
    )       
                

        if ($myPSBoundParameters.ContainsKey('CimSession')) { 
            $__cmdletization_objectModelWrapper.PSObject.Properties['CimSession'].Value = $myPSBoundParameters['CimSession'] 
        }
                    

        if ($myPSBoundParameters.ContainsKey('ThrottleLimit')) { 
            $__cmdletization_objectModelWrapper.PSObject.Properties['ThrottleLimit'].Value = $myPSBoundParameters['ThrottleLimit'] 
        }
                    

        if ($myPSBoundParameters.ContainsKey('AsJob')) { 
            $__cmdletization_objectModelWrapper.PSObject.Properties['AsJob'].Value = $myPSBoundParameters['AsJob'] 
        }
                    

}
                

function Get-DataProcess
{
    [CmdletBinding(DefaultParameterSetName='DefaultSet', PositionalBinding=$false)]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
[OutputType('Microsoft.Management.Infrastructure.CimInstance#ROOT\cimv2\CIM_Process')]

    param(
    
    [Alias('Session')]
    [ValidateNotNullOrEmpty()]
    [Microsoft.Management.Infrastructure.CimSession[]]
    ${CimSession},

    [int]
    ${ThrottleLimit},

    [switch]
    ${AsJob})

    DynamicParam {
        try 
        {
            if (-not $__cmdletization_exceptionHasBeenThrown)
            {
                $__cmdletization_objectModelWrapper = Microsoft.PowerShell.Utility\New-Object $script:ObjectModelWrapper
                $__cmdletization_objectModelWrapper.Initialize($PSCmdlet, $script:ClassName, $script:ClassVersion, $script:ModuleVersion, $script:PrivateData)

                if ($__cmdletization_objectModelWrapper -is [System.Management.Automation.IDynamicParameters])
                {
                    ([System.Management.Automation.IDynamicParameters]$__cmdletization_objectModelWrapper).GetDynamicParameters()
                }
            }
        }
        catch
        {
            $__cmdletization_exceptionHasBeenThrown = $true
            throw
        }
    }

    Begin {
        $__cmdletization_exceptionHasBeenThrown = $false
        try 
        {
            __cmdletization_BindCommonParameters $__cmdletization_objectModelWrapper $PSBoundParameters
            $__cmdletization_objectModelWrapper.BeginProcessing()
        }
        catch
        {
            $__cmdletization_exceptionHasBeenThrown = $true
            throw
        }
    }
        

    Process {
        try 
        {
            if (-not $__cmdletization_exceptionHasBeenThrown)
            {
    $__cmdletization_queryBuilder = $__cmdletization_objectModelWrapper.GetQueryBuilder()


    $__cmdletization_objectModelWrapper.ProcessRecord($__cmdletization_queryBuilder)
            }
        }
        catch
        {
            $__cmdletization_exceptionHasBeenThrown = $true
            throw
        }
    }
        

    End {
        try
        {
            if (-not $__cmdletization_exceptionHasBeenThrown)
            {
                $__cmdletization_objectModelWrapper.EndProcessing()
            }
        }
        catch
        {
            throw
        }
    }

    # .EXTERNALHELP Cim_DataProcess.cdxml-Help.xml
}
Microsoft.PowerShell.Core\Export-ModuleMember -Function 'Get-DataProcess'
        

