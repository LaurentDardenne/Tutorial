#Script impl�mentant -Asjob
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
  
   # Ex�cute cette fonction dans un background job
   [Switch]
   $AsJob
  )
   #Fontion utilis�e pour les tests uniquement
  function Convert-DictionnaryEntry($Parameters) 
  {  #Converti un DictionnaryEntry en une string "cl�=valeur cl�=valeur..." 
    "$($Parameters.GetEnumerator()|% {"$($_.key)=$($_.value)"})"
  }#Convert-DictionnaryEntry
  
 
#---------------- Code cr�ation du job ------------
     #Construction du code du job
     #puis ex�cution d'un job   
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
              { Write-Warning  "Attention la fonction '$MyCommandName' est h�berg�e dans un module." }
            }
            else 
            { $MyCommandName=$Myinvocation.MyCommand.Name -replace '\.ps1$',''}
              
            #Construit, � partir de l'ex�cution de ce code, le code � passer au job
            # On cr�e une fonction puis l'appel � la fonction
            #
            #Un script est transform� en une fonction
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
    #Lors de l'ex�cution du job: Appel la fonction avec les param�tres re�us 
   $MyCommandName @parameter
"@
        )#Create 
           
            #Passe au job les param�tres SAUF le param�tre AsJob
            #On propage donc les arguments recus de la ligne de commande au job
           Start-Job -ScriptBlock $Code -ArgumentList $psBoundParameters 
            #Fin on renvoi un job
        }
        else
        { Throw "Le type de commande '$CommandType' n'est pas support�." }
       
        return
     }

 
#---------------- Code du traitement ------------
  Write-host "R�sultat du traitement en tant que job."
  Write-host "Ce traitement en t�che de fond a re�u les param�tres suivants :`r`n@{$(Convert-DictionnaryEntry $PSBoundParameters )}"    
