#bug :
#https://connect.microsoft.com/PowerShell/feedback/ViewFeedback.aspx?FeedbackID=509985

 function do-something {
 #[CmdletBinding()]
  Param (
   [Parameter()]
   [system.management.automation.credential()]$cred,
    [Parameter(Mandatory=$True,ValueFromPipeline = $true)]
   $ComputerName)

  process {
    $cred} 
} 

 #Trace àl'écran
Trace-Command -name ParameterBinding {"localhost"|do-something} –pshost

 #Trace dans un fichier
Trace-Command -name ParameterBinding {"localhost"|do-something} –File Trace.log 

 #Autres problèmes autour de la gestion des attributs dotnet
 # http://powershell-scripting.com/index.php?option=com_joomlaboard&Itemid=76&func=view&id=5881&catid=14
