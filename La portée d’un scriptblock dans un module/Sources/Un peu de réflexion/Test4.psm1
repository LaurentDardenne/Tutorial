#extracted from Pester module
function Set-ScriptBlockScope
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromSessionState')]
        [System.Management.Automation.SessionState]
        $SessionState,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromSessionStateInternal')]
        $SessionStateInternal
    )

    $flags = [System.Reflection.BindingFlags]'Instance,NonPublic'

    if ($PSCmdlet.ParameterSetName -eq 'FromSessionState')
    {
        $SessionStateInternal = $SessionState.GetType().GetProperty('Internal', $flags).GetValue($SessionState, $null)
    }

    [scriptblock].GetProperty('SessionStateInternal', $flags).SetValue($ScriptBlock, $SessionStateInternal, $null)
}

#extracted from Pester module
function Get-ScriptBlockScope
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )

    $flags = [System.Reflection.BindingFlags]'Instance,NonPublic'
    [scriptblock].GetProperty('SessionStateInternal', $flags).GetValue($ScriptBlock, $null)
}

$SbOuter=New-SbOuter
Remove-item function:New-SbOuter

 #Récupère l'état de session de l'appelant
$SessionSateCaller=Get-ScriptBlockScope $SbOuter

$SbPrivate={
     Write-Warning "Dans SbPrivate maVar=$MaVar. Crée la variable `FromModule dans la portée de l'appelant"
      #le SB est exécuté dans sa propre portée, on adresse celle du parent, c'est à dire l'état de session appelant le module      
     New-Variable -Name 'FromModule' -Value 'Créée par un module' -scope 1
} 
 #Affecte l'état de session de l'appelant à un script déclaré dans le module
Set-ScriptBlockScope -ScriptBlock $SbPrivate -SessionStateInternal $SessionSateCaller
&$SbPrivate
#.$SbPrivate
