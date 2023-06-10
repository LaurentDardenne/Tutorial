Function FcntAvancée{
  [CmdletBinding()]
  Param (   
  [Parameter(
      ValueFromPipeline = $true)]
  $NomParam,
  $Count)
  Begin {
      #$pscmdlet.WriteCommandDetail("**** Test de log --------")
      $pscmdlet.WriteDebug("**** Test de log --------")
      $pscmdlet.WriteObject("Test WriteObject")
    }
 Process {
     $ErrorRecord = New-Object System.Management.Automation.ErrorRecord  ( 
            (New-Object Exception "Erreur: l'objet n'existe pas."), 
            "FcntAvancée.MonErreur_1", 
            [System.Management.Automation.ErrorCategory]::ObjectNotFound, 
            $NomParam
         ) 

      $ErrorRecord.ErrorDetails="Informations supplémentaires: actions recommandées (Indiquer un objet existant)"
      $PSCmdlet.ThrowTerminatingError($ErrorRecord) 


      Throw "Erreur: l'objet n'existe pas."
      $pscmdlet.WriteCommandDetail("**** Test de log --------")
      $properties=@{CurrentOperation=" début"}
      $ProgressRecord= new-object System.Management.Automation.ProgressRecord(1,"TestProgress","En cours") -property $properties 

      $Tab=dir variable:
      $i=1
      foreach ($VarName in $Tab)
      {
       $ProgressRecord.PercentComplete=($i/($Tab.Count))*100
       $ProgressRecord.CurrentOperation="Traite : $($VarName.Name)"
       $pscmdlet.WriteProgress($ProgressRecord)
       $i++
       sleep -m 250 
      }
      pause
      #ferme le progress
     $ProgressRecord.RecordType=[System.Management.Automation.ProgressRecordType]::Completed
     $pscmdlet.WriteProgress($ProgressRecord)
   }
 end{  
   Write-host "`$NomParam=$NomParam `t `$Count=$Count"
   $pscmdlet|gm |Sort membertype,name
   $pscmdlet.WriteCommandDetail("**** Test de log --------")
 }
}

FcntAvancée un 9 

Trace-command -Name * -Option All -Exp  {FcntAvancée un 9 } -FilePath c:\temp\Trace.log
Trace-Command -name ParameterBinding {FcntAvancée un 9 } –pshost

Trace-command -Name * -Option All -Exp  {"Un","Deux"|FcntAvancée -Nom "Trois" -c 9 } -FilePath c:\temp\Trace.log
