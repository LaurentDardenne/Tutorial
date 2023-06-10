#crée une arborescence de répertoire d'une longueur supèrieure à 260 caractères
#C:\Temp\001\002\003\004\..\109\110

$SourcePath='C:\temp\'
cd $SourcePath
try {
foreach ($i in 1..110)
{
  $path='{0:000}' -F $i
  try {
     md $path -ea Stop > $null
  } catch {
     #Le path est trop long, on substitue le drive X
     #puis on modifie le path courant, ensuite on continue la création
   Subst x: "$pwd"
    #On associe le drive substitué 
   new-psdrive -Name X -Root X:\ -PSProvider FileSystem
   set-location x:\
   md $path -ea Stop > -null
  }
  set-location $path
  Write-host "$i $pwd"
}
} finally {
   #retour à la case départ
  set-location $SourcePath
  Remove-PSDrive x
  Subst X: /D
}

#Extrait du site DotNetReference : http://referencesource.microsoft.com/ 
#
# Fichier:   ..\BCL\System\IO\Path.cs
#
# // Make this public sometime.
# // The max total path is 260, and the max individual component length is 255. 
# // For example, D:\<256 char file name> isn't legal, even though 
# // it's under 260 chars.
#  internal static readonly int MaxPath = 260;
#  private static readonly int MaxDirectoryLength = 255;
#  
#   // Windows API definitions
#  internal const int MAX_PATH = 260;  // From WinDef.h
#  internal const int MAX_DIRECTORY_PATH = 248; // cannot create directories 
# 						// greater than 248 characters

