#Analyse de code
#Vérifie l'usage des clés de la hashtable déclarée par le cmdlet Import-LocalizedData 

#Requires -Module ExploreAST

throw "Modifier, dans la ligne suivante, le nom du répertoire contenant le module ExploreAST"

$env:PSModulePath=";VotreRépertoireSources\Modules"
$Module=Import-Module ExploreAST -PassThru

#Pour appliquer la régle sur du code on doit déjà récupérer des informations 
#contenues dans ce même code
Function Search-ASTLocalizedData {
<#
.SYNOPSIS
  Recherche dans un script les noms de clés de localisation.
  Peut renvoyer plusieurs objets, bien que par convention on ait un appel par script/module
#> 
 [CmdletBinding()]
 param(
      #Chemin complet d'accès au fichier à analyser
     [Parameter(Position=1, Mandatory=$true)] 
     [ValidateScript({Test-Path $_})]
   $Path
  ) 

 function New-LocalizedDataInformations{
  param (
   $Path,
   $VisitCommandResult
  )
  [pscustomobject]@{
     PSTypeName='LocalizedDataInformations'
       #Nom du fichier de localisation des messages 
     FileName=$VisitCommandResult.FileName 
       #Nom de la variable utilisée pour accèder aux clés de la hashtable 
       #contenant les messages localisés
     BindingVariable=$VisitCommandResult.BindingVariable 
       #Nom du fichier contenant les appels à Import-localizedData
     ScriptName=[System.IO.Path]::GetFileName($Path)
       #Nom du répertoire du fichier 
     BaseDirectory=[System.IO.Path]::GetDirectoryName($Path)
       #Liste des clés trouvées
     KeysFound=$null
  }
 } #New-LocalizedDataInformations
 
 
  # 1 - Première lecture de l'arbre
  #----------Recherche les appels du cmdlet Import-LocalizedData
  #----------afin de récupèrer la valeur des paramètres 'BindingVariable' et'FileName' 
  $CmdLocalizedData=New-VisitorMembersDictionnary
  $CmdLocalizedData.VisitCommand={
   Param ($Ast) 
  try {
   Write-debug 'Call $CmdLocalizedData.VisitCommand'
     #Suppose une seule déclaration de 'Import-LocalizedData'
      #Suppose des arguments de type string.
    $HBind=Get-CommandParameter $Ast  'Import-LocalizedData' 'BindingVariable','FileName'
    if ($HBind -ne $null) 
    { 
      If ($HBind.Contains('BindingVariable') -eq $false) 
      {
          Write-debug 'Not contains BindingVariable'
          # Prise en compte de ps V3 : $Messages=Import-LocalizedData ...
          $Parent=$Ast.Parent.Parent
          Write-debug "Parent=$Parent"
          if ( ($Parent -is [System.Management.Automation.Language.AssignmentStatementAst]) -and 
             ($Parent.Left -is [System.Management.Automation.Language.VariableExpressionAst]) )
          { 
            Write-debug "PS v3 syntax found !"
            $HBind.'BindingVariable'=Split-VariablePath $Parent.Left 
          }
          #L'affectation multiple ( $a,$b=1,2 ou $a=$b=3 ) n'est pas implémentée.
      }
     ,$HBind
   }
    else { Write-debug 'HBind is null' } 
   } catch {
       write-error -exception $_.exception 
       Write-debug "EXCEPT `$CmdLocalizedData.VisitCommand : $($_.exception)" 
       throw $_
    } finally {
         Write-debug 'fin $CmdLocalizedData.VisitCommand'
      } 
  }#VisitCommand
  
  $Ast=Invoke-Visitors -File $Path -VisitorScript $CmdLocalizedData
  Write-debug "Appels à Import-LocalizedData : $($CmdLocalizedData.VisitCommand.Result.Count)"
  $LDIs=New-Object System.Collections.ArrayList 
  $CmdLocalizedData.VisitCommand.Result|
   Foreach {
    $LDIs.Add( (New-LocalizedDataInformations $Path $_) ) > $Null 
   }
  
  # 2- relecture de l'arbre
  #----------Contrôle les noms de clé utilisés, inconnus ou inutilisés.

   #On relit l'arbre autant fois qu'il y a d'appel à Import-LocalizedData                
  $LDIs|
   Foreach {
     Write-debug "Current=$_"
     $Msg=New-VisitorMembersDictionnary
      
      #Le scriptblock est exécuté dans la portée de ce script.
     $Msg.VisitMemberExpression={
       Param ($Ast)                         
         #Recherche dans les membres d'expression 
         #celles dont la propriété 'Expression' est une variable, 
         #dans ce cas sa propriété 'Member' est le nom d'une clé de localisation
        if ($Ast.Expression -is [System.Management.Automation.Language.VariableExpressionAst]) 
         {
           Write-debug "MemberExpressionAst BindingVariable='$($CurrentBindingVariable)' $ast"   
           #Supprime l'indicateur de portée précisé dans le nom de variable
           if ((Split-VariablePath $Ast.Expression) -eq $CurrentBindingVariable)  
           {$Ast}
        }
     }           
     $VisiteurMsg=New-AstVisitor $Msg
     $CurrentBindingVariable=$_.BindingVariable
     Write-debug "CurrentBindingVariable = $CurrentBindingVariable"
     Invoke-ScriptVisitor $AST.EndBlock.Statements $VisiteurMsg
     $Msg.VisitMemberExpression.Result.Member.Value|Select -Unique |% {write-debug "found: $_"}
     $_.KeysFound=@($Msg.VisitMemberExpression.Result.Member.Value|Select -Unique)
   }
  
  Write-Output $LDIs
} #Search-ASTLocalizedData

