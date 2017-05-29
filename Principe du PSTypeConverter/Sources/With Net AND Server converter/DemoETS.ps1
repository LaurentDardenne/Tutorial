PSTypeConverter and extended members

A PSTypeConverter must explicitly (https://github.com/PowerShell/PowerShell/blob/7a55bf98b2370ab4817ab2533cb67673053ee446/src/System.Management.Automation/engine/serialization.cs#L6625) manage extended properties or the runtime manage them ?
In this case 



$code=@'
using System;
using System.Management.Automation;
 
namespace My
{
    public class Test
    {
        public string Name { get; set; } 
    }

    public class TestConverter : PSTypeConverter
    {
        public override bool CanConvertFrom(Object sourceValue, Type destinationType)
        {
           return true;
        }
 
        public override object ConvertFrom(object sourceValue, Type destinationType, IFormatProvider provider, bool IgnoreCase)
        {
            if (sourceValue == null)
                throw new InvalidCastException("no conversion possible");
            //Test o = new Test();
            //return o;
            PSObject ps=PSObject.AsPSObject(new Test());
             //read PSExtended
            ps.Properties.Add(new PSNoteProperty("MyMember", "Test inner"));
            return ps;
        }

        public override bool CanConvertTo(object Value, Type destinationType)
        {
            return false;
        }

        public override object ConvertTo(object Value, Type destinationType,
        IFormatProvider provider, bool IgnoreCase)
        {
            throw new InvalidCastException("conversion failed");
        }
    }
}
'@
Add-Type -TypeDefinition $code 
Update-TypeData -TypeName 'My.Test' -TypeConverter 'My.TestConverter'
Update-TypeData -TypeName 'Deserialized.My.Test' -TargetTypeForDeserialization 'My.Test'
$O=Start-Job {
 $code=@'
using System;
using System.Management.Automation;
 
namespace My
{

    public class Test
    {
        public string Name { get; set; } 
    }

    public class TestConverter : PSTypeConverter
    {
        /// Override for the CanConvertFrom Method.
        /// Returns true if the Source object
        /// is of type String and can be Converted to GetAdmin.Net type
        public override bool CanConvertFrom(Object sourceValue, Type destinationType)
        {
           return true;
        }
 
        public override object ConvertFrom(object sourceValue, Type destinationType, IFormatProvider provider, bool IgnoreCase)
        {
            if (sourceValue == null)
                throw new InvalidCastException("no conversion possible");
            Test o = new Test();
            //return o;
            //return o;
            PSObject ps=PSObject.AsPSObject(o);
            ps.Properties.Add(new PSNoteProperty("Mymember", "Test inner"));
            return ps;
        }

        public override bool CanConvertTo(object Value, Type destinationType)
        {
            return false;
        }

        public override object ConvertTo(object Value, Type destinationType,
        IFormatProvider provider, bool IgnoreCase)
        {
            throw new InvalidCastException("conversion failed");
        }
    }
}
'@
 Add-Type -TypeDefinition $code
Update-TypeData -TypeName 'My.Test' -TypeConverter 'My.TestConverter'
Update-TypeData -TypeName 'Deserialized.Test' -TargetTypeForDeserialization 'My.Test'
 $o=New-Object My.Test
 Add-Member -InputObject $O -MemberType Noteproperty -Name MyMember -Value Test -Passthru 
} |Receive-Job -Wait -AutoRemoveJob
$O

#todo on manipule un PSobject dés que l'on ajoute un membre ETS