#Affichage des erreurs de syntaxe présent dans un script

#Requires -Version 3

throw "Modifier, dans la ligne suivante, le nom du répertoire contenant le module ExploreAST"

$env:PSModulePath=";VotreRépertoireSources\Modules"
Import-Module ExploreAST 


#$code='10/0' # Détecté à l'exécution
#$code='foreach (0;0;0)' # Détecté à l'analyse
$code=@'
 function Test{
  param(
    [int] $a,
    [Object] $objet=$(Thow "Erreur")
  )
  dir
 }
function {    
 switch (0) {
 a
 }
}
'@

 #Bien qu'une erreur soit déclenchée et affichée la variable AST est renseignée
$AST= Get-AST -Input $Code -ErrorsList ErrorAst -TokensList Tokens
 #Ici la variable AST n'est pas renseignée
 #$AST= Get-AST -Input $Code -ErrorsList ErrorAst -TokensList Tokens -Strict

 #Affiche les types de noeud
$AST.EndBlock.Statements|% {$_.gettype()}

 #Affiche les erreurs contenues dans les scripts
 #1 : le nom de fonction manque
 #2 : la construction du switch est erroné 
$FctrErrorStatement=New-FunctorASTClass ErrorStatementAst
$Ast.FindAll($FctrErrorStatement, $true)

 #Parcourt l'arbre 
$H=New-VisitorMembersDictionnary   
 
 #PS, lors du TypeConversion, appel implicitement le constructeur "Powershell.Visitor.VisitorMembers
 #La propriété Result est initialisée dans le constructeur  
$H.'VisitCommand'={Param ($ast) Write-Warning "Call Cmd"; $ast.CommandElements[0].Value}
$H.'VisitFunctionDefinition'={Param ($ast) Write-Warning "Call Fnct";$ast.Name}
$H.VisitErrorStatement={
 [CmdletBinding()]
  Param ($ast) 
  Write-Warning "Call error"
  $frmt="Erreur -> Ligne:{0} Colonne:{1} Fichier:'{2}' Type:{3} kind: {4} Parent:{5}"
  $MessageError= $frmt -F $Ast.Extent.StartLineNumber,$Ast.Extent.StartColumnNumber,$Ast.Extent.File,$Ast.Parent.GetType().Name,$Ast.Kind,$Ast.Extent
   #Write-Error renseigne la collection $Error, mais n'est pas affiché sur la console
   #On simule donc ces appels.
   #
   #C'est une limite due à la conception actuelle de la classe ScriptVisitor.
   #Plus précisément une caractèristique de la méthode Invoke() 
   $ExecutionContext.Host.ui.WriteErrorLine($MessageError)  
   Write-Error $MessageError
} 

$Visiteur=New-AstVisitor $H
$Error.Clear()
Invoke-ScriptVisitor $AST.EndBlock $Visiteur

 #Affiche le détail
$H.GetEnumerator()|Fl @{Name='Result';E={$_.Value.Result}},@{Name='Code';E={$_.Value.Code}} -GroupBy Key
 #Affiche les noms des commandes trouvé dans le code analysé
$H.VisitCommand.Result
 #PS v3: itérateur automatique sur une collection
 #Affiche le résultat de toutes les entrées 
 #Mais ici on ne connait plus le producteur
$H.Values.Result