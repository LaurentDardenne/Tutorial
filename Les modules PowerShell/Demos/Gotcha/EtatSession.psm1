#Module EtatSession
#Met en évidence un problème de portée lié à l'état de session d'un module

function TestData {
  param( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
      $Datas,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
      [Scriptblock] $sb
  ) 
    &$sb 
} #TestData

function TestData2 {
  param( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
      $Datas,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
      [Scriptblock] $sb
  ) 
    $Sb|select *
    &$sb 
} #TestData2

function TestData3 {
  param( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
      $Datas,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
      [Scriptblock] $sb
  ) 
    #On lie explicitement le scriptblock dans la portée du module,
    #sinon la variable $Datas est recherchée dans la portée de l'appelant ce 
    #qui générerait une erreur : VariableIsUndefined    
    &($MyInvocation.MyCommand.ScriptBlock.Module.NewBoundScriptBlock($sb)) 
} #TestData3

function TestData4 {
  param( 
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateNotNull()]
      $Datas,
        [Parameter(Position=1, Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
      [Scriptblock] $sb
  ) 
    $SbBounded=$MyInvocation.MyCommand.ScriptBlock.Module.NewBoundScriptBlock($sb)
     #visu des champs du scriptblock
    $SbBounded|select *
    &$SbBounded 
} #TestData4
