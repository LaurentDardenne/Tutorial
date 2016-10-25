Workflow CompteurDeReprise {
 param( 
     [ValidateRange(1,10)]
   [int] $Maximum=3,
     
     [ValidateNotNullOrEmpty()]
   [string] $Path='C:\Temp\WF1'
 )
  
  $nbReprise=1
    
  Do
  { 
    Write-Verbose "Tentative numéro : $nbReprise/$Maximum"
    $PathExist=Test-Path $Path
    If  (-Not $PathExist)
    {
      $nbReprise++
      Write-Error "Le répertoire '$Path' n’existe pas. Corrigez ce point"
      if ($nbReprise -gt $Maximum)  
      { Write-Warning "Echec. Nombre de reprise maximum atteint.";Exit }
      Suspend-Workflow
    }
  } While (-Not $PathExist)

  Write-Verbose "Réussite le workflow continue..." 
}

# $VerbosePreference='Continue'
# CompteurDeReprise -JobName Reprises 
# 
# Get-Job -Name Reprises|Resume-Job|Receive-Job -Wait