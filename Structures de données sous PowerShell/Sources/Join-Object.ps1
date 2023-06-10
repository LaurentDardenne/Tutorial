Function Join-Object($first=@(), 
                     $second = $(throw "Please specify a target to join"), 
                     $where={$firstItem -eq $secondItem}, 
                     $output={$firstItem})
{ 
## join-object.ps1
## From http://www.leeholmes.com/blog/CreatingSQLsJoinlikeFunctionalityInMSH.aspx
## Outputs the intersection of two lists, based on a given property
##
## Parameters:
##    -First:  The first set to join with.  Defaults to the pipeline if not specified
##    -Second: The second set to join with.
##    -Where:  A script block by which to compare the elements of the two sets.
##       -$firstItem refers to the element from 'First'
##       -$secondItem refers to the element from 'Second'
##    -Output: An expression to execute when the 'Where' expression evaluates to 'True".
##             Defaults to outputting $firstItem if not specified.
##
## Examples:
## "Hello","World" | join-object -second:"World"
## join-object -first:"A","E","I" -second:"BAT","BUG","BIG" -where:{$secondItem.Contains($firstItem)} -output:{$secondItem}
## 
## $dirset1 = (get-childitem c:\winnt)
## $dirset2 = (get-childitem c:\winnt\system32)
## join-object $dirset1 $dirset2 -where:{$firstItem.Name -eq $secondItem.Name}

  if(-not $first) 
  { 
      foreach($element in $input) { $first += $element }
  }
  
  foreach($firstItem in $first)
  {
     foreach($secondItem in $second)
     {
        if(&$where) { & $output }
     }
  }
}
