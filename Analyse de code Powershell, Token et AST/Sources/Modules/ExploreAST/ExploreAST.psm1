#ExploreAST.PSM1
#Code de test d'exploration d'un AST Powershell

#Requires -Version 3.0

Import-LocalizedData -BindingVariable ExploreAstMsgs -Filename ExploreASTLocalizedData.psd1 -EA Stop
 #Exemple de syntaxe spécifique à la V3
#$ExploreAstMsgs=Import-LocalizedData -Filename ExploreASTLocalizedData.psd1 -EA Stop

#Classes C# utilisées pour parcourir l'AST et mémoriser le résultat
#
#La classe AstVisitor ne dérivant pas de la classe PSCmdlet
#on accède aux propriétés du 'moteur' PS (console, flux d'erreur,...) via la propriété 'ExecutionContext'

$Code=@'
using System.Collections;
using System.Collections.Generic; 
using System.Collections.ObjectModel; 
using System.Management.Automation;
using System.Management.Automation.Runspaces;
using System.Management.Automation.Language;

namespace Powershell.Visitor
{
    public class VisitorMembers : AstVisitor
    {
           //Code Powershell a exécuter
        public ScriptBlock Code;
        
           //Résultats des appels du ScriptBlock
        public List<PSObject> Result; 
        
        public VisitorMembers(ScriptBlock visitor)
        {
           Code= visitor;
           Result= new List<PSObject>();
        }
        
        //Helper
        public static Dictionary<string, VisitorMembers> CreateDictionary()
        {
          return new Dictionary<string, VisitorMembers>();
        }
    } 

    public class ScriptVisitor : AstVisitor
    {

         //AstVisitor doit connaitre le contexte afin de pouvoir écrire sur la console
        private EngineIntrinsics ExecutionContext;
        
         //Les méthodes Host.UI ne tiennent pas compte des variables de préférence de Powershell
        private bool isDebug;
        private bool isWarning;
        
         //On ne parcourt pas les noeuds enfants
        public  bool isSkipChildren;
        
         //Hashtable portant les méthodes du visiteur
        public Dictionary<string, VisitorMembers> Methods;

        public ScriptVisitor(EngineIntrinsics Context, Dictionary<string, VisitorMembers> methods)
        {
             //L'instance peut accéder à la session Powershell
           ExecutionContext = Context;
           
           isSkipChildren=false;
           
           SetPSPreference();
           
           if (methods != null)
            Methods=methods;
           else
            Methods= new Dictionary<string, VisitorMembers>();
        } 
        
         //Doit être appelé avant chaque visite
        public void SetPSPreference()
        {
           isDebug=(System.Management.Automation.ActionPreference)ExecutionContext.SessionState.PSVariable.Get("DebugPreference").Value == System.Management.Automation.ActionPreference.Continue ;
           isWarning=(System.Management.Automation.ActionPreference)ExecutionContext.SessionState.PSVariable.Get("WarningPreference").Value == System.Management.Automation.ActionPreference.Continue ;
        }

         //Exécute le scriptblock associé à la clé Key
        private AstVisitAction InvokePSCode(string Key,Ast ast)
        {
            VisitorMembers MyVisitorMethods;
            
            if (Methods == null)
            {
              if (isWarning) 
               ExecutionContext.Host.UI.WriteWarningLine("[ScriptVisitor] Aucune méthode n'est définie. Arrêt du parcourt de l'AST");
              return AstVisitAction.StopVisit;
            }  
            
            if (Methods.TryGetValue(Key, out MyVisitorMethods))
            {
                if (MyVisitorMethods.Code != null)
                {
                    if (isDebug)
                     ExecutionContext.Host.UI.WriteDebugLine(string.Format("[ScriptVisitor] InvokeScript '{0}'",Key));                   
                   try { 
                     //Mémorise le résultat
                     
                     // 1)
                     //La collection $Error est renseignée, les erreurs sont émisent sur la console.
                     //Les flux Debug,verbose et Warning fonctionnent. Les variables de préférence aussi.
                     //La variable automatique PSCmdlet est renseignée. 
                     //MAIS pb de portée :/                    
                /*    Collection<PSObject> ResultInvoke =  ExecutionContext.InvokeCommand.InvokeScript(
                                                           MyVisitorMethods.Code.ToString(),
                                                           false,
                                                           PipelineResultTypes.Error|
                                                            PipelineResultTypes.Warning|
                                                            PipelineResultTypes.Output,
                                                             // La présence de ces deux bits déclenchent -> NewNotImplementedException
                                                             //PipelineResultTypes.Debug, 
                                                             // PipelineResultTypes.Verbose, 
                                                           null,
                                                           new[] {ast});
                */
                    // 2)
                    //La collection $Error est renseignée, mais n'émet pas les erreurs sur la console.
                    //Les flux Debug,verbose et Warning fonctionnent. Les variables de préférence aussi.
                    //La variable automatique PSCmdlet n'est pas renseignée ( elle est à $null).
                    //Pas de pb de portée
                    Collection<PSObject> ResultInvoke = MyVisitorMethods.Code.Invoke(ast);
                    
                    //{ $null } la collection contient un élément
                    //{ Write-warning "test"} la collection ne contient pas d'élément
                    if ((ResultInvoke.Count > 0) & (MyVisitorMethods.Result != null))
                    {
                       MyVisitorMethods.Result.AddRange(ResultInvoke);
                    }
                    else if (isDebug) 
                     ExecutionContext.Host.UI.WriteDebugLine("[ScriptVisitor] Aucune information à mémoriser.");
                   } catch (System.Exception e){
                       //Le code du scriptbloc peut ne pas contenir de gestionnaire d'exception,
                       //on indique donc où a eu lieu l'erreur. l'appel suivant ne crée pas d'entrée dans $Error.
                      ExecutionContext.Host.UI.WriteErrorLine(string.Format("[ScriptVisitor.{0}] : {1}.",Key,e.Message));
                       //Le message de l'exception est affichée sur la console à la suite de celui affiché par WriteErrorLine
                      throw; 
                   }
                }
                else if (isDebug)
                  ExecutionContext.Host.UI.WriteDebugLine("[ScriptVisitor] Aucun code de déclaré.");
            }
            if (isSkipChildren) 
             return AstVisitAction.SkipChildren;
            else
             return AstVisitAction.Continue;
        } 
        
