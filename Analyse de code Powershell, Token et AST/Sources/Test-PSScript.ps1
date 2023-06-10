﻿function Test-PSScript 
{  #Valide la syntaxe d'un fichier powershell (ps1,psm1,psd1)
 #From http://blogs.microsoft.co.il/blogs/scriptfanatic/archive/2009/09/07/parsing-powershell-scripts.aspx 

   param( 
      [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]  
      [ValidateNotNullOrEmpty()]  
      [Alias('PSPath','FullName')]  
      [System.String[]] $FilePath, 

      [Switch]$IncludeSummaryReport 
   ) 

   begin 
   { $total=$fails=$FileUnknown=0 }   

   process 
   { 
       $FilePath | 
        Foreach-Object { 
           if(Test-Path -Path $_ -PathType Leaf) 
           { 
              $Path = Convert-Path -Path $_  
  
              $Errors = $null 
              $Content = Get-Content -Path $path  
              $Tokens = [System.Management.Automation.PsParser]::Tokenize($Content,[ref]$Errors) 
              if($Errors -ne $null) 
              { 
                 $fails++ 
                 $Errors | 
                  Foreach-Object {  
                    $CurrentError=$_
                    $CurrentError.Token | 
                     Add-Member -MemberType NoteProperty -Name Path -Value $Path -PassThru | 
                     Add-Member -MemberType NoteProperty -Name ErrorMessage -Value $CurrentError.Message -PassThru 
                 } 
              } 
             $total++
           }#if 
           else 
           { Write-Warning  "File unknown :'$_'";$FileUnknown++ } 
       }#for 
   }#process  

   end  
   { 
      if($IncludeSummaryReport)  
      { 
         Write-Host "`n$total script(s) processed, $fails script(s) contain syntax errors,  $FileUnknown file(s) unknown." 
      } 
   } 
} #Test-PSScript

