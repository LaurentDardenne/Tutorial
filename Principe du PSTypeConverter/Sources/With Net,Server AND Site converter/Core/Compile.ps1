if($PSEdition -ne 'Core') 
{Throw "Need Ps V6.0 core" }

Add-Type -path ".\Adapters.cs" -OutputAssembly ".\Adapters.dll" -OutputType Library `
 -ReferencedAssemblies .\Log4net.dll,
                       "$PsHome\System.Management.Automation.dll",
                       "$PsHome.\System.Linq.dll",
                       "$PsHome\System.Reflection.dll",
                       "$PsHome\System.Xml.XmlDocument.dll",
                       "$PsHome\System.Private.Uri.dll",
                       "$PsHome\System.IO.dll",
                       "$PsHome\System.IO.FileSystem.dll",
                       "$PsHome\System.Collections.NonGeneric.dll",
                       "$PsHome\System.Collections.dll",
                       "$PsHome\System.Net.Primitives.dll"
                       

#WARNING: (26) : Assuming assembly reference  you may need to supply runtime policy
# Log4Not use  previous version of assembly                       
                       

