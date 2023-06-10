Function Expand-Alias {
#from http://www.dougfinke.com/blog/index.php/2009/01/03/expand-alias-for-powershell-integrated-scripting-environment/
  $content=$psise.CurrentFile.Editor.text
  [System.Management.Automation.PsParser]::Tokenize($content, [ref] $null) |
    Where { $_.Type -eq 'Command'} |
    Sort StartLine, StartColumn -Desc |
     ForEach {
       if($_.Content -eq '?') {
         $result = Get-Command '`?' -CommandType Alias
       } else {
         $result = Get-Command $_.Content -CommandType Alias -ErrorAction SilentlyContinue
       }    
       if($result)
       {
         $psise.CurrentFile.Editor.Select($_.StartLine,$_.StartColumn,$_.EndLine,$_.EndColumn)
         $psise.CurrentFile.Editor.InsertText($result.Definition)
      }
     }
}

if( -Not ($psISE.CustomMenu.Submenus | ?{$_.DisplayName -eq 'Expand Alias'}) ) 
{ $null = $psISE.CurrentPowershellTab.AddOnsMenu.Submenus.Add("Expand Alias", {Expand-Alias}, 'Ctrl+Shift+E') }