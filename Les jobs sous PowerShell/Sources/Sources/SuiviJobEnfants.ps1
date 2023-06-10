Function Test-JobFinishedState{
 param([System.Management.Automation.JobState] $State)
  ($state -eq 'Completed') -or ($state -eq 'Failed') -or ($state -eq 'Stopped')
} #Test-JobFinishedState

function Assert {
#from  http://poshcode.org/1942

#.Example
# set-content C:\test2\Documents\test2 "hi"
# C:\PS>assert { get-item C:\test2\Documents\test2 } "File wasn't created by Set-Content!"
#
[CmdletBinding()]
param( 
   [Parameter(Position=0,ParameterSetName="Script",Mandatory=$true)]
   [ScriptBlock]$condition,

   [Parameter(Position=0,ParameterSetName="Bool",Mandatory=$true)]
   [bool]$success,

   [Parameter(Position=1,Mandatory=$true)]
   [string]$message
)

   $message = "ASSERT FAILED: $message"
  
   if($PSCmdlet.ParameterSetName -eq "Script") {
      try {
         $ErrorActionPreference = "STOP"
         $success = &$condition
      } catch {
         $success = $false
         $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"         
      }
   }
   if(!$success) {
      throw $message
   }
} #Assert


$DEFAULT_THROTTLE_LIMIT =32
 # MaxProcessesPerShell : 24 par défaut (ps v3 Seven)
$MaxProcessesPerShell= (Get-Item Microsoft.WSMan.Management\WSMan::localhost\Shell\MaxProcessesPerShell).Value
$ThrottleLimit=10
$ThrottleLimit=[math]::Min($MaxProcessesPerShell,$DEFAULT_THROTTLE_LIMIT)

$Max=40
$servers=New-Object System.Collections.Arraylist($max)
foreach ($i in 1..$max)
{ [void]$servers.Add('LocalHost')}
 
 #Génére le statut 'Failed'
[void]$servers.insert($max-1,'bocalHost')
[void]$servers.insert(0,'bocalHost')

Get-Job|Remove-Job -force

#get-process -name wsmprovhost
#stop-service Winrm ; start-service Winrm

 #Le paramètre ThrottleLimit doit toujours être défini !
$Job=invoke-command -computerName $Servers -JobName Parent -AsJob -scriptblock { Sleep -s 20; get-item c:\} -ThrottleLimit $ThrottleLimit

 #isMonitoringDone indique qu'un job est terminé et ses données traitées.
 #Son suivi a été fait, c'est le code qui le précise et pas 
 #une information calculée d'aprés les propriétés du job
 #Note : Cet appel à Add-member ne fonctionne avec PS v2
$Job.ChildJobs.GetEnumerator()|                                                 
 Add-member -Member NoteProperty -name isMonitoringDone -value $false -Passthru
 
# $T=$job.ChildJobs.GetEnumerator()|% {$_} # BreakingChange v3 ??
# $T|Add-member -Member NoteProperty -name isMonitoringDone -value $false
  
  #Génére le statut 'Stopped'
  #Le job doit être dans le statut 'Running' sinon l'appel est bloquant
if ($Job.ChildJobs[-1].State -ne 'NotStarted')
{ $Job.ChildJobs[-1]|Stop-job } else
{ $Job.ChildJobs[0]|Stop-job}

 #Total des job traités
$count=0

#Délai avant suppression automatique d'un job, jugé en erreur/planté
$TimeOutJobInterval =[TimeSpan]"00:0:10"
$isTimeOutEnabled =$false

 #Prépare la gestion d'erreurs des jobs
$Error.Clear()
 #On traite un sous ensemble tant qu'il reste des jobs à suivre.