         // Chaque méthode appelle InvokePSCode
         //  Le premier paramètre correspond au nom de la clé portant 
         //  le code Powershell à exécuter, le second étant l'arbre sur lequel opérer 
        public override AstVisitAction VisitErrorStatement(ErrorStatementAst ast)
        {
                return InvokePSCode("VisitErrorStatement",ast);
        }
        public override AstVisitAction VisitErrorExpression(ErrorExpressionAst ast)
        {
                return InvokePSCode("VisitErrorExpression",ast);
        }
        public override AstVisitAction VisitScriptBlock(ScriptBlockAst ast)
        {
                return InvokePSCode("VisitScriptBlock",ast);
        }
        public override AstVisitAction VisitParamBlock(ParamBlockAst ast)
        {
                return InvokePSCode("VisitParamBlock",ast);
        }
        public override AstVisitAction VisitNamedBlock(NamedBlockAst ast)
        {
                return InvokePSCode("VisitNamedBlock",ast);
        }
        public override AstVisitAction VisitTypeConstraint(TypeConstraintAst ast)
        {
                return InvokePSCode("VisitTypeConstraint",ast);
        }
        public override AstVisitAction VisitAttribute(AttributeAst ast)
        {
                return InvokePSCode("VisitAttribute",ast);
        }
        public override AstVisitAction VisitParameter(ParameterAst ast)
        {
                return InvokePSCode("VisitParameter",ast);
        }
        public override AstVisitAction VisitTypeExpression(TypeExpressionAst ast)
        {
                return InvokePSCode("VisitTypeExpression",ast);
        }
        public override AstVisitAction VisitFunctionDefinition(FunctionDefinitionAst ast)
        {
                return InvokePSCode("VisitFunctionDefinition",ast);
        }
        public override AstVisitAction VisitStatementBlock(StatementBlockAst ast)
        {
                return InvokePSCode("VisitStatementBlock",ast);
        }
        public override AstVisitAction VisitIfStatement(IfStatementAst ast)
        {
                return InvokePSCode("VisitIfStatement",ast);
        }
        public override AstVisitAction VisitTrap(TrapStatementAst ast)
        {
                return InvokePSCode("VisitTrap",ast);
        }
        public override AstVisitAction VisitSwitchStatement(SwitchStatementAst ast)
        {
                return InvokePSCode("VisitSwitchStatement",ast);
        }
        public override AstVisitAction VisitDataStatement(DataStatementAst ast)
        {
                return InvokePSCode("VisitDataStatement",ast);
        }
        public override AstVisitAction VisitForEachStatement(ForEachStatementAst ast)
        {
                return InvokePSCode("VisitForEachStatement",ast);
        }
        public override AstVisitAction VisitDoWhileStatement(DoWhileStatementAst ast)
        {
                return InvokePSCode("VisitDoWhileStatement",ast);
        }
        public override AstVisitAction VisitForStatement(ForStatementAst ast)
        {
                return InvokePSCode("VisitForStatement",ast);
        }
        public override AstVisitAction VisitWhileStatement(WhileStatementAst ast)
        {
                return InvokePSCode("VisitWhileStatement",ast);
        }
        public override AstVisitAction VisitCatchClause(CatchClauseAst ast)
        {
                return InvokePSCode("VisitCatchClause",ast);
        }
        public override AstVisitAction VisitTryStatement(TryStatementAst ast)
        {
                return InvokePSCode("VisitTryStatement",ast);
        }
        public override AstVisitAction VisitBreakStatement(BreakStatementAst ast)
        {
                return InvokePSCode("VisitBreakStatement",ast);
        }
        public override AstVisitAction VisitContinueStatement(ContinueStatementAst ast)
        {
                return InvokePSCode("VisitContinueStatement",ast);
        }
        public override AstVisitAction VisitReturnStatement(ReturnStatementAst ast)
        {
                return InvokePSCode("VisitReturnStatement",ast);
        }
        public override AstVisitAction VisitExitStatement(ExitStatementAst ast)
        {
                return InvokePSCode("VisitExitStatement",ast);
        }
        public override AstVisitAction VisitThrowStatement(ThrowStatementAst ast)
        {
                return InvokePSCode("VisitThrowStatement",ast);
        }
        public override AstVisitAction VisitDoUntilStatement(DoUntilStatementAst ast)
        {
                return InvokePSCode("VisitDoUntilStatement",ast);
        }
        public override AstVisitAction VisitAssignmentStatement(AssignmentStatementAst ast)
        {
                return InvokePSCode("VisitAssignmentStatement",ast);
        }
        public override AstVisitAction VisitPipeline(PipelineAst ast)
        {
                return InvokePSCode("VisitPipeline",ast);
        }
        public override AstVisitAction VisitCommand(CommandAst ast)
        {
                return InvokePSCode("VisitCommand",ast);
        }
        public override AstVisitAction VisitCommandExpression(CommandExpressionAst ast)
        {
                return InvokePSCode("VisitCommandExpression",ast);
        }
        public override AstVisitAction VisitCommandParameter(CommandParameterAst ast)
        {
                return InvokePSCode("VisitCommandParameter",ast);
        }
        public override AstVisitAction VisitMergingRedirection(MergingRedirectionAst ast)
        {
                return InvokePSCode("VisitMergingRedirection",ast);
        }
        public override AstVisitAction VisitFileRedirection(FileRedirectionAst ast)
        {
                return InvokePSCode("VisitFileRedirection",ast);
        }
        public override AstVisitAction VisitBinaryExpression(BinaryExpressionAst ast)
        {
                return InvokePSCode("VisitBinaryExpression",ast);
        }
        public override AstVisitAction VisitUnaryExpression(UnaryExpressionAst ast)
        {
                return InvokePSCode("VisitUnaryExpression",ast);
        }
        public override AstVisitAction VisitConvertExpression(ConvertExpressionAst ast)
        {
                return InvokePSCode("VisitConvertExpression",ast);
        }
        public override AstVisitAction VisitConstantExpression(ConstantExpressionAst ast)
        {
                return InvokePSCode("VisitConstantExpression",ast);
        }
        public override AstVisitAction VisitStringConstantExpression(StringConstantExpressionAst ast)
        {
                return InvokePSCode("VisitStringConstantExpression",ast);
        }
        public override AstVisitAction VisitSubExpression(SubExpressionAst ast)
        {
                return InvokePSCode("VisitSubExpression",ast);
        }
        public override AstVisitAction VisitUsingExpression(UsingExpressionAst ast)
        {
                return InvokePSCode("VisitUsingExpression",ast);
        }
        public override AstVisitAction VisitVariableExpression(VariableExpressionAst ast)
        {
                return InvokePSCode("VisitVariableExpression",ast);
        }
        public override AstVisitAction VisitMemberExpression(MemberExpressionAst ast)
        {
                return InvokePSCode("VisitMemberExpression",ast);
        }
        public override AstVisitAction VisitInvokeMemberExpression(InvokeMemberExpressionAst ast)
        {
                return InvokePSCode("VisitInvokeMemberExpression",ast);
        }
        public override AstVisitAction VisitArrayExpression(ArrayExpressionAst ast)
        {
                return InvokePSCode("VisitArrayExpression",ast);
        }
        public override AstVisitAction VisitArrayLiteral(ArrayLiteralAst ast)
        {
                return InvokePSCode("VisitArrayLiteral",ast);
        }
        public override AstVisitAction VisitHashtable(HashtableAst ast)
        {
                return InvokePSCode("VisitHashtable",ast);
        }
        public override AstVisitAction VisitScriptBlockExpression(ScriptBlockExpressionAst ast)
        {
                return InvokePSCode("VisitScriptBlockExpression",ast);
        }
        public override AstVisitAction VisitParenExpression(ParenExpressionAst ast)
        {
                return InvokePSCode("VisitParenExpression",ast);
        }
        public override AstVisitAction VisitExpandableStringExpression(ExpandableStringExpressionAst ast)
        {
                return InvokePSCode("VisitExpandableStringExpression",ast);
        }
        public override AstVisitAction VisitIndexExpression(IndexExpressionAst ast)
        {
                return InvokePSCode("VisitIndexExpression",ast);
        }
        public override AstVisitAction VisitAttributedExpression(AttributedExpressionAst ast)
        {
                return InvokePSCode("VisitAttributedExpression",ast);
        }
        public override AstVisitAction VisitBlockStatement(BlockStatementAst ast)
        {
                return InvokePSCode("VisitBlockStatement",ast);
        }
        public override AstVisitAction VisitNamedAttributeArgument(NamedAttributeArgumentAst ast)
        {
                return InvokePSCode("VisitNamedAttributeArgument",ast);
        }
    }
}
'@

