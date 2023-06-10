#Script implémentant -Asjob
#From http://blog.start-automating.com/updates/Adding%20an%20-AsJob%20to%20any%20PowerShell%20function/
<#
  .Synopsis
     Une fonction de test.
   
  .EXAMPLE
    $job=.\AsJobScript.ps1 -AsJob -Name 'test' -Count 10
    Sleep -s 2
    Receive-Job $job
   
          
#>    
  [OutputType([Nullable],[Management.Automation.Job])]    
  param(            
   $Name,
   
   $Count,
  
   # Exécute cette fonction dans un background job
   [Switch]
   $AsJob
  )
   #Fontion utilisée pour les tests uniquement
  function Convert-DictionnaryEntry($Parameters) 
  {  #Converti un DictionnaryEntry en une string "clé=valeur clé=valeur..." 
    "$($Parameters.GetEnumerator()|% {"$($_.key)=$($_.value)"})"
  }#Convert-DictionnaryEntry
  
 
#---------------- Code création du job ------------
     #Construction du code du job
     #puis exécution d'un job   
     if ($AsJob) {
        $CommandType=$Myinvocation.MyCommand.CommandType
        if (($CommandType -eq 'Function') -or ($CommandType -eq 'ExternalScript'))
        {
            $null = $psBoundParameters.Remove('AsJob')
            $Code=$null
            
            $MyCommandName=$Myinvocation.MyCommand.Name
            if ($CommandType -eq 'Function')
            {
              if ($MyInvocation.MyCommand.ModuleName -ne [string]::Empty)
              { Write-Warning  "Attention la fonction '$MyCommandName' est hébergée dans un module." }
            }
            else 
            { $MyCommandName=$Myinvocation.MyCommand.Name -replace '\.ps1$',''}
              
            #Construit, à partir de l'exécution de ce code, le code à passer au job
            # On crée une fonction puis l'appel à la fonction
            #
            #Un script est transformé en une fonction
            $Code=[ScriptBLock]::Create(@"
   param([Hashtable]`$parameter) 
   function $MyCommandName {
  $(
      if ($CommandType -eq 'Function') 
      {Get-Command $MyCommandName | Select-Object -ExpandProperty Definition}
      else 
      {
        "# $($Myinvocation.MyCommand.Definition)`r`n"
        Get-Command $Myinvocation.MyCommand.Definition | Select-Object -ExpandProperty ScriptContents
      }
  )
  }
    #Lors de l'exécution du job: Appel la fonction avec les paramètres reçus 
   $MyCommandName @parameter
"@
        )#Create 
           
            #Passe au job les paramètres SAUF le paramètre AsJob
            #On propage donc les arguments recus de la ligne de commande au job
           Start-Job -ScriptBlock $Code -ArgumentList $psBoundParameters 
            #Fin on renvoi un job
        }
        else
        { Throw "Le type de commande '$CommandType' n'est pas supporté." }
       
        return
     }

 
#---------------- Code du traitement ------------
  Write-host "Résultat du traitement en tant que job."
  Write-host "Ce traitement en tâche de fond a reçu les paramètres suivants :`r`n@{$(Convert-DictionnaryEntry $PSBoundParameters )}"    
