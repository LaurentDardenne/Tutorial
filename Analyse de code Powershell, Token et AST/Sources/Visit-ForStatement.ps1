#Transformation de code : 
#   For($i=0; $i -lt $Range.Count; $i++) { $i }
#en 
#   $RangeCount = $Range.Count
#   For($i=0; $i -lt $RangeCount; $i++) { $i }

throw "Modifier, dans la ligne suivante, le nom du répertoire contenant le module ExploreAST"

$env:PSModulePath=";VotreRépertoireSources\Modules"
Import-Module ExploreAST 

Function New-ForStatementInformations{
#Crée un objet émis dans le pipline par le visiteur 'VisitForStatement'
param(
   [Parameter(Mandatory=$True,position=0)]
  $ID,
   [Parameter(Mandatory=$True,position=1)]
  $Variable,
   [Parameter(Mandatory=$True,position=2)]
  $Expression
)
  #Les paramétres liés définissent aussi les propriétés de l'objet
 $O=New-Object PSObject -Property $PSBoundParameters

 $O.PsObject.TypeNames.Insert(0,"ForStatementInformations")
 $O

}# New-ForStatementInformations

Function New-ForStatementRewriter{
#Mémorise les informations nécessaire à la réécriture du code source.
#C'est un objet imbriqué en tant que propriétés d'un objet 'ForStatementInformations' 
param(
   [Parameter(Mandatory=$True,position=0)]
  $Text,
   [Parameter(Mandatory=$True,position=1)]
  $StartOffset,
   [Parameter(Mandatory=$True,position=2)]
  $Length
)
  #Les paramétres liés définissent aussi les propriétés de l'objet
 $O=New-Object PSObject -Property $PSBoundParameters

 $O.PsObject.TypeNames.Insert(0,"ForStatementRewriter")
 $O

}# New-ForStatementRewriter

function ConvertTo-TitleCase {
#Transforme une chaîne du type $Range.Count en $RangeCount
param ([string] $Text)         
 $S=(Get-Culture).TextInfo.ToTitleCase($Text).Replace('.','')
 Write-Debug "ConvertTo-TitleCase =$s"
 $S
}#ConvertTo-TitleCase

function Measure-ColumnStarting {
 #Ajoute des espaces pour aligner une ligne de code 
 param([int]$StartColumnNumber )

 ' ' * ($StartColumnNumber-1)
}#Measure-ColumnStarting

#Crée le visiteur des instructions For()
#Il ne traite que la propriété Condition
#
#Seul les trois écritures suivantes sont prises en compte :
#   $i -lt $Range.Count
#   $i -lt $Range.Count-1
#   $i -lt ($Range.Count-1)

