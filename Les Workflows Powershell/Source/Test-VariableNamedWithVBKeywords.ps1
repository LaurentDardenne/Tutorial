#Requires -Version 4.0
Function Test-VariableNamedWithVBKeywords {
<#
.Synopsis
Teste la présence de noms de variable de workflow identiques à un mot clé du 
VB.Net.

.Description
Renvoie $True si un nom de variable de workflow est identique à un mot clé du 
VB.Net, $False sinon.
.
En cas d'erreur la fonction renvoie $Null.
Cette fonction utilise la fonction Get-VariableNamedWithVBKeywords. 
 
.Parameter Code 
Texte du code d'un workflow Powershell à analyser.

.Example
$Code=@'
Workflow Test {
 param ([String[]] $Handles)
 $Handles=@("Test affectation.") 
 Write-Output $Handles 
}
'@

$Code|Test-VariableNamedWithVBKeywords
.        
Description
-----------
L'analyse du code contenu dans la variable $Code renvoie $True, car la variable 
nommée 'Handles' est également un mot-clé du VB.Net.
.
Note : Seule l'affectation d'une telle variable déclenche une exception lors de 
l'exécution du workflow.     

.Notes
AUTHOR: Dardenne Laurent
LASTEDIT: 09/02/2105

.Link
Bug MSConnect : 
 https://connect.microsoft.com/PowerShell/Feedback/Details/735357

Liste des mots-cles du VB.Net pour VS 2013 : 
https://msdn.microsoft.com/en-us/library/dd409611.aspx 
#> 
  Param(
      [ValidateNotNull()]
      [Parameter(Mandatory=$true,ValueFromPipeline = $true)]  
     [string] $Code
  )
 process {
   try {
      $Result=@($Code|Get-VariableNamedWithVBKeywords -ErrorAction Stop|Where-Object {$_.Variables.Count -ne 0})
      ($Result.Count -ne 0)
   } catch [System.Management.Automation.ActionPreferenceStopException]{
       #la fonction Get-VariableNamedWithVBKeywords ne renvoie 
       #que des erreurs simples. 
       #Ainsi, on les propage et renvoie $Null.
      Write-Error $_
   }     
 }#process
}#Test-VariableNamedWithVBKeywords

