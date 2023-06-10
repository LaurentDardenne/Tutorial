Function VisualisePipe3
{ #Affichage d'information lors du passage d’objet dans un segment de pipeline
  #Implémente aucun des 3 trois blocs. Equivaut par défaut à l'implémentation du bloc End 

    Write-Warning "Pas de bloc déclaré" 
    Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    if ($_ -eq $null)
     {Write-host "`tPas de donnée issue du pipe " -f red }
     else 
     {Write-host "`tDonnée issue du pipe : $_" -f green 
      $_ # réémet l'objet
     }
    if ($input -eq $null)
     {Write-host "`L'énumérateur `$input est `$null" -f green}
    else 
     {Write-host "`L'énumérateur `$input n'est pas `$null" -f green}
     
     #Sans cet appel l'affichage suivant est faussé puisque 
     #qu'on a déjà consommé les données de l'itérateur
     $input.reset() 

    if ($input.Movenext() -eq $false) #Renvoi $true si des données existent
      {Write-host "`tPas de donnée issue de l'énumérateur." -f red }
     else 
        #La donnée n'est accessible qu'après l'appel à MoveNext
      {Write-host "`tDonnée issue de l'énumérateur : $($input.Current)" -f green 
       Write-host "`tReste des données issues de l'énumérateur : $input" -f green
      }  
    $input    
 }
