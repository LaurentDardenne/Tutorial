function Example1
{
  [cmdletbinding()]
  param(
    [String]$name,
    [String]$path
  )

  DynamicParam
  {
     #Référence le contenu d'un paramètre 
    if ($path -match "^HKLM:")
    {
      $attributes = New-Object System.Management.Automation.ParameterAttribute -Property @{
                                ParameterSetName = "set1"
                                Mandatory = $false
                                }
      $attributeCollection = New-Object System.Collections.objectModel.Collection[System.Attribute] 
      $attributeCollection.Add($attributes)
      
      $dynParaml = New-Object  System.Management.Automation.RuntimeDefinedParameter "dp1",int,$attributeCollection
         
      $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
      $paramDictionary.Add("dp1",$dynParaml)
      return $paramDictionary
    }
  }

  End {
   $psboundparameters
   Write-Host "`$dp1=$dp1" 
   if ($psboundparameters.ContainsKey("dp1") )
    {Write-Host "[psboundparameters] dp1=$($psboundparameters.dp1)"}
   if ((test-path variable:dynParaml))
    {Write-Host "[dynParaml] dp1=$($dynParaml.Value)" }
  }
}

example1 -name "test" -dp1 5 -path "hklm:\"
example1 -name "test" -dp1 5 -path "c:\"