#------------------ Scénario 1

$Error.Clear()
Write-Warning "Pas d'erreur"
$jobOk = Start-Job -scriptblock {Get-Item c:\} -Name JobOk 
Wait-job $jobOK

Write-Warning "Erreur simple"
$jobErreurSimple = Start-Job -scriptblock {Write-Error "Test erreur simple"} -Name JobErreurSimple 
Wait-job $jobErreurSimple

Write-Warning "Erreur bloquante"
$jobErreurBloquante = Start-Job -scriptblock {Throw "Test erreur bloquante"} -Name jobErreurBloquante 
Wait-job $jobErreurBloquante


Write-Warning "Erreur Simple + bloquante"
$jobErreurSimpleEtBloquante = Start-Job -scriptblock {Write-Error "Test erreur simple";Throw "Test erreur bloquante"} -Name jobErreurBloquante 
Wait-job $jobErreurSimpleEtBloquante


$JobOk.JobStateInfo
$JobOk.ChildJobs[0].JobStateInfo
$JobOk.Error.Count
$JobOk.ChildJobs[0].Error.Count
$Error.Count
Receive-Job $jobOk
$Error.Count
$JobOk.JobStateInfo
$JobOk.ChildJobs[0].JobStateInfo
$JobOk.Error.Count
$JobOk.ChildJobs[0].Error.Count


$jobErreurSimple.JobStateInfo
$jobErreurSimple.ChildJobs[0].JobStateInfo
$jobErreurSimple.Error.Count
$jobErreurSimple.ChildJobs[0].Error.Count
$Error.Count
Receive-Job $jobErreurSimple
$Error.Count
$jobErreurSimple.JobStateInfo
$jobErreurSimple.ChildJobs[0].JobStateInfo
$jobErreurSimple.Error.Count
$jobErreurSimple.ChildJobs[0].Error.Count
$jobErreurSimple.ChildJobs[0].Error

$Error.Clear()
$jobErreurBloquante.JobStateInfo
$jobErreurBloquante.ChildJobs[0].JobStateInfo
$jobErreurBloquante.Error.Count
$jobErreurBloquante.ChildJobs[0].Error.Count
$Error.Count
Receive-Job $jobErreurBloquante
$Error.Count
$jobErreurBloquante.JobStateInfo
$jobErreurBloquante.ChildJobs[0].JobStateInfo
$jobErreurBloquante.Error.Count
$jobErreurBloquante.ChildJobs[0].Error.Count


$Error.Clear()
$jobErreurSimpleEtBloquante.JobStateInfo
$jobErreurSimpleEtBloquante.ChildJobs[0].JobStateInfo
$jobErreurSimpleEtBloquante.Error.Count
$jobErreurSimpleEtBloquante.ChildJobs[0].Error.Count
$Error.Count
Receive-Job $jobErreurSimpleEtBloquante
 #$Error contient une erreur simple et une erreur bloquante
$Error.Count
$jobErreurSimpleEtBloquante.JobStateInfo
$jobErreurSimpleEtBloquante.ChildJobs[0].JobStateInfo
$jobErreurSimpleEtBloquante.Error.Count
$jobErreurSimpleEtBloquante.ChildJobs[0].Error.Count
#$Error contient une erreur simple et une erreur bloquante
$jobErreurSimpleEtBloquante.ChildJobs[0].Error

#------------------ Scénario 2

Write-Warning '$ErrorActionPreference="Continue"'
$Job=Invoke-Command -computername LocalHost  -scriptblock {
  $ErrorActionPreference="Continue"
  xcopy.exe Inconnu.txt Nouveau.txt 2>&1
} –AsJob | 
 Wait-job|
 Get-job
$Error #bug du parseur
$Error.clear()

$job.JobStateInfo
$job.ChildJobs[0].JobStateInfo
$job.Error.Count
$job.ChildJobs[0].Error.Count
$Error.Count
$Result=Receive-Job $job
$Error.Count
$job.JobStateInfo
$job.ChildJobs[0].JobStateInfo
$job.Error.Count
$job.ChildJobs[0].Error.Count

$Result
$Result.Count
$Result[0].PSTypenames
$Result[1].PSTypenames

$Result[0].Exception|select *

Write-Warning '$ErrorActionPreference="Stop"'
$Job=Invoke-Command -computername LocalHost  -scriptblock {
  $ErrorActionPreference="Stop"
  xcopy.exe Inconnu.txt Nouveau.txt 2>&1
} –AsJob | 
 Wait-job|
 Get-job
$Error #bug du parseur
$Error.clear()

$job.JobStateInfo
$job.ChildJobs[0].JobStateInfo
$job.Error.Count
$job.ChildJobs[0].Error.Count
$Error.Count
$ErrorActionPreference="Continue"
#$ErrorActionPreference="Stop"
try {
$Result=Receive-Job $job 
} catch {
  Write-warning "trap receive !"
}
$Error.Count
$job.JobStateInfo
$job.ChildJobs[0].JobStateInfo
$job.Error.Count
$job.ChildJobs[0].Error.Count

