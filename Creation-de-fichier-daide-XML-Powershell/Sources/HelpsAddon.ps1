if (!(Test-Path function:'New-helps'))
{ Throw "You must load Helps.ps1 - PowerShell Help Builder" }

function New-Exception($Exception,$Message=$null) {
#Crée et renvoi un objet exception pour l'utiliser avec $PSCmdlet.WriteError()

   #Le constructeur de la classe de l'exception trappée est inaccessible  
  if ($Exception.GetType().IsNotPublic)
   {
     $ExceptionClassName="System.Exception"
      #On mémorise l'exception courante. 
     $InnerException=$Exception
   }
  else
   { 
     $ExceptionClassName=$Exception.GetType().FullName
     $InnerException=$Null
   }
  if ($Message -eq $null)
   {$Message=$Exception.Message}
    
   #Recrée l'exception trappée avec un message personnalisé 
	New-Object $ExceptionClassName($Message,$InnerException)       
} #New-Exception

function Initialize-HelpFile {
#construit à partir de metadonnée d'un module une arborescence de fichier d'aide 
#Dépend des fonctions New-CommandHelp et New-CommandHelpTemplate
  [CmdletBinding(DefaultParameterSetName = "Path",SupportsShouldProcess=$True)]        
  Param (
       #nom du module à traiter, doit être dans le path PSModulePath
       #On en extrait les fonctions exportées 
     [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Name")]
     [ValidateNotNullOrEmpty()]    
   [string] $Name,
     [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="Path")]
     [ValidateNotNullOrEmpty()]    
   [System.IO.FileInfo] $Path,
      #Les métadonnées du module sont passé en paramètres
     [Parameter(Mandatory=$true,ValueFromPipeline = $true,ParameterSetName="MetaData")]
   [System.Management.Automation.PSModuleInfo] $Module,
      #Répertoire parent où seront généré les squelettes de fichier d'aide du module 
      #Est crée s'il n'existe pas
     [Parameter(Position=0)]
     [ValidateNotNullOrEmpty()]    
   $WorkingDirectory=(Join-Path $env:Temp 'Helps'),
      #culture concernée, par défaut celle en cours 
      #dans la session
     [Parameter(Position=1)]
     [ValidateNotNullOrEmpty()]
   [string[]]$Culture=@(Get-Culture),
      #Liste des commandes concernées par la génération
     [Parameter(Position=2)]
     [ValidateNotNullOrEmpty()]
  [string[]]$Command='*',
      #On recharge le module
      #Pour Metadata ce n'est pas nécessaire.
     [Parameter(ParameterSetName="Name")]
     [Parameter(ParameterSetName="Path")]
   [Switch] $Force
  )
  
  process {    
   try 
   {
     $ModuleName=$null
     switch ($PsCmdlet.ParameterSetName) 
     {
       'Name' {$ModuleName=$Name}            
       'Path' {$ModuleName=$Path.BaseName}
       'MetaData' {$ModuleName=$Module.Name}
     }  
     Write-debug "ModuleName :$ModuleName"
     $CurrentDirectory="$WorkingDirectory\$ModuleName"
     
     $isRemoveModule=$false
      #On ne recharge pas les modules à traiter via les métadonnées
     if ($PsCmdlet.ParameterSetName -ne 'MetaData')
     { 
        $Module=Get-Module |Where {$_.Name -eq $ModuleName}
        if ( ($Module -eq $null) -or $Force )
        {  #charge ou recharge le module à traiter  
          try {
           Write-debug "Load module $modulename"              
           $Module=Import-Module $ModuleName -PassThru -EA Stop -Force:$Force
           $isRemoveModule=$true
          }
          catch 
          {
            $PSCmdlet.WriteError(
            (New-Object System.Management.Automation.ErrorRecord(
            	 (New-Exception $_.Exception ("Impossible to load the module '$ModuleName'")), 
                 "ImportModule", 
                 "InvalidData",
                 ("[{0}]" -f $ModuleName)
               )  
            )
            )#WriteError            
          }
        }
     }       
      
     if ($Module -ne $Null) 
     {
        #répertoire de travail
       if (-not (Test-Path $CurrentDirectory) )
       {  md $CurrentDirectory > $null }
       Push-Location $CurrentDirectory
       Write-debug "CurrentDirectory: $CurrentDirectory"       
       
       Write-debug "Create Helps template for the module : $ModuleName"
       $Module.ExportedFunctions.GetEnumerator()|
         Where {
          #Write-Debug  "Filtre $($_.Key)"
          $Result=$false
          foreach ($cmd in $Command){
            #Write-Debug "Valide $cmd"
            if ($_.Key -like "$cmd")
            {$Result=$true;break}
           }
          $Result 
         }|
         Foreach {
           $Current=$_.Key
           Write-debug "Template for command : $Current"
           $Current|New-CommandHelpTemplate $Module.Name $CurrentDirectory
           $Culture|
            Foreach { 
             $Current|New-CommandHelp $Module.Name $CurrentDirectory $_
            }
         }
     }
    }
   Finally {
    if ($Module -ne $Null)
    { Pop-Location }

    if ($isRemoveModule)
    { 
      Write-debug "Remove module $modulename"  
      Remove-Module $ModuleName 
    }
   }
 }#process
}#Initialize-HelpFile

