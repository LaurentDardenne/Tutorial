$Code=@'
using System;
using System.Text;

  public class ErrOut
  {
  	static void Main()
  	{
  		int num = 10;
  		int num2 = 0;
  		int value = num / num2;
  	}
  }
'@
Add-Type -TypeDefinition $Code -OutputAssembly 'C:\Temp\ErrorOut.exe' -OutputType ConsoleApplication 