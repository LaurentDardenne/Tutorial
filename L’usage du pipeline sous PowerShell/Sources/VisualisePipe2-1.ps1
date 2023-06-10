Function VisualisePipe2-1
{ #Affichage d'information lors du passage d’objet dans un segment de pipeline
  #Implémente que les blocs Process et End 
 Process{ 
    Write-Warning "Processs"
    #if ($IsPremier)     La variable n'existe plus sans sa déclaration dans le bloc Begin
    #{ 
    #  Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    #  $IsPremier =$false
    # }
    if ($_ -eq $null)
     {Write-host "`tPas de donnée issue du pipe " -f red }
     else 
     {Write-host "`tDonnée issue du pipe : $_" -f green 
      Write-host "`tType de la donnée :$(($input.GetType()).Fullname)"
      $_ # réémet l'objet
     }

    if ($input.Movenext() -eq $false) #Renvoi $true si des données existent
      {Write-host "`tPas de donnée issue de l'énumérateur." -f red }
     else 
        #La donnée n'est accessible qu'après l'appel à MoveNext
      {Write-host "`tDonnée issue de l'énumérateur : $($input.Current)" -f green }      
      
    #Write-host "Total : $($input.count)" $input est un itérateur il ne posséde donc pas de propriété count 

 }  
 End{ 
    Write-Warning "End" 
    Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    $_ # réémet l'objet
    if ($_ -eq $null)
     {Write-host "`tPas de donnée issue du pipe " -f red }
     else 
     {Write-host "`tDonnée issue du pipe : $_" -f green }


    if ($input.Movenext() -eq $false) #Renvoi $true si des données existent
      {Write-host "`tPas de donnée issue de l'énumérateur." -f red }
     else 
        #La donnée n'est accessible qu'après l'appel à MoveNext
      {Write-host "`tDonnée issue de l'énumérateur : $($input.Current)" -f green }      
 
   }
 }
