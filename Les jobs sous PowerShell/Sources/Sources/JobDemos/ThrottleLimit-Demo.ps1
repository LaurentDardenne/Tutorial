#basé sur http://blogs.msdn.com/b/powershell/archive/2011/04/04/scaling-and-queuing-powershell-background-jobs.aspx

Function Split-MagJobName {
 #Parse le nom d'un Job et renvoi un objet
 param ($MagJobName)
  
 $Nom,$Date=$MagJobName -split "\\"
 New-Object PSObject -Property @{Magasin=($Nom -Replace "^MAG","");
                                 StartTime=([DateTime]::FromBinary($Date));
                                 State=$Null;
                                 Name=$MagJobName #Nom du job utilisé par Stop-Job
                                }
}
    
Function New-Magasin {
 param(
   [String]$NomMag,
   [String]$NumMag
 )
 New-Object PsObject -property @{ 
                                  Nom=$NomMag; 
                                  Numero=$NumMag; 
                                  DebutReplication=$Null; 
                                  FinReplication=$null;
                                  Success=$null
                                }
}

$Path="C:\Temp\TraitementDunMagasin.ps1"

@'
param($Magasin)
 Write-host "Traite le magasin situé à $($Magasin.Nom)"  -Fore White
 Sleep -Seconds (Get-Random -Maximum 3 -Minimum 1)
 $result=(Get-Random -Maximum 2 -Minimum 0) -as [Boolean]
 if ($result )
  {Write-host "Réussite du traitement du magasin situé à $($Magasin.Nom)"  -Fore Green}
 else
  {Write-host "Echec du traitement du magasin situé à $($Magasin.Nom)"  -Fore Red}
 $Magasin.FinReplication=[DateTime]::Now
 $Magasin.Success=$Result
 return $Magasin
'@ > $Path


$Magasins=@(
 (New-Magasin 'Paris' 9),
 (New-Magasin 'Marseille' 21),
 (New-Magasin 'Lyon' 55),
 (New-Magasin 'Lille' 123),
 (New-Magasin 'Bordeaux' 1985),
 (New-Magasin 'Toulouse' 6),
 (New-Magasin 'Brest' 1),
 (New-Magasin 'Strasbourg' 33),
 (New-Magasin 'Clermont' 66)
)

 # How many jobs we should run simultaneously
$maxConcurrentJobs = 3;
$Queue = [System.Collections.Queue]::Synchronized( (New-Object System.Collections.Queue) )

foreach($Mag in $Magasins)
 { $Queue.Enqueue($Mag) }

# Function that pops input off the queue and starts a job with it
function Start-JobFromQueue
{
    if( $Queue.Count -gt 0)
    {
        $MagasinCourant=$Queue.Dequeue()
        $StartDate=[DateTime]::Now
        $MagasinCourant.DebutReplication=$StartDate
        $JobName="MAG$($MagasinCourant.Nom)\$($StartDate.ToBinary())"

        $CurrentJob = Start-Job -FilePath $Path -ArgumentList $MagasinCourant -Name $JobName
        Register-ObjectEvent -InputObject $CurrentJob -EventName StateChanged -SourceIdentifier "Event$JobName" -Action { 
                  Start-JobFromQueue 
                  Unregister-Event $eventsubscriber.SourceIdentifier
                  Remove-Job $eventsubscriber.SourceIdentifier 
        } | Out-Null
    }
}
 
# Start up to the max number of concurrent jobs 
# Each job will take care of running the rest
for( $i = 0; $i -lt $maxConcurrentJobs; $i++ )
{
    Start-JobFromQueue
}

sleep -Seconds (1*60)
$MagasinsResultat=Get-Job|Where-Object {$_.Name -Match "^MAG"}|Receive-Job -kee