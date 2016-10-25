Workflow Test 
{ 
    Write-Warning "Recherche des process"
    $Name='Po*'
    Get-Process -Name $Name 
    
 #---- Enregistre l'état du workflow 
    Suspend-Workflow 
    Write-Warning "Suite du Workflow. Name='$Name'"
    Get-service -Name W*
}

Test –JobName TestReprise 
