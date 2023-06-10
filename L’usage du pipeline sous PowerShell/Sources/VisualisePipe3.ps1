Function VisualisePipe3
{ #Affichage d'information lors du passage d�objet dans un segment de pipeline
  #Impl�mente aucun des 3 trois blocs. Equivaut par d�faut � l'impl�mentation du bloc End 

    Write-Warning "Pas de bloc d�clar�" 
    Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    if ($_ -eq $null)
     {Write-host "`tPas de donn�e issue du pipe " -f red }
     else 
     {Write-host "`tDonn�e issue du pipe : $_" -f green 
      $_ # r��met l'objet
     }
    if ($input -eq $null)
     {Write-host "`L'�num�rateur `$input est `$null" -f green}
    else 
     {Write-host "`L'�num�rateur `$input n'est pas `$null" -f green}
     
     #Sans cet appel l'affichage suivant est fauss� puisque 
     #qu'on a d�j� consomm� les donn�es de l'it�rateur
     $input.reset() 

    if ($input.Movenext() -eq $false) #Renvoi $true si des donn�es existent
      {Write-host "`tPas de donn�e issue de l'�num�rateur." -f red }
     else 
        #La donn�e n'est accessible qu'apr�s l'appel � MoveNext
      {Write-host "`tDonn�e issue de l'�num�rateur : $($input.Current)" -f green 
       Write-host "`tReste des donn�es issues de l'�num�rateur : $input" -f green
      }  
    $input    
 }