do {
   #Pour ces critères $T peut être vide, par exemple auc_un job n'a encore démarré
  $T=$Job.ChildJobs.GetEnumerator()|Where {($_.isMonitoringDone -eq $false) -and ($_.State -ne 'NotStarted')}
  #$T| Select-Object  name,ps*,state,isMonitoringDone|ft
  
   #Ici un tableau est vide ne signifie pas qu'il n'y a plus de job à traiter. 
   #On attend avant de relancer la demande
  if ($T.Count -eq 0) {Sleep -m 500}
   Write-warning "------ Boucle sur $($T.Count) job -------" 
  Foreach ($CurrentChildJob in $T){
    try {
      Write-warning "Attente sur l'état de $($CurrentChildJob.Name) $(get-date -Format 'hh:mm:ss')"
       
       #Les jobs dans l'état 'terminé' (Test-JobFinishedState) ne déclenche pas le timeout
      $JobWaited=Wait-job -id $CurrentChildJob.id  -timeout 5 #(60*5) 
      
       #Si le timeout sur Wait-Job est déclenché il n'y a pas d'erreur, 
       #mais il renvoie $null 
      if ($JobWaited -eq $Null)
      {
          #Ici le timeout est un temps d'attente, pas la durée de vie d'un job 
         Write-Warning "`tTemps d'attente atteint pour le job $($CurrentChildJob.Name). On passe au suivant"
          #La date actuelle moins la date de démarrage du job doit être inférieure au timeout
         If ($isTimeOutEnabled -and ($CurrentChildJob.State -eq 'Running') -and ( ([DateTime]::Now -$CurrentChildJob.PSBeginTime) -gt $TimeOutJobInterval))
         { 
            Write-warning "Timeout pour le job $($_.name)"
            # On supprime le job
            #todo gestion du suivi : Stoppé par timeout, on doit relancer le traitement sur cette machine
            Stop-Job -Job $CurrentChildJob
         }
         elseif ($CurrentChildJob.State -eq 'Running') 
         {  continue }
      }
      else 
      {  Write-Warning "`t L'attente de $($CurrentChildJob.Name) réussie $(get-date -Format 'hh:mm:ss')"   }
    } 
    catch [System.ArgumentException] {
       #Job bloqué
      if ($_.FullyQualifiedErrorId -match '^BlockedJobsDeadlockWithWaitJob,')
      {
         # Avec -scriptblock { sleep -s 2;read-host }
        Write-Warning "Supprimez les instructions de type Read-Host dans le job $($CurrentChildJob.Name). Job stoppé." 
        $CurrentChildJob|Stop-Job
      }  
    } 
    
    Assert { $CurrentChildJob.State -ne 'Running' } "Le job ne doit pas être dans l'état Running."

    Write-Warning "`tTraite l'état du job $($CurrentChildJob.Name)"
    Switch ($CurrentChildJob.State) {
    'Completed' { Write-Warning "`t`t $($CurrentChildJob.Name) dans l'état Completed."
                 if ($CurrentChildJob.State -ne 'NotStarted')
                 {
                   if ($CurrentChildJob.HasMoreData)  
                   {$d=Receive-job $CurrentChildJob} #todo gestion du résultat
                 }
                 Break
               }
    'Failed'    { Write-Warning "`t`t $($CurrentChildJob.Name) dans l'état Failed"; Break}   #todo gestion du suivi : rapport d'erreurs ou Log4Poh   
    'Stopped'   { Write-Warning "`t`t $($CurrentChildJob.Name) dans l'état Stopped"; Break}
    default     { Write-Warning "`t`t Cet état n'est pas géré : $($CurrentChildJob.State)."}  
    }#Switch 
    Write-warning "`tJob $($CurrentChildJob.Name) traité (2)." 
     #todo gestion du suivi : Demande sur le serveur ($CurrentChildJob.Location) traitée
    $CurrentChildJob.isMonitoringDone=$true   
    $count++  
  }#foreach 
  Write-warning "Suite Count=$count Childs=$($Job.ChildJobs.count)"
} While ($count -lt $Job.ChildJobs.count)
#todo gestion d'erreur try catch général



$JobId=$Job.ID
Get-Job -id $JobId -IncludeChildJob
Write-warning "End"
$job|
 Select-Object  name,ps*,state
$Job.ChildJobs|
 Select-Object  name,ps*,state,isMonitoringDone|ft

rv Job
Remove-Job -ID $JobId
