 #Cette demo nécessite l'usage de DebugView.exe dispo sur :
 # http://technet.microsoft.com/en-us/sysinternals/bb896647.aspx
 
function ValidateDgbView($Variable, 
                         $CallerInvocation,
                         [string] $Format="{0} = {1}" )
{ 
   if ($MyInvocation.CommandOrigin -eq "Internal")
   {
     $msg="Exécution via un attribut"
     $Data=$_
   }
   else 
   {
     $msg="Exécution via un runspace"
      #on récupère les données via $input (cf. bloc End)
     $Data=$input|% {$_}
   }
   Write-host $msg -fore green
   [System.Diagnostics.Debug]::WriteLine("`$Data")
  
   #cf. http://projets.developpez.com/wiki/add-lib
   Write-Properties $Data -Silently
   
   [System.Diagnostics.Debug]::WriteLine("`$Variable")
   Write-Properties $Variable.Value –Silently
   #Write-Properties $CallerInvocation
     
    #Ecrit sur le debugger actif, s'il en existe un. 
    #cf. http://technet.microsoft.com/en-us/sysinternals/bb896647.aspx 
   [System.Diagnostics.Debug]::WriteLine( ("Ancienne valeur "+ $Format -F $Variable.Name, $Variable.Value) )
   [System.Diagnostics.Debug]::WriteLine( ("Nouvelle valeur "+ $Format -F $Variable.Name, $_) )

   #Ici on renvoie toujours vrai, 
   #on ne fait que tracer.
   $True
}


Function Test{
    Param (
       [ValidateScript({ValidateDgbView (gv Date) $myinvocation})]
       [DateTime] $Date
)
   #Ici la variable $Date existe
   #lors du second appel à ValidateDgbView 
  #$Date=[DateTime]::Now.AddDays(-1)
  Write-host "Test"
}

 #Lors du premier appel de la fonction, 
 #la variable $Date n'existe pas encore,
 #mais dans ValidateDgbView on connait au moins la nouvelle valeur: $_
Test (Get-Date)
  
$Date=Get-Date
Function Test{
    Param (
    #Ici la variable $Date existe dans le contexte de l'appelant
       [ValidateScript({ValidateDgbView (gv Date) $myinvocation})]
       [DateTime] $Date
)
   #Ici la variable $Date existe
  $Date=[DateTime]::Now.AddDays(-1)
  Write-host "Test"
}

Test $Date  

 #Exécution via un runspace
Get-Date|ValidateDgbView

 #a priori on ne peut pas connaitre l'ancienne valeur, Get-PScallStack référence le contexte du scritpblock 
$Brkpnt=Set-PSBreakPoint -variable "Date" -action { [System.Diagnostics.Debug]::WriteLine( ("Nouvelle date ={0}" -F $Date)) }
$Date=[DateTime]::Now.AddDays(+1)
Remove-PSBreakPoint $Brkpnt
