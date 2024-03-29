#http://blogs.msdn.com/powershell/archive/2009/03/13/dir-a-d.aspx

$flags = @{
    [char]'a' = [IO.FileAttributes]::Archive
    [char]'d' = [IO.FileAttributes]::Directory
    [char]'h' = [IO.FileAttributes]::Hidden
    [char]'i' = [IO.FileAttributes]::NotContentIndexed
    [char]'l' = [IO.FileAttributes]::ReparsePoint
    [char]'r' = [IO.FileAttributes]::ReadOnly
    [char]'s' = [IO.FileAttributes]::System
}

function get-childitem
{
    <#
    .SYNOPSIS
        Gets the items and child items in one or more specified locations.
        
    .DESCRIPTION
        For full details, try 'get-help -Category cmdlet get-childitem'
        
        This function calls the cmdlet, but adds some parameters to act
        more like the 'dir' command in cmd.exe.
        
    .PARAMETER Attribute

        Displays files with specified attributes.

            D  Directories                R  Read-only files
            H  Hidden files               A  Files ready for archiving
            S  System files               I  Not content indexed files
            L  Reparse Points             -  Prefix meaning not    

    .EXAMPLE
    
        C:\PS>get-childitem -a d
   
        Returns directories

    .EXAMPLE

        C:\PS>get-childitem -a:h-d
        
        Returns hidden files that are not directories.        
    #>
    [CmdletBinding(DefaultParameterSetName='Items', SupportsTransactions=$true)]
    param(
        [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $Path,

        [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]]
        $LiteralPath,

        [Parameter(Position=1)]
        [string]
        $Filter,

        [string[]]
        $Include,

        [System.String[]]
        $Exclude,
        
        [System.String]
        $Attribute = '',
        
        [Switch]
        [Alias("s")]
        $Recurse,

        [Switch]
        $Force,
        
        [Switch]
        $Name)

    dynamicparam
    {
        [void]$PSBoundParameters.Remove('Attribute')
        $argList = @($psboundparameters.getenumerator() | % { "-$($_.Key)"; $_.Value })
        
        $wrappedCmd = Get-Command Get-ChildItem -Type Cmdlet -ArgumentList $argList
        $providerParams = @($wrappedCmd.Parameters.GetEnumerator() | Where-Object { $_.Value.IsDynamic })
        if ($providerParams.Length -gt 0)
        {
            $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
            foreach ($param in $providerParams)
            {
                $param = $param.Value
                $dynParam1 = new-object System.Management.Automation.RuntimeDefinedParameter $param.Name, $param.ParameterType, $param.Attributes
                $paramDictionary.Add($param.Name, $dynParam1)            
            }
            
            return $paramDictionary
        }
    }
    
    begin
    {
        try {
            [void]$PSBoundParameters.Remove('Attribute')
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
            if ($Attribute -ne '')
            {
                $includeMask = 0
                $excludeMask = 0
                
                [bool]$onOrOff = $true
                foreach ($char in $Attribute.GetEnumerator())
                {
                    if ($char -eq '-')
                    {
                        $onOrOff = $false
                    }
                    else
                    {
                        if ($flags[$char] -eq $null)
                        {
                            throw "Attribute '$char' not supported"
                        }
                        if ($onOrOff)
                        {
                            $includeMask = $includeMask -bor $flags[$char]
                        }
                        else
                        {
                            $excludeMask = $excludeMask -bor $flags[$char]
                        }
                        $onOrOff = $true
                    }
                }

                if ($includeMask -band [IO.FileAttributes]::Hidden) {
                    $PSBoundParameters.Force = $true
                }

                $scriptCmd = {& $wrappedCmd @PSBoundParameters |
                    ? { $_.PSProvider.Name -ne 'FileSystem' -or
                        ((($_.Attributes -band $includeMask) -eq $includeMask) -and
                         (($_.Attributes -band $excludeMask) -eq 0))
                    }
                }
            }
            else
            {
                $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            }
            
            $steppablePipeline = $scriptCmd.GetSteppablePipeline()
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
}
