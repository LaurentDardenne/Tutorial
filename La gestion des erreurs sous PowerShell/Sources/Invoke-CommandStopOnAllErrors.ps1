Function Out-Debuger{
  #Envoi $Message vers un debuger actif
  #Si aucun debugger n'existe au moment de l'exécution de ce code, il 
  # n'y aura aucune erreur de déclenchée, car l'appel ne fait rien.
  #Le préfix permet de faciliter le filtrage des lignes dans DebugView.
  #N'est actif que si le code est exécuté dans la même session que celle
  #l'appelant. 
  #par exemple un script exécuté par un service ne pourra afficher des 
  #traces dans une instance de debugview exécuté dans la session d'un 
  #dévellopeur/se 
 
 param (
  $Message,
  $PrefixFilter="[Orchestrator]"
 )
  [System.Diagnostics.Debug]::Write("$PrefixFilter $Message")   
}#Out-Debuger  

Function Invoke-CommandStopOnAllErrors {
 #Etant donné que PowerShell peut émettre des erreurs non bloquante on exécute 
 #les instructions $Command dans un contexte où $ErrorActionPreference est egale à 'Stop'.
 # 
 #En production, on présuppose les prérequis à l'exécution du code, droits, accès disque, etc comme étant toujours validés.
 #Ainsi,en appelant le code dans ce contexte 'protégé', on se prémunit de leur hypothétique changement.
 #
 #Cette fonction exécute par défaut du code Powershell en configurant $ErrorActionPreference à STOP.
 #En cas de changement du contexte, directory, module, droits, etc toutes erreur provoquera un arrêt du workflow Orchestrator.
 #La collection $Error sera sérialisée dans un fichier XML.
 
 # Voir aussi http://powershell-scripting.com/index.php?option=com_joomlaboard&Itemid=76&func=view&id=11783&catid=14#11783
 #
 #Dépendance : script "New-Exception.ps1"

  param ( 
     [Parameter(Position=0, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
      #Nom de l'activité d'un workflow Orchestrator
      #utilisé pour construire le nom du fichier d'erreur
    [String] $ActivityName,
     
     [Parameter(Position=1, Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
      #Chemin du fichier de log.
    [String] $Path,     
     
     [Parameter(Position=2, Mandatory=$true)]
     [ValidateNotNull()]
     [ValidateScript( {$_.ToString().Trim() -ne [string]::Empty} )]
      #Code Powershell de l'activité du workflow Orchestrator ( cf AvtivityName)
    [ScriptBlock]$Command
  )
  
  $isStopException=$False
  $ErrorActionPreference = 'Stop'
  
  #Dans un bloc catch la variable $_ est tjr une instance de ErrorRecord hébergeant une instance d'exception.
  #Alors que dans $Error celle-ci peut contenir :
  # soit une erreur non bloquante du type ErrorRecord (PowerShell)
  #   $error[0].ErrorRecord.Exception
  # soit une erreur bloquante d'un type dérivé de la classe Exception (dotnet)
  #   $error[0].Exception
  #
  #On obtient le contexte de l'erreur avec : $Error[0].ErrorRecord.InvocationInfo |select *  
  
  try {
    Out-Debuger "Run Command"
      #Exécute le code dans le portée courante
    . $command 
  } catch [System.Management.Automation.ActionPreferenceStopException]
  {
     # Déclenchée, si $ErrorActionPreference='Stop', lors  
     # d'un appel à Write-Error ou à $PSCmdlet.WriteError
    Out-Debuger "Catch StopException: $_"
    $isStopException=$true

     #Redéclenche l'exception encapsulée dans l'exception ActionPreferenceStopException
     #cf. http://msdn.microsoft.com/en-us/library/ms714465(v=vs.85).aspx
 
     #L'exception qui nous intéresse est imbriqé dans ActionPreferenceStopException
    Throw (New-Exception $_.Exception)
     #Le bloc Catch suivant ne traitera pas l'exception que l'on créé ici
     # Pour ce faire il faut une nouvelle imbrication try/catch :
     #  try  { Invoke-CommandStopOnAllErrors  { myFunction } } catch {...}
        
  }#catch ActionPreferenceStopException
  
  catch  #Trappe les autres erreurs
  {
     #Les objets Orchestrator ne renvoient pas d'exception, mais des résulats de réussite ou d'erreur (format String)
     
     #Pour une exception de type System.Management.Automation.RuntimeException, 
     #le champ InnerException est tjr renseigné :
     #  System.Management.Automation.RuntimeException +  System.DivideByZeroException 
     #Pour d'autres type d'exception ce n'est pas tjr le cas.     
    if ($_.Exception)  # -isnot [MYAPPException])
    {
        $isStopException=$true
        Out-Debuger "Catch global : $($_.Exception.getType())"
        Out-Debuger "InnerException is null : $($_.Exception.InnerException -eq $null)"
    }
   Throw $_    #le WorkFlow Orchestrator échoue sur une erreur
 } #catch all exceptions

 Finally {
  try {
    Out-Debuger "Finally isStopException=$isStopException"
    if ($isStopException)
    { 
      Out-Debuger "$ActivityName : exception imprévue $_"  
      $FileName="$Path\{0:dd-MM-yyyy-HH-mm-ss}-{1}.xml" -F ([DateTime]::Now),$ActivityName
      Out-Debuger "Nom de fichier de log = $FileName"
      $CpError=$Global:Error.Clone()
      $CpError|Export-clixml $FileName
    }
   }catch {
     Out-Debuger "catch : '$_'"
     $_|set-content $FileName
   }
 }#Finally
}#Invoke-CommandStopOnAllErrors