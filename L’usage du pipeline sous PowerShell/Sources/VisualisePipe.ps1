Function VisualisePipe
{ #Affichage d'information lors du passage d’objet dans un segment de pipeline
 #Implémete les blocs Begin,Process et End 
   
   # Function Visu{ ..} 
   # Si on déclare un bloc on ne peut pas déclarer de function imbriquée
   
  begin{ 
      #Visu...
     Write-Warning "Begin"
     Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
     Write-host "Vérification de la déclaration de la variable automatique `$input : $(dir variable:i*)"

     if ($_ -eq $null)
     {Write-host "Pas de donnée issue du pipe " -f red }
     else 
     {Write-host "Donnée issue du pipe : $_" -f green }

     if ($input.Movenext() -eq $false)
      {Write-host "Pas de donnée issue de l'énumérateur." -f red }
     else 
      {Write-host "Donnée issue de l'énumérateur : $($input.Current)" -f green }
      $IsPremier=$true
 }

 Process{ 
    Write-Warning "Processs"
    if ($IsPremier) 
     { 
      Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
      $IsPremier =$false
     }
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
    if ($_ -eq $null)
     {Write-host "`tPas de donnée issue du pipe " -f red }
     else 
     {Write-host "`tDonnée issue du pipe : $_" -f green 
      $_ # réémet l'objet     
     }
     
    if ($input.Movenext() -eq $false) #Renvoi $true si des données existent
      {Write-host "`tPas de donnée issue de l'énumérateur." -f red }
     else 
        #La donnée n'est accessible qu'après l'appel à MoveNext
      {Write-host "`tDonnée issue de l'énumérateur : $($input.Current)" -f green  }      

   }
 }