Function Compare-LocalizedData {
<#
.SYNOPSIS
  Compare des données générées par la fonction Search-ASTLocalizedData.
#> 
 [CmdletBinding()]
 param(
      #Permet de pointer sur le fichier d'aide associé à une culture
     [Parameter(Position=0, Mandatory=$true,ValueFromPipeline=$true)]
   $Culture, 
      #Informations de localisation et de comparaison 
     [Parameter(Position=1, Mandatory=$true)]
     [ValidateScript({@($_.PsObject.TypeNames[0] -eq "LocalizedDatasInformations").Count -gt 0})] 
   $LocalizedDatas
  ) 
  
  if ($LocalizedDatas.KeysFound.Count -ne 0)
  {
      #Charge le fichier de localisation utilisée dans le code analysé.
      # Si le fichier est introuvable on arrête le traitement
      #On recherche -Filename dans le répertoire -BaseDirectory
     Import-LocalizedData -BindingVariable HelpMsg -Filename $LocalizedDatas.FileName -UI $Culture -BaseDirectory $LocalizedDatas.BaseDirectory -EA Stop
     $Compare=Compare-Object ($HelpMsg.Keys -as [string[]]) $LocalizedDatas.KeysFound -IncludeEqual
     Add-member -Member NoteProperty -name Culture -input $Compare -value $Culture
     Add-member -Member NoteProperty -name Filename -input $Compare -value $LocalizedDatas.FileName -Passthru
  }
  else
  {Write-Error "Aucune occurence trouvée pour $LocalizedDatas."}
} #Compare-LocalizedData

Function Format-TestLocalizedData {
<#
.SYNOPSIS
  Formate et affiche les données issues de Compare-Localized.
#> 
 param(
       #Collection des clés à comparer
     [Parameter(Position=0, Mandatory=$true,ValueFromPipeline=$true)]
   [Object[]]$Inputobject 
 )
  $Egaux, $Supprime, $Nouveaux =1..3|% {New-Object System.Collections.ArrayList}
  
  foreach ($Item in $InputObject)
  {
     switch ($Item.SideIndicator) 
     {
      '==' {$Egaux.Add($Item.InputObject)>$null}
      '<=' {$Nouveaux.Add($Item.InputObject)>$null}
      '=>' {$Supprime.Add($Item.InputObject)>$null}
     }
  }
  
  $ofs="`r`n`t"
  Write-host "Valide les clés du fichier '$($InputObject.FileName)':" -fore Cyan
  Write-host " Clés utilisées pour la culture '$($InputObject.Culture)':" -fore green
   Write-host "`t$Egaux" 
  
  Write-host " Clés inconnues dans le code source :" -fore green
   Write-host "`t$Supprime"
  
  Write-host " Clés inutilisées de la liste localisée :" -fore green
   Write-host "`t$Nouveaux" 
}#Format-TestLocalizedData


Function Test-LocalizedData {
<#
.SYNOPSIS
  Recherche et valide les noms de clés de localisation utilisée dans un script, une fonction ou un module.
#> 
 [CmdletBinding()]
 param(
      #Chemin complet d'accès du fichier à analyser
     [Parameter(Position=1, Mandatory=$true,ValueFromPipeline=$true)] 
     [ValidateScript({Test-Path $_})]
   $Path,
      #Permet de pointer sur le fichier d'aide associé à une ou plusieurs culture
      #Si ce paramètre n'est pas précisé toutes les cultures sont concernées.
     [Parameter(Position=2, Mandatory=$false)]
   [System.Globalization.CultureInfo[]]$Cultures
  )     

 begin {
    if ($PSBoundParameters.ContainsKey('Culture') )
    { $AllCultures=$Cultures|Select -ExpandProperty Name}
    else  
    { $AllCultures=[System.Globalization.CultureInfo]::GetCultures('AllCultures')|Select -ExpandProperty Name}
 }
 process {
   Search-ASTLocalizedData $Path |
   Foreach {
     $Result=$_
     #Parcourt les répertoires normalisés contenant le fichier de localisation.
     Dir $Result.BaseDirectory|
      Where {$AllCultures -Contains $_.Name}|
      Foreach {$_.Name}|
      Compare-LocalizedData -LocalizedDatas $Result|
      Format-TestLocalizedData
   }
 }
}#Test-LocalizedData

Test-LocalizedData -Path $Module.Path

#Resultats :
#   Valide les clés du fichier 'ExploreASTLocalizedData.psd1':
#    Clés utilisées pour la culture 'Fr-fr':
#           AliasParameterNotSupported
#           UnknownParameterName
#    Clés inconnues dans le code source :
#           UnknownLocalizedDataKey
#    Clés inutilisées de la liste localisée :
#           PathMustExist
