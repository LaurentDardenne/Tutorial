function Get-NormalizedFileSystemPath
{
 #http://gallery.technet.microsoft.com/scriptcenter/Normalize-file-system-5d33985a
    <#
    .Synopsis
       Normalizes file system paths.
    .DESCRIPTION
       Normalizes file system paths.  This is similar to what the Resolve-Path cmdlet does, except Get-NormalizedFileSystemPath also properly handles UNC paths and converts 8.3 short names to long paths.
    .PARAMETER Path
       The path or paths to be normalized.
    .PARAMETER IncludeProviderPrefix
       If this switch is passed, normalized paths will be prefixed with 'FileSystem::'.  This allows them to be reliably passed to cmdlets such as Get-Content, Get-Item, etc, regardless of Powershell's current location.
    .EXAMPLE
       Get-NormalizedFileSystemPath -Path '\\server\share\.\SomeFolder\..\SomeOtherFolder\File.txt'

       Returns '\\server\share\SomeOtherFolder\File.txt'
    .EXAMPLE
       '\\server\c$\.\SomeFolder\..\PROGRA~1' | Get-NormalizedFileSystemPath -IncludeProviderPrefix

       Assuming you can access the c$ share on \\server, and PROGRA~1 is the short name for "Program Files" (which is common), returns:

       'FileSystem::\\server\c$\Program Files'
    .INPUTS
       String
    .OUTPUTS
       String
    .NOTES
       Paths passed to this command cannot contain wildcards; these will be treated as invalid characters by the .NET Framework classes which do the work of validating and normalizing the path.
    .LINK
       Resolve-Path
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath', 'FullName')]
        [string[]]
        $Path,

        [switch]
        $IncludeProviderPrefix
    )

    process
    {
        foreach ($_path in $Path)
        {
            $_resolved = $_path

            if ($_resolved -match '^([^:]+)::')
            {
                $providerName = $matches[1]

                if ($providerName -ne 'FileSystem')
                {
                    Write-Error "Only FileSystem paths may be passed to Get-NormalizedFileSystemPath.  Value '$_path' is for provider '$providerName'."
                    continue
                }

                $_resolved = $_resolved.Substring($matches[0].Length)
            }

            if (-not [System.IO.Path]::IsPathRooted($_resolved))
            {
                $_resolved = Join-Path -Path $PSCmdlet.SessionState.Path.CurrentFileSystemLocation -ChildPath $_resolved
            }

            try
            {
                $dirInfo = New-Object System.IO.DirectoryInfo($_resolved)
            }
            catch
            {
                $exception = $_.Exception
                while ($null -ne $exception.InnerException)
                {
                    $exception = $exception.InnerException
                }

                Write-Error "Value '$_path' could not be parsed as a FileSystem path: $($exception.Message)"

                continue
            }
    
            $_resolved = $dirInfo.FullName

            if ($IncludeProviderPrefix)
            {
                $_resolved = "FileSystem::$_resolved"
            }

            Write-Output $_resolved
        }
    } # process

} # function Get-NormalizedFileSystemPath
