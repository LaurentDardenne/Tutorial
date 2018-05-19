 #Crée un objet basé sur un module dynamique
$CustomObject=New-Module -AsCustomObject -ScriptBlock {
    #Crée une variable en Read/Only 
  New-Variable LectureSeule -Option ReadOnly -Value ([String]"Non modifiable")
  
   #Crée des variables accessibles dans la portée 
   #de ce module dynamique. 
  [int] $script:Nombre=0
  
  [int] $script:VariableExportée=0
    
 
  Function TransforméeEnMethode {
    $script:Nombre++
    FonctionPrivée        
  }

  Function FonctionPrivée {
   get-variable t*
   Write-host "La variable nombre = $script:Nombre"
   Write-host "La variable Externe= $($this.externe)"            
  }

  
  Export-ModuleMember -function TransforméeEnMethode -variable VariableExportée,LectureSeule 
}

   #Membres additionnels
$CustomObject=$CustomObject|
  add-member -membertype ScriptProperty -Name Nombre -value { 
     $this.Nombre}  -secondvalue { $this.Nombre=$Args[0] } -passthru | 
  add-member -membertype ScriptProperty -Name Externe -value { 
     "Membre externe"}   -passthru 

$CustomObject
