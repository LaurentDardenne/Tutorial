#Adapté de CmdletExtensionLibrary.ps1 de Kirk Munro      
Import-Module PSWorkflow
 
 #Force le chargement de 
 #Microsoft.PowerShell.Activities.resources.dll
Workflow Test { $args;"Test erreur"}

$ResourceString=@{}
[appdomain]::currentdomain.GetAssemblies()|
 Where {$_.location -match "resources.dll$"}| #récupère uniquement les assemblies resources
 Foreach {
    $CurrentAssembly=$_
      #On ne prend, dans le nom de fichier assembly, que la partie 'namespace' 
      #et on remplace les points par des tirets
    $AssemblyName=(split-path $_.Location -leaf).Replace(".resources.dll","").Replace(".","_")
      Write-Debug $AssemblyName 
    $ResourceString."$AssemblyName"=@{}
    $ResourceString."$AssemblyName"=$ResourceString."$AssemblyName"| Add-Member NoteProperty Location $_.Location -pass
     #récupère les noms des ressources du fichier resources courant 
    $_.GetManifestResourceNames()|
    Foreach {
      $CurrentResourceName=$_
       #Supprime le postfixe
      $ResourceName= $_ -replace '.resources$',""
      $ResourceNameH=$ResourceName.Replace(".","_")
       Write-Debug "`t$ResourceName"
      $ResourceString."$AssemblyName"."$ResourceNameH"=@{}
       #Crée un gestionnaire de ressources
      $rm=new-object System.Resources.ResourceManager($ResourceName,$CurrentAssembly)
       #récupère les ressources du fichier courant
      ($rm.GetResourceSet((Get-Culture),$true,$true)).GetEnumerator()|
       Foreach {
         $NameKeyResource=$_.Key.Replace(".","-")
         Write-debug "`t`t$NameKeyResource"
           #Insére la clé et la valeur dans la table  
         $ResourceString."$AssemblyName"."$ResourceNameH"."$NameKeyResource"=$_.Value
       }  
    }
 }

$ResourceString.GetEnumerator()| 
 Foreach {$_.value.getenumerator()} |
 Foreach {$_.value.getenumerator()}|
 Where {$_.value -match 'Workflow'}|
 Format-List

 $ResourceString.getenumerator()|% {
  $Level1=$_.Name
  $_.Value.getenumerator()|% {
   $Level2=$_.Name
   $_.Value.getenumerator()|? Name  -match 'supported'|% { "$level1.$level2."+ $_.Name} 
  }
}

$ResourceString.Microsoft_PowerShell_Activities.ActivityResources_fr.GetEnumerator()|sort name