Add-Type -TypeDefinition $Code -Language CSharp

$ASTShortCut=@{
  AstParser = [System.Management.Automation.Language.Parser]
}

$AcceleratorsType= [PSObject].Assembly.GetType("System.Management.Automation.TypeAccelerators")
Try {
  $ASTShortCut.GetEnumerator() |
  Foreach {
   Try {
     $AcceleratorsType::Add($_.Key,$_.Value)
   } Catch [System.Management.Automation.MethodInvocationException]{
     Write-Error -Exception $_.Exception 
   }
 } 
} Catch [System.Management.Automation.RuntimeException] {
   Write-Error -Exception $_.Exception
}

 #http://technet.microsoft.com/en-us/library/hh847741.aspx
$script:CoreModules=@(
 'Microsoft.PowerShell.Core',
 'Microsoft.PowerShell.Diagnostics',
 'Microsoft.PowerShell.Host',
 'Microsoft.PowerShell.Management',
 'Microsoft.PowerShell.Security',
 'Microsoft.PowerShell.Utility',
 'Microsoft.WSMan.Management',
 'ISE',
 'PSDesiredStateConfiguration', #PS v4
 'PSScheduledJob',
 'PSWorkflow',
 'PSWorkflowUtility' 
)

 #Crée le cache hébergeant les alias
 #todo classe C#, car ainsi il n'y a pas de contrainte sur PSTypename ... 
$script:AliasCache= New-Object 'System.Collections.Generic.Dictionary[string,PSObject]'([StringComparer]::CurrentCultureIgnoreCase)

function Reset-AliasCache {
 $script:AliasCache.Clear()
}

Function New-ResolvedAliasInformation{
#Crée un PSobjet contenant les informations de résolution d'un alias 
  param(
     [Parameter(Mandatory=$True,position=0)]
    $ModuleName,
     [Parameter(Mandatory=$True,position=1)]
    $CommandName
  )
 $O=New-Object PSObject -Property $PSBoundParameters
 $O.PsObject.TypeNames.Insert(0,"ResolvedAliasInformation")
 $O
}#New-ResolvedAliasInformation

Function Get-ResolvedAliasName {
#Renvoi, à partir d'informations de résolution d'alias, un nom court ou long d'une commande.         
 param(
      [Parameter(position=0,Mandatory=$true)]
      [PSTypename("ResolvedAliasInformation")]
    $InputObject,

    [switch] $All,
    
    [switch] $ShortName
 )
  if ($All -and $ShortName)
  {throw "Les paramètres All et ShortName sont exclusif."} 
  
  if ( $ShortName -or ([string]::IsNullOrEmpty($InputObject.ModuleName)) -or (-not $All -and ($script:CoreModules -Contains $InputObject.ModuleName)))
  { $CmdName="{0}" -F $InputObject.CommandName }
  else 
  { $CmdName="{0}\{1}" -F $InputObject.ModuleName,$InputObject.CommandName }
  Write-Debug "Return : $CmdName"
  $CmdName
}#Get-ResolvedAliasName

Function Test-ExploreASTpsd1 {
#Démos pour Test-LocalizedData
#Evite la création d'un jeux de test... 
 Write-Error $ExploreAstMsgs.UnknownLocalizedDataKey
}

