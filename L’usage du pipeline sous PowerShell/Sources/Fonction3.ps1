Function Fonction3
{  
  begin{ 
     Write-Host "Begin Fonction3" -f Green
 }

 Process{ 
    Write-Host "`tProcesss Fonction3" -F Yellow
    $_
 }
 End{ 
    Write-Host "End Fonction3" -f Cyan
 }
}