Function New-CommandHelpTemplate { 
 param (
   [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
   [ValidateNotNullOrEmpty()]
  [string]$CommandName,
  
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string]$ModuleName,
  
    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string] $TargetDirectory
 )

 Process {
    $isDataBloc=$false
    $isCmdBloc=$false
    $sBuildData=new-object System.Text.StringBuilder
    $sBuildCmd=new-object System.Text.StringBuilder
    
    Write-Verbose "`r`nCurrent command : $CommandName"
    $WorkingDirectory="$TargetDirectory\$CommandName"
    Write-debug "[New-CommandHelpTemplate] WorkingDirectory=$WorkingDirectory"
    if (-not (Test-Path $WorkingDirectory) )
    {  
      Write-debug "Create WorkingDirectory '$WorkingDirectory'"
      md $WorkingDirectory > $null }
   
     #hashtable des messages
    $FileDataBlocTemplate="$WorkingDirectory\{0}.{1}.Datas.Template.ps1" -F $ModuleName,$CommandName
     #hashtable du code
    $FileCmdBlocTemplate="$WorkingDirectory\{0}.{1}.Cmds.Template.ps1" -F $ModuleName,$CommandName
     #fichier commun pour toutes les cultures qui 
     # ne déclarent pas de fichier 'cmds' spécifique
    $FileCmdBlocCommon="$WorkingDirectory\Common.{0}.{1}.Cmds.ps1" -F $ModuleName,$CommandName
    
     #Les déclarations émisent le sont dans deux 'blocs' distincts
    New-Helps -Command $CommandName -LocalizedData Datas |
     Foreach-Object { 
        $Line=$_
        switch ($Line)  
        {
         "# $CommandName command help"  {$isCmdBloc=$true;$isDataBloc=$false; break}
         "# $CommandName command data"  {$isDataBloc=$true;$isCmdBloc=$false;break}
        } 
           
        if ($isDataBloc)
        { 
          [void]$sBuildData.AppendLine($Line)
        }elseif ($isCmdBloc)
        { 
          [void]$sBuildCmd.AppendLine($Line)
        }
     }#Foreach 
 
    Write-verbose "Write $FileDataBlocTemplate"
    $sBuildData.ToString()|Set-Content $FileDataBlocTemplate
   
    Write-verbose "Write $FileCmdBlocTemplate"
    $sBuildCmd.ToString() |Set-Content $FileCmdBlocTemplate 
    Write-verbose "Write $FileCmdBlocCommon"
    $sBuildCmd.ToString() |Set-Content $FileCmdBlocCommon  
 }#process
} #New-CommandHelpTemplate

Function New-CommandHelp {
 param (
   [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
   [ValidateNotNullOrEmpty()]
  [string]$CommandName,
  
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string]$ModuleName,
  
    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path $_})]
  [string] $TargetDirectory,
  
    [Parameter(Position=2,Mandatory=$true)]
    [ValidateNotNull()]
  [System.Globalization.CultureInfo]$Culture,
    
  [Switch] $All
 )
 
 Begin {
  function Touch{
   param ($File)
    Dir $File | 
     Foreach-Object {$_.LastWriteTime =[DateTime]::Now}
   
  }#touch      
 }
 
 Process {
    Write-Verbose "[$Culture] create files help for the command : $CommandName"
    $WorkingDirectory="$TargetDirectory\$CommandName" 
     #Crée les fichiers finaux de l'aide, préfixé du nom de culture
    $FileDataBlocTemplate="$WorkingDirectory\{0}.{1}.Datas.Template.ps1" -F $ModuleName,$CommandName
    $NewFileDataBloc="$WorkingDirectory\{0}.{1}.{2}.Datas.ps1" -F $Culture,$ModuleName,$CommandName
    Write-verbose "Write $NewFileDataBloc"
    Copy $FileDataBlocTemplate $NewFileDataBloc 
    Touch $NewFileDataBloc 
    
     #Si demandé, on crée le fichier 'cmds' spécifique à une culture 
    if ($All) 
    {
      $FileCmdBlocTemplate="$WorkingDirectory\{0}.{1}.Cmds.Template.ps1" -F $ModuleName,$CommandName
      $NewFileCmdBloc="$WorkingDirectory\{0}.{1}.{2}.Cmds.ps1" -F $Culture,$ModuleName,$CommandName
      Write-verbose "Write $NewFileCmdBloc"
      Copy $FileCmdBlocTemplate $NewFileCmdBloc
      Touch $NewFileCmdBloc
    } 
 }#process
} #New-CommandHelp

