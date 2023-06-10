#demo de New-PSCustomObjectFunction

 
Type $MyInvocation.MyCommand.Path
return

Import-Module PSObjectHelper

#L'appel suivant : 
$Name="ParsingDirective"
New-PSCustomObjectFunction $Name 'Name','Line'
 
#Génére et affiche le code suivant: 
# 
# param(
#          [Parameter(Mandatory=$True,position=0)]
#         $Name,
#          [Parameter(Mandatory=$True,position=1)]
#         $Line
# )
#   
#   #Les paramétres liés définissent aussi les propriétés de l'objet
#  $O=New-Object PSObject -Property $PSBoundParameters
#  $O.PsObject.TypeNames.Insert(0,"ParsingDirective")
#  $O|Add-Member ScriptMethod ToString {'{0}:{1}' -F $this.Name,$this.Line} -Force -Passthru

#Cet appel créé des membres basé PSObject en ReadOnly : 
$Name="ParsingDirective"
New-PSCustomObjectFunction $Name 'Name','Line' -AsPSVariableProperty

# param(
#          [Parameter(Mandatory=$True,position=0)]
#         $Name,
#          [Parameter(Mandatory=$True,position=1)]
#         $Line
# )
#   #Les paramétres liés définissent aussi les propriétés de l'objet
#    $O=New-Object PSObject
#   $PSBoundParameters.GetEnumerator()|
#    Foreach {
#      $O.PSObject.Properties.Add( (New-PSVariableProperty $_.Key $_.Value -ReadOnly) )
#    }
# 
#  $O.PsObject.TypeNames.Insert(0,"ParsingDirective")
#  $O
 

#Le code généré peut être directement utilisé pour construire une fonction à l'aide du provider :
 
$Name="ParsingDirective"
New-PSCustomObjectFunction $Name 'Name','Line' | Set-Item Function:"New-$Name" -Force
$o=New-ParsingDirective 'Debug' '10'
$o
$o.psobject.TypeNames
 

#On peut vouloir créer une fonction avec la déclaration complète : 
$Code=New-PSCustomObjectFunction 'ParsingDirective' 'Name','Line' -File
$Code|
 Set-Content C:\Temp\New-ParsingDirective.ps1
Type C:\Temp\New-ParsingDirective.ps1
 

#Une possible simplification de la saisie : 
Function ql {$args}
New-PSCustomObjectFunction 'Test' (ql  QL avec une fonction comportant de nombreux paramètres facilite la saisie) -File

#On peut donc déclarer ce type de fonction de création d'objet simple à la volée
New-PSCustomObjectFunction 'New-Disk' 'DeviceID','Status','Partition','TotalSize'| 
 Set-Item Function:"New-$Name" -Force

New-PSCustomObjectFunction New-LogicalDisk 'Size','FreeSpace','DriveType','MediaType','VolumeName','DeviceID','Number'| 
 Set-Item Function:"New-$Name" -Force
