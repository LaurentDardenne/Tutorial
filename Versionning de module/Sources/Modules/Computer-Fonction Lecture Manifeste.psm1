#Computer.psm1
#Chapitre 3.2	Récupérer les informations de version
 
Function Get-Info {
 Write-Warning "Call Get-Info" 
 Write-host "Name=$($ExecutionContext.SessionState.Module.Name)"
 Write-host "Version=$($ExecutionContext.SessionState.Module.Version)"
 Write-host "GUID=$($ExecutionContext.SessionState.Module.GUID)"
}
Get-Info

