Function TraiteEventlog{
  [CmdletBinding(SupportsShouldProcess=$True)]
  param ([Parameter(mandatory=$true,ValueFromPipeline = $true)]$Computername)
 Begin 
 {
  Function Traitement($Object) {
   Write-Host "Traite $Object" 
  }
  $OutValue = $null
  if ($MyInvocation.BoundParameters.TryGetValue('Confirm', [ref]$outValue)) 
  {
    if ($OutValue -eq $null) 
     {Write-Warning "[TraiteEventlog-Begin] Le paramètre Confirm prend la valeur `$null."}
    else 
     {Write-Warning "[TraiteEventlog-Begin] Le paramètre Confirm est précisé et prend la valeur $OutValue."}  
  }
  else
  {
    Write-Warning "[TraiteEventlog-Begin] Le paramètre Confirm n'est pas précisé."
  }

 }#Begin

 process {  
  write-warning "[TraiteEventlog-Process]"
  get-eventlog -computer $Computername -list|%{
  if ($psCmdlet.shouldProcess("$Computername : $($_.logDisplayName)" , "traite eventlog de $Computername"))
   {
    Traitement "$Computername :  $($_.logDisplayName)"
    #Clear-Eventlog -comp $computername -log $_.log -Whatif
   }
  else {Write-host "Pas de traitement sur event $($_.logDisplayName)"}
  } 
 }
}

Function TestAttenuationRisque
{
  [CmdletBinding( 
      SupportsShouldProcess=$True, 
      ConfirmImpact="Medium")] 
   param( 
    [Parameter(
      Position=0,
      Mandatory = $true,
      ValueFromPipeline = $true)] 
    [string]$Computername) 

  Process 
  { 
     if ($psCmdlet.shouldProcess($_ , "Opération sur $Computername"))
      {
        write-warning "[TestAttenuationRisque-Process]"
        $computername 
      }
    else {Write-host "Pas de traitement avec $computername"}

  }#Process 
  
  End 
  { 
  }#End
}

 #La fonction TraiteEventlog ne reçoit aucune donnée  
".","127.0.0.10","."|TestAttenuationRisque -whatif|TraiteEventlog -Whatif

 #La fonction TraiteEventlog traite tous les journaux sans demande confirmation
 #On confirme sur le nom de machine
".","127.0.0.10","."|TestAttenuationRisque -confirm|TraiteEventlog 

 #La fonction TraiteEventlog traite tous les journaux avec une demande de confirmation
 #On confirme sur le nom de machine et sur chacun de ses journaux
".","127.0.0.10","."|TestAttenuationRisque -confirm|TraiteEventlog -Confirm 

".","127.0.0.10","."|
 Foreach {
  Get-Eventlog  -Computer $_ -list |
  Foreach {Clear-Eventlog -Computer $_.MachineName $_.Log -Whatif } #confirm }
 }  
