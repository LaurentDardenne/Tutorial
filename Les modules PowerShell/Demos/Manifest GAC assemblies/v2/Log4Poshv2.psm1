#http://www.nivot.org/2008/12/30/PowerShellCTP3AndModuleManifests.aspx
#todo http://poshcode.org/1608

##########################################################################
#                               Add-Lib
#
# Version : 1.0.0 
#   basée sur la version 0.6 du script PackageLog4NET.ps1 
#
# Date    : 10 février 2010
#
# Nom     : Log4Posh.psm1
#
# Usage   : Import-Module Log4Posh
#
# Objet   : Powershell wrapper functions for Log4net
#
# Auteur : Laurent Dardenne 
#
##########################################################################
#doc
# La dll log4net est chargée à partir du GAC sinon dans le répertoire du module.
# La version de ce module à été testé avec la 1.2.10.0
# -Force appel OnRemove 

#Todo On ne peut pas utilser des attributs perso dérivé de ValidateArgumentsAttribute
# les proxy ne gére que les attributs du Runtime

Write-Debug ("Args[0] : {0}" -F $Args[0])

[String] $Path=$args[0]
[String] $DllName="log4net"
if ($Path -eq [string]::empty)
 {$Path=$PSScriptRoot}

Write-Debug ("Path : {0}" -F $Path)
Write-Debug ("PSScriptRoot : {0}" -F $PSScriptRoot)

$Frmt=" : $($MyInvocation.MyCommand.ScriptBlock.Module.Name).{0}"
#todo
 #$ParentInvocation = (Get-Variable MyInvocation -Scope 1).Value 
 #$CS="{0}.{1}" -F $ParentInvocation.MyCommand,$MyInvocation.MyCommand
$FrmtCall="Call$Frmt"
$FrmtBegin="Begin$Frmt"
$FrmtProcess="Process$Frmt"
$FrmtEnd="End$Frmt"

Write-Debug ("Call module : {0}" -F $MyInvocation.MyCommand.ScriptBlock.Module.Name)

# ------------ Initialisation et Finalisation  ----------------------------------------------------------------------------
 #Note: On importe le module avec .psd1   
# Si l'assembly est installé dans le GAC il est prioritaire même s'il est présent dans le répertoire du module.

 #Définition des couleurs d'affichage par défaut
[System.Collections.Hashtable[]] $LogDefaultColors=@(
   @{Level="Debug";FColor="Green";BColor=""},
   @{Level="Info";FColor="White";BColor=""},
   @{Level="Warn";FColor="Yellow,HighIntensity";BColor=""},
   @{Level="Error";FColor="Red,HighIntensity";BColor=""},
   @{Level="Fatal";FColor="Red";BColor="Red,HighIntensity"}
 )

 # ------------- Type Accelerators -----------------------------------------------------------------
  #Usage :
  #  $Logger = new-object [LogManager]::GetLogger($Name))
  #  On doit charger la DLL du Framework avant de pouvoir référencer ses classes.
function Get-LogShorcuts{
  #Affiche les raccourcis dédiés à Log4net
 $AcceleratorsType::Get.GetEnumerator()|Where {$_.Value.FullName -match "^log4net\.(.*)"}
}
 
$AcceleratorsType = [Type]::GetType("System.Management.Automation.TypeAccelerators")   
 # Ajoute les raccourcis de type    
  Try {
    $LogShortCut=@{
      LogManager = [log4net.LogManager];
      LogBasicCnfg = [log4net.Config.BasicConfigurator];
      LogXmlCnfg = [log4net.Config.XmlConfigurator];
      LogColoredConsole = [log4net.Appender.ColoredConsoleAppender];
      LogColors = [log4net.Appender.ColoredConsoleAppender+Colors];
      LogLevel = [log4net.Core.Level];
      LogThreadCtx = [log4net.ThreadContext];
      LogGlobalCtx = [log4net.GlobalContext];
      LogMailPriority = [System.Net.Mail.MailPriority];
      LogSmtpAuthentication = [log4net.Appender.SmtpAppender+SmtpAuthentication];
    }
    $LogShortCut.GetEnumerator() |
    Foreach {
     Try {
       Write-debug "Add TypeAccelerators $($_.Key) =$($_.Value)"
       $AcceleratorsType::Add($_.Key,$_.Value)
     } Catch [System.Management.Automation.MethodInvocationException]{
       write-Error $_.Exception.Message 
     }
   } 
  } Catch [System.Management.Automation.RuntimeException] {
     write-Error $_.Exception.Message
  }

Set-Alias -Scope Global -name Stop-Log -value Stop-Log4Net
Function Stop-Log4Net{
 #On arrête proprement le Framework de Log
  #Avec [log4net.LogManager]::Shutdown() tous les appenders sont fermés proprement, mais le repository par défaut reste configuré

  Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
   #Shutdown() est appellé en interne, le repository par défaut n'est plus configuré
 [log4net.LogManager]::ResetConfiguration()
}


