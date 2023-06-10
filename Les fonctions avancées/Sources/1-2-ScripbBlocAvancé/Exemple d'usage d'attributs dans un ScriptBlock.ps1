#AttributsWithSB
$SB={
  param (  
    [Parameter(Position=0, Mandatory=$false,ValueFromPipeLine=$true)]  
   [string] $Domain = "Cookham" ,      
    [Parameter(Position=1, Mandatory=$false)]  
   [string] $Computer = "Cookham8",  
    [Parameter(Position=2, Mandatory=$false, ValueFromRemainingArguments=$true)]  
    [string] $User     = "tfl"
  )  
  $pscmdlet|gm|Sort membertype,name 
}

&$sb

function isAdmin {  
  $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()  
   $principal = new-object `
                 System.Security.Principal.WindowsPrincipal($identity)  
   $admin = [System.Security.Principal.WindowsBuiltInRole]::Administrator  
  $principal.IsInRole($admin)  
} 

$sbPublish_Application={ 
  [cmdletbinding()]
  Param ([String]$Name)

  DynamicParam 
  {
   Write-Warning "Traitement de la clause DynamicParam"
   if (isAdmin) 
    {
      Write-Warning "Création du paramètre Reboot "
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
   Write-Host "Traitement du bloc Begin" –fore white
  }#begin
  
  End{
   $S="Liste des paramètres dynamique : "
   # Write-host "$ $($pscmdlet.GetDynamicParameters().Keys)"
   $PSBoundParameters
   Write-Host "Traitement du bloc End" –fore Green
   Write-Host "Installation de l'application $Name."
   [switch]$Reboot= $null
   if ($PSBoundParameters.TryGetValue('Reboot',[REF]$Reboot) )
   { 
    if ($Reboot) #Peut être à false -reboot:false
     {Write-Host "Reboot du poste après traitement." –fore white }
   }
  }#end
}#sbPublish_Application

&$sbPublish_Application OpenOffice


$sbTestAttenuationRisque={
  [CmdletBinding( 
      SupportsShouldProcess=$True, 
      ConfirmImpact="Medium")] 
   param( 
    [Parameter(
      Position=0,
      Mandatory = $true,
      ValueFromPipeline = $true)] 
    $ID, 
    [Switch]$Force) 

  Begin 
  {
    Function Traitement($Object) {
     Write-Host "Traite $Object" 
    }
  }#Begin 
  
  Process 
  { 
    # ShouldProcess(string verboseDescription, string verboseWarning, string caption) :
    #   Affiche une description de l'opération à exécuter, un message de warning incluant 
    #   la question et un titre du message de warning.
    #
   # Avec $ErrorActionPreference="Inquire" et présence du paramètre -Confirm.
   if ($psCmdlet.shouldProcess("verboseDescription", "verboseWarning","Caption"))
    {
      if ($force –or $pscmdlet.ShouldContinue($_, "Opération Traitement"))
       { Traitement $_}
    }
   else {Write-host "Pas de traitement avec SouldProcess"} 
  }#Process 
  
  End 
  { 
  }#End
}

 #Exemple de double confirmation a usein d'un scriptblock
1..3|&$sbTestAttenuationRisque -whatif
1..3|&$sbTestAttenuationRisque -confirm