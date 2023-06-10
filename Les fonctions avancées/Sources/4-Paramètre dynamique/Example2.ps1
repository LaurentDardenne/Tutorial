function Exemple2 { 
 [cmdletbinding()]
  Param (
      [String]$Name,
      [String]$path
  )

  DynamicParam 
  {
    Write-Warning "Traitement de la clause DynamicParam"
     #R�f�rence un contexte, la localisation courante
    if ((Get-Location).Provider.Name �eq "FileSystem")
    {
        Write-Warning "Cr�ation du param�tre dp1 "
      $attributes = new-object System.Management.Automation.ParameterAttribute 
      $attributes.ParameterSetName = 'pset1' 
      $attributes.Mandatory = $false 
      $attributeCollection = new-object `
                             System.Collections.ObjectModel.Collection[System.Attribute] 
      $attributeCollection.Add($attributes)
      $dynParam1 = new-object System.Management.Automation.RuntimeDefinedParameter(
                               "dp1",
                               [Int32],
                               $attributeCollection)
  
      $paramDictionary = new-object `
                          System.Management.Automation.RuntimeDefinedParameterDictionary 
      $paramDictionary.Add("dp1", $dynParam1) 
      $paramDictionary 
    } 
  }
  end{
   [Int]$Dp1= $null
   if ($PSBoundParameters.TryGetValue('Dp1',[REF]$Dp1) )
   { 
    if ($Dp1) 
     {Write-Host "Valeur du param�tre dynamique `$dp1=$Dp1" �fore white }
   }
  }
}#Sample

function test {
   #Tous les appels r�ussissent avec C:\temp
 Exemple2 -name "test" -dp1 5
   #Le suivant r�ussi avec HKLM:\
 Exemple2 -name "test" -path "C:\"
 Exemple2 -name "test" -dp1 5 -path "C:\"
  #Le suivant r�ussi avec HKLM:\
 Exemple2 -name "test" -path "hklm:\"
 Exemple2 -name "test" -dp1 5 -path "hklm:\"
}
cd C:\temp;Test 
cd "hklm:\";Test
