#Exemple de job du type CimJob
#Adapté de  http://blogs.msmvps.com/richardsiddaway/2014/01/05/cdxml-cim-jobs/

 #Charge un  module 'Cmdlet Definition XML' 
 # voir : http://msdn.microsoft.com/en-us/library/jj542520%28v=vs.85%29.aspx   
IPMO .\Cim_DataProcess.cdxml

$ModuleCim=Get-Module Cim_DataProcess
$ModuleCim

#bug en V3 avec Get-Command sur ce type de module
# https://connect.microsoft.com/PowerShell/Feedback/Details/756056

$Job=Get-DataProcess –AsJob
Get-job
Receive-job $Job

