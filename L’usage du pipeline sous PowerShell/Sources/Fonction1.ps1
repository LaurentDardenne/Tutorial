Function Fonction1
{  
  begin{ 

     Write-Host "Begin Fonction1" -f Green
 }

 Process{ 
    Write-Host "`tProcesss Fonction1" -F Yellow
    $_
 }
 End{ 
    Write-Host "End Fonction1" -f Cyan
 }
}
