#James Brundage [MSFT]
#http://blogs.msdn.com/powershell/archive/2007/09/24/get-wmihelp-search-wmihelp.aspx
If ($args)
{
'
This script will add a set of functions for getting help about WMI classes
 when you dot-source it. You should runs this script as
. .\Add-WmiHelpFunctions.ps1

Once the functions are loaded, you can use them like:

Get-WmiHelp Win32_Process    #Gets the help on the Win32_Process class
Search-WmiHelp {$_ -like "*Process*"}

'
return
}

# Returns the namespace containing localized
# class descriptions in the current language
function Get-LocalizedNamespace($namespace, [int]$cultureID = (Get-Culture).LCID)
{
    #First, get a list of all localized namespaces under the current namespace
    $localizedNamespaces = Get-WmiObject -NameSpace $namespace -Class "__Namespace" | where {$_.Name -like "ms_*"}
    if ($localizedNamespaces -eq $null)
    {
        if (-not $quiet)
        {
            Write-Warning "Could not get a  list of localized namespaces"
        }
        return
    }

    return ("$namespace\ms_{0:x}" -f $cultureID)
}


#Retrieves a dictionary of class descriptions for a given Wmi path
function Get-WmiClassInfo([string]$classLocation)
{
    if ((Test-Path variable:cachedWmiInfo) -eq $false)
    {
	    #This is a hashtable containing the localized information for Wmi
	    $script:cachedWmiInfo = @{};
    }

    if (($script:cachedWmiInfo.ContainsKey($classLocation) -eq $false))
    { 
        $script:cachedWmiInfo.Add($classLocation, @{}) 
    }
    else
    {
        # If we already know the information, don't waste time looking it up again.

        return $script:cachedWmiInfo[$classLocation]	    
    }

    $localizedClass = [WmiClass]$classLocation   
    $outputDictionary = @{}    
    $outputDictionary.Description = $localizedClass.psBase.Qualifiers.Item("Description").Value.Trim();

    $outputDictionary.Properties = @{}
    foreach ($property in $localizedClass.psBase.Properties)
    {
        $outputDictionary.Properties.Add($property.Name, $property.Qualifiers.Item("Description").Value.Trim())
    }

    $outputDictionary.Methods = @{}
    foreach ($method in $localizedClass.psBase.Methods)
    {
        $outputDictionary.Methods.Add($method.Name, $method.Qualifiers.Item("Description").Value.Trim())
    }

    if (($outputDictionary.Properties.Count -eq 0) `
        -and ($outputDictionary.Methods.Count -eq 0)) {
        $script:cachedWmiInfo.Remove($classLocation)    
        return $null
    } else {
        $script:cachedWmiInfo[$classLocation] = $outputDictionary
        return $outputDictionary
    }

    trap
    {	
	Write-Verbose "Class description could not be retrieved + $_"
        continue;
    }
}

#Get Wmi function.  Retrieves localized help for a given Wmi class
function Get-WmiHelp(
        [string]$class = $(throw "No classname provided"),
	[string]$namespace="root\cimv2",
        [int]$cultureID = (Get-Culture).LCID
)
{
    $localizedNamespace = Get-LocalizedNamespace $namespace $cultureID
    $classLocation= $localizedNamespace + ':' + $class
    return (Get-WmiClassInfo $classLocation)
}

function Search-WmiHelp(
        [ScriptBlock]$descriptionExpression={},

        [ScriptBlock]$methodExpression={}, 
        [ScriptBlock]$propertyExpression={},
	$namespaces="root\cimv2",
        $cultureID = (Get-Culture).LCID,
        [switch]$list
)
{    

    $resultWmiClasses = @{}
   
    foreach ($namespace in $namespaces)
    {
        #First, get a list of all localized namespaces under the current namespace
	
        $localizedNamespace = Get-LocalizedNamespace $namespace
        if ($localizedNamespace -eq $null)
        {
    	    Write-Verbose "Could not get a list of localized namespaces"
            return
	}

        $localizedClasses = Get-WmiObject -NameSpace $localizedNamespace -Query "select * from meta_class"
        $count = 0;
        foreach ($WmiClass in $localizedClasses)
        {
            $count++
            Write-Progress "Searching Wmi Classes" "$count of $($localizedClasses.Count)" -Perc ($count*100/$localizedClasses.Count)
            $classLocation= $localizedNamespace + ':' + $WmiClass.__Class
            $classInfo = Get-WmiClassInfo $classLocation
            [bool]$found = $false
            if ($classInfo -ne $null)
            {
                if (! $resultWmiClasses.ContainsKey($classLocation))
                {
                    $resultWmiClasses.Add($wmiClass.__Class, $classInfo)
                }

                $descriptionMatch = [bool]($classInfo.Description | where $descriptionExpression)
                $methodMatch = [bool]($classInfo.Methods.GetEnumerator() | where $methodExpression)
                $propertyMatch = [bool]($classInfo.Properties.GetEnumerator() | where $propertyExpression)

                $found = $descriptionMatch -or $methodMatch -or $propertyMatch
                
                if (! $found)
                {
                    $resultWmiClasses.Remove($WmiClass.__Class)
                }
            }
      	}      	    
    }

    
    if ($list)
    {
        $resultWmiClasses.Keys | sort
    } else {
        $resultWmiClasses.GetEnumerator() | sort Key
    }
}