# ----------- Suppression des objets du Wrapper -------------------------------------------------------------------------
function OnRemoveLog4Posh {
  Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)

  if ($MyInvocation.MyCommand.ScriptBlock.Module.PrivateData.StopLog) 
   {  Write-debug "Stop log4net";Stop-Log }
  
   #Remove shortcuts
  $LogShortCut.GetEnumerator() |
    Foreach {
     Try {
       Write-debug "Remove TypeAccelerators $($_.Key)"
       [void]$AcceleratorsType::Remove($_.Key)
     } Catch {
       write-Error $_.Exception.Message
     }
  }
}
 #Accès à 'this', c'est à dire aux propriétés de ce module
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveLog4Posh } 
# $MyInvocation.MyCommand.ScriptBlock.Module.AccessMode="Constant"

#------------------------ Code -------------------------------------------
Set-Alias -Scope Global -name Set-BasicConfigurator -value Set-LogBasicConfigurator 
Set-Alias -Scope Global -name slbcfg -value Set-LogBasicConfigurator  

function Set-LogBasicConfigurator{
  Param (   
    [Parameter(Position=0,
               Mandatory=$True,
               ValueFromPipelineByPropertyName = $true,
               ParameterSetName="Appender")]
    [log4net.Appender.AppenderSkeleton] 
   $Appender,
    [Parameter(ParameterSetName="Default")]
    [Switch] 
   $Default)
    
 #Configure le Framework, le root pointera sur $Appender 
  process #Gestion du pipeline  
  {
     Write-Debug ($FrmtProcess -F $MyInvocation.InvocationName)
     Stop-Log4Net #Sinon on ajoute la nouvelle configuration à l'existante
     if ($Default) 
      { [log4net.Config.BasicConfigurator]::Configure() }
     else 
      { [log4net.Config.BasicConfigurator]::Configure($Appender) }
      #réémet l'objet
	  $Appender
  }
}


# -------------  Logger ----------------------------------------------------------------------------
Set-Alias -Scope Global -name Get-Loggers -value Get-LogLoggers
Set-Alias -Scope Global -name gllgr -value Get-LogLoggers

function Get-LogLoggers{
  #Renvoi tous les loggers du repository par défaut
  #The root logger is not included in the returned array. 
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)
 [log4net.LogManager]::GetCurrentLoggers()
}


Set-Alias -Scope Global -name Get-Logger -value Get-LogLogger
Set-Alias -Scope Global -name gllgr -value Get-LogLogger

function Get-LogLogger{
  Param (   
    [Parameter(Position=0,
                 Mandatory=$True,
                 ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String] 
   $Name)
 #Renvoi un logger de nom $Name ou le crée s'il n'existe pas. 
 # le nom "Root" est valide et renvoi le root existant
 
  process
  {
     Write-Debug ($FrmtProcess -F $MyInvocation.InvocationName)
      #Emet un logger
    [log4net.LogManager]::GetLogger($Name) 
  }
}



Set-Alias -Scope Global -name Get-LoggerRepository -value Get-LogLoggerRepository
Set-Alias -Scope Global -name gllgrrpy -value Get-LogLoggerRepository

function Get-LogLoggerRepository{
  Param (   
    [Parameter(Position=0,
                 Mandatory=$True,
                 ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [String] 
   $RepositoryName,
    [ValidateNotNullOrEmpty()]
    [String] 
   $Name)
 #Renvoi un logger de nom $Name ou le crée s'il n'existe pas. 
 # le nom "Root" est valide et renvoi le root existant
 process {
   Write-Debug ($FrmtProcess -F $MyInvocation.InvocationName)
   [log4net.LogManager]::GetLogger($RepositoryName,$Name)
 }
}

Set-Alias -Scope Global -name Get-RootLogger -value Get-LogRootLogger
Set-Alias -Scope Global -name glrtlgr -value Get-LogRootLogger

function Get-LogRootLogger {
  Param (   
     [ValidateNotNull()]
     [ValidateScript( {Test-IsImplementingInterface $_ "log4net.Core.ILoggerWrapper"} )]
     [Parameter(Position=0,
                Mandatory=$True,
                ValueFromPipelineByPropertyName = $true,
                ParameterSetName="Logger")]
    $Logger, 
     [Parameter(ParameterSetName="Default")]
     [Switch] 
    $Default)
 #Renvoi le logger racine du logger passé en paramètre   
                                   
 Write-Debug ($FrmtCall -F $MyInvocation.InvocationName)                                    
 if ($Default) 
  { $Repository=Get-LogRepository -Default }  
 else 
  {$Repository=$Logger.Repository }
 $Repository.Root
}

$F=@("Get-LogShorcuts",
     "Stop-Log4Net",
     "Set-LogBasicConfigurator",
     "Get-LogLoggers",
     "Get-LogLogger",
     "Get-LogLoggerRepository",
     "Get-LogRootLogger")	
Export-ModuleMember -Function $F  -Variable LogDefaultColors -alias Stop-Log
rv F
