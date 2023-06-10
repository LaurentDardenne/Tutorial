Function VisualisePipe
{ #Affichage d'information lors du passage d�objet dans un segment de pipeline
 #Impl�mete les blocs Begin,Process et End 
   
   # Function Visu{ ..} 
   # Si on d�clare un bloc on ne peut pas d�clarer de function imbriqu�e
   
  begin{ 
      #Visu...
     Write-Warning "Begin"
     Write-host "Nom du type de la variable automatique `$input : $(($input.GetType()).Fullname)"
     Write-host "V�rification de la d�claration de la variable automatique `$input : $(dir variable:i*)"

     if ($_ -eq $null)
     {Write-host "Pas de donn�e issue du pipe " -f red }
     else 
     {Write-host "Donn�e issue du pipe : $_" -f green }

     if ($input.Movenext() -eq $false)
      {Write-host "Pas de donn�e issue de l'�num�rateur." -f red }
     else 
      {Write-host "Donn�e issue de l'�num�rateur : $($input.Current)" -f green }
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
    if ($_ -eq $null)
     {Write-host "`tPas de donn�e issue du pipe " -f red }
     else 
     {Write-host "`tDonn�e issue du pipe : $_" -f green 
      $_ # r��met l'objet     
     }
     
    if ($input.Movenext() -eq $false) #Renvoi $true si des donn�es existent
      {Write-host "`tPas de donn�e issue de l'�num�rateur." -f red }
     else 
        #La donn�e n'est accessible qu'apr�s l'appel � MoveNext
      {Write-host "`tDonn�e issue de l'�num�rateur : $($input.Current)" -f green  }      

   }
 }
