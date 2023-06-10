Function Fonction2
{  
  begin{ 
     Write-Host "Begin Fonction2" -f Green
 }

 Process{ 
    Write-Host "`tProcesss Fonction2" -F Yellow
    $_
 }
 End{ 
    Write-Host "End Fonction2" -f Cyan
 }
}
