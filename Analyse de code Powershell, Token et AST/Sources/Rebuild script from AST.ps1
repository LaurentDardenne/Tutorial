#Exemple de reconstruction d'un source à partir de l'AST

throw "Modifier, dans la ligne suivante, le nom du répertoire contenant le module ExploreAST"

$env:PSModulePath=";VotreRépertoireSources\Modules"
$Module=Import-Module ExploreAST -PassThru

$AST=Get-AST -File $Module.Path

$H=New-VisitorMembersDictionnary -All
$Visiteur=New-AstVisitor $H
$Visiteur.isSkipChildren=$true
Invoke-ScriptVisitor $AST.EndBlock.Statements $Visiteur
$Results=Convert-ResultCollection $H

#$Results|Sort $SortExtent|ft  

#Recontruit le code source du script à partir des noeuds AST
$Results|
 Sort {$_.extent.startlinenumber}|
 Select -ExpandProperty Extent|
 Select -ExpandProperty Text > 'C:\Temp\NewScript.psm1'

 #Le nouveau fichier ne contient plus les commentaires présent dans le fichier d'origine. 
 #Winmerge $Module.Path 'C:\Temp\NewScript.psm1' 