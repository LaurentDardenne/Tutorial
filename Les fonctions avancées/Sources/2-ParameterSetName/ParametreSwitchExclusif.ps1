#Impl�mentation de switchs exclusifs, � l'aide de jeux de param�tre 
#On doit pr�ciser au moins un des trois switchs et un seul.

function ParametreSwitchExclusif{
  Param (
   [Parameter(ParameterSetName="Format")]
   [switch] $Format,
   [Parameter(ParameterSetName="Type")] 
   [switch] $Type,
   [Parameter(ParameterSetName="Assembly")]
   [switch] $Assembly)
    
   Write-Host $PsCmdlet.ParameterSetName 
}

 #erreur
ParametreSwitchExclusif
ParametreSwitchExclusif -format -type -assembly
ParametreSwitchExclusif -type -assembly
 #Ok
ParametreSwitchExclusif -assembly
ParametreSwitchExclusif -format