function Get-AST {
#from http://becomelotr.wordpress.com/2011/12/19/powershell-vnext-ast/

<#

.Synopsis
   Function to generate AST (Abstract Syntax Tree) for PowerShell code.

.DESCRIPTION
   This function will generate Abstract Syntax Tree for PowerShell code, either from file or direct input.
   Abstract Syntax Tree is a new feature of PowerShell 3 that should make parsing PS code easier.
   Because of nature of resulting object(s) it may be hard to read (different object types are mixed in output).

.EXAMPLE
   $AST = Get-AST -FilePath MyScript.ps1
   $AST will contain syntax tree for MyScript script. Default are used for list of tokens ($Tokens) and errors ($Errors).

.EXAMPLE
   Get-AST -Input 'function Foo { param ($Foo) Write-Host $Foo }' -Tokens MyTokens -Errors MyErors | Format-Custom
   Display function's AST in Custom View. $MyTokens contain all tokens, $MyErrors would be empty (no errors should be recorded).

.INPUTS
   System.String

.OUTPUTS
   System.Management.Automation.Languagage.Ast

.NOTES
   Just concept of function to work with AST. Needs a polish and shouldn't polute Global scope in a way it does ATM.

#>

[CmdletBinding(
    DefaultParameterSetName = 'File'
)]
param (
    # Path to file to process.
    [Parameter(
        Mandatory,
        HelpMessage = 'Path to file to process',
        ParameterSetName = 'File'
    )]
    [Alias('Path','PSPath')]
    [ValidateScript({
        if (Test-Path -Path $_ -ErrorAction SilentlyContinue) {
            $true
        } else {
            throw "File does not exist!"
        }
    })]
    [string]$FilePath,
    
    # Input string to process.
    [Parameter(
        Mandatory,
        HelpMessage = 'String to process',
        ParameterSetName = 'Input'

    )]
    [Alias('Script','IS')]
    [string]$InputScript,

    # Name of the list of Errors.
    [Alias('EL')]
    [ValidateScript({$_ -ne 'ErrorsList'})] 
    [string]$ErrorsList = 'ErrorsAst',
    
    # Name of the list of Tokens.
    [Alias('TL')]
    [ValidateScript({$_ -ne 'TokensList'})]
    [string]$TokensList = 'Tokens',
    [switch] $Strict
)
    New-Variable -Name $ErrorsList -Value $null -Scope Global -Force
    New-Variable -Name $TokensList -Value $null -Scope Global -Force


    switch ($psCmdlet.ParameterSetName) {
        File {
            $ParseFile = (Resolve-Path -Path $FilePath).ProviderPath
            [AstParser]::ParseFile(
                $ParseFile, 
                [ref](Get-Variable -Name $TokensList),
                [ref](Get-Variable -Name $ErrorsList)
            )
        }
        Input {
            [AstParser]::ParseInput(
                $InputScript, 
                [ref](Get-Variable -Name $TokensList),
                [ref](Get-Variable -Name $ErrorsList)
            )
        }
    }
   if ( (Get-Variable $ErrorsList).Value.Count -gt 0  )
   {
      $Er= New-Object System.Management.Automation.ErrorRecord(
              (New-Object System.ArgumentException("La syntaxe du code est erronée.")), 
              "InvalidSyntax", 
              "InvalidData",
              "[AST]"
             )  

      if ($Strict) 
      { $PSCmdlet.ThrowTerminatingError($Er)}
      else
      { $PSCmdlet.WriteError($Er)}
   }
} #Get-AST

#Association ClasseAST-MethodeVisitorAST
$script:cmAST=[ordered]@{}
[System.Management.Automation.Language.AstVisitor].GetMethods() |
  Where { $_.Name -like 'Visit*' }| 
  Sort Name|
  ForEach {
   $cmAST.($_.GetParameters()[0].ParameterType.Name)=$_.Name
  }

filter New-ASTMethod{
<#
.SYNOPSIS
   Crée le code C# d'une méthode virtuelle pour une classe dérivée de 
   [System.Management.Automation.Language.Ast]. 
   Permet de ne déclarer que les méthodes utilisées par un traitement spécifique.
#>

# $Methods=@(
#  'VisitCommand',
#  'VisitCommandExpression',
#  'VisitCommandParameter'
# )
# 
# $script:cmAST.GetEnumerator()|
#  Where {$_.Value -in $Methods}|
#  New-ASTMethod  
 
@"
    public override AstVisitAction $($_.Value)($($_.Key) ast)
    {
         return InvokePSCode("$($_.Name)",ast);
    }
"@          
}#New-ASTMethod

function New-ICustomASTMethod{
<#
.SYNOPSIS
   Crée le code C# des méthodes de l'interface  
   [System.Management.Automation.Language.ICustomAstVisitor] 
#>  
 
$script:cmAST.GetEnumerator()|
    ForEach {
@"
    public object $($_.Value)($($_.Key) ast)
    {
        return ast;
    }
"@          
    }#foreach
}#New-ICustomASTMethod

function New-AstVisitor {
<#
.SYNOPSIS
   Crée un visiteur AST de type Powershell.Visitor.ScriptVisitor
#>  
 [CmdletBinding()] 
 param(
   #Hashtable spécialisée associée au ScriptVisitor contenant le code à exécuter pour chaque un type de noeud et son résultat d'exécution.
   #Le nom de la clé est un nom de classe AST Powershell, la valeur est une instance de la classe VisitorMembers
  [System.Collections.Generic.Dictionary[string, Powershell.Visitor.VisitorMembers]] $Methods,
  
     #Ne parcourt pas les noeuds enfants
  [switch] $SkipChildren
 )
   #On récupère le contexte d'exécution de la session, pas celui du module. 
  $Visitor=New-Object Powershell.Visitor.ScriptVisitor(($PSCmdlet.SessionState.PSVariable.Get("ExecutionContext").Value),$Methods)
  $Visitor.isSkipChildren=$SkipChildren
  $Visitor 
} #New-AstVisitor

function Invoke-ScriptVisitor{
<#
.SYNOPSIS
   Exécute la méthode Visit() sur un AST
#>   
 [CmdletBinding()]          
 param(
     #Noeud AST a parcourir
    [Parameter(Mandatory=$true)]
    [ValidateScript( {$_.GetType().IsSubclassOf("System.Management.Automation.Language.Ast")} )]
   $Ast, 
    
    #Visiteur AST Powershell
    [Parameter(Mandatory=$true)]
   [Powershell.Visitor.ScriptVisitor] $Visitor,
  
   #Hashtable contenant le code à exécuter pour chaque type de noeud et son résultat d'exécution
   #Le nom de la clé est un nom de classe AST Powershell
   [Parameter(Mandatory=$false)]
   [System.Collections.Generic.Dictionary[string, Powershell.Visitor.VisitorMembers]] $Methods
  )
 
 if ($PSBoundParameters.ContainsKey('Methods'))
 { $Visitor.Methods=$Methods }
  #Redéfinie les variables de préférence Debug et Warning
 $Visitor.SetPSPreference()
 $AST.Visit($Visitor) 
} #Invoke-ScriptVisitor

