#requires -version 2  
function Resolve-Aliases {
#from http://www.nivot.org/blog/post/2008/07/01/PSParserTricks1NdashResolveAllAliasesToDefinitionsInAScript         
    param($filename = $(throw "need filename!"))  
     
    $lines = $null 
    $path = Resolve-Path $filename -ErrorAction 0  
     
    if ($path) {  
        $lines = Get-Content $path.path  
    } else {  
        Write-Warning "Could not find $filename" 
        return  
    }  
     
    # Initialize  
    $parser = [system.management.automation.psparser]  
    $errors = $Null #new-object system.management.automation.psparseerror[] 0  
     
    do {  
        $tokens = $parser::tokenize($lines, [ref]$errors)     
        $retokenize = $false 
          
        if ($errors.count -gt 0) {  
            Write-Warning "$($errors.count) error(s) found in script." 
            $errors 
            return  
        }  
     
        # look through tokens for commands  
        $tokens | % {  
            if ($_.Type -eq "Command") {  
                $name = $_.Content  
                  
                # is it an alias?  
                # we use -literal here so '?' isn't treated as wildcard  
                if ((!($name -eq ".")) -and (Test-Path -LiteralPath alias:$name)) {  
                      
                    # gcm may return more than one match, so specify "alias"  
                    # filtering against name kludges the '?' alias/wildcard   
                    $command = gcm -CommandType alias $name | ? { $_.name -eq $name }  
                                  
                    # resolve alias which may lead to another alias  
                    # so loop until we reach a non-alias  
                    do {  
                        $command = Get-Command $command.definition  
                    } while ($command.CommandType -eq "Alias")  
                      
                    Write-Host -NoNewline "Resolved " 
                    Write-Host -NoNewline -ForegroundColor yellow $name 
                    write-host -nonewline " to "   
                    write-host -ForegroundColor green $command.name           
                      
                    # Use a stringbuilder to replace the alias in the line  
                    # pointed to in the Token object. StringBuilder has a much  
                    # more precise Replace method than String. This allows us to  
                    # replace the token with 100% confidence.  
                    $sb = New-Object text.stringbuilder $lines[$_.startline - 1]  
                    $sb = $sb.replace($name, $command.Name, $_.startcolumn - 1, $_.length)  
                    $lines[$_.startline - 1] = $sb.tostring()  
                      
                    # now that we've replaced a token, the script needs to be reparsed  
                    # as offsets have changed on this line.   
                    $retokenize = $true 
                      
                    # break out of pipeline, (not 'do' loop)  
                    continue;  
                }  
            }  
        }  
    } while ($retokenize)  
     
    Write-Host "" # blank line  
     
    # output our modified script  
    $lines  
}#Resolve-Aliases