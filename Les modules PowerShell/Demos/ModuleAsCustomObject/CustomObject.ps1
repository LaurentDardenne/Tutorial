 #Cr�e un objet bas� sur un module dynamique
$CustomObject=New-Module -AsCustomObject -ScriptBlock {
    #Cr�e une variable en Read/Only 
  New-Variable LectureSeule -Option ReadOnly -Value ([String]"Non modifiable")
  
   #Cr�e des variables accessibles dans la port�e 
   #de ce module dynamique. 
  [int] $script:Nombre=0
  
  [int] $script:VariableExport�e=0
    
 
  Function Transform�eEnMethode {
    $script:Nombre++
    FonctionPriv�e        
  }

  Function FonctionPriv�e {
   get-variable t*
   Write-host "La variable nombre = $script:Nombre"
   Write-host "La variable Externe= $($this.externe)"            
  }

  
  Export-ModuleMember -function Transform�eEnMethode -variable VariableExport�e,LectureSeule 
}

   #Membres additionnels
$CustomObject=$CustomObject|
  add-member -membertype ScriptProperty -Name Nombre -value { 
     $this.Nombre}  -secondvalue { $this.Nombre=$Args[0] } -passthru | 
  add-member -membertype ScriptProperty -Name Externe -value { 
     "Membre externe"}   -passthru 

$CustomObject