Function Invoke-Visitors {
<#
.SYNOPSIS
   (Command pattern) Construit l'Ast d'un script, crée un visiteur à partir de $VisitorScript puis exécute l'analyse.
   Renvoi l'AST correspondant au contenu du script.
#>
 [CmdletBinding(DefaultParameterSetName = 'File')]
 param(
      # Path to file to process.
    [Parameter(Mandatory, ParameterSetName = 'File' )]
    [Alias('Path','PSPath')]
    [string]$FilePath,
   
    # Input string to process.
    [Parameter(Mandatory,ParameterSetName = 'Input')]
    [Alias('Script','IS')]
    [string]$InputScript,
  
    #Hashtable contenant le code à exécuter pour chaque un type de noeud.
    #Le nom de la clé est un nom de classe AST Powershell
  #[System.Collections.Generic.Dictionary[string, Powershell.Visitor.VisitorMembers]] 
  $VisitorScript,
   
   #Ne parcourt pas les noeuds enfants
  [switch] $SkipChildren
 )
 if ($psCmdlet.ParameterSetName -eq 'File')
 { $Ast= Get-AST -FilePath $FilePath }
 else
 { $Ast= Get-AST -Input $InputScript }

 $Visitor=New-AstVisitor $VisitorScript -SkipChildren:$SkipChildren
  Write-debug "$($Visitor -eq $null)"
 Invoke-ScriptVisitor $Ast.EndBlock.Statements $Visitor
 $Ast
} #Invoke-Visitors

function New-VisitorMembersDictionnary {
<#
.SYNOPSIS
   Crée une hashtable de type [System.Collections.Generic.Dictionary[string, Powershell.Visitor.VisitorMembers]]
#>
  [CmdletBinding(DefaultParameterSetName="Empty")]
 param(
   #Scriptbloc à exécuter pour chaque méthode VisitXYZ
 	[parameter(ParameterSetName="All")]
  [ScriptBlock] $Code={Param ($Ast) Write-Warning $Ast.Gettype();$Ast},
  #Implémente toutes les méthodes Visitxx
  [parameter(Mandatory=$True,ParameterSetName="All")]
 [switch] $All
 )   
  $H=[Powershell.Visitor.VisitorMembers]::CreateDictionary()
  if ($All) 
  {
    $cmAst.Getenumerator()|
     foreach {
      $key=$_.Value
      $H.$Key=$Code
     }
   }
  $H 
} #New-VisitorMembersDictionnary

function Format-VisitorMembersDictionnary {
<#
.SYNOPSIS
   Affiche le contenu d'une hashtable de type [System.Collections.Generic.Dictionary[string, Powershell.Visitor.VisitorMembers]]
#>   
  param(
      #Hashtable contenant le code à exécuter pour chaque type de noeud et son résultat d'exécution
      #Le nom de la clé est un nom de classe AST Powershell
     [Parameter(position=0,Mandatory=$true,ValueFromPipeline = $true)]
   [System.Collections.Generic.Dictionary[string, Powershell.Visitor.VisitorMembers]] $VisitorMembersDictionnary
  )
 process {  
  $VisitorMembersDictionnary.GetEnumerator()|
   Format-List @{Name='Result';E={$_.Value.Result}},@{Name='Code';E={$_.Value.Code}} -GroupBy Key
 }
} #Format-VisitorMembersDictionnary


Function New-FunctorASTClass{
<#
.SYNOPSIS
   Crée un scritpbloc de type System.Func[System.Management.Automation.Language.Ast,bool]
   Ce scriptbloc peut être utilisé avec les méthodes Find() ou FindAll() d'une instance de classe AST
#>   
# $F=New-FunctorASTClass ErrorStatementAst
# $Ast.FindAll($F, $true)        

 [OutputType([System.Func[System.Management.Automation.Language.Ast,bool]])]
 param (
   #Nom de classe à tester dans le foncteur
  [ValidateSet(
    'ArrayExpressionAst',
    'ArrayLiteralAst',
    'AssignmentStatementAst',
    'AttributeAst',
    'AttributedExpressionAst',
    'BinaryExpressionAst',
    'BlockStatementAst',
    'BreakStatementAst',
    'CatchClauseAst',
    'CommandAst',
    'CommandExpressionAst',
    'CommandParameterAst',
    'ConstantExpressionAst',
    'ContinueStatementAst',
    'ConvertExpressionAst',
    'DataStatementAst',
    'DoUntilStatementAst',
    'DoWhileStatementAst',
    'ErrorExpressionAst',
    'ErrorStatementAst',
    'ExitStatementAst',
    'ExpandableStringExpressionAst',
    'FileRedirectionAst',
    'ForEachStatementAst',
    'ForStatementAst',
    'FunctionDefinitionAst',
    'HashtableAst',
    'IfStatementAst',
    'IndexExpressionAst',
    'InvokeMemberExpressionAst',
    'MemberExpressionAst',
    'MergingRedirectionAst',
    'NamedAttributeArgumentAst',
    'NamedBlockAst',
    'ParamBlockAst',
    'ParameterAst',
    'ParenExpressionAst',
    'PipelineAst',
    'ReturnStatementAst',
    'ScriptBlockAst',
    'ScriptBlockExpressionAst',
    'StatementBlockAst',
    'StringConstantExpressionAst',
    'SubExpressionAst',
    'SwitchStatementAst',
    'ThrowStatementAst',
    'TrapStatementAst',
    'TryStatementAst',
    'TypeConstraintAst',
    'TypeExpressionAst',
    'UnaryExpressionAst',
    'UsingExpressionAst',
    'VariableExpressionAst',
    'WhileStatementAst' )]
    [string] $Class
 )
 [scriptblock]::Create("`$args[0] -is [System.Management.Automation.Language.$Class]")
} # New-FunctorASTClass

function Get-AstClasse {
<#
.SYNOPSIS
   Renvoi les classes AST publiques de Powershell.
#>   
 $Asm=[System.AppDomain]::CurrentDomain.GetAssemblies()|
        Where {$_.ManifestModule.Name -eq 'System.Management.Automation.dll'}
 $Asm.GetExportedTypes() |
  Where {$_.Name -match 'Ast$'}
}#Get-AstClasse

