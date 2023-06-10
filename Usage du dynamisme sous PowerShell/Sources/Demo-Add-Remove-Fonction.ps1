Function Auto([string]$Statement,
              [switch] $Build)
{
  function modify {
    Write-Host "Ajout des instructions : $Statement"
    $AncienCode=$Function:Auto
    Write-Debug "`t ancien code `r`n$AncienCode" 
    $null=new-item function:Auto -value "$AncienCode`r`n$Statement" -force
    $NouveauCode=$Function:Auto
    Write-Debug "`t nouveau code`r`n$NouveauCode"
  }
  Write-Host "Fonction Auto"
  if ($Build) { Modify; return }
}

Function Add-FunctionStatements([String]$FunctionName=$(Throw "Le param�tre FunctionName doit �tre renseign�."),
                                [String]$Statements=$(Throw "Le param�tre Statements doit �tre renseign�.") )
{ #Ins�re une cha�ne dans le code d�une fonction, l�insertion se fait � la ligne 1. 
  #Si la clause Param existe on ajoute un cr+lf avant $Statement
   
   $Code=(Invoke-Expression "`$Function:$FunctionName").ToString()
     #Reconnaissance de construction imbriqu�es.
     #Groupe nomm� 'Parameters'
   $PatternGroupeParameters="(?<Parameters>(?>[^()]+|\((?<DEPTH>)|\)(?<-DEPTH>))*(?(DEPTH)(?!))\))"
     #Reconnaissance SingleLine, on prend en compte les CR+LF lors de la recherche. 
   $PatternParamClause="(?s)^param\($PatternGroupeparameters(.*)$"
   
   if( $Code -Match $PatternParamClause)
    { $NewCode= "param($($Matches.Parameters)`r`n$Statements$($Matches[1])" }
   else  
   { $NewCode= "$WrtDbg$Code" }
    # Si la fonction a �t� cr�� avec "constant" : 
    # Exception= System.Management.Automation.SessionStateUnauthorizedAccessException
   new-item function:$FunctionName -value $NewCode -force    
}


Function Remove-FunctionStatements([String]$FunctionName=$(Throw "Le param�tre FunctionName doit �tre renseign�."),
                                   [Int]$NbLines=$(Throw "Le param�tre NbLines doit �tre renseign�."))
{ #Supprime n lignes dans le code d�une fonction, la suppression se fait � partir de la ligne 1.
  #Si la clause Param existe on retire le cr+lf ajout� avant $Statement par Add-FunctionStatements

   $Code=(Invoke-Expression "`$Function:$FunctionName").ToString()
     #Reconnaissance de construction imbriqu�es.
     #Groupe nomm� 'Parameters'
   $PatternGroupeParameters="(?<Parameters>(?>[^()]+|\((?<DEPTH>)|\)(?<-DEPTH>))*(?(DEPTH)(?!))\))"
     #Reconnaissance SingleLine, on prend en compte les CR+LF lors de la recherche. 
   $PatternParamClause="(?s)^param\($PatternGroupeparameters(.*)$"
   $isMatch=$Code -Match $PatternParamClause
   if ($isMatch)
    {  #String en tableau de cha�ne
      $T=$Matches[1].Split("`r`n") 
      $NbLines++  
    }
   else  
    { $T=$Code.Split("`r`n")}
   
    #Supprime le nb de lignes ajout�es pr�c�dement
   $Lines=$T|Select -Last ($T.Count -($NbLines))
   #Tableau de cha�ne en string  
   $Lines=[system.string]::Join("`r`n",$Lines)
   
   if ($isMatch)
    { $NewCode= "param($($Matches.Parameters)$Lines" }
   else  
   { $NewCode= "$Lines" }
     # Si la fonction a �t� cr�� avec "constant" : 
     # Exception= System.Management.Automation.SessionStateUnauthorizedAccessException
   new-item function:$FunctionName -value $NewCode -force
}


$Function:Auto 
 #Ajoute deux lignes
 #Si la clause Param existe on ajoute un cr+lf avant $Statement
Add-FunctionStatements "Auto" "Write-Debug `"Code debug ajout� pour $FunctionName`"`r`n"
$Function:Auto
 #Si la clause Param existe on retire le cr+ajout� avant $Statement 
Remove-FunctionStatements "Auto" 2
$Function:Auto 