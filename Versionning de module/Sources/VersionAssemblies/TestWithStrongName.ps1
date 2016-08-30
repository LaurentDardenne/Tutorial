
$path=$PSScriptRoot

#DLL en .net 2.0
Write-Host "Charge la version 11" -Fore green
add-type -path "$Path\v11\log4net.dll"
$A=New-object log4net.Appender.ColoredConsoleAppender
Write-host "Type de l'objet A : $($A.Gettype().AssemblyQualifiedName)" 

Write-Host "Charge la version 10" -Fore green
add-type -path "$Path\v10\log4net.dll"
$B=New-object log4net.Appender.ColoredConsoleAppender
Write-host "Type de l'objet créé : $($B.Gettype().AssemblyQualifiedName)" 
Write-Warning "Le type pointe sur celui de la première DLL chargée."
 
#le type est identique [log4net.Appender.ColoredConsoleAppender].AssemblyQualifiedName
# les 2 dll sont chargées mais PS référence la classe du premier assembly chargé

#Même comportement avec une DLL en .net 4.0
#add-type -path "$Path\v13\log4net.dll"

Remove-Variable A,B
Write-Host "Crée deux objets de classe distincte en utilisant des noms fort" -Fore green
$A=New-object 'log4net.Appender.ColoredConsoleAppender, log4net, Version=1.2.10.0, Culture=neutral, PublicKeyToken=1b44e1d426115821'
$B=New-object 'log4net.Appender.ColoredConsoleAppender, log4net, Version=1.2.11.0, Culture=neutral, PublicKeyToken=669e0ddf0bb1aa2a'
Write-host "Type de l'objet A  : $($A.Gettype().AssemblyQualifiedName)" 
Write-host "Type de l'objet B  : $($B.Gettype().AssemblyQualifiedName)" 

Write-host "`r`nTests de cast :" -Fore green
$A -as [log4net.Appender.ColoredConsoleAppender]
#$null
$B -as [log4net.Appender.ColoredConsoleAppender]
#ok

[log4net.Appender.ColoredConsoleAppender] $A
#Exception :
#Impossible de convertir la valeur «log4net.Appender.ColoredConsoleAppender» du type 
# «log4net.Appender.ColoredConsoleAppender» en type «log4net.Appender.ColoredConsoleAppender».

Write-host "`r`nIl existe deux dll de version différente :" -Fore green
[AppDomain]::CurrentDomain.GetAssemblies()|Where {$_.location -match "log4net"}|Select Location
