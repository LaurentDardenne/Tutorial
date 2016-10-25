$codeError=@'
# Workflow TestWFError { "ok";$s='}

Workflow TestEmpty {}
'@

$code=@'

Workflow TestEmpty {}

Workflow TestOk {
  param ([switch] $Strict)
  $Text='Unreserved Keyword'
}

Workflow Test2 {
 param ([String[]] $Handles)
 Write-Output $Handles #pas d'affectation, exécution OK
}
#Test2 -Handles 1,2 OK

Workflow Test2_1([String[]] $Path){
$Handles=@('Test') #Affectation OK, exécution KO         
 Write-Output $Handles 
}
#Test2_1 -path 'C:\temp" KO

Workflow VBKeyWords{
    "One"
    $Const='vb'
    
    Two
    Function Distinct{ param($ParamArray) "Distinct"}
    workflow Two()
    {
        "Two"
        $in=10
       
        Three
        Function Three{ 
         param($AddressOf)
         "Three"
        }
   }
  
  InlineScript {
     function F2 {"F2"; $event=1..5;$Event}
     Workflow W2 { 
      "W2"
      $Set=F2
      InlineScript {
         function F3 {"F3";W3}
         Workflow W3 {Param ($Date) "W3"}
         $Delegate=F3               
      } 
     } 
    $Option=W2            
  }
}

Workflow Distinct{
 param($ParamArray)
 
 InlineScript {
   $Event=10
   Workflow Distinct{
    param($ParamArray)
     
     Workflow Inner{
       param($Next)
     }#Inner            
   }#Distinct             
 }#Inline          
}#Distinct

Workflow Variant 
{
    "One"
    $Const='vb'
    
    Two
    workflow Two()
    {
        "Two"
        $in=10
        $Dim=get-process -name ps*
        
        Three
        Function Three
        { param($AddressOf)
            "Three"
            function Five {"Five"}
            Workflow Four {
              Param () 
               "Four" 
               Five
               $Distinct='Test'
            Workflow Six {
              Param ($Text) 
              $Test='testt'
              "Six $text" 
            }
           }
         Four
       }  
       $event=1..5  
    } #two 
    
    InlineScript {
       function F2 {"F2"; $event=1..5;$Event}
       Workflow W2 { 
        "W2"
        $Set=F2
        InlineScript {
           function F3 {"F3";W3}
           Workflow W3 {Param ($Date) "W3"}
           $Delegate=F3               
        } 
       } 
      $Option=W2            
    }
}

Workflow Test3 {
  param (
      [String[]] $Handles,
      [switch] $Explicit
  )
  $In=10 #usage impossible, car 'In' est un mot clé du VB
  $Return=$Input
  Write-Output $Handles #usage possible, car $Handles n'est pas dans une affectation
  Write-Output $Variant
  $Text='Unreserved Keyword' 
   #usage possible, car 'Distinct' ne pose pas de pb ici.
  $Distinct='Unreserved Keyword'
}

Workflow Test5() {
  InlineScript {
    $Variant=10 #inline
   
    Workflow Inner() {
      $Erase=$true #WF
      InlineScript {
        $Erase=$false #Inline
      }#Inline
   }#WF Inner
  }#Inline  
}

Workflow Test5_1 {
 param()
  Write-Output $Handles #usage possible, car $Handles est un paramètre
  InlineScript {
    $Variant=10 #inline
    Write-Output $Variant #inline
    $Handles='Test'  #inline
   
    Workflow Inner([switch] $Erase) {
      $Erase=$true #WF
      Write-Output $Erase #WF
      InlineScript {
        $Erase=$false #Inline
        Write-Output $using:Erase #Inline
      }#Inline
   }#WF Inner
  }#Inline  
}

Workflow Test6([String[]] $Handles, [switch] $Erase) {
  
  Write-Output $Handles 
  $testHandles=@('tt')
  Write-Output $Erase

  InlineScript {
    $Variant=10
    Write-Output $Variant
    $Handles='Test'
   
    Workflow Inner([String[]] $Handles) {
      Write-Output $Handles 
      $Handles=@('tt')
      InlineScript {
        [switch] $Erase=$true
        Write-Output $Erase
      }#Inline
   }#WF Inner
  }#Inline  
  $Text='Unreserved Keyword' 
   #usage possible, car 'Distinct' ne pose pas de pb ici.
  $Distinct='Unreserved Keyword'
}

Workflow Test7
{
    param ($ModuleName)

    function Initialize-Files
    { $Variant=10 }

    workflow Get-Metadata
    { 
        Initialize-Files
        Get-Module -ModuleName $ModuleName
        $in=1..3        
        function Get-DataSource($Erase) 
        {
           "..."
        }
    }

    function Get-Configuration
    {
      workflow Get-Metadata2
      { 
         InlineScript { 
          Initialize-Files
          Get-Module -ModuleName $ModuleName
          $in=1..3        
         }
         $return=10
      }
    }

   InlineScript { 
    $in=1..3        
   }
  $return=10  
}
'@