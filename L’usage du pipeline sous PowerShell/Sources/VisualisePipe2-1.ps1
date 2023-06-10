Function VisualisePipe2-1
{ #Affichage d'information lors du passage d�objet dans un segment de pipeline
  #Impl�mente que les blocs Process et End 
 Process{ 
    Write-Warning "Processs"
    #if ($IsPremier)     La variable n'existe plus sans sa d�claration dans le bloc Begin
    #{ 
    #  Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    #  $IsPremier =$false
    # }
    if ($_ -eq $null)
     {Write-host "`tPas de donn�e issue du pipe " -f red }
     else 
     {Write-host "`tDonn�e issue du pipe : $_" -f green 
      Write-host "`tType de la donn�e :$(($input.GetType()).Fullname)"
      $_ # r��met l'objet
     }

    if ($input.Movenext() -eq $false) #Renvoi $true si des donn�es existent
      {Write-host "`tPas de donn�e issue de l'�num�rateur." -f red }
     else 
        #La donn�e n'est accessible qu'apr�s l'appel � MoveNext
      {Write-host "`tDonn�e issue de l'�num�rateur : $($input.Current)" -f green }      
      
    #Write-host "Total : $($input.count)" $input est un it�rateur il ne poss�de donc pas de propri�t� count 

 }  
 End{ 
    Write-Warning "End" 
    Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
    $_ # r��met l'objet
    if ($_ -eq $null)
     {Write-host "`tPas de donn�e issue du pipe " -f red }
     else 
     {Write-host "`tDonn�e issue du pipe : $_" -f green }


    if ($input.Movenext() -eq $false) #Renvoi $true si des donn�es existent
      {Write-host "`tPas de donn�e issue de l'�num�rateur." -f red }
     else 
        #La donn�e n'est accessible qu'apr�s l'appel � MoveNext
      {Write-host "`tDonn�e issue de l'�num�rateur : $($input.Current)" -f green }      
 
   }
 }
