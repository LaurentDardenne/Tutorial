function New-ReversedHashtable {
    param($Hashtable)
<#
$h=@{}
$h.'Un'=1
$h.'Deux'=2
$h.'Trois'=3

$Result=New-ReversedHashtable $h
$Result
#>

    if(-not ( ($Hashtable -is [System.Collections.Hashtable]) -OR ($Hashtable-is [System.Collections.Specialized.OrderedDictionary])) )
    { Throw "The argument `$Hashtable([$($Hashtable.GetType().Fullname)]) the argument must be one of the following types : [System.Collections.Hashtable], [System.Collections.Specialized.OrderedDictionary]" }
    $isReadOnly=$Hashtable.IsReadOnly

    if ($isReadOnly)
    { $ReverseHashtable=[ordered]@{} }
    else
    { $ReverseHashtable=@{} }

    Foreach ($Current in $Hashtable.GetEnumerator())
    {
        $Key=$Current.Key
        $Value=$Current.Value
        if ($null -eq $Value) #ArgumentNullException
        { Throw "Impossible to reverse the hashtable. The key '$Key' has a value null.The value of a key cannot be null." }
        $ValueType=$Value.Gettype()

        if ( ($Value -is [string]) -or $ValueType.isPrimitive)
        {
            try {
              $ReverseHashtable.Add($Current.Value,$Key)
            } catch [System.ArgumentException] { #ArgumentException
              Throw "Impossible to reverse the hashtable. Key values '$($Current.Value)'' are duplicated."
            }
        }
        else
        { Throw "Impossible to reverse the hashtable. The value of the key '$Key' is not a scalar or a string :'$ValueType'." }
    }

    if ($isReadOnly)
    { return ,$ReverseHashtable.AsReadOnly() }
    return ,$ReverseHashtable
}