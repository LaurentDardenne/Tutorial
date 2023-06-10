#Get-Help About_Redirection
#  *   All output
#  1   Success output
#  2   Errors
#  3   Warning messages
#  4   Verbose output
#  5   Debug messages

function Test-Redirection {
  Write-host "Affichage sur le host" -fore green
  Write-Error "Erreur"
  Write-Warning "Attention warning "
  Write-verbose "Mode verbeux"
  Write-Debug "Info de Debug"
  "Emission d'un objet dans le pipe"
}

$VerbosePreference="continue"
$DebugPreference="continue"
$ErrorActionPreference="continue"

$path ="C:\temp"
Set-Location $path    
Test-Redirection 3> "$path\warning.txt"
type  "$path\warning.txt"

Test-Redirection 4> "$path\verbose.txt" 
type "$path\verbose.txt"

Test-Redirection 5> "$path\debug.txt"
type "$path\debug.txt"
Test-Redirection 5>&1 

#L'instruction suivante ne fonctionne pas
#Test-Redirection 1,3,5> "$path\host-warning-debug.txt"

Test-Redirection 4>&1 3>&1 1> "$path\host-warning-debug.txt"
type "$path\host-warning-debug.txt"

Test-Redirection 4>$null 3>$null 2>$null


Test-Redirection *> "$path\out.txt"
type "$path\out.txt"

$w="$path\warning.txt"
$v="$path\verbose.txt" 
$d="$path\debug.txt"
$e="$path\Error.txt"

Test-Redirection 2>$e 3>$w 4>$v 5>$d
$w,$v,$d,$e | % { write-host $_ -fore cyan; Type $_}
$w,$v,$d,$e |Remove-item

$w,$v,$d,$e=$null

Test-Redirection 2>$e 3>$w 4>$v 5>$d
$w,$v,$d,$e | 
 Where {$_ -not null} |
 Foreach { write-host $_ -fore cyan; Type $_}


#Certains flux dépendent de variables associées, 
#si elles ne sont pas activées la redirection ne reçoit rien, 
#car le cmdlet ou le paramètre associé ne fera rien :

$VerbosePreference="Silentlycontinue"
$DebugPreference="Silentlycontinue"
$ErrorActionPreference="Silentlycontinue"

Test-Redirection 2> "$path\Error.txt" 
type "$path\Error.txt"

Test-Redirection 4> "$path\verbose.txt" 
type "$path\verbose.txt"

Test-Redirection 5> "$path\debug.txt"
type "$path\debug.txt"


La doc contient des exemples de ce type là :

InstructionsXX 5>&1 


Mais cela est 