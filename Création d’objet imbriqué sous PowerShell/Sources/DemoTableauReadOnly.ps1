function New-VariableInScope {
   #On crée une variable dans une nouvelle portée
  [int[]]$Tableau=@(1..5)
   # On renvoi un objet de type PSVariable
  Get-Variable Tableau
}

$V= New-VariableInScope
$V.Options="ReadOnly"
$PSVP = New-Object System.Management.Automation.PSVariableProperty ($V)
$UnObjet = New-Object PSCustomObject
$UnObjet.PSObject.Members.Add($PSVP)
$UnObjet.Tableau +=99
#[. : Impossible de remplacer la variable Tableau, car elle est constante ou en lecture seule.
$UnObjet.Tableau
#1..5
$UnObjet.Tableau[0]=99
$UnObjet.Tableau
#99..5

Function New-ArrayReadOnly {
 param([ref]$Tableau)
   #La méthode AsReadOnly retourne un wrapper en lecture seule pour le tableau spécifié.
   #On recherche les informations de la méthode publique spécifiée.  
  [System.Reflection.MethodInfo] $Methode = [System.Array].GetMethod("AsReadOnly")
  
   #Crée une méthode générique
   #On précise le même type que celui déclaré pour la variable $Tableau
  $MethodeGenerique = $Methode.MakeGenericMethod($Tableau.Value.GetType().GetElementType())
  
   #Appel la méthode générique créée qui renvoi 
   #une collection en lecture seule, par exemple :
   # [System.Collections.ObjectModel.ReadOnlyCollection``1[System.String]]
  $TableauRO=$MethodeGenerique.Invoke($null,@(,$Tableau.Value.Clone()))
  ,$TableauRO
} #New-ArrayReadOnly

function New-VariableInScope {
   #On crée une variable dans une nouvelle portée
  [int[]]$Tab=@(1..5)
      #protége les éléments du tableau
  $Tableau=New-ArrayReadOnly ([ref]$Tab)

   # On renvoi un objet de type PSVariable
  Get-Variable Tableau
}

$V= New-VariableInScope
$V.Options="ReadOnly"
$PSVP = New-Object System.Management.Automation.PSVariableProperty ($V)
$UnObjet = New-Object PSCustomObject
$UnObjet.PSObject.Members.Add($PSVP)

$UnObjet.Tableau +=99
#[. : Impossible de remplacer la variable Tableau, car elle est constante ou en lecture seule.

$UnObjet.Tableau[0]=99
# [ : Impossible d'indexer dans un objet de type System.Collections.ObjectModel.ReadOnlyCollection`1[[System.Int32, mscor
# lib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]].
