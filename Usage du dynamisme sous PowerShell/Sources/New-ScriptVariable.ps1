function Compile-Csharp ([string] $code, [Array]$References) { 
 #Compile à la volée du code CSharp un assembly
 # code de Jeffrey Snover adapté par Greg Borota proposé sur "microsoft.public.windows.powershell"
 #  Code d'origine : http://blogs.msdn.com/powershell/archive/2006/04/25/583236.aspx
 
  # Get an instance of the CSharp code provider 
  $cp = New-Object Microsoft.CSharp.CSharpCodeProvider 
   # Recherche dans la registry le répertoire des assemblies de Powershell
  $PathAssemblies=Dir -path "HKLM:\Software\Microsoft\.NETFramework\AssemblyFolders"|`
                   ? {$_.Name -Match "PowerShell 1.0"}|`
                   % {(gp -path $_.PsPath -ea SilentlyContinue)."(default)"}
  $framework = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory() 

  $refs = New-Object Collections.ArrayList 
  $refs.AddRange( @("${framework}System.dll", 
   "${PathAssemblies}\System.Management.Automation.dll", 
   "${PathAssemblies}\Microsoft.PowerShell.ConsoleHost.dll", 
   "${framework}System.Windows.Forms.dll", 
   "${framework}System.Data.dll", 
   "${framework}System.Drawing.dll", 
   "${framework}System.XML.dll")) 
   if ($References.Count -ge 1) { 
    $refs.AddRange($References) 
   } 
  
  # Build up a compiler params object... 
  $cpar = New-Object System.CodeDom.Compiler.CompilerParameters 
  $cpar.GenerateInMemory = $true 
  $cpar.GenerateExecutable = $false
  $cpar.IncludeDebugInformation = $false 
  $cpar.CompilerOptions = "/target:library" 
  $cpar.ReferencedAssemblies.AddRange($refs) 
  $cr = $cp.CompileAssemblyFromSource($cpar, $code) 
  
  if ( $cr.Errors.Count) { 
    $codeLines = $code.Split("`n"); 
    foreach ($ce in $cr.Errors) { 
      write-host "Error: $($codeLines[$($ce.Line - 1)])" 
      $ce | out-default 
    } 
    Throw "INVALID DATA: Errors encountered while compiling code" 
  } 
} 

Function New-ScriptVariable($name, 
                            [ScriptBlock] $getter, 
                            [ScriptBlock] $setter) 
{
# http://www.leeholmes.com/blog/MoreTiedVariablesInPowerShell.aspx
# http://blogs.msdn.com/powershell/archive/2009/03/26/tied-variables-in-powershell.aspx
#
#Cette fonction crée une variable liè à un scriptblock, l'accès à une telle variable 
#déclenche automatiquement l'appel au scriptblock attaché.

#La variable crée peut être en lecture seule si on ne déclare pas de setter :
# New-ScriptVariable GLOBAL:today { Get-Date -uformat "%A" }
#ATTENTION dans ce cas, une affectation ne déclenchera pas d'exception
# $today=(Get-Date).AddDays(1).DayOfWeek
#

$Code=@"
using System;
using System.Collections.ObjectModel;
using System.Management.Automation;

namespace PowerShell.ExtVariable
{
    public class PSScriptVariable : PSVariable
    {
        public PSScriptVariable(string name,
            ScriptBlock scriptGetter, ScriptBlock scriptSetter)
            : base(name, null, ScopedItemOptions.AllScope)
        {
            getter = scriptGetter;
            setter = scriptSetter;
        }
        private ScriptBlock getter;
        private ScriptBlock setter;

        public override object Value
        {
            get
            {
                if(getter != null)
                {
                    Collection<PSObject> results = getter.Invoke();
                    if(results.Count == 1)
                    {
                        return results[0];
                    }
                    else
                    {
                        PSObject[] returnResults = new PSObject[results.Count];
                        results.CopyTo(returnResults, 0);
                        return returnResults;
                    }
                }
                else { return null; }
            }
            set
            {
                if(setter != null) { setter.Invoke(value); }
            }
        }
    }
}
"@ 
 
  Compile-Csharp  $code
     
  if(Test-Path variable:\$name) 
  { 
    Remove-Item variable:\$name -Force 
  } 
  $ExecutionContext.SessionState.PSVariable.Set( 
     (New-Object PowerShell.ExVariable.PSScriptVariable $name,$getter,$setter)
  ) 
}
