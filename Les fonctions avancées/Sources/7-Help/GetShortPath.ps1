 #Récupére le nom court d'un nom de chemin long
 # Appel l'API GetShortPathName, 
 #Renvoi un nom de fichier 8.3
 
$Code_GetShortPathName=@"
 //http://www.c-sharpcorner.com/UploadFile/crajesh1981/RajeshPage103142006044841AM/RajeshPage1.aspx
using System;
using System.Runtime.InteropServices;
using System.Text;
using System.ComponentModel;

public class ShortPath
{
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetShortPathName(
             [MarshalAs(UnmanagedType.LPTStr)]
             string path,
             [MarshalAs(UnmanagedType.LPTStr)]
             StringBuilder shortPath,
             int shortPathLength
             );

    public static string GetShortPath(string Path)
    {
       StringBuilder shortPath = new StringBuilder(255);
       int retVal = GetShortPathName(Path, shortPath, shortPath.Capacity);
			if(retVal != 0)
			{ return shortPath.ToString(); }
			else
			{
				//Initialise une nouvelle instance de la classe Win32Exception 
        //avec la dernière erreur Win32 qui s'est produite.
				throw new Win32Exception(); 
			}       
    }
}
"@

Add-Type -TypeDefinition $Code_GetShortPathName

[ShortPath]::GetShortPath($Pwd)
 #Le chemin doit exister
[ShortPath]::GetShortPath("c:\temp\h elp")
