Function VisualisePipe2
{ #Affichage d'information lors du passage d�objet dans un segment de pipeline
  #Impl�mente le bloc End uniquement
 End{ 
    Write-Warning "End" 
    Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    $_ # r��met l'objet
    if ($_ -eq $null)
     {Write-host "`tPas de donn�e issue du pipe " -f red }
     else 
     {Write-host "`tDonn�e issue du pipe : $_" -f green }

    if ($input -eq $null)
     {Write-host "`L'�num�rateur `$input est `$null" -f green}
    else 
     {Write-host "`L'�num�rateur `$input n'est pas `$null" -f green}

    if ($input.Movenext() -eq $false) #Renvoi $true si des donn�es existent
      {Write-host "`tPas de donn�e issue de l'�num�rateur." -f red }
     else 
        #La donn�e n'est accessible qu'apr�s l'appel � MoveNext
      {Write-host "`tDonn�e issue de l'�num�rateur : $($input.Current)" -f green }      
    $input
   }
 }
