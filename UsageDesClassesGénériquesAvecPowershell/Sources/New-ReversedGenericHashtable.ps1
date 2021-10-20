function New-ReversedGenericHashtable{
    param(
        $InputObject
    )
<#
    $h = new-object 'System.Collections.Generic.Dictionary[String,Int]'
    $h.'Un'=1
    $h.'Deux'=2
    $h.'Trois'=3
    
    $Result=New-ReversedGenericHashtable $h
    $Result
    # Key Value
    # --- -----
    #   1 Un
    #   2 Deux
    #   3 Trois
    "$($Result.GetType())"
    #System.Collections.Generic.Dictionary[int,string]
#>

     #On manipule des informations du type
    $SourceType=$InputObject.GetType()

    if ($SourceType.IsGenericType -eq $false)
    { Throw 'InputObject doit être un type générique.' }

     # On distingue les deux erreurs
    if ($SourceType.IsGenericTypeDefinition -eq $true)
    { Throw 'InputObject doit être un type générique fermé.' }

     #On cherche à savoir si $inputObject implémente l'interface générique
     # IDictionary<TKey,TValue> ( qui elle même implémente System.Collections.Generic.IEnumerable<System.Collections.Generic.KeyValuePair<TKey,TValue>>)
    $isIDictionaryImplemented=$InputObject.GetType().GetInterfaces().Where({
        if ($_.isGenericType)
        { $_.GetGenericTypeDefinition().fullname -eq 'System.Collections.Generic.IDictionary`2'}
    }).Count -eq 1
    # Note MsDoc :
    #   L'interface IDictionary<TKey,TValue> est l'interface de base pour les collections génériques de paires clé/valeur.
    #   Chaque élément est une paire clé/valeur stockée dans un KeyValuePair<TKey,TValue> objet.

    if ($isIDictionaryImplemented -eq $false)
    { Throw 'InputObject n''est pas une collection générique de paires clé/valeur (IDictionary<TKey,TValue>).' }

     #On récupère les types utilisés pour créer la 'hashtable' générique
    $GenericArguments=$InputObject.GetType().GetGenericArguments()

     #Crée un type ouvert à partir de la classe System.Collections.Generic.KeyValuePair
     #Ici on sait que ce type générique à deux arguments de type; cf. 'System.Collections.Generic.IDictionary`2'
    $KeyValuePairType=[Type]'System.Collections.Generic.KeyValuePair`2'
    Write-debug "KeyValuePairType : $($KeyValuePairType.ToString())"
    Write-debug "KeyValuePairType est un type ouvert ? $($KeyValuePairType.IsGenericTypeDefinition -eq $true)"

     #Crée un type fermé (exemple: System.Collections.Generic.KeyValuePair<String,Int> ) à partir des arguments de type de $InputObject
     #C'est une classe générique différente mais les types des arguments sont identiques
    $DelegateInputParameterType=$KeyValuePairType.MakeGenericType($GenericArguments)
    Write-debug "DelegateInputParameter : $($DelegateInputParameterType.ToString())"
    Write-debug "DelegateInputParameter est un type fermé ? $($DelegateInputParameterType.IsGenericTypeDefinition -eq $false)"

    #On crée les foncteurs (delégués) nécessaires pour manipuler les argument de types de $InputObject
    #on sait, d'après 'System.Collections.Generic.IDictionary`2', que le functor à deux arguments de type
    $FunctorType=[Type]'Func`2'

     #L'ordre de la liste des paramètres correspond à celui
     # indiqué lors de la création de l'objet
    [Type[]] $ParametersType=@($DelegateInputParameterType,$GenericArguments[0])
    $KeyDelegateType=$FunctorType.MakeGenericType($ParametersType)
    Write-debug "Foncteur pour KeyDelegateType : $($KeyDelegateType)"

    [Type[]] $ParametersType=@($DelegateInputParameterType,$GenericArguments[1])
    $ValueDelegateType=$FunctorType.MakeGenericType($ParametersType)
    Write-debug "Foncteur pour ValueDelegateType : $($ValueDelegateType)"

     #Cast nécessaire des scriptblocks
    $KeyDelegate =  { $args[0].Key } -as $KeyDelegateType
    If ($null -eq $KeyDelegate)
    { Throw "Impossible to cast the 'Key' scriptblock to '$KeyDelegateType'."}

    $ValueDelegate ={ $args[0].Value} -as $ValueDelegateType
    If ($null -eq $ValueDelegate)
    { Throw "Impossible to cast the 'Value' scriptblock to '$ValueDelegate'."}


    #Bien que le paramétre $InputObject ne soit pas typé dans l'entête de la fonction, on manipule un PSObject
    #on doit donc récupérer l'objet encapsulé via la propriété PsObject.BaseObject
    #Sinon on a une erreur d'appel
    #
    #L'ordre des délégués est ici inversé puisque c'est l'objectif : la valeur devient la clé et inversement
    $Result=[Linq.Enumerable]::ToDictionary($InputObject.PsObject.BaseObject, $ValueDelegate,$KeyDelegate)
    if ("$SourceType" -notmatch '^System\.Collections\.Generic\.Dictionary\[')
    {
        #On récupère le 'nom court' du type : FullClassName[String,Int]
        # On n'utilise pas ici le système de réflexion de dotNet.
       $TargetTypeName="$SourceType"
        #On inverse <TKey,TValue> pour avoir <TValue,TKey>
        #Note:  on suppose que TKey,TValue ne sont pas des types génériques
        #       IDictionary<typeof(T), T> est impossible.
       $TargetTypeName=$TargetTypeName -replace '^(.*?)\[(.*?),(.*)\]$','$1[$3,$2]'

       Write-Debug "Tente un transtypage à la Powershell vers le type $TargetTypeName"
       #Peut appeler un constructeur utilisant un dictionnaire génèrique en paramètre.
       #Cf. https://devblogs.microsoft.com/powershell/understanding-powershells-type-conversion-magic/
       $Result=$Result -as [Type]$TargetTypeName
       If ($null -eq $Result)
       { Throw "Impossible to cast the type '$($Result.Gettype())' to  '$TargetTypeName'." }
    }
    Write-Output $Result -NoEnumerate
}
