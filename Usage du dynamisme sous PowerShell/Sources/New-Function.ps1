Function New-Function {
           #($Name, $properties) on utilise Args 
           
#Auteur : Doug Finke
# From  : http://dougfinke.com/blog/index.php/2009/09/12/powershell-function-factory/
#
# Création dynamique de fonction créant des objets personnalisés.
#par défaut la fonction est créée dans la portée globale, 
# si on utilise le dotsourcing la fonction est créée dans la porté locale
#
#Exemple :
# New-Function 'New-Personne' 'Nom Prénom Adresse Ville CodePostal'            
# $Personne=New-Personne Durand Pierre -CodePostal 59100
#
# . New-Function 'New-Personne' 'Nom Prénom Adresse Ville CodePostal'            
# $Personne=New-Personne Durand Pierre -CodePostal 59100

 #On crée un scriptbloc afin de créer une porté locale
 # Il renvoi le code de la fonction à créer
 
$sbNewFunction={
     #On ne déclare pas de paramètre pour cette fonction
     #et ce afin d'éviter un écrasement de variable existante si on
     #appel cette fonction en dotsourcing. 
    $Name=((gv Args -scope 1).value)[0]
     Test-Variable (gv Name) String -strict -TestEmptyString
    $Properties=((gv Args -scope 1).value)[1]
     Test-Variable (gv Properties) String -strict -TestEmptyString
    
     #On interroge la portée parent et pas celle du scriptblock
     #le point indique une demande d'exécution dans la porté locale
   if ((Get-Variable MyInvocation -Scope 1).Value.InvocationName -eq '.') 
    { 
     Write-Debug "Scope local"
     $Scope=[String]::Empty 
    }
   else 
    { 
     Write-Debug "Scope global"
     $Scope="Global:" 
    }

    $parts=$null
    $selectProperties=$null
    $properties= $properties.Trim() -replace "\s{2,}"," " 
    $parts = $properties.split(' ')
    $parts |
        Foreach {
            $selectProperties += @"
 @{
            Name = '$_'
            Expression = {`$$_}
        },
"@
        }

   # simple way to remove the trailing comma        
  $selectProperties = $selectProperties -Replace ",$", ""

@"
Function $Scope$name {
param(`$$([string]::Join(',$',$parts) ))

New-Object PSObject|
 select $selectProperties
}        
"@
}
 #on crée la fonction dans la portée
Invoke-Expression (&$sbNewFunction)
}

Function TestF {
  $name
  $properties
   . New-Function 'New-Personne' 'id number '
  (dir function:new-personne).Definition
  $name
  $properties
}
  
$name="debut"
$properties="debut"
New-Function 'New-Personne' 'Nom Prénom Adresse Ville CodePostal'
TestF
(dir function:new-personne).Definition
$Personne=New-Personne Durand Pierre -CodePostal 59100
  $name
  $properties