Function ConvertTo-XmlHelp {
 param (
   [Parameter(Mandatory=$true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
   [ValidateNotNullOrEmpty()]
   [Alias('Key')]
  [string]$CommandName,
  
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string]$ModuleName,

    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path $_})]
  [string] $SourceDirectory,  
  
    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path $_})]
  [string] $TargetDirectory,
  
    [Parameter(Position=2,Mandatory=$true)]
    [ValidateNotNull()]
  [System.Globalization.CultureInfo]$Culture  
 )
 begin {
    $NewDirectory="$TargetDirectory\{0}" -F $Culture        
    if (-not (Test-Path $NewDirectory) )
    { 
      Write-Verbose "Create directory : $NewDirectory"
      md $NewDirectory > $null 
    }       
 }
 
 Process {
    Write-Verbose "[$Culture] create xml help files for the command : $CommandName"
    $WorkingDirectory="$SourceDirectory\$CommandName" 
    $FileDataBloc="$WorkingDirectory\{0}.{1}.{2}.Datas.ps1" -F $Culture,$ModuleName,$CommandName
    Write-Verbose "Load Datas from $FileDataBloc"
    if (Test-Path $FileDataBloc)
    { 
       #Charge la hashtable dans la portée courante
      .$FileDataBloc
      
       #Traite le fichier Cmds de la culture courante
      $FileCmdBloc="$WorkingDirectory\{0}.{1}.{2}.Cmds.ps1" -F $Culture,$ModuleName,$CommandName 
      Write-verbose "`tValidate $FileCmdBloc"
      if (-not (Test-Path $FileCmdBloc) ) 
      {
        #sinon, traite le fichier Cmds commun
        $FileCmdBloc="$WorkingDirectory\Common.{0}.{1}.Cmds.ps1" -F $ModuleName,$CommandName
      }
      Write-verbose "Convert $FileCmdBloc"
      $NewXmlFile="$NewDirectory\{0}.{1}.xml" -F $ModuleName,$CommandName
      Write-verbose "Write $NewXmlFile`r`n"
      Convert-Helps  $FileCmdBloc $NewXmlFile
    }
    else 
    { Write-Error "The file do not exist : '$FileDataBloc'" } 
 }#process
} #ConvertTo-XmlHelp

function Join-XmlHelp {
#Fusionne des fichiers d'aide MAML 
#On insére dans le premier fichier trouvé tous les noeuds $NextCommand.helpItems.command
#trouvés dans les fichiers restants.
 
 param (
   [Parameter(Mandatory=$true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)]
   [ValidateNotNullOrEmpty()]
   [Alias('Key')]
  [string]$CommandName,
  
    [Parameter(Position=0,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string]$ModuleName,

    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( {Test-Path $_})]
  [string] $SourceDirectory,
  
    [Parameter(Position=1,Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
  [string] $TargetDirectory,
  
    [Parameter(Position=2,Mandatory=$true)]
    [ValidateNotNull()]
  [System.Globalization.CultureInfo]$Culture  
 )         
 begin { 
    $NewDirectory="$SourceDirectory\{0}" -F $Culture        
    Write-Verbose "Read from directory : $NewDirectory"
    if ($TargetDirectory -notmatch '$Culture$')
    { $TargetDirectory=join-path $TargetDirectory $Culture }
    
    if (-not (Test-Path $TargetDirectory) )
    { 
      Write-Verbose "Create directory : $TargetDirectory"
      md $TargetDirectory > $null 
    }
    Write-Verbose "Write into directory : $TargetDirectory"
    $FirstCmd=$true
    $Help=$null
 }
          
 Process {
    $XmlFile="$NewDirectory\{0}.{1}.xml" -F $ModuleName,$CommandName
    if (Test-Path $XmlFile) 
    {
      Write-Verbose "Read $XmlFile"
      if ($FirstCmd)         
      {
        Write-Debug "Add first command : $CommandName"
         #Lit le premier fichier
        [xml]$Help=Get-Content $XmlFile
        $FirstCmd=$false
      }
      else 
      { 
        Write-Debug "Add next command : $CommandName"
         #On ajoute la commande courante dans la structure du premier fichier
        [xml]$NextCommand=Get-Content $XmlFile
        $Node=$NextCommand.helpItems.command.CloneNode($true)
        $NewNode=$Help.ImportNode($Node, $true);
        [void]$help.helpItems.AppendChild($NewNode)
      }
   }
   else 
   { Write-Error "The file do not exist : $XmlFile" } 
  }#process
  
  end {
   if ($Help -ne $null)
   {
      Write-Debug "Save all commands."
      $HelpFileName= "$TargetDirectory\${ModuleName}-Help.xml"
      Write-Verbose "Write $HelpFileName"
      $Help.Save($HelpFileName)
   }
   else 
   { Write-Warning  "Nothing to save." } 
 }#end
}#Join-XmlHelp