$Visiteur=New-VisitorMembersDictionnary
$Visiteur.VisitForStatement={
 Param ($Ast) 
   Write-debug 'Call $ForStatementAst'
   write-error 'Test erreur in $ForStatementAst'
   if ($Ast.Condition -ne $null)
   {
     foreach ($Node in $Ast.Condition.PipelineElements)
     {
       if ( $Node -is [System.Management.Automation.Language.CommandExpressionAst] )
       {
         $Expression=$Node.Expression
         Write-Debug "Expression=$Expression" 
         if ($Expression -is [System.Management.Automation.Language.BinaryExpressionAst])
         {  
           Write-Debug "Right=$($Expression.Right.gettype())"
            #Tous les noeuds sont dans 'System.Management.Automation.Language'
           $RightNodeType=$Expression.Right.GetType().Name
           Write-Debug "`t -> switch $RightNodeType"
           $CreateObject=$true
           switch ($RightNodeType) { 
             'MemberExpressionAst'   {  # cas : $I -le $Range.Count
                                         # mémorise '$I -le $Range.Count'
                                        $ExpressionText=$Expression.Extent.Text
                                        write-debug "ExpressionText=$ExpressionText"
                                       
                                        # mémorise '$Range.Count'
                                        $RightHandSideText=$Expression.Right.Extent.Text
                                        write-debug "RightHandSideText=$RightHandSideText"
                                        
                                        $VarName=ConvertTo-TitleCase $RightHandSideText
                                        
                                        #L'ajout d'un retour chariot place la ligne suivante en colonne 0
                                        $DecalageColonne=Measure-ColumnStarting $Ast.Extent.StartColumnNumber 
                                        $V=New-ForStatementRewriter "$VarName=$RightHandSideText`r`n$DecalageColonne" `
                                                                    $Ast.Extent.StartOffset `
                                                                    ([int]-1)  #On insére uniquement. Nouvelle ligne de texte
                                        
                                        $E=New-ForStatementRewriter ($ExpressionText -replace ([regex]::Escape($RightHandSideText)),$VarName)`
                                                                    $Expression.Extent.StartOffset `
                                                                    $ExpressionText.Length #Remove & Insert. Remplacement de texte
                                        #Pour supprimer uniquement : text=''
                                   } #MemberExpressionAst 
                                     
             'BinaryExpressionAst' { # $I -le $Range.Count-1
                                      $ExpressionText=$Expression.Right.Extent.Text
                                      write-debug "ExpressionText=$ExpressionText"
                                      
                                       #todo (-1+$V.count) possible mais pas pris en compte
                                      $LeftHandSideText=$Expression.Right.Left.Extent.Text
                                      write-debug "LeftHandSideText=$LeftHandSideText"
  
                                      $VarName=ConvertTo-TitleCase $LeftHandSideText
                                       
                                      $DecalageColonne= Measure-ColumnStarting  $Ast.Extent.StartColumnNumber
                                      $V=New-ForStatementRewriter "$VarName=$($Expression.Right.Extent.Text)`r`n$DecalageColonne" `
                                                                  $Ast.Extent.StartOffset `
                                                                  ([int]-1)
                        
                                      $E=New-ForStatementRewriter ($Expression.Extent.Text -replace ([regex]::Escape($ExpressionText)),$VarName)`
                                                                  $Expression.Extent.StartOffset `
                                                                  $Expression.Extent.Text.Length 
                                   } #BinaryExpressionAst                                     
               
             'ParenExpressionAst' { # cas : $I -le ($Range.Count-1)  
                                     foreach ($RNode in $Expression.Right.Pipeline.PipelineElements)
                                     {
                                        if ( $RNode -is [System.Management.Automation.Language.CommandExpressionAst] )
                                        {
                                           $RExpression=$RNode.Expression
                                           if ($RExpression -is [System.Management.Automation.Language.BinaryExpressionAst])
                                           { 
                                             #Ici on utilise le texte du noeud contenu dans la proprièté 'Condition' 
                                             # et le texte du noeud courant.
                                             
                                              # mémorise '($Range.Count-1)'
                                             $ExpressionText=$Expression.Right.Extent.Text
                                             write-debug "ExpressionText=$ExpressionText"

                                              #mémorise '$Range.Count' Todo (-1+$V.count) possible mais pas pris en compte
                                             $LeftHandSideText=$RExpression.Left.Extent.Text
                                             write-debug "LeftHandSideText=$LeftHandSideText"
                                             
                                             $VarName=ConvertTo-TitleCase $LeftHandSideText
                                             
                                             $DecalageColonne= Measure-ColumnStarting $Ast.Extent.StartColumnNumber
                                                                                     #$Range.Count-1
                                             $V=New-ForStatementRewriter "$VarName=$($RExpression.Extent.Text)`r`n$DecalageColonne" `
                                                                         $Ast.Extent.StartOffset `
                                                                         ([int]-1)
                                                                         
                                                                         #$I -le ($Range.Count-1) 
                                             $E=New-ForStatementRewriter ($Expression.Extent.Text -replace ([regex]::Escape($ExpressionText)),$VarName)`
                                                                         $Expression.Extent.StartOffset `
                                                                         $Expression.Extent.Text.Length 
                                           }#BinaryEx 
                                        }#CommandEx 
                                     }#Foreach
                                  } #ParenExpressionAst
             default { $CreateObject=$False }                                     
           }#switch
           if ($CreateObject)
           {
              #ID est un identifiant unique POUR ce contexte !
             $Object=New-ForStatementInformations $Ast.Extent.StartOffset $V $E       
              Write-debug "Variable =$($Object.Variable.Text)"  
              Write-debug "new expression = $($Object.Expression.Text)"   
             $Object                 
           }
         }#BinaryEx 
       }#CommandEx      
     }#Foreach
  } #If condition
 }#VisitForStatement


  
function Set-AstForStatement {
 param( 
    [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
    [PSTypeName('ForStatementRewriter')] 
   $InputObject,
    [Parameter(position=0,Mandatory=$true)]
   [System.Text.StringBuilder] $Code
 )
 process {  
  Write-debug "Traite : $InputObject" 
  $Pos=$InputObject.StartOffset
  if ( ($InputObject.Length -ne $null) -and ($InputObject.Length -ge 0) )
  {
    Write-debug "Supprime l'ancien texte"
    $Code.Remove($Pos,$InputObject.Length)> $null
    #Write-debug ($Code.Remove($Pos,$InputObject.Length).ToString())
  }
  Write-debug "Insére le nouveau texte" 
  $Code.Insert($Pos,$InputObject.Text) > $null
  #Write-debug ($Code.Insert($Pos,$InputObject.Text).ToString())
 }         
}#Set-AstForStatement

$sb={
#Zéro
for($I=0; $I -le $Range.Count; $i++) {
  $i
} 
 #Un
 for($I=0; $I -le $Range.Count-1; $i++) {
   $i
 }
  #Deux 
  for($I=0; $I -le ($Range.Count-1); $i++) {
    $i
  } 
}

$Ast=Invoke-Visitors -InputScript $sb -VisitorScript $Visiteur
$Visiteur.VisitForStatement.Result

$SourceCode = New-Object System.Text.StringBuilder $sb
$Visiteur.VisitForStatement.Result|
 Sort ID -Desc|
 Foreach {
   #On modifie en premier l'expression,
   #puis on insére la déclaration de variable
   $_.Expression,$_.Variable|  Set-AstForStatement $SourceCode
 }
 
$SourceCode.ToString()

