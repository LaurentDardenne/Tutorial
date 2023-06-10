$path='Votre_Répertoire_Des_Sources'
Write-Warning "Modifiez le path"
return

ipmo "$path\PsObjectHelper.psm1"

Function New-ItemInformations{
#Crée un objet personnalisé portant des informations 
#Il contient les propriétés Size et Datas (en Read/Only)         
param(
   [Parameter(Mandatory=$True,position=0)]
  [int64]$Size,
   [Parameter(position=1)]
   [AllowNull()]
  [string[]]$Datas=@()
)
    #Les paramétres liés définissent les propriétés de l'objet
  $O=New-Object PSObject 
  $O.PSObject.Properties.Add( (New-PSVariableProperty Size $Size -ReadOnly) )
    #Protége les éléments du tableau
  $DatasRO=New-ArrayReadOnly ([ref]$Datas)
    #Protége la valeur du membre 
  $O.PSObject.Properties.Add( (New-PSVariableProperty Datas $DatasRO -ReadOnly) ) 
  $O.PsObject.TypeNames.Insert(0,"ItemInformations")
  $O
}#  New-ItemInformations

function BuildObject {
#Crée un objet de base
#on compléte ses membres par la suite
  $MyObject=New-Object PSObject -Property @{
    Nom=$null;
    #Le membre Collection est ajouté ci-dessous
    #Le membre Nested est ajouté ci-dessous
   }
  $MyObject.PsObject.TypeNames.Insert(0,'NestedObject')
  
  $MyObject.Nom='Server1'
  
   #Crée une collection
  $Collection=New-Object System.Collections.ArrayList(4)
   #La renseigne
  'Compte1','Compte2','Compte3'|% {[void]$Collection.Add($_)}
    #L'ajoute en tant que propriété nommée Collection, elle est en Read/Only 
  $MyObject.PSObject.Properties.Add( (New-PSVariableProperty 'Collection' $Collection -ReadOnly) )
}#BuildObject

 #Appel la fonction dans le scope de l'appelant
 #la fonction crée l'objet dans la portée courante 
. BuildObject

 #Affiche l'objet
$MyObject
 #Affiche la proprièté collection de l'objet
$MyObject.Collection
 #Tentative d'affectation
 #Echec de l'affectation d'une nouvelle valeur à la proprièté, le contenu de cette propriété ne peut être réassigné.
$MyObject.Collection=@()
 #Tentative d'ajout d'élément dans la liste 
 #Reussite de l'affectation d'une nouvelle entrée à la collection, l'objet contenu dans cette propriété peut être modifié.
$MyObject.Collection.add('compte4')
$MyObject.Collection


#Creé un objet en lui passant un entier et une collection
$Item=New-ItemInformations 250 @('Compte1','Compte2','Compte3')

  #Ajoute une propriété Nested 
$MyObject.PSObject.Properties.Add( (New-PSVariableProperty 'Nested' $Item -ReadOnly) )

 #Tentative d'affectation
 #Echec de l'affectation d'une nouvelle valeur à la proprièté, le contenu de cette propriété ne peut être réassigné.
$MyObject.Nested.Size=10
 #Tentative d'affectation
 #Echec de l'affectation d'une nouvelle valeur à la proprièté, le contenu de cette propriété ne peut être réassigné.
$MyObject.Nested.Datas +=@()
$MyObject.Nested.Datas +='Compte4' #Ici, en interne PS recréé un tableau, ajoute le nouvel élément et réaffecte le nouveau tableau à la variable
 #Tentative d'ajout d'élément dans le tableau 
 #Echec de l'affectation d'un nouvel élément dans le tableau porté par la proprièté, l'objet contenu dans cette propriété ne peut être modifié.
$MyObject.Nested.Datas[0]='Compte4'
