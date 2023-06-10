function isAdmin {  
  $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()  
   $principal = new-object `
                 System.Security.Principal.WindowsPrincipal($identity)  
   $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator  
  $principal.IsInRole($admin)  
} 

function Publish-Application{ 
  [cmdletbinding()]
  Param ([String]$Name)

  DynamicParam 
  {
   Write-Warning "Traitement de la clause DynamicParam"
   if (isAdmin) 
    {
      Write-Warning "Cr�ation du param�tre Reboot "
      $attributes = new-object ` System.Management.Automation.ParameterAttribute 
      $attributes.ParameterSetName = 'Admin' 
      $attributes.Mandatory = $false 
      $attributeCollection = new-object ` System.Collections.ObjectModel.Collection[System.Attribute] 
      $attributeCollection.Add($attributes)
      $dynParam1 = new-object ` System.Management.Automation.RuntimeDefinedParameter(
                      "Reboot",
                      [System.Management.Automation.SwitchParameter],
                      $attributeCollection)
  
      $paramDictionary = new-object ` System.Management.Automation.RuntimeDefinedParameterDictionary 
      $paramDictionary.Add("Reboot", $dynParam1) 
      $paramDictionary
    }#if 
   #Else : renvoi implicitement $null
  }#DynamicParam

  Begin {
   Write-Host "Traitement du bloc Begin" �fore white
  }#begin
  
  End{
   # $S="Liste des param�tres dynamique : "
   # Write-host "$ $($pscmdlet.GetDynamicParameters().Keys)"
   $PSBoundParameters
   Write-Host "Traitement du bloc End" �fore Green
   Write-Host "Installation de l'application $Name."
   [switch]$Reboot= $null
   if ($PSBoundParameters.TryGetValue('Reboot',[REF]$Reboot) )
   { 
    if ($Reboot) #Peut �tre � false -reboot:false
     {Write-Host "Reboot du poste apr�s traitement." �fore white }
   }
  }#end
}#Publish-Application

Publish-Application -name "OpenOffice" -Reboot

#function isAdmin { $false}
Publish-Application -name "OpenOffice" -Reboot 