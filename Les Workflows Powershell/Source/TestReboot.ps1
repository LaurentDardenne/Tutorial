Workflow Test 
{ 
    Write-Warning "Recherche des process"
    $Name='Po*'
    Get-Process -Name $Name 
    
 #---- Enregistre l'état du workflow, puis reboot le poste locale 
    Restart-Computer -Wait
    Write-Warning "Suite du Workflow. Name='$Name'"
    Get-service -Name W*
}

Test –JobName TestReprise 
