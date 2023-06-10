## New-Struct
##   Creates a Struct class and emits it into memory
##   The Struct includes a constructor which takes the parameters in order...
## 
## Usage:
##   # Assuming you have a csv file with no header and columns: artist,name,length
##   New-Struct Song @{
##     Artist=[string];
##     Name=[string];
##     Length=[TimeSpan];
##   }
##   $songs = gc C:\Scripts\songlist.csv | % { new-object Song @($_ -split ",") }
##
# http://poshcode.org/190
# Auteurs : Joel Bennett 

function New-Struct {
	param([string]$Name,[HashTable]$Properties)
	switch($Properties.Keys){{$_ -isnot [String]}{throw "Invalid Syntax"}}
	switch($Properties.Values){{$_ -isnot [type]}{throw "Invalid Syntax"}}

	# CODE GENERATION MAGIKS!
	$code = @"
using System;
public struct $Name {

  $($Properties.Keys | % { "  public {0} {1};`n" -f $Properties[$_],($_.ToUpper()[0] + $_.SubString(1)) })
  public $Name ($( [String]::join(',',($Properties.Keys | % { "{0} {1}" -f $Properties[$_],($_.ToLower()) })) )) {
    $($Properties.Keys | % { "    {0} = {1};`n" -f ($_.ToUpper()[0] + $_.SubString(1)),($_.ToLower()) })
  }
}
"@

	## Obtains an ICodeCompiler from a CodeDomProvider class.
	$provider = New-Object Microsoft.CSharp.CSharpCodeProvider
	## Get the location for System.Management.Automation DLL
	$dllName = [PsObject].Assembly.Location
	## Configure the compiler parameters
	$compilerParameters = New-Object System.CodeDom.Compiler.CompilerParameters
	$assemblies = @("System.dll", $dllName)

	$compilerParameters.ReferencedAssemblies.AddRange($assemblies)
	$compilerParameters.IncludeDebugInformation = $true
	$compilerParameters.GenerateInMemory = $true

	$compilerResults = $provider.CompileAssemblyFromSource($compilerParameters, $code)
	if($compilerResults.Errors.Count -gt 0) {
	  $compilerResults.Errors | % { Write-Error $_.Line + ":`t" + $_.ErrorText }
	}
}
