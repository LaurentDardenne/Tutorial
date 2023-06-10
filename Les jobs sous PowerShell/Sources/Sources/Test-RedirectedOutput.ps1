  Function Test-RedirectedOutput {
     #Analyse le texte d'exécution d'une commande externe dont le flux d'erreur est redirigé vers la sortie standard
     #  prg.exe 2>&1
     #Renvoi $null si la collection est vide ou un tableau d'erreur
     #
     #  $Result=Receive-Job $Job
     #  Test-RedirectedOutput "[UnProgramme]" $Result
    param ( 
        [Parameter(Position=0,Mandatory=$true)]
      [String] $Header,
        [Parameter(Position=1,Mandatory=$true)]
        [AllowNull()]
      $OutputText
    )
    
    $Message=$Null
     #La variable OutputText est-elle un tableau ?
    if ($OutputText -ne $null -and $OutputText -is [System.Collections.IEnumerable] -and $OutputText  -isnot [String] )
    {
       #On s'assure de renvoyer un tableau
      $Message=@()
       #Collection vide
      if ($OutputText.Count -eq 0)
      { $Message=$Null }
       #Cas de retour d'éxécution distante via winrm
      elseif ($OutputText[-1].PSObject.TypeNames[0] -eq "Deserialized.System.Management.Automation.ErrorRecord" )
      {
          #Extrait les lignes d'erreurs qui ne peuvent être qu'en fin de collection
         For ($i=($OutputText.count-1); $i -ge 0; $i--)
         {
            if ($OutputText[$i].PSObject.TypeNames[0] -eq "Deserialized.System.Management.Automation.ErrorRecord")
             { $Message += $OutputText[$i] }
            else
             { break }
         }
         throw "$Header $Message" 
      }
      elseif ($OutputText[-1] -is [System.Management.Automation.ErrorRecord])
      {

          #Cas de retour d'exécution local sur un distant
         For ($i=($OutputText.count-1); $i -ge 0; $i--)
         {
           if ($OutputText[$i] -is [System.Management.Automation.ErrorRecord])
            { $Message += $OutputText[$i] }
           else
            { break }
         }
         throw "$Header $Message" 
      }
    }
    elseif ($OutputText -ne $null -and $OutputText[-1] -is [System.Management.Automation.Runspaces.RemotingErrorRecord])
    {
      throw "$Header $Message" 
    }
    elseif ($OutputText -ne $null -and $OutputText -is [String])
    {
       #La variable OutputText est une simple chaîne de caractères
       #Celle-ci peut contenir un texte d'erreur si le prg externe est mal codé ...
      $Message=$Null
    }  
    else {throw "[Test-RedirectedOutput] bug type :$($OutputText.getType()) non géré"}
    $Message
  }#Test-RedirectedOutput