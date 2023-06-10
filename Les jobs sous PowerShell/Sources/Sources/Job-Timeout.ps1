#Impl�mentation d'un timeout sur des jobs

<#
----------------------------------------------------------------------------------
#-- PS v2 impl�mente l'heure de d�amrrage du job 
   #On utilise \ comme s�parateur, car la m�thode ToBinary() renvoi un entier n�gatif
   #Le nom peut porter d'autres informations
 $JobName="Nom\$([DateTime]::Now.ToBinary())"
  
Function Split-JobName {
 #Parse le nom d'un job et renvoi un objet
 param ($JobName)
 
 $Name,$Date=$JobName -split "\\"
 New-Object PSObject -Property @{
      StartTime=([DateTime]::FromBinary($Date));
      Name=$Name
      JobName=$JobName #Nom du job utilis� par Stop-Job
 }
}#Split-JobName
----------------------------------------------------------------------------------  
#>

#Intervalle du d�clenchement du timer de surveillance des JOB
$TimerIntervalJob =[TimeSpan]"00:0:5"
#D�lai avant suppression automatique d'un job, jug� en erreur/plant�
$global:TimeOutJobInterval =[TimeSpan]"00:0:10"

 #Surveillance du temps d'ex�cution des jobs (TimeOut) 
$TimeOutJob = New-Object Timers.Timer 
 #On s'abonne � l'�v�nement Timer.Elapsed d�clench� par $TimeOutJob
$Global:JobTimerElapsed=Register-ObjectEvent $TimeOutJob Elapsed -SourceIdentifier Timer.Elapsed �Action {
     Write-warning "Verification Timeout $(get-date)"
       #On parcourt la liste des job 
     Get-Job -Name LD*|
       #La date actuelle moins la date de d�marrage du job doit �tre inf�rieure au timeout
      Where { ($_.State -eq 'Running') -and ( ([DateTime]::Now -$_.PSBeginTime) -gt $global:TimeOutJobInterval) }|
      % { Write-warning "[$(get-date)] Timeout pour le job $($_.name)";$_}|
        #Son �tat bascule en 'Stopped', son event StateChanged est d�clench�
       Stop-Job
    }
$TimeOutJob.Interval = $TimerIntervalJob.TotalMilliseconds
$TimeOutJob.Autoreset = $True 
$TimeOutJob.Enabled=$true
 
 #Attention les jobs suivants peuvent utiliser les CPU � 100% 
 1..5|% {Start-job -name "LDJob$_" {foreach ($i in 0..12000000) {};$Args[0]} -argumentlist "LDJob$_" }>$null
 6..10|% {Start-job -name "LDJob$_" {foreach ($i in 0..6000000) {};$Args[0]} -argumentlist "LDJob$_"} >$null

 #Debut :
# 1- Attente de la fin d'ex�cution
 Sleep -S 8
 Get-Job -name LD*|
  Format-Table Name,State,PSBeginTime,PSEndTime,@{Name='Dur�e';E={$_.PSEndTime-$_.PSBeginTime}}
#2- Receive-Job  -wait bloque les �v�nements du Timer  
#Get-Job -Name LD*|Receive-Job  -wait  

#Fin :
# supprime le gestionnaire et le job associ�
(Get-EventSubscriber -SourceIdentifier Timer.Elapsed  -EA SilentlyContinue).SourceObject.AutoReset = $false 
UnRegister-Event -SourceIdentifier Timer.Elapsed -EA SilentlyContinue
Remove-Job -id $Global:JobTimerElapsed.Id

Get-Job -name LD*| Remove-Job
