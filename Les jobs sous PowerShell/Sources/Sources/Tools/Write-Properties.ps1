function Write-Properties($InputObject, $PropertyName ="*", [Switch] $Passthru, [Switch] $Silently)
{ #Adaptation d'un script de J.Snoover
  # http://blogs.msdn.com/powershell/archive/2006/12/29/use-copy-property-to-make-it-easier-to-write-read-and-review-scripts.aspx
  #
  # Peut utiliser DebugView for Windows :
  #       http://technet.microsoft.com/en-us/sysinternals/bb896647.aspx
  #
  #Emet le contenu de toutes les propriétés d'un objet sur la console et sur un debugger actif
  #
  # $InputObject         : l'objet à interroger.
  #
  # $PropertyName : le nom de la propriété, ce nom peut contenir des jokers.
  #                 C'est un tableau de string, par défaut on affiche toutes les propriétés 
  #
  # $Silently     : N'émet plus les informations sur la console mais seulement vers le debugger actif
  #                 Par défaut les informations sont émise sur la console et vers le debugger actif.
  #
  # $Passthru     : Indique l'émission de l'objet interrogé dans le pipeline.
  #                 Par défaut il n'est pas émit.
  #
  #Exemples :
  # $a=dir $env:USERPROFILE
  #  Affiche sur la console
  # Write-Properties $a[-1]
  # 
  #  Affiche sur la console et émet l'objet dans le pipe
  # Write-Properties $a[-1] -pass |%{Write-host $_ -fore DarkGreen}
  # $Fichiers=$A[1..3]|Write-Properties -pass| Where {$_.psiscontainer -eq $false}
  #
  #  émet les datas dans le pipe, aucun affichage sur la console
  # Write-Properties $a[-1] -pass -silently |%{Write-host $_ -fore DarkGreen}
  #
  # Affiche uniquement les propriétés listées
  # wp $A[-1] Name,Extension,L*
  
  
  begin
  {
    $IsDebuggerAttached=[System.Diagnostics.Debugger]::IsAttached
    $CS="Call : {0}" -F $MyInvocation.InvocationName
    Write-Debug $CS;Write-Debug $("-" * 80)

    function WriteProperties($InputObject, $PropertyName,[Switch] $Passthru, [Switch] $Silently){

        if ($IsDebuggerAttached) # faire [System.Diagnostics.Debugger]::Launch()
        {
         $sbDbgWrite={[System.Diagnostics.Debug]::WriteLine($Args[0])} #Pour Visual Studio
         [System.Diagnostics.Debug]::Indent()
        }
        else {$sbDbgWrite={[System.Diagnostics.Debug]::Write($Args[0])}} #Pour DbgView
         #La chaine $CS est envoyé vers le debugger actif
        &$sbDbgWrite $CS
         
        foreach ($P in $InputObject |Get-Member -MemberType *Property -Name $propertyName|Sort name)
        {     
#           #Ps V2  
#           try {   
#             $Result ="$($P.Name) : $($InputObject.$($P.Name))"
#            } catch {
#             $Result ="$($P.Name) : Errror : not applicable"
#            }

           trap {continue}
           $Result ="$($P.Name) : Errror - not applicable."
            #La propriété peut contenir un objet
           $Result ="$($P.Name) : $($InputObject.$($P.Name))"        
           #Affiche ou non sur la console.
           #Mais dans tous les cas on affiche au moins sur le débugger
          if (!$Silently)
           {Write-Host $Result}
          &$sbDbgWrite $Result
        }
       if ($IsDebuggerAttached)
        {[System.Diagnostics.Debug]::Unindent() }
       &$sbDbgWrite $("-" * 80)             
    }#writeproperties
  }#begin
  
 process
  {
      #On ne test pas le "delay-bind ScriptBlock"
      #Aucun apport pour cette fonction de debug
      #Faire directement $Objet.Property|WP
     if ($InputObject -and $_) 
      {throw "Impossible de coupler l'usage du pipeline avec le paramètre `$InputObject"}

     if ($_)
     {   
       Write-Debug ("Process : {0}" -F $_)
         #Affiche les propriétés de l'objet
       WriteProperties -InputObject $_ -PropertyName $PropertyName -Silently:$Silently  
         #réémet l'objet
       if ($Passthru) 
        {$_}
     }
  }#process
  
 end
  {
     if ($InputObject)
      { 
        trap {continue}
         #L'opérateur -F Appel ToString()
         #si un process n'existe plus l'appel échoue.
        Write-Debug ("End : {0}" -F $InputObject)
#           #Ps V2  
#           try {   
#              Write-Debug ("End : {0}" -F $InputObject)        
#            } catch {
#             Write-Debug "End : "Les informations demandées ne sont pas disponibles"
#            }

        WriteProperties -InputObject $InputObject -PropertyName $PropertyName -Silently:$Silently  
        if ($Passthru)
        {$InputObject}
      }
  }#end
} #Write-Properties