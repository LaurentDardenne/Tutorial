#Une fonction permettant de vérifier si un objet implémente l'interface générique IEnumerable et ce sans avoir à tester un type fermé

${Function:Test-GenericIEnumerable}=.{
    #On recherche le type ouvert de l'interface générique IEnumerable
    $GenericIEnumerable=[Type]'System.Collections.Generic.IEnumerable`1'

    Return {
     #La variable $InputObject implémente-t-elle l'interface générique IEnumerable ?
      param(
        [ValidateNotNull()]
        $InputObject
      )
        foreach ($Interface in $InputObject.GetType().GetInterfaces())
        {
           if ($Interface.IsGenericType)
           {
                 #On suppose une seule implémentation de l'interface générique IEnumerable (https://stackoverflow.com/a/7852650)
               if ($Interface.GetGenericTypeDefinition() -eq $GenericIEnumerable)
               {return $true}
           }
        }
        return $false
    }.GetNewClosure()
}
<#
[void][Reflection.Assembly]::LoadWithPartialName("System.Data.DataSetExtensions");
$Dt = New-Object System.Data.DataTable
[void]$Dt.Columns.Add( 'C1')
[void]$Dt.Columns.Add( 'C2')
[void]$Dt.Rows.Add( '1','2')
[void]$Dt.Rows.Add( 'Y','Z')

$Dt.Rows -is [System.Collections.IEnumerable]
#True
Test-GenericIEnumerable $Dt.Rows
#False

 #$Dt.Rows est une collection mais pas une collection générique

#>