function Convert-ResultCollection {
<#
.SYNOPSIS
   Développe chaque collection contenue dans le champ 'Result' d'une instance de type Powershell.Visitor.VisitorMembers.
   Les collections vide ne sont pas concernées.
#>   
  param(
      #Hashtable contenant le code à exécuter pour chaque type de noeud et son résultat d'exécution
      #Le nom de la clé est un nom de classe AST Powershell
     [Parameter(position=0,Mandatory=$true,ValueFromPipeline = $true)]
   [System.Collections.Generic.Dictionary[string, Powershell.Visitor.VisitorMembers]] $VisitorMembersDictionnary
  )         
 Foreach ($Item in $VisitorMembersDictionnary.GetEnumerator())
 {
   if ($Item.Value.Result -ne $null)
   {$Item.Value.Result |Foreach {$_}} 
 }
}#Convert-ResultCollection

function ConvertFrom-Alias { 
<#
.SYNOPSIS
   Converti un nom d'alias en un nom de commande.
   Par défaut renvoi le nom de commande préfixé du nom de module.
   Le configuration de la variable $PSModuleAutoloadingPreference affectera le résultat.
#>
           
 param(
   #Nom de l'alias à rechercher.
   [Parameter(Mandatory=$true, position=1)]
  [string] $CommandName,
  
   #Par défaut la gestion des collisions de nom de commande
   #ne concerne pas les modules du runtime Powershell.
  [switch] $All,
  
   #Renvoi le nom de la commande sans être préfixée du nom de module.
  [switch] $ShortName
 )  
   Write-debug "ConvertFrom-Alias '$CommandName'"
   if ($All -and $ShortName)
   {throw "Les paramètres All et ShortName sont exclusif."} 

     #Gestion du cache des alias
      #renvoi l'objet ou $null s'il n'existe pas
    $CmdName=$Null
    if ($script:AliasCache.TryGetValue($CommandName, [ref]$CmdName))
    {
      Write-Debug "Objet '$CmdName' présent dans le cache."
      return (Get-ResolvedAliasName $CmdName -ShortName:$ShortName -All:$All)
    } 
    #Get-Command utilise PSModuleAutoloading, mais pas Get-Alias
    # ErrorAction est nécessaire si on ne trouve pas le module 
    # ou si l'alias est dans un module imbriqué.
    #PSModuleAutoloading ne recherche que dans les modules 'primaire' (cf. RootModule d'un manifest) 
   if ($CommandName -eq '?') 
   { $result = Get-Command '`?'  -CommandType Alias } 
   else 
   { $result = Get-Command $CommandName  -CommandType Alias -ErrorAction SilentlyContinue}

   if($result)
   {
      Write-Debug "Create cache entry for '$CommandName' alias."
      $RAI=New-ResolvedAliasInformation $Result.ResolvedCommand.ModuleName $Result.ResolvedCommand.Name
      if (-not $script:AliasCache.ContainsKey($CommandName)) 
      {
        $script:AliasCache.Add($CommandName, $RAI)
      } 
      
      #Dans le cas ou l'alias pointe sur un alias
      #ResolvedCommand référence la commande primaire.
      #
      #L'alias Cls est une fonction injectée par le runtime, 
      # la propriété ModuleName n'est donc pas renseignée. 
      Get-ResolvedAliasName $RAI -ShortName:$ShortName 
  }
  else { Write-Debug "`tAlias not found for the command '$CommandName'."}
}#ConvertFrom-Alias 

Function Expand-Alias {
<#
.SYNOPSIS
   Modifie dans un code source les noms d'alias par leur nom de commande.
   Renvoi le code source modifié.
   Le configuration de la variable $PSModuleAutoloadingPreference influencera la résolution des alias.
   Des modules peuvent donc être chargés implicitement dans l'état de session de l'appelant. 
#>           
 param( 
   #Code source à modifier. 
   #Celui-ci doit être une chaîne de caractères et pas un tableau de chaînes, car 
   #on utilise l'offset (l'index dans la chaîne) et pas les coordonnée Ligne,Colonne.
  [string] $Content,
  
   #Par défaut la gestion des collisions de nom de commande
   #ne concerne pas les modules du runtime Powershell.
  [switch] $All,
  
   #Renvoi le nom de la commande sans être préfixée du nom de module.
  [switch] $ShortName
 )
 
  $sb = New-Object System.Text.StringBuilder $Content
  [ref]$TokenErrors=$null
  [System.Management.Automation.PsParser]::Tokenize($Content, $TokenErrors) |
    Where { $_.Type -eq 'Command'} |
     #Astuce : Débuter la modification de texte en partant de la fin, évite d'invalider la position des autres tokens.
    Sort StartLine, StartColumn -Desc |  
     ForEach {
          $CmdName= ConvertFrom-Alias $_.Content -All:$All -ShortName:$ShortName
          if ($CmdName -ne $null)
          {
            Write-Debug "Expand alias '$($_.Content)' to '$CmdName'."  
            $Pos=$_.Start
             #Supprime le texte de l'alias,
             #puis insére le texte du nom de commande.
            $sb.Remove($Pos,$_.Length).Insert($Pos,$CmdName) > $null
          }
    }
 $sb.ToString()
}#Expand-Alias   

