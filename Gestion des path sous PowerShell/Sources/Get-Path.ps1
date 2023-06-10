#Test de manipulation de nom de chemin
function Get-path {
#from https://connect.microsoft.com/PowerShell/feedback/details/816367/need-dedicated-parameter-attributes-to-simplify-proper-path-handling
[CmdletBinding(DefaultParameterSetName="Path")]
    param(
        [Parameter(Mandatory,
                 Position=0,
                 ParameterSetName="Path",
                 ValueFromPipeline=$true,
                 ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
         #[SupportsWildcards()]   #PS v3, utilisé par le système de documentation
        [string[]]
        $Path,
    
        [Alias("PSPath")]
        [Parameter(Mandatory,
                 Position=0,
                 ParameterSetName="LiteralPath",
                 ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
         #Par convention -LiteralPath ne supporte pas les Wildcards
        [string[]]
        $LiteralPath
    )

    Process {
        if ($psCmdlet.ParameterSetName -eq "Path") {
            if (!(Test-Path $Path)) {
                #Modification : on souhaite récupèrer directement les exceptions déclenchées par Test-Path
               Write-host "`t [Path] Cannot find path '$Path' because it does not exist."
            }
            $resolvedPaths = $Path | Resolve-Path | Convert-Path
        }
        else {
            if (!(Test-Path -LiteralPath $LiteralPath)) {
              Write-host "`t [LiteralPath]  Cannot find path '$Path' because it does not exist."
            }
            $resolvedPaths = Convert-Path -LiteralPath $LiteralPath
        }
        foreach ($rpath in $resolvedPaths) {
            "process $rpath"
        }
    }          
}
