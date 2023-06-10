function New-Enum ([string] $name)
#From http://blogs.msdn.com/powershell/archive/2007/01/23/how-to-create-enum-in-powershell.aspx
#New-Enum my.color blue red yellow
#[my.color]::blue
{
    $appdomain = [System.Threading.Thread]::GetDomain()
    $assembly = new-object System.Reflection.AssemblyName
    $assembly.Name = "EmittedEnum"

    $assemblyBuilder = $appdomain.DefineDynamicAssembly($assembly,[System.Reflection.Emit.AssemblyBuilderAccess]::Save -bor [System.Reflection.Emit.AssemblyBuilderAccess]::Run);
    $moduleBuilder = $assemblyBuilder.DefineDynamicModule("DynamicModule", "DynamicModule.mod");
    $enumBuilder = $moduleBuilder.DefineEnum($name, [System.Reflection.TypeAttributes]::Public, [System.Int32]);
    for($i = 0; $i -lt $args.Length; $i++)
    { $null = $enumBuilder.DefineLiteral($args[$i], $i); }

   $enumBuilder.CreateType() > $null;
}


