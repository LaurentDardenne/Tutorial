Throw "Modifier le nom du chemin d'installation et supprimer cette ligne."
$InstallFullPath="xxx" 

cd $InstallPath 
Import-Module .\ValidationsArgument.psm1
$DebugPreference="Continue"
Test-IsImplementingInterface -?
help Test-IsImplementingInterface

  #Résumé de l'aide des fonctions exportées
((get-module ValidationsArgument).exportedcommands).Keys|
 Foreach {Write-host "$_ :" -fore white;(get-help $_).SYNOPSIS}

 #On valide le contenu du chemin, pas son existence
function ContainsWildcard(
     [ValidateScript( {Test-ContainsWildcardCharacters } )]
     [Parameter(Mandatory = $true,Position=0,
                ValueFromPipeline = $true,
                HelpMessage="Nom de chemin.")]$Path)
{ 
 process {Write-Host "Le chemin ne contient pas de jokers : $Path"} 
}
"C:\Windows\notepad.exe",
"C:\Windows\*.exe",
"Truc:\Windows\*.exe",
"..\*.exe",
"ORCL:\test.exe"|ContainsWildcard

#Nécessite le projet AddLib et un OS x86
if (Test-Path Variable:Addlib)
 {
    #On valide le PSdrive précisé dans le nom de chemin.
   function ProviderConstraint{
    Param (
     [ValidateScript( {Test-ProviderConstraint "FileSystem"} )]
     [Parameter(Mandatory = $true,Position=0,
                ValueFromPipeline = $true,
                HelpMessage="Nom de chemin.")]$Path) 
    
      process {Write-Host "Le chemin référence le provider FileSystem : $Path"}
    }
    Write-host "Test ProviderConstraint" 
    cd Env:
    "C:\Windows\notepad.exe",
    "C:\Windows\*.exe",
    "Truc:\Windows\*.exe",
    "..\*.exe",
    "ORCL:\*.exe"|ProviderConstraint
    cd C:
     "..\*.exe"|ProviderConstraint
 }
else  #http://projets.developpez.com/wiki/add-lib 
{Write-Warning "Le test ProviderConstraint nécessite des scripts du projet AddLib."}

 #On valide l'existence du chemin
function PathMustexist(
  [ValidateScript( {Test-PathMustexist } )]
  [Parameter(Mandatory = $true,Position=0,
             ValueFromPipeline = $true,
             HelpMessage="Nom de chemin.")]$Path)
{
  process {Write-Debug "Le chemin existe `$_=$_"; $Path}
}
"C:\Windows\notepad.exe",
"C:\Windows\*.exe",
"Truc:\Windows\*.exe",
"..\*.exe",
"ORCL:\*.exe",
"C:\Autoexec.bat",
"C:\Inconnu\absent.txt"|PathMustexist 

 #On vérifie qu'un objet est bien de la classe WMI spécifiée.
function IsWMIClass(
  [ValidateScript( {Test-IsWMIClass "Win32_Share"} )]
  [Parameter(Mandatory = $true,Position=0,
             ValueFromPipeline = $true,
             HelpMessage="Objet de type Win32_Share.")]$Share)
{
  process {Write-Debug "L'objet est du type Win32_Share `$_=$_"; $true}
}

$SD = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance()
$Shares=gwmi win32_share
 #Valide le contenu du tableau d'objets de type Win32_Share
$Shares|IsWMIClass
#Valide 1 instances de type Win32_Share
$Shares[0]|IsWMIClass 
$Shares,$SD|IsWMIClass


function IsSubclassOf(
  [ValidateScript( {Test-IsSubClassOf "System.Management.Automation.Runspaces.RunspaceConfigurationEntry"} )]
  [Parameter(Mandatory = $true,Position=0,
             ValueFromPipeline = $true,
             HelpMessage="Objet d'un type dérivé RunspaceConfigurationEntry")]$RSCfgEntry)
{
  process {Write-Host "La classe $($_.GetType()) est dérivée du type RunspaceConfigurationEntry";}
}

$S=New-object System.Management.Automation.Runspaces.ScriptConfigurationEntry("Test","validation")
$S2=New-object System.Management.Automation.Runspaces.FormatConfigurationEntry("test","c:\test.ps1x")
$S3="Erreur de type"
$S,$S3,$S2|IsSubclassOf


if (Test-ServiceStatus "winmgmt" "Running")
 {gwmi Win32_Share}
else {Write-Warning "Le service winmgmt (WMI) n'est pas dans l'état Running."}  

 #On vérifie qu'un objet implémente bien une interface
 #ici on souhaite valider des collections et pas leurs éléments.
function IsImplementingInterface(
   #Doit être une collection indexée
  [ValidateScript( {Test-IsImplementingInterface "System.Collections.IList"} )]
  [Parameter(Mandatory = $true,Position=0,
             ValueFromPipeline = $true,
             HelpMessage="Une collection d'objets.")]
  $Collection)
{
  process {Write-Debug "L'objet implémente l'interface IList `$_=$_"; $Collection}
}

$Disque=gwmi Win32_DiskDrive|select -first 1
$TempAssociations=$Disque.psbase.GetRelationships()
$TempAssociations.GetType().GetInterfaces()
$TempAssociations|IsImplementingInterface

$T=@("Test1","Test2")
$T.GetType().GetInterfaces()

 #valide le contenu de la collection
$T|IsImplementingInterface
 #valide le contenu de la collection
,$T|IsImplementingInterface
 #valide l'objet collection
$T.PsBase|IsImplementingInterface
 
 #valide l'objet collection
$TempAssociations.PsBase|IsImplementingInterface

  #valide le contenu de la collection
IsImplementingInterface $T
   #valide la collection
IsImplementingInterface (,$T)
   #valide la collection
IsImplementingInterface $T.PsBase
 
 #Utilisation d'une fonction de validation en dehors de l'attribut ValidateScript
 # Assigne la valeur à tester
 #puis appel la fonction de validation  
$_=$T;Test-IsImplementingInterface "System.Collections.IList"
