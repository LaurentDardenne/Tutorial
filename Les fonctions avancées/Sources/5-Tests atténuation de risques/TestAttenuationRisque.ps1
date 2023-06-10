Function TestAttenuationRisque
{
<# 
.Synopsis 
    This is My Version of GetProcess 
.Description 
    QQDescription 

.Parameter ID 
.Example 
    Get-MyProcess 
.ReturnValue 
    QQReturnValue 
.Link 
    QQLink 
.Notes 
NAME:      Get-MyProcess 
AUTHOR:    Laurent Dardenne 
LASTEDIT:  04/01/2009 13:45:00 
#Requires -Version 2.0 
#> 

  [CmdletBinding( 
      SupportsShouldProcess=$True, 
      ConfirmImpact="Medium")] 
   param( 
    [Parameter(
      Position=0,
      Mandatory = $true,
      ValueFromPipeline = $true)] 
    $ID) 

  Begin 
  {
    Function Traitement($Object) {
     Write-Host "Traite $Object" 
    }
  }#Begin 
  
  Process 
  { 
    #ShouldContinue(string query, string caption)
    #ShouldContinue(string query, string caption, System.Boolean [ref] yesToAll, System.Boolean [ref] noToAll)

    # ShouldProcess(string target) : 
    #   Affiche le nom de l'op�ration ex�cut�e
    # ShouldProcess(string target, string action) : 
    #   Affiche le nom de l'op�ration � ex�cuter et le nom de la ressource cible � modifier.
    # ShouldProcess(string verboseDescription, string verboseWarning, string caption) :
    #   Affiche une description de l'op�ration � ex�cuter, un message de warning incluant la question et un titre du message de warning .
    # ShouldProcess(string verboseDescription, string verboseWarning, string caption, 
    #                System.Management.Automation.ShouldProcessReason [ref]shouldProcessReason) :
    # Affiche une description d�taill�e de la ressource cible � modifier de l'op�ration � ex�cuter. 
     #if ($force �or $pscmdlet.ShouldProcess($_, "Message")) 
     #if ( $pscmdlet.ShouldProcess($_, "Message"))
     #if ($force �or $pscmdlet.ShouldContinue($_, "Op�ration Traitement"))
    
   if ($psCmdlet.shouldProcess($_, "Op�ration Traitement"))
      { Traitement $_} 
     
  }#Process 
  
  End 
  { 
  }#End
}

1..3|TestAttenuationRisque