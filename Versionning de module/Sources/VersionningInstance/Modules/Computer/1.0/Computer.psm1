#Computer.psm1

 #Contient les informations de versionning du module courant 
$script:ModuleSpecification=(ConvertTo-ModuleSpecification -Data ([system.io.Path]::ChangeExtension($MyInvocation.MyCommand.ScriptBlock.Module.path,$ManifestExtension)))

Write-Debug "ModuleSpecification : $script:ModuleSpecification"
 
class Computer {
    [string] $Nom
    [string] $OS
    [string] $Ver='1.0'

    [Void] GetVersion([Microsoft.PowerShell.Commands.ModuleSpecification] $value) {
      Write-host "Current=$script:ModuleSpecification"
    }
}
