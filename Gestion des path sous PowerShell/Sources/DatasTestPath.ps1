#Fichier déclarant un jeux de test définissant des noms de chemin de différente constructions.
# La duplication de certains cas est volontaire.
# 
#Le test doit être effectués deux fois :
# - la première en ayant la localisation courante sur le FileSystem,
# - la seconde en étant la Registry ou tout autre provider n'utilisant pas le FileSystem.

# !!! Suppose le disque C:\
#     Certains chemins seront inexistant sur votre ordinateur. 

#test path et item existe, plusieurs path
# C:\Temp\Tests\*\Test.txt
md c:\Temp -ea 'SilentlyContinue'
cd c:\Temp 
md Tests\a -ea 'SilentlyContinue' 
md Tests\b -ea 'SilentlyContinue'
"Test a" >C:\Temp\Tests\a\test.txt
"Test b" >C:\Temp\Tests\b\test.txt


fsutil.exe file createnew C:\Temp\[a 20 
fsutil.exe file createnew C:\Temp\`[a 20
md 'C:\Temp\PSTest[' -ea 'SilentlyContinue'
fsutil.exe file createnew C:\Temp\PSTest[\Test.ps1 20 
md 'C:\Temp\PSTest`[' -ea 'SilentlyContinue'
fsutil.exe file createnew C:\Temp\PSTest`[\Test.ps1 20

# validation de l'analyse path & literal en ayant sur ces deux répertoires
md 'C:\Temp\frm[az]' -ea 'SilentlyContinue'
fsutil.exe file createnew C:\Temp\frm[az]\Test.ps1 20 
md 'C:\Temp\frm`[az`]' -ea 'SilentlyContinue'
fsutil.exe file createnew 'C:\Temp\frm`[az`]\Test.ps1 20


fsutil.exe file createnew C:\Temp\frm[az].ps1 20 
fsutil.exe file createnew C:\Temp\frm`[az`].ps1 20

#Drive de test
 #Invalide le globbing 
New-PSDrive -name 'C*' -root C:\Temp -psp FileSystem > $null
#Présence de caractère espace dans le nom du drive
New-PSDrive -name ' Space' -root C:\Temp -psp FileSystem > $null
#Drive sur la registry
md HKCU:\Test -ea 'SilentlyContinue'
New-PSDrive -name 'My' -root HKCU:\Test -psp Registry > $null

#Test-UNCPath
$UNCPaths=@(
  #'' #Le paramètre Path est Mandatory
  ' ', #renvoi le chemin courant. Bug PS ? C:\Get-Item ' ' -> ok HKLM:\Get-Item ' ' -> Nok 
  '\',
  '/',
  '\\',
  'FileSystem::\\',
  'Registry::\\',
  '//',
  '/\',
  '\\l',
  '//l',
  '\localhost',
  '\\localhost\',
  '/\localhost\',
  '//localhost\',
  '\\localhost\c',
  '//localhost\c',
  '\\localhost\c$',
  '/\localhost\c$',
  '\\localhost\c$\temp',
  '\FileSystem::\\localhost\c$\temp', #valide pour PS
  'Microsoft.PowerShell.Core\\FileSystem::\\localhost\c$\temp', #Invalide
  'FileSystem::\\localhost\c$\temp\',
  '\\localhost\c$\temp\',
  '//localhost\c$\temp\', #WIN32 :A path containing forward slashes often needs to be surrounded by double quotes to disambiguate it from command line switches.
  '//localhost/c$/temp',
  '\\localhost\c$\temp\*',
  'FileSystem::\\localhost\c$\temp\*',   
  '\\localhost\c$\temp\inconnu\*', #Déclenche une exception, là où 'c:\temp\inconnu\*' n'en déclenche pas. Les deux ne sont pas candidat, mais pas pour la même raison.
  'FileSystem::\\localhost\c$\temp\inconnu',
  '\\127.0.0.1\c$\temp',
  '\\\localhost\c$\temp\', #Bug en V2, path OK. Erreur en V3
  '\\localhost\\\\c$\temp\', #ok en v2 et v3
  'localhost\c$\temp\',
  'c:\temp\',
  'FileSystem:://localhost/c$/temp', #WIN32 : A path containing forward slashes often needs to be surrounded by double quotes to disambiguate it from command line switches.
  'FileSystem::\\localhost\c$\temp',
  'Microsoft.PowerShell.Core\FileSystem::\\localhost\c$\temp',
  'Microsoft.PowerShell.Core\FileSystem:://localhost/c$/temp', 
  'FileSystem::\\\\localhost\c$\temp',
  'FileSystem::////localhost/c$/temp',
  'FileSystem::\\\\localhost\c$\\\\temp',
  'FileSystem::////localhost/c$////temp',
  '\\Test.zip',
  'FileSystem::\\Test.zip',
  'Registry::\\Test.zip',
  '\\localhost\c$\', 
  '\\localhost\c$\temp\inconnu',
  '\\localhost\c$\temp\inconnu*',
   #Lecteur H inconnu. Déclenche une exception,
  '\\localhost\H$\temp\inconnu\*',
   #Lecteur E indisponible
  '\\localhost\E$\temp\inconnu\*',
  'C:\Test2*.cs',
  'C:\Test.cs',
  'file.cs',
  'file*.cs',
  'Registry::\\localhost\c$\temp'
)

$UNCPathsNetWork=@(
 '\\server.domain.local\c$\temp', 
 '\\220.10.56.3\C$',
 '\\NotExist\C$',
 '\\?\C:\temp', #Longpath
 '\\.\PHYSICALDRIVE1', #Nom de disque physique
 '\\.\C:'
)

$UNCPathsAll=@(
 $UNCPathsNetWork
 $UNCPaths;
)

#$UNCPathsAll| % { Test-UNCPath $_}

$Security=@(
 'Registry::HKEY_LOCAL_MACHINE\SECURITY' # Analyse possible, mais l'accès est impossible
)
$LecteurInconnu=@(
 # Le lecteur n'existe pas (pas déclaré dans le bios)
'A:\',
  #Pas nécessaire de dériver les cas : DriveNotFoundException
  #'A:', 
  #'A:\Test',
  #'A:\*',
 # Le lecteur CD existe, mais ne contient pas de CD (disque amovible)
'E:\', 
  #Pas nécessaire de dériver les cas : ItemNotFoundException
  # 'E:',
  # 'E:\Test',
  # 'E:\*',
'w:\', 
'FileSystem::w:\',
'FileSystem::A:\test',
'NotExist:\Test',
' pscx:\Test',
'pscx*:\',
' pscx*:\',
'FileSystem::toto:\temp',
'Microsoft.PowerShell.Core\FileSystem::A:\'
)

$LecteurPossible=@(
#TODO : Créer le drive et les répertoires
'C*:\',
'C*:',
'C*:\Temp', # isWilCard renvoi $true. todo
'C*:\Temp\*',
'C*:\Test*.cs',
'C*:\Test.cs',
' Space:\',
' Space:\*',
' Space:\Test',
' Space:\Test*',
'My',
'TestsWinform:\Test1'
)

$CaractereInvalide=@(
'c:\temp\test[2', #globing incomplet
'c:\temp\t<.txt',
'c:\temp\t<\t.txt',
'c:\temp\t>.txt',
'c:\temp\t>\t.txt',
'c:\temp\t|.txt',
'c:\temp\t|\t.txt',
'c:\temp\t*.txt',
'c:\temp\t*\t.txt',
'c:\temp\t?.txt',
'c:\temp\t?\t.txt',
'c:\temp\t\\t.txt', #Valide en v2 et v3. Autant de \ que l'on veut entre le nom du répertoire et le nom du fichier. cf class IO.FileInfo
'c:\temp\t//t.txt',
'c:\temp\t:t.txt',
'c:\temp\t.tx:t',
'c:\temp\t'+([char]8)+'.txt'
)

$Globing=@(
'c:\temp\*',       
'c:\temp\*.log',
'c:\temp\Test[0-9].log',
'c:\temp\Test?.log',
'c:\win*\sy*\win*s[p-v]o*l',
'c:\temp\Test[.].log',
'C:\temp*\Test*.cs*',
 #dépend de la localisation courante
'C:Test.cs*',
'C:\autoexec.bat*',
'C:\auto*',
'C:\*',
'Test*.cs',
'..\temp\Test*.cs',
'..\temp*\Test*.cs',
 #recherche les entrées ayant au moins une lettre et un point d'extension
'Wsman:\*.*', 
'Wsman:\*',
'pscx:Home*',
'HKLM:\*',
 #System.Management.Automation.WildcardPatternException
'Wsman:\[a', 
'c:\temp\test[12]',
 #System.Management.Automation.WildcardPatternException
'C:\[a', 
 #System.Management.Automation.WildcardPatternException
'C:\`[a',
'?', #Globing et relatif
'*', #Globing et relatif
'[a]', #Globing et relatif
'[abc]', #Globing et relatif
'[a-c]', #Globing et relatif
'Test*[a][0-9]', #Globing et relatif
'..\t*', #Globing et relatif
'..\auto*', #Globing et relatif
'MyTest[ab*12?+]', #Globing et relatif. Nom valide pour le provider registry
'hkcu:MyTest[ab*12?+]', #registry a*t possible
'hkcu:MyTest[ab12?+]',
'c:\temp\MyTest[ab*12?+]', #idem mais sur le FS   
'FileSystem::c:\temp\MyTest[ab*12?+]', #idem mais sur le FS  
'FileSystem::c:\temp\*',
'c:\temp\MyTest[a', #globbing détecté, mais incomplet
'c:\temp\MyTest`[a', #échappement, pas de globbing détecté 
'c:\temp\MyTest`*', #échappe le globbing, mais le nom reste invalide sur le FS!
 'C:\Temp\Tests\*\Test.txt',
'hkcu:MyTest[ab12>+]',
'Registry::HKEY_CURRENT_USER\Environment*'
)

$Relatif=@(
'Test.cs',  
"//////\\/\//\/"
"/temp/../temp/../",
"/temp/foo/../../"
"c:",
"hklm:",     
"\temp", 
"/temp", 
"/temp/..", 
"/temp/foo/../../temp",
"/temp/./temp/../.",    
"/temp/./././../temp", 
'Pscx:.',
'PscxSettings::.', #Le provider n'est pas hiérarchique
'wsman::\' #Le provider n'est pas hiérarchique
'pscx:Home',
'...', #Reconnu par les API de PS, mais Set-Location l'interdit
'.', #'.' dépend si le provider est hiérarchique 
'..',
'/.',
'\.\', 
'\..\', # Le chemin d'accès 'HKEY_LOCAL_MACHINE\..' fait référence à un élément situé hors du chemin d'accès de base 'HKEY_LOCAL_MACHINE'.   
'\..',  # idem
'\.',
'..\',
'.\',
'..\temp',
'..\temp\Test.cs',
'..\Test.cs',
'..\..\t.ps1',
'Test.zip',
'C:Test.cs',
'FileSystem::C:Test.cs',
'FileSystem::\temp\*',  # renvoi le path pointé par [Environment]::CurrentDirectory
'FileSystem::\temp',    #idem
'FileSystem::Test.zip', #idem
'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\Winmgmt',
'Registry::.', 
'Registry::..',
'Registry::..\temp',
'FileSystem::.', 
'FileSystem::..',
'FileSystem::..\temp',
'..\Hardware',
'..\Windows'
)

$Tilde=@(     
 #(get-psprovider 'Registry').Home peut ne pas être renseigné, dasn ce cas certaines API déclenchent une exception
 "~",  
 "~\temp", #relatif si la propriété 'Home' est renseigné   
 "~foo" #itemnotfound
) 

$ItemInexistant=@(
'c:\temp\inconnu*',
'c:\temp\foo.txt',
 # registry     
 "HKLM:\Softwar",
'wsman:\inc*onnu',
'Registry::HKEY_CURRENT_USER\Environment\toto',
"$(dir variable:OutputEncoding)",
"$(Get-Service Winmgmt)",
'Registry::\Hardware',
'WSMan::\localhost',
'Registry::hklm:\',
'FileSytem::Z:\',
'filesystem::MyModules:\', #Le drive 'MyModules' doit exister 
'filesystem::1:\',
'certificate::currentuser:\',
'filesystem::',
'C:\Temp:"<>|invalidchars:*?\' 
)

$ItemExistant=@(
 #HD
'C:\',
"C:/",  
'G:\',
'MyModules:\', #Pour Win32Path
'MyModules:\Pester',
"$(Get-Item 'C:\temp')", #FullName As string
'FileSystem::c:\',  
'FileSystem::F:\',  
'G:\temp\PSHistory\datas',
'c:\temp',
 #Cd R/O
'F:\', #PS V3 : Test-path peut sur un CD déclencher une exception : FileTime Win32 non valide.  -> LastAccessTime    : 01/01/1601 01:00:00
       #Ok avec la v2  
 # registry     
"HKLM:\Software",
'HKLM:\',
#autre
'PSCX:',
'Env:\',
'Registry::\System\*',
'Registry::\System',
'Registry::Test.zip',
'WSMan:\localhost',
'WSMan::localhost',
'Registry::HKEY_CURRENT_USER\Environment',
'Registry::HKEY_CLASSES_ROOT\.js',
'Registry::HKEY_CLASSES_ROOT\evtfile'
'certificate::currentuser',
'certificate::',
'filesystem::\', # Renvoi le root du drive C [system.io.fileinfo]'\'|select *
'.\Temp:"<>|invalidchars:*?\', #Valide selon le provider courant
'asdfkjadsfdafssadfadfs..\..' #bug PS ?   référence le path pointé par [Environment]::CurrentDirectory
)

$ProviderInconnu=@(
'SVN::Root\product\PS',
'SVN::Ro ot\product\PS', #espace dans le nom du drive
'Microsoft.PowerShell.Core\System::Truc\temp',
'Micro.Po.truc\FileSystem::c:\NotExist',
'Microsoft.PowerShell.Core\SVN::c:\NotExist'
)

#todo créer le répertoire. ceci est spécifique à un poste !
$PathItemisExist=@(
'G:\PS\PsIonic\tests\*\Test.gz', #existe au moins 1
'G:\PS\PsIonic\test\*\Test.gz', #le path 'test' n'existe pas
'G:\PS\PsIonic\tests\Archive erronees\Test.gz', # path et item exist
'G:\PS\PsIonic\tests\*\notexist.txt', #existe au moins 1 path
'G:\PS\PsIonic\test\*\notexist.txt', #n'existe pas ni l'un ni l'autre
'G:\PS\PsIonic\tests\notexist.txt', #l'item n'existe pas, le path oui
'G:\PS\PsIonic\tests\not>exist.txt', #l'item invalide , le path oui
'G:\PS\PsIonic\tes|ts\notexist.txt', #Item et path invalide
'G:\PS\PsIonic*\tests\not>exist.txt', 
'G:\PS\PsIonic*\tes|ts\notexist.txt',
'G:\PS\PsIonic\tests\not>exist*.txt', 
'G:\PS\PsIonic\tests?\notexist.txt' 
"$PSionicTests\Archive",
"$PSionicTests\0Archive",
"$PSionicTests\A*",
"$PSionicTests\0Archive*",
"$PSionicTests\*0Archive"
)

$Datas=@(
 $UNCPaths;
 $Security;
 $LecteurInconnu;
 $LecteurPossible;
 $CaractereInvalide;
 $Globing;
 $Relatif;
 $Tilde;
 $ItemInexistant;
 $ItemExistant;
 $ProviderInconnu;
 $PathItemisExist;
 'FileSystem::wsman:\localhost'; # Le format du chemin d'accès donné n'est pas pris en charge
 'filesystem::';
 'filesystem::\';
 'registry::';
 'registry::\';
 'wsman::';
 'wsman::\',
 'C:\temp?\test>',
 'C:\temp\test>a',
 'Registry::..\temp' #bug v2 & v3 -> ProviderInvocationException
)

$DatasAll=@(
 $Datas;
 $UNCPathsNetWork
)
