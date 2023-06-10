Function Get-ChildItemProxy {
[CmdletBinding(DefaultParameterSetName='Items', SupportsTransactions=$true)]
param(
    [Parameter(ParameterSetName='Items', Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    ${Path},

    [Parameter(ParameterSetName='LiteralItems', Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')]
    [System.String[]]
    ${LiteralPath},

    [Parameter(Position=1)]
    [System.String]
    ${Filter},

    [System.String[]]
    ${Include},

    [System.String[]]
    ${Exclude},

    [Switch]
    ${Recurse},

    [Switch]
    ${Force},

    [Switch]
    ${Name},
    
    [Switch] #Ajout
    ${ContainersOnly},
    
    [Switch] #Ajout
    ${NoContainersOnly}
    )

begin
{
    try {
        $outBuffer = $null
        if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer) -and $outBuffer -gt 1024)
        {
            $PSBoundParameters['OutBuffer'] = 1024
        }

        $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Get-ChildItem', [System.Management.Automation.CommandTypes]::Cmdlet)
        
        if ($ContainersOnly)
        {
              #On supprime notre paramètre qui n'est pas connu de la commande d'origine
            [Void]$PSBoundParameters.Remove("ContainersOnly")
            $scriptCmd = {& $wrappedCmd @PSBoundParameters | Where-Object {$_.PSIsContainer -eq $true}}
            
        } elseif ($NoContainersOnly)
               {
                    #On supprime notre paramètre qui n'est pas connu de la commande d'origine
                   [Void]$PSBoundParameters.Remove("NoContainersOnly")
                   $scriptCmd = {& $wrappedCmd @PSBoundParameters | Where-Object {$_.PSIsContainer -eq $false}}
               }    
        else
        {
             #crée un scriptblock
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
        }

        $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
        write-host "[$($myInvocation.MyCommand)-Begin]: before"
        $steppablePipeline.Begin($PSCmdlet)
        write-host "[$($myInvocation.MyCommand)-Begin]: After"
    } catch {
        throw
    }
}
 #on déclare un bloc process afin de pouvoir ajouter ou modifier l'objet transmis au cmdlet
 #c'est un principe de l'héritage  NON  c'est faux ici
 #on ne manipule pas les objets traités par le cmdlet mais les objets qu'on lui passe en argument via le pipeline
process
{
    try {
        write-host "[$($myInvocation.MyCommand)-Process] Before : Traite l'objet $_"
         #un seul passage dans le bloc process du cmdlet on exécute : $_|cmdlet 
        $result=$steppablePipeline.Process($_)
         #$Résult est vide car l'appel précédent écrit dans le pipe de ce script
        write-host "[$($myInvocation.MyCommand)-Process] After: Result = $((gv result).Value -eq $null)"
         #Ajout/Modification
    } catch {
        throw
    }
}

end
{
    try {
        write-host "[$($myInvocation.MyCommand)-End] Before $input"
        $steppablePipeline.End()
        write-host "[$($myInvocation.MyCommand)-End] After $input"
    } catch {
        throw
    }
}
 # Redirige l'aide sur l'aide du cmdlet d'origine
<#

.ForwardHelpTargetName Get-ChildItem
.ForwardHelpCategory Cmdlet

#>

}

Get-ChildItemProxy -ContainersOnly
"C:\"|Get-ChildItemProxy -noContainersOnly|% {write-host "Itération Pipe : $_" -fore green}
"HKLM:\"|Get-ChildItemProxy -ContainersOnly|% {write-host "Itération Pipe : $_" -fore green}