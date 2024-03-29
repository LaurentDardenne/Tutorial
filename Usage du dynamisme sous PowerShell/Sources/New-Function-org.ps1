Function New-Function ($name, $properties) {
#Auteur : Doug Finke
# From  : http://dougfinke.com/blog/index.php/2009/09/12/powershell-function-factory/
#
# Création dynamique de fonction globale créeant des objets personnalisés.
#
#Exemple :
# New-Function 'New-Personne' 'Nom Prénom Adresse Ville CodePostal'            
# $Personne=New-Personne Durand Pierre -CodePostal 59100

    $properties= $properties.Trim() -replace "\s{2,}"," " 
    $parts = $properties.split(' ')
    $parts |
        %{
            $selectProperties += @"
 @{
            Name = '$_'
            Expression = {`$$_}
        },
"@
        }

# simple way to remove the trailing comma        
$selectProperties = $selectProperties -Replace ",$", ""

Invoke-Expression @"
Function Global:$name {
param(`$$([string]::Join(',$',$parts) ))
    
New-Object PSObject|
 select $selectProperties
}        
"@
}

New-Function 'New-Personne' 'Nom Prénom Adresse Ville CodePostal'
$Personne=New-Personne Durand Pierre -CodePostal 59100
(dir function:new-personne).Definition