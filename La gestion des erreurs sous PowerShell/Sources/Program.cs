using System;
using System.Text;

namespace ErrorOut
{
   //$Error.Clear()
   // .\program.exe 1 > "c:\temp\t.txt"
   // type "c:\temp\t.txt"
   //.\program.exe 2>&1
   
    public class ErrOut { 
        static void Main()
        {
            Console.Error.WriteLine("Emit sur le flux d'erreur (stderr)");
            Console.Out.WriteLine("Emit sur le flux de sortie (stdout)");
            int a=10, b=0; 
            int result;
            try { 
              result = a / b; // generate an exception 
            } catch(DivideByZeroException exc) { 
              Console.Error.WriteLine(exc.Message); 
            } 
        } 
    }
}
