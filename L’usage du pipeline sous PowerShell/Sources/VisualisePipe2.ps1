Function VisualisePipe2
{ #Affichage d'information lors du passage d’objet dans un segment de pipeline
  #Implémente le bloc End uniquement
 End{ 
    Write-Warning "End" 
    Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    $_ # réémet l'objet
    if ($_ -eq $null)
     {Write-host "`tPas de donnée issue du pipe " -f red }
     else 
     {Write-host "`tDonnée issue du pipe : $_" -f green }

    if ($input -eq $null)
     {Write-host "`L'énumérateur `$input est `$null" -f green}
    else 
     {Write-host "`L'énumérateur `$input n'est pas `$null" -f green}

    if ($input.Movenext() -eq $false) #Renvoi $true si des données existent
      {Write-host "`tPas de donnée issue de l'énumérateur." -f red }
     else 
        #La donnée n'est accessible qu'après l'appel à MoveNext
      {Write-host "`tDonnée issue de l'énumérateur : $($input.Current)" -f green }      
    $input
   }
 }