Function Get-VariableNamedWithVBKeywords { 
<#
.Synopsis
Renvoie les noms de variable correspondant à un mot clé du VB.net.

.Description
L'usage de noms de variable identique aux mots-clés du VB.Net dans un workflow 
déclenchera une exception lors de son exécution.
Seule l'affectation d'une telle variable déclenche l'exception.
.
Cette fonction analyse le code d'un workflow afin de déterminer si chaque nom de 
variable est identique à mot-clé du VB.Net est autorisé dans le contexte de sa 
déclaration. Une fonction ou un bloc InlineScript peut déclarer et utiliser de tels 
noms de variable sans problème.     
 
.Parameter Code 
Texte du code d'un workflow Powershell à analyser.

.Example
$code=@'
Workflow TestWFError { 
 "ok"
 $s='
}
'@

$Code|Get-VariableNamedWithVBKeywords
.        
Description
-----------
L'analyse du code contenu dans la variable $Code est impossible, la fonction 
renvoie la liste des erreurs de parsing.

.Example
$Code=@'
Function Test {
 param ([String[]] $Handles)
 Write-Output $Handles 
}
'@

$Code|Get-VariableNamedWithVBKeywords
.        
Description
-----------
L'analyse du code renvoie un Warning, car il ne contient pas de déclaration 
de Workflow.
    
.Example
$Code=@'
Workflow Test {
 param ([String[]] $Handles)
 $Handles="Test affectation." 
 Write-Output $Handles 
}
'@

$Code|Get-VariableNamedWithVBKeywords
.        
Description
-----------
L'analyse du code contenu dans la variable $Code renvoie des objets de type
'VariableWorkflow' :
  Name   Variables
  ----   ----------
  Test   {Handles}
.
La propriété 'Name' contient le nom du workflow.
La propriété 'Variables' contient la liste des noms de variable correspondant 
à un mot clé du VB.net ou une liste vide.
.   
Dans cet exemple la variable nommée '$Handles' est identique à un mot clé du 
VB.Net.
L'exécution de ce workflow provoquera une exception due à la présence de ce nom 
de variable.

.Example
$Code=@'
Workflow Distinct{
 param($ParamArray)
 
 InlineScript {
   $Event=10
 
   Workflow Nested{
    param($ParamArray)
     
    Function Convert-Date{
     Param ($Date) 
      "Transforme la date"
     }Convert-Date
 
     Convert-Date (Get-Date)
     $Next=10
   }#Distinct             
 }#Inline          
}#Distinct
'@

$Code|Get-VariableNamedWithVBKeywords
.        
Description
-----------
L'analyse du code contenu dans la variable $Code renvoie :
  Name        Variables
  ----        ----------
  Distinct    {ParamArray}
  Nested      {ParamArray, Next}
.
Dans cet exemple la variable nommée '$Event' est identique à un mot clé du VB.Net, 
mais elle est déclarée dans un bloc InlineScript, ce qui est autorisé.
.
La variable nommée '$Date' est également identique à un mot clé du VB.Net, 
mais elle est déclarée dans une fonction, ce qui est autorisé.   

.Example
$Code=@'
Workflow Variant 
{
    "One"
    $Const='vb'
    
    Two
    workflow Two()
    {
        "Two"
        $in=10
        $Dim=get-process -name ps*
        
        Three
        Function Three
        { param($AddressOf)
            "Three"
            function Five {"Five"}
            Workflow Four {
              Param () 
               "Four" 
               Five
               $Distinct='Test'
            Workflow Six {
              Param ($Text) 
              $Test='testt'
              "Six $text" 
            }
           }
         Four
       }  
       $event=1..5  
    } #two 
    
    InlineScript {
       function F2 {"F2"; $event=1..5;$Event}
       Workflow W2 { 
        "W2"
        $Set=F2
        InlineScript {
           function F3 {"F3";W3}
           Workflow W3 {Param ($Date) "W3"}
           $Delegate=F3               
        } 
       } 
      $Option=W2            
    }
}
'@

$Code|Get-VariableNamedWithVBKeywords
.        
Description
-----------
L'analyse du code contenu dans la variable $Code renvoie :
  Name       Variables
  ----       ---------
  Variant    {Const}
  Two        {in, Dim, event}
  Four       {}
  Six        {}
  W2         {Set}
  W3         {Date}
.
Dans cet exemple la présence de noms de variable identiques à des mots-clés du 
VB.Net déclenchera une erreur de compilation lors de la création des workflows 
dépendants.
Note : l'usage d'un mot-clé du VB.Net en tant que nom de workflow est autorisé. 

AUTHOR: Dardenne Laurent
LASTEDIT: 09/02/2105

.Link
Bug MSConnect : 
 https://connect.microsoft.com/PowerShell/Feedback/Details/735357

Liste des mots-cles du VB.Net pour VS 2013 : 
https://msdn.microsoft.com/en-us/library/dd409611.aspx 
#> 
 [CmdletBinding()]
  Param(
      [ValidateNotNull()]
      [Parameter(Mandatory=$true,ValueFromPipeline = $true)]  
     [string] $Code
  )
 begin {  
   $_EA= $null
   [void]$PSBoundParameters.TryGetValue('ErrorAction',[REF]$_EA)
   if ($_EA -ne $null) 
   { $ErrorActionPreference=$_EA}

   try {
       if (-not ([PSVariableNameComparer].IsSubclassOf([System.Collections.Generic.EqualityComparer[System.String]])))
       { Throw (New-Object System.ApplicationException("Impossible de compiler la classe [PSVariableNameComparer]. La classe existe déjà, mais n'est pas du type attendu.")) }
   } catch {
       #PS specification : Each exception thrown is raised as a System.Management.Automation.RuntimeException
     if ($_.Exception -isnot [System.Management.Automation.RuntimeException])
     { Throw $_ }
     else
     {      
       Write-Debug "Compile le type [PSVariableNameComparer]"
       #Comparateur insensible à la casse, utilsé avec un HashSet
      $CodeComparer=@'
using System;
using System.Collections.Generic;

public class PSVariableNameComparer : EqualityComparer<string>
{
    public override bool Equals(string s1, string s2)
    {
        return s1.Equals(s2, StringComparison.CurrentCultureIgnoreCase);
    }


    public override int GetHashCode(string s)
    {
        return base.GetHashCode();
    }
}
'@
      Add-type -TypeDefinition $CodeComparer -ErrorAction Stop
    }
  }

  Function New-VariableWorkflow{
  # Construit un objet portant le nom d'une fonction de workflow et 
  # les noms de variable correspondant à un mot clé du VB.net ou
  # une liste vide si elle n'en contient pas. 
  param(
           [Parameter(Mandatory=$True,position=0)]
          [String] $Name,
           
           [Parameter(Mandatory=$false,position=1)]
            #Mandatory=$false -> autorise tableau vide ou $null
          [String[]] $Variables
  )
  
    if ($Variables -eq $null)
    { [string[]]$Variables=@() } #Force la création d'un tableau vide
    
    [pscustomobject]@{
      PSTypeName='VariableWorkflow';
      Name=$Name;
      Variables=New-Object 'System.Collections.ObjectModel.ReadOnlyCollection[System.String]' -argumentlist @(,$Variables)
     }
  }# New-VariableWorkflow
         
  Function TruncateString{
   param([string] $Message,[int]$SizeMax=80)
    $Message.Substring(0,([Math]::Min(($Message.Length),$Sizemax)))
  }#TruncateString

#L'usage d'un mot clé VB en tant que nom de variable de workflow est possible 
# TANT qu'aucune affectation ne la concerne. 
#
#Liste pour VS 2013 : https://msdn.microsoft.com/en-us/library/dd409611.aspx
#
[String[]]$VB_Keywords=@(
 'AddHandler' , 'AddressOf' , 'Alias' , 'And' , 'AndAlso' , 'As' , 'Boolean' , 
 'ByRef' , 'Byte' , 'ByVal' , 'Call' , 'Case' , 'Catch' , 'CBool' , 'CByte' , 
 'CChar' , 'CDate' , 'CDbl' , 'CDec' , 'Char' , 'CInt' , 
 'Class',   # pas de collision avec PS v5 où Class est un mot clé.
 'CLng' , 'CObj' , 'Const' , 'Continue' , 'CSByte' , 'CShort' , 'CSng' , 'CStr' ,
 'CType' , 'CUInt' , 'CULng' , 'CUShort' , 'Date' , 'Decimal' , 'Declare' , 
 'Default' , 'Delegate' , 'Dim' , 'DirectCast' , 'Do' , 'Double' , 'Each' , 
 'Else' , 'ElseIf' , 'End' , 'EndIf' , 'Enum' , 'Erase' , 'Event' , 'Exit' , 
 'Finally' , 'For' , 'Friend' , 'Function' , 'Get' , 'GetType' , 'GetXMLNamespace' , 
 'Global' , 'GoSub' , 'GoTo' , 'Handles' , 'If' , 'If()' , 'Implements' , 
 'Imports' , 'In' , 'Inherits' , 'Integer' , 'Interface' , 'Is' , 'IsNot' , 'Let' , 
 'Lib' , 'Like' , 'Long' , 'Loop' , 'Me' , 'Mod' , 'Module' , 'MustInherit' , 
 'MustOverride' , 'MyBase' , 'MyClass' , 'Namespace' , 'Narrowing' , 'New' , 
 'Next' , 'Not' , 'Nothing' , 'NotInheritable' , 'NotOverridable' , 'Object' , 
 'Of' , 'On' , 'Operator' , 'Option' , 'Optional' , 'Or' , 'OrElse' , 'Out' , 
 'Overloads' , 'Overridable' , 'Overrides' , 'ParamArray' , 'Partial' , 'Private' , 
 'Property' , 'Protected' , 'Public' , 'RaiseEvent' , 'ReadOnly' , 'ReDim' , 
 'REM' , 'RemoveHandler' , 'Resume' , 'Return' , 'SByte' , 'Select' , 'Set' , 
 'Shadows' , 'Shared' , 'Short' , 'Single' , 'Static' , 'Step' , 'Stop' , 'String' , 
 'Structure' , 'Sub' , 'SyncLock' , 'Then' , 'Throw' , 'To' , 'Try' , 'TryCast' , 
 'TypeOf' , 'UInteger' , 'ULong' , 'UShort' , 'Using' , 'Variant' , 'Wend' , 
 'When' , 'While' , 'Widening' , 'With' , 'WithEvents' , 'WriteOnly' , 'Xor' , 
 '#Const' , '#Else' , '#ElseIf' , '#End' , '#If' #  Le parseur invalide les noms '#...' dans un workflow
 )
  
   #Collisions de mot clés entre le VB et PS
   #'True' et 'False' sont en R/O 
   #et l'usage de 'Error' est invalidé par le parseur : VariableNotSupportedInWorkflow
  $Except=@('True','False','Error')
  
  $isWorkflow= {
     $Args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $Args[0].isWorkflow 
  }

   #Recherche les noeuds de type variable
  $isVariable={
    ($Args[0] -is [System.Management.Automation.Language.VariableExpressionAst]) -or 
    ($Args[0] -is [System.Management.Automation.Language.SwitchStatementAst])
 }
}#begin

 process { 
  $ErrorsList=$TokensList=$null
  $Ast=[System.Management.Automation.Language.Parser]::ParseInput($Code,[ref]$TokensList,[ref]$ErrorsList)
  if ($ErrorsList.Count -gt 0  )
  {
     Write-error "$ErrorsList"
     $Er= New-Object System.Management.Automation.ErrorRecord(
              (New-Object System.ArgumentException("La syntaxe du code est erronée.")), 
              "InvalidSyntax", 
              "InvalidData",
              "[AST] : $(TruncateString $Code -SizeMax 40)"
           )  
     #Usage du pipeleine, on ne bloque pas les autres données.
    $PSCmdlet.WriteError($Er) 
  }
  else
  {
     #Recherche toutes les définitions de workflow
    $Workflows=$Ast.FindAll($isWorkflow, $true)
    if ($Workflows.Count -ne 0)
    {
      $Workflows|
       Foreach {
          $CurrentWF=$_ 
           
           #Permet de déterminer si la variable courante est déclarée dans le contexte 
           #du WF en cours d'analyse.   
          $StartLineNumber=$CurrentWF.Extent.StartLineNumber
          $StartColumnNumber=$CurrentWF.Extent.StartColumnNumber
          
           #Nom de toutes les variables concernées
          [string[]]$vNames=@(
               $_.FindAll($isVariable, $True)|
                 Foreach {
                   $Name=$_.VariablePath.UserPath -Replace '^(.*):(.*)$','$2'
                   if ($Name -Notmatch '^True|^False')
                   {
                      $Current=$_
                      Write-Debug "Traite la variable : $Name"
                       #Recherche si la variable est déclarée dans le workflow courant et 
                       #qu'elle n'est pas déclarée dans un bloc InlineScript ni dans une fonction (où les mots-clés VB sont autorisés) 
                      While ($Current.Parent -ne $null)
                      {
                         if($Current -is [System.Management.Automation.Language.FunctionDefinitionAst] -and (-not $Current.isWorkflow))
                         {
                             Write-Debug "Abort. La variable '$Name' est déclarée dans une fonction." 
                             break  
                         }
                         elseif($Current -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $Current.isWorkflow)
                         {
                             if (($Current.Extent.StartLineNumber -eq $StartLineNumber) -and ($Current.Extent.StartColumnNumber -eq $StartColumnNumber)) 
                             {  
                               Write-Debug "Match. La variable '$Name' est déclarée dans le workflow courant."
                               $Name
                             }
                             else
                             { Write-Debug "Abort. La variable '$Name' n'est pas déclarée dans le workflow courant." }
                             break  
                         }
                         elseif ($Current -is [System.Management.Automation.Language.CommandAst])
                         { 
                           $CE=$Current.CommandElements
                           if ( ($CE.StringConstantType -eq 'BareWord') -and ($CE.Value -eq 'InlineScript'))
                           {
                             Write-Debug "Abort. La variable '$Name' est déclarée dans un bloc InlineScript"
                             break
                           }
                         }
                         $Current=$Current.Parent
                      } #while
                   }#if
                  }#Foreach|
                  Select -Unique
          )
          
          $Comparer=New-Object PSVariableNameComparer
          $SetVar = New-Object System.Collections.Generic.HashSet[String] -argumentlist $vNames,$Comparer
           #Liste des variables dont le nom est identique à un mot clé du VB 
          $SetVar.IntersectWith($VB_Keywords)
          New-VariableWorkflow -Name $_.Name -Variables $SetVar        
       }        
    }
    else 
    {  Write-Warning "Le code ne contient pas de déclaration de workflow :$(TruncateString $Code)" }
  }
 }#process 
}#Get-VariableNamedWithVBKeywords
