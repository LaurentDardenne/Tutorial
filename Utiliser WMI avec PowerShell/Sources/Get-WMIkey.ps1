function Get-WmiKey 
{ #Jeffrey Snoover
  # http://blogs.msdn.com/powershell/archive/2008/04/15/wmi-object-identifiers-and-keys.aspx
  $class = [wmiclass]$args[0] 
  $class.psbase.Properties | 
      Select @{Name="PName";Expression={$_.name}} -Expand Qualifiers | 
      Where {$_.Name -eq "key"} | 
      foreach {$_.Pname} 
}