Function Test-ParameterSet{
<#
.SYNOPSIS
   Détermine si les jeux de paramètres d'une commande sont valides.
   Un jeux de paramètres valide doit contenir au moins un paramètre unique et
   les numéros de positions de ses paramètres doivent se suivre et ne pas être dupliqué.
#>  

 param (
   #Nom de la commande à tester
  [parameter(Mandatory=$True,ValueFromPipeline=$True)]
  [string]$Command
 ) 
begin {
 [string[]] $CommonParameters=[System.Management.Automation.Internal.CommonParameters].GetProperties()| 
                               Foreach {$_.Name}
 function Test-Sequential{
  #La collection doit être triée
  param([int[]]$List)
    $Count=$List.Count
    for ($i = 1; $i -lt $Count; $i++)
    {
       if ($List[$i] -ne $List[$i - 1] + 1)
       {return $false}
    }
    return $true
 }# Test-Sequential
}#end

process {
  $Cmd=Get-Command $Command
  Write-Debug "Test $Command"
  
        #bug PS : https://connect.microsoft.com/PowerShell/feedback/details/653708/function-the-metadata-for-a-function-are-not-returned-when-a-parameter-has-an-unknow-data-type
  $oldEAP,$ErrorActionPreference=$ErrorActionPreference,'Stop'
   $SetCount=$Cmd.get_ParameterSets().count
  $ErrorActionPreference=$oldEAP

  $_AllNames=@($Cmd.ParameterSets|
            Foreach {
              $PrmStName=$_.Name
              $P=$_.Parameters|Foreach {$_.Name}|Where  {$_ -notin $CommonParameters} 
              Write-Debug "Build $PrmStName $($P.Count)"
              if (($P.Count) -eq 0)
              { Write-Warning "[$($Cmd.Name)]: the parameter set '$PrmStName' is empty." }
              $P
            })

  $Sets=@{}
  Add-Member -Input $Sets -MemberType NoteProperty -Name CommandName -value $Cmd.Name 
  if ($_AllNames.Count -eq 0 ) 
  { return $Sets  }
   
   #Contient les noms des paramètre de tous les jeux
   #Les noms peuvent être dupliqués
  $AllNames=new-object System.Collections.ArrayList(,$_AllNames)
  
  $Cmd.ParameterSets| 
   foreach {
     $Name=$_.Name
      #Contient tous les noms de paramètre du jeux courant
     $Params=new-object System.Collections.ArrayList
      #Contient les positions des paramètres du jeux courant
     $Positions=new-object System.Collections.ArrayList
     $Others=$AllNames.Clone()
     
     $_.Parameters|
      Where {$_.Name -notin $CommonParameters}|
      Foreach {
        Write-debug "Add $($_.Name) $($_.Position)"
        $Params.Add($_.Name) > $null
        $Positions.Add($_.Position) > $null
      }
     
      #Supprime dans la collection globale
      #les noms de paramètres du jeux courant
     $Params| 
      Foreach { 
        Write-Debug "Remove $_"
        $Others.Remove($_) 
      }

      #Supprime les valeurs des positions par défaut
     $FilterPositions=$Positions|Where {$_ -ge 0}
      #Get-Unique attend une collection triée
     $SortedPositions=$FilterPositions|Sort-Object  
     $isDuplicate= -not (@($SortedPositions|Get-Unique).Count -eq $FilterPositions.Count)
     $isSequential= Test-Sequential $SortedPositions
     
     $isPositionValid=($isDuplicate -eq $False) -and ($isSequential -eq $true)
     
     $HasParameterUnique= &{
         if ($Others.Count -eq 0 ) 
         { 
           Write-Debug "Only one parameter set."
           return $true
         }
         foreach ($Current in $Params)
         {
           if ($Current -notin $Others)
           { return $true}
         }
         return $false           
      }#$HasParameterUnique
            
     $O=[psCustomObject]@{
            #Mémorise les informations.
            #Utiles en cas de construction de rapport
           Params=$Params;
           Others=$Others;
           Positions=$Positions;
            
            #Les propriété suivantes indiquent la ou les causes d'erreur
           isHasUniqueParameter= $HasParameterUnique;

           isPositionContainsDuplicate= $isDuplicate;
            #S'il existe des nombres dupliqués, la collection ne peut pas être une suite
           isPositionSequential= $isSequential
            
           isPositionValid= $isPositionValid
           
            #La propriété suivante indique si le jeux de paramètre est valide ou pas.
           isValid= $HasParameterUnique -and $isPositionValid
         }#PSObject
     Write-Debug "Add $Name key"
     $Sets.$Name=$O
   }#For ParameterSets
   ,$Sets
 }#process
}#Test-ParameterSet


function Test-CommandASTScript {
 #La commande est-elle un appel à un script .ps1?
 #suppose le paramère AST du type [System.Management.Automation.Language.CommandAst] 
#Vrai pour : 
#    &Myfunction
#    . Myfunction
#    &$mySB
#    .$mySB
#    &"C:\temp\Traitement.ps1"
#    ."C:\temp\Traitement.ps1"
#    . .\Traitement.ps1
#    .\Traitement.ps1
#
#Faux pour 
#    .Myfunction  #Pas d'erreur lors de l'analyse, mais à l'exécution
#    Dir c:\temp
#    Myfunction
#    Notepad.exe #etc...
         
param ($Ast)
         
 if ($Ast.InvocationOperator -in ('Ampersand','Dot'))
 {$true}
 elseif ( ($Ast.InvocationOperator -eq 'Unknown') -and ($Ast.Extent -match '\.\\(.*)\.ps1$') )  
 {$true}
 else
 {$false} 
}#Test-CommandASTScript
 
function Get-ParameterAlias {
<#
.SYNOPSIS
  Renvoi la liste des alias de paramètre d'une commande (cmdlet,script,fonction).
#>             
 param (
   #Metadonnées de la commande à interroger
  $CmdInfo
 )
         
 $H=@{}

 $CmdInfo.Parameters.GetEnumerator()|
 Foreach {
    $ParamName=$_.Key
    $_.Value.Aliases|
    Foreach { 
      #Nom d'alias=Nom de paramètre
     $H.$_=$ParamName
    }
 }
 ,$H
}#Get-ParameterAlias

