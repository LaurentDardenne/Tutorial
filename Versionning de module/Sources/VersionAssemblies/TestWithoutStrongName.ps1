$TestPath= "$PSScriptRoot\AddType"
$Filter={
  [AppDomain]::CurrentDomain.GetAssemblies()|Where {$_.location -match "MaClasse"}|Select Location
}
md $TestPath
Set-Location $TestPath 
1..2|
 Foreach {
 md "V$_"                 
 Add-Type -OutputAssembly "$TestPath\V$_\MaClasse.dll" @"
using System;
using System.Reflection;

[assembly:AssemblyVersion("$_.0.0.0")]

namespace Test
{

    public class MaClasse
    {
        public string Message="Version $_";
        public void ShowMessage()
        {
          Console.WriteLine(this.Message);
        }
    }
}
"@
} #Foreach

Write-host "Charge la dll version 1"  -fore green
add-type -path "$TestPath\v1\MaClasse.dll"
$o=New-object Test.MaClasse
Write-host "`r`nType de l'objet créé"  -fore green
$o.Gettype().AssemblyQualifiedName
Write-host "Liste des assemblies 'MaClasse'" -fore green 
&$Filter


Write-host "Charge la dll version 2"  -fore green
add-type -path "$TestPath\v2\MaClasse.dll"
$o2=New-object Test.MaClasse
Write-host "`r`nType de l'objet créé"  -fore green
$o2.Gettype().AssemblyQualifiedName
Write-host "Liste des assemblies 'MaClasse'" -fore green 
&$Filter
Write-host "`r`nSeule la première dll est chargée." -fore yellow  
Write-host "Add-type ne renvoi pas d'erreur ce qui est normal car la dll n'a pas de nom fort ( PublicKeyToken est égal à null )." -fore yellow
#
# Vérification : sn.exe -v "$pwd\v1\MaClasse.dll"
# Microsoft (R) .NET Framework Strong Name Utility  Version 4.0.30319.1
# 
# ..\v1\MaClasse.dll ne représente pas un assembly à nom fort

#La liaison se fait donc tjr sur le premier assembly


#On ne peut donc pas différencier les 2 classes
$A=New-object 'Test.MaClasse, MaClasse, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null'
Write-host "`r`nType de l'objet créé"  -fore green
$A.Gettype().AssemblyQualifiedName
Write-host "Tente de créer 'Test.MaClasse, MaClasse, Version=2.0.0.0, Culture=neutral, PublicKeyToken=null'" -Fore Yellow
$B=New-object 'Test.MaClasse, MaClasse, Version=2.0.0.0, Culture=neutral, PublicKeyToken=null'
#exception :
#New-object : Le type [Test.MaClasse, MaClasse, Version=2.0.0.0, Culture=neutral, PublicKeyToken=null] est introuvable :
# vérifiez que l'assembly dans lequel il se trouve est chargé.
