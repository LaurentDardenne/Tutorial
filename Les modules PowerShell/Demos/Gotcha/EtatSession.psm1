#Module EtatSession
#Met en �vidence un probl�me de port�e li� � l'�tat de session d'un module

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
    #On lie explicitement le scriptblock dans la port�e du module,
    #sinon la variable $Datas est recherch�e dans la port�e de l'appelant ce 
    #qui g�n�rerait une erreur : VariableIsUndefined    
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
