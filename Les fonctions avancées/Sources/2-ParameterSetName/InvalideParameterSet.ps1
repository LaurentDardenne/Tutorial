Function InvalideParameterSet{
  Param (
   [Parameter(ParameterSetName="Fonctionnalite1")]
   [Parameter(ParameterSetName="Fonctionnalite3")]
   [Switch] $A,
   [Parameter(ParameterSetName="Fonctionnalite1")]
   [Parameter(ParameterSetName="Fonctionnalite2")]
   [Switch] $B,
   [Parameter(ParameterSetName="Fonctionnalite2")]
   [Parameter(ParameterSetName="Fonctionnalite3")]
   [Switch] $C)
   
   Write-Host "Traitement..."
}

 #Les appels suivants ne fonctionnent pas car PowerShell ne sait pas de quel jeu de paramètres il s’agit. 
 #Par exemple pour –A est-ce qu’il s’agit de la Fonctionnalite1 ou de la Fonctionnalite3 ?
InvalideParameterSet –A; InvalideParameterSet –B; InvalideParameterSet –C

 #Ceux-ci fonctionnent car on sait de quel jeu il s’agit :
InvalideParameterSet –A -B; InvalideParameterSet –B -C; InvalideParameterSet -A –C