Function Get-CommandParameter{ 
<#
.SYNOPSIS
   Recherche dans une ligne d'appel de commande, l'argument associé à un nom de paramètre.
   puis extrait la valeur des paramètres indiqués dans $Parameter.
   Le résultat est une hashtable nomDeParametre=ValeurArgument pouvant contenir une chaîne de caractères ou un noeud AST. 
   Les appels de script ne sont pas gérés dans cette version.
#>     
 param(
    #Arbre de syntaxe à analyser
   $Ast,
    
    #Nom du cmdlet a rechercher. Les noms d'alias sont transformés.
   [string] $CommandName, #todo le nom de commande est par défaut un nom court, 
                          #implémenter la recherche sur un nom long : ModuleName\CmdName
    
    #Les noms complets des paramètres à rechercher, si le nom n'est pas un nom complet une erreur est déclenchée.
    #Si le nom est un nom d'alias une erreur est déclenchée.
    #Par exemple, pour rechercher le paramètre 'ErrorAction' vous devez indiquer son nom complet, ni 'EA', ni 'ErrorA'.  
    #En revanche la ligne de commande analysée peut contenir le nom de paramètre 'ErrorAction', 'Error' 'ErrorAc' ou 'EA'.
   [string[]]$Parameter 
 )
try {
 if ($Ast -is [System.Management.Automation.Language.CommandAst])
 {
   $Result=$null
    #Le premier élément est le nom de commande/nom d'alias
   $CommandElement=$Ast.CommandElements[0] 
   Write-debug "CommandElement=$CommandElement"
    
   $Name=$CommandElement.Value
    # Les syntaxes suivante sont possibles :
    # &"Get-ChildItem", &Get-ChildItem, . Get-ChildItem et . "Get-ChildItem"  
    #todo  :  -and (Test-CommandASTScript $Ast)) #cas d'un alias pointant sur un script ?
   If (-not [string]::IsNullOrEmpty($Name))  
   {
     $ResolvedAlias=ConvertFrom-Alias $Name -ShortName
     if ($ResolvedAlias -ne $null)
     {
       $Name=$ResolvedAlias
       Write-debug "Change '$($CommandElement.value)' to '$Name'"
     }
   } 
   
   Write-debug "'$Name' -eq '$CommandName'" 
    #Recherche le nom de commande
    #Uniquement les constructions 'simples' : NomDeCmdlet -param
   if (($Name -eq $CommandName) -and ($CommandElement.StringConstantType -eq 'BareWord') )
   {
      Write-debug "Found '$CommandName'"
       #Les métadatas de la commande sont nécessaires pour contrôler le nom des paramètres recherchés.
       #La ligne de commande peut contenir un ou des noms du paramètres considérés comme ambigus lors 
       # de l'exécution du ParameterBinding. 
      $Command=Get-Command $CommandName 
      if ($Command.CommandType -ne "Application")
      {
        $Result=@{}
        $Alias=Get-ParameterAlias $Command
        foreach ($SearchedParameter in $Parameter) 
        {
          write-debug "Recherche le paramètre '$SearchedParameter'"
          $I=0
          
          $SearchedParameterAlias=$Alias.$SearchedParameter
          if ($SearchedParameterAlias -ne $null)
          {
            Write-Error ($ExploreAstMsgs.AliasParameterNotSupported -F  $SearchedParameter,$SearchedParameterAlias)
            Continue 
          }
          elseif ($SearchedParameter -notin $Command.Parameters.Keys)
          {
            Write-Error ($ExploreAstMsgs.UnknownParameterName -F $SearchedParameter,$CommandName)
            Continue 
          }
        
          #Un paramètre obligatoire peut être précisé dans $PSDefaultParameterValues,
          #il peut donc ne pas être précisé sur la ligne de commande.
          #Ce cas n'est pas géré, ni la valeur par défaut d'un paramètre
          foreach ($Element in $Ast.CommandElements)
          {
            $I++ 
            if ($Element -is [System.Management.Automation.Language.CommandParameterAst])
            {
              Write-debug "I=$I Recherche le paramètre AST '$($Element.ParameterName)'"
              
              $AstParameterName=$Element.ParameterName
              try {
                  #Resolves a full, shortened, or aliased parameter name to the actual cmdlet parameter name, 
                  #using the parameter resolution algorithm in Windows PowerShell. 
                 $ResolveParameter=$Command.ResolveParameter($AstParameterName)
                 $AstParameterName=$ResolveParameter.Name
              } 
              catch [System.Management.Automation.ParameterBindingException] {
                Write-Error -Exception $_.Exception  
                continue     
              }
              if ($SearchedParameter -eq $AstParameterName)
              { 
                 write-debug "`t`t '$AstParameterName' bind to '$SearchedParameter'"
                 write-debug "`t`t '$SearchedParameter' type=$($ResolveParameter.ParameterType)"
  
                 #Seule la syntaxe -param:argument assure du couplage Paramétre:Valeur du paramètre
                 # car la syntaxe suivante est aussi possible : Comdlet -NomParamTypeSwitch ArgumentPositionel_1 
                 #L'AST est 'statique', ces régles sont validées à l'exécution :
                 #  http://msdn.microsoft.com/en-us/library/system.management.automation.language.commandparameterast%28v=vs.85%29.aspx 
                if ($Element.Argument -ne $null)
                {
                    #On récupère la valeur de l'argument
                   Write-Debug "La valeur de l'argument est '$($Element.Argument.Value)'"
                    #Value est un noeud AST qui peut contenir une chaîne de caractères,
                    #un tableau d'élément, un nom de variable, un appel à une fonction,...
                    #l'appelant analysera le résultat
                   $Result.$SearchedParameter=$Element.Argument.Value
                   break
                } 
                elseif ($ResolveParameter.ParameterType.Fullname -ne 'System.Management.Automation.SwitchParameter')
                {
                    #Sinon l'argument est dans l'élément (noeud AST) suivant
                    #S'il contient un nom de variable on ne sait pas, via l'AST, déterminer son contenu.
                   $Result.$SearchedParameter=$Ast.CommandElements[$I]
                } 
              }
              else
              { write-debug "`t`t '$AstParameterName' ne concerne pas '$SearchedParameter'" }        
            }
          }#foreach  $Ast.CommandElements
         }#foreach  $parameter 
       }#if CommandType
       
       if ($Result -ne $null) 
       { 
           Write-debug "Send Result"
          ,$Result  
       }
    }#if -eq $CommandName
  }#if -is CommandAst
 } catch {  
      #Permet de tracer l'origine de l'erreur, s'il est exécuté dans un visitor
      Write-Debug "EXCEPTION Get-CommandParameter : $($_.exception)"
      throw $_ 
 }

}#Get-CommandParameter

Function Test-RuleEmptyCatchBlock {
#D'après CheckInPolicy.CheckForEmptyCatchBlock - MS Script Browser
 param($catchClauseAst) 
 $Result=$false
 if ($catchClauseAst -is [System.Management.Automation.Language.CatchClauseAst])
 {
   $Result=$catchClauseAst.Body.Statements.Count -eq 0
   Write-Warning "RuleEmptyCatchBlock is $Result := $catchClauseAst"
 }
 $Result
}#Test-RuleEmptyCatchBlock

function Split-VariablePath {
<#
.SYNOPSIS
   Supprime l'indicateur de portée précisé dans le nom de variable          
#>            
 param (
  [System.Management.Automation.Language.VariableExpressionAst] $VEA
 )
 $VEA.VariablePath.UserPath -Replace '^(.*):(.*)$','$2'
}#Split-VariablePath

# Suppression des objets du module 
Function OnRemoveExploreAST {
  $ASTShortCut.GetEnumerator()|
   Foreach {
     Try {
       [void]$AcceleratorsType::Remove($_.Key)
     } Catch {
       write-Error -Exception $_.Exception 
     }
   }
}#OnRemoveExploreAST
 
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveExploreAST }

 #Propriétés de tri
$SortExtent=@({$_.Extent.StartLineNumber},{$_.Extent.StartColumnNumber})

Export-ModuleMember -Function * -Variable cmAST,SortExtent