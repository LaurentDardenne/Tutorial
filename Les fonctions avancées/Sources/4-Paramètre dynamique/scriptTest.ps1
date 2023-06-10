[CmdletBinding()]
   Param (
     [Parameter(Position=0,Mandatory=$true,HelpMessage="Objet à analyser.")]
    [String]$Name)
    

  DynamicParam 
  {
   Write-Warning "Traitement de la clause DynamicParam"
   if (isadmin) 
    {
      Write-Warning "Création du paramètre Reboot "
      $attributes = new-object System.Management.Automation.ParameterAttribute 
      $attributes.ParameterSetName = 'Admin' 
      $attributes.Mandatory = $false 
      $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute] 
      $attributeCollection.Add($attributes)
      $dynParam1 = new-object System.Management.Automation.RuntimeDefinedParameter(
                      "Reboot",
                      [System.Management.Automation.SwitchParameter],
                      $attributeCollection)
  
      $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary 
      $paramDictionary.Add("Reboot", $dynParam1) 
      $paramDictionary
    }#if 
   #Else : renvoi implicitement $null
  }#DynamicParam

  Begin {
   Write-Host "Traitement du bloc Begin" –fore white
  }#begin
  
  End{
   $PScmdlet|gm
   Write-Host "Traitement du bloc End" –fore Green
   Write-Host "Installation de l'application $Name."
   [switch]$Reboot= $null
   if ($PSBoundParameters.TryGetValue('Reboot',[REF]$Reboot) )
   { 
    if ($Reboot) #Peut être à false -reboot:false
     {Write-Host "Reboot du poste après traitement." –fore white }
   }
  }#end
