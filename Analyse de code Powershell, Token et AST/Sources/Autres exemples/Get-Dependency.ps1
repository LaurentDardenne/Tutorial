﻿##############################################################################
#.AUTHOR
# Josh Einstein
# Einstein Technologies, LLC
#from : http://poshcode.org/1075
##############################################################################

$BuiltInAliases   = @{}
$BuiltInCmdlets   = @{}
$BuiltInFunctions = @{}
$BuiltInVariables = @{}

##############################################################################
#.SYNOPSIS
# Gets a list of tokenized strings from the specified PowerShell code sample
# which can be used for dependency analysis or other unique purposes.
#
#.DESCRIPTION
# This command will use the currently active PowerShell ISE editor tab if the
# current shell is PowerShell ISE and a block of code was not provided to
# the command.
#
#.PARAMETER Type
# If specified, returns only PSTokens of the specified type(s).
#
#.PARAMETER Token
# If specified, returns only PSTokens that contain the specified text.
#
#.PARAMETER Text
# The block of text to tokenize. If this parameter is not specified, and the
# current shell is PowerShell ISE, the current editor tab's text will be used
# otherwise, no output is returned.
#
#.PARAMETER Path
# Specifies the path to an item. Wildcards are permitted.
#
#.PARAMETER LiteralPath
# Specifies the path to an item. Unlike Path, the value of LiteralPath is
# used exactly as it is typed. No characters are interpreted as wildcards.
# If the path includes escape characters, enclose it in single quotation marks.
# Single quotation marks tell Windows PowerShell not to interpret any
# characters as escape sequences.
#
#.PARAMETER Lines
# If specified, returns only the tokens that are on one of the line numbers
# specified. This is useful for doing a two-pass check as in the first example
# which aims to list function declarations which consist of two related tokens,
# the keyword containing the word "function" and the command argument containing
# the function name. It is assumed they will both be on the same line.
#
#.EXAMPLE
# $FunctionLines = Get-PSToken -Type Keyword -Token function | %{ $_.StartLine }
# $FunctionNames = Get-PSToken -Type CommandArgument | ?{ $FunctionLines -contains $_.StartLine }
#
#.LINK 
# Get-Dependency
#
#.RETURNVALUE 
# A collection of PSTokens parsed from the source code.
##############################################################################
function Get-PSToken {

    [CmdletBinding(DefaultParameterSetName='Selection')]
    param(
        
        [Parameter(Position=1)]
        [String[]]$Type,
        
        [Parameter(Position=2)]
        [String[]]$Token,

        [Parameter(ParameterSetName='Path', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [String[]]$Path,
        
        [Alias("PSPath")]
        [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [String[]]$LiteralPath,
        
        [Parameter()]
        [Int32[]]$Lines

    )

    process {
    
        if ($PSCmdlet.ParameterSetName -eq 'Selection') {
            if (-not $PSISE) { throw 'The Selection parameter set is not valid outside of the PowerShell ISE.' }
            if (-not $PSISE.CurrentOpenedFile) { throw 'There is no file currently opened.' }
            if (-not $PSISE.CurrentOpenedFile.IsSaved) { throw 'Please save the currently active document first.' }
            if ($PSISE.CurrentOpenedFile.IsUntitled) { throw 'Please save the currently active document first.' }
            $ResolvedPaths = @(Resolve-Path -LiteralPath $PSISE.CurrentOpenedFile.FullPath)
        }
        elseif ($PSCmdlet.ParameterSetName -match '^(Literal)?Path$') {
            switch ($PSCmdlet.ParameterSetName) {
                Path        { $ResolvedPaths = @(Resolve-Path -Path $Path) }
                LiteralPath { $ResolvePathArgs = @(Resolve-Path -LiteralPath $LiteralPath) }
            }
        }
        
        # Delegate path expansion to Resolve-Path
        foreach ($ResolvedPath in $ResolvedPaths) {
            
            $ScriptContent = Get-Content $ResolvedPath
            
            # Call the PSParser to tokenize!
            $ParserErrors = [System.Management.Automation.PSParseError[]]@()
            $ParserTokens = [System.Management.Automation.PSParser]::Tokenize($ScriptContent, [Ref]$ParserErrors)
            
            # If there were any errors, write them out as warnings
            for ($i=0; $i -lt $ParserErrors.Length; $i++) {
                $ParserError = $ParserErrors[$i]
                if (-not $ParserError.Token) { Write-Warning $ParserError.Message }
                else { Write-Warning "($($ParserError.Token.StartLine), $($ParserError.Token.StartColumn)) $($ParserError.Message)" }
            }

            if (-not $ParserTokens.Count) { return }

            # Filter the output
            if ($Type.Length)  { $ParserTokens = @($ParserTokens | ?{ $Type -contains $_.Type       }) }  # Filter By Type
            if ($Token.Length) { $ParserTokens = @($ParserTokens | ?{ $Token -contains $_.Content   }) }  # Filter By Content
            if ($Lines.Length) { $ParserTokens = @($ParserTokens | ?{ $Lines -contains $_.StartLine }) }  # Filter By Line

            if (-not $ParserTokens.Count) { return }
        
            # Return the tokens, adding a Path property to each one
            # that points back to the script or editor file
            # note that text blocks will have a null path
            $ParserTokens | Add-Member -PassThru NoteProperty Script (Split-Path -Leaf $ResolvedPath)

        }

    } # process

}


##############################################################################
#.SYNOPSIS
# Calculates the dependencies of a script file, block of PowerShell code, or
# an open PowerShell ISE document.
#
#.DESCRIPTION
# Before deploying a script or module, it is important to ensure that any
# external dependencies are resolved otherwise code that runs fine on your
# machine will bomb on someone else's. This function will scan a single
# level of dependencies from the specified script and by default returns
# any dependency that is 1) not a part of the built-in PowerShell command
# and variable configuration and 2) not defined in the script being analyzed.
# You can override this behavior and include these dependencies with the
# Force parameter.
#
#.PARAMETER Path
# Specifies the path to an item. Wildcards are permitted.
#
#.PARAMETER LiteralPath
# Specifies the path to an item. Unlike Path, the value of LiteralPath is
# used exactly as it is typed. No characters are interpreted as wildcards.
# If the path includes escape characters, enclose it in single quotation marks.
# Single quotation marks tell Windows PowerShell not to interpret any
# characters as escape sequences.
#
#.PARAMETER Text
# The block of text to tokenize. If this parameter is not specified, and the
# current shell is PowerShell ISE, the current editor tab's text will be used
# otherwise, no output is returned.
#
#.PARAMETER Unresolved
# When specified, only unresolved dependencies are returned.
#
#.PARAMETER Force
# When specified, all dependencies are included, even if they are known to
# be defined locally or in the default PowerShell configuration.
#
#.EXAMPLE
# Get-Dependency | Out-GridView
#
#.LINK 
# Get-PSToken
#
#.RETURNVALUE 
# An array of PSObjects containing information about the external dependencies.
##############################################################################
function Get-Dependency {

    [CmdletBinding(DefaultParameterSetName='Selection')]
    param(

        [Parameter(ParameterSetName='Path', Position=1, Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [String[]]$Path,
        
        [Alias("PSPath")]
        [Parameter(ParameterSetName='LiteralPath', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [String[]]$LiteralPath,

        [Parameter()]
        [Switch]$Unresolved,
        
        [Parameter()]
        [Switch]$Force

    )

    begin {
    
        $Dependencies = New-Object System.Collections.ArrayList

        $LocalFunctions    = @{}
        $ImportedAliases   = @{}
        $ImportedCmdlets   = @{}
        $ImportedFunctions = @{}

        ##############################################################################
        #.SYNOPSIS
        # Strips off the scope modifier of an identifier so its name can be checked.
        ##############################################################################
        filter Normalize-Identifier([String]$Name) {
            if ($_ -is [System.Management.Automation.PSToken]) { $Name = $_.Content }
            if ($_ -is [String]) { $Name = $_ }
            $Name -replace '^$?(Script|Global|Local):',''
        }


        ##############################################################################
        #.SYNOPSIS
        # Wraps calls to Get-PSToken, making sure to use the appropriate parameter set.
        ##############################################################################
        function Get-PSTokenProxy([String[]]$Type,[String[]]$Token,[Int32[]]$Lines) {

            $GetPSTokenArgs = @{}
            if ($Type.Length)        { $GetPSTokenArgs['Type'] = $Type }
            if ($Token.Length)       { $GetPSTokenArgs['Token'] = $Token }
            if ($Lines.Length)       { $GetPSTokenArgs['Lines'] = $Lines }

            $ResolvedPaths | Get-PSToken @GetPSTokenArgs

        }

        ##############################################################################
        #.SYNOPSIS
        # Rebuilds the cache of built-in command, alias, function, and variable names
        # that are present in an unconfigured PowerShell session so that they can
        # be skipped from dependency checking.
        ##############################################################################
        function Discover-BuiltInCommands {

            if ($BuiltInCmdlets.Count -eq 0) {

                $BuiltInAliases.Clear()
                $BuiltInCmdlets.Clear()
                $BuiltInFunctions.Clear()
                $BuiltInVariables.Clear()

                $Posh = [PowerShell]::Create()

                try {

                    [Void]$Posh.AddScript('Get-Command -CommandType Cmdlet,Function,Alias')
                    foreach($CommandInfo in $Posh.Invoke()) {
                        switch($CommandInfo.CommandType) {
                            Alias    { $BuiltInAliases[$CommandInfo.Name]   = $true }
                            Cmdlet   { $BuiltInCmdlets[$CommandInfo.Name]   = $true }
                            Function { $BuiltInFunctions[$CommandInfo.Name] = $true }
                        }
                    }

                    [Void]$Posh.AddScript('Get-Variable')
                    foreach($VariableInfo in $Posh.Invoke()) {
                        $BuiltInVariables[$VariableInfo.Name] = $true
                    }
                    
                    # Note: PSISE won't appear as a built-in variable this way
                    # I decided I actually prefer it that way. I want to know if
                    # I accidentially couple a script to the ISE
                    $BuiltInVariables['this'] = $true
                    
                }
                finally {
                    $Posh.Dispose()
                }
                
            } # if count 0
            
        }

        ##############################################################################
        #.SYNOPSIS
        # Scans the source code for Import-Module statements and gathers up the
        # module export information into hashtables.
        ##############################################################################
        function Discover-ModuleImports {

            $ImportedAliases.Clear()
            $ImportedCmdlets.Clear()
            $ImportedFunctions.Clear()

            $TokenLines = @(Get-PSTokenProxy Command Import-Module | %{$_.StartLine})
            if (-not $TokenLines.Length) { return } # nothing to do
            
            $TokenNames = @(Get-PSTokenProxy CommandArgument -Lines $TokenLines | Normalize-Identifier)
            if (-not $TokenNames.Length) { return } # nothing to do

            # Find out which referenced modules are not imported
            $MissingModules = @()
            foreach ($TokenName in $TokenNames) {
                if (-not (Get-Module $TokenName)) {
                    $MissingModules += $TokenName
                }
            }
            
            if ($MissingModules.Length) {
                
                $MenuItem1 = New-Object System.Management.Automation.Host.ChoiceDescription "&No - Do Not Import Modules"
                $MenuItem2 = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes - Import These Modules"
                [System.Management.Automation.Host.ChoiceDescription[]]$MenuItems = @($MenuItem1,$MenuItem2)
                
                $MenuCaption = "Imported Modules Not Loaded"
                $MenuMessage = "One or more modules imported by the script are not currently loaded.`r`n" +
                               "This can lead to unresolved external references and missing`r`n" +
                               "information in the dependency report.`r`n" +
                               "`r`n" +
                               "You can attempt to temporarily import the following modules into the`r`n" +
                               "session by selection the option below.`r`n" +
                               "`r`n"

                foreach ($MissingModule in $MissingModules) {
                    $MenuMessage += "    Import-Module $MissingModule`r`n"
                }

                # Show the menu
                # If the user picks choice Y then import the modules
                # Because you can't import modules into the global scope from a lower scope,
                # the imported module will not be visible from outside of the current scope.
                $Response = $Host.UI.PromptForChoice($MenuCaption, $MenuMessage, $MenuItems, 0)
                if ($Response = 1) {
                    foreach ($MissingModule in $MissingModules) {
                        # Using Invoke-Expression so this Import-Module command
                        # doesn't cause a screw-up when checking dependencies of
                        # Dependency.psm1. Gay huh...
                        Invoke-Expression ".{Import-Module $MissingModule -ErrorAction Continue}"
                    }
                }
                
            }
                

            $ImportedModules = @(Get-Module $TokenNames -ListAvailable) + @(Get-Module $TokenNames)
            foreach ($ImportedModule in $ImportedModules) {
                $ImportedModule.ExportedAliases.Values   | %{ $ImportedAliases[$_.Name]   = $_ }
                $ImportedModule.ExportedCmdlets.Values   | %{ $ImportedCmdlets[$_.Name]   = $_ }
                $ImportedModule.ExportedFunctions.Values | %{ $ImportedFunctions[$_.Name] = $_ }
            }

        }

        ##############################################################################
        #.SYNOPSIS
        # Scans the source code for function and filter keywords that define local
        # functions that should not be treated as external dependencies.
        ##############################################################################
        function Discover-LocalFunctions {
            
            $LocalFunctions.Clear()
            
            # Gather information about defined functions
            $TokenLines = @(Get-PSTokenProxy Keyword function,filter | %{$_.StartLine})
            if (-not $TokenLines.Length) { return } # nothing to do

            $TokenNames = @(Get-PSTokenProxy CommandArgument -Lines $TokenLines | Normalize-Identifier)
            if (-not $TokenNames.Length) { return } # nothing to do

            # No CommandInfo for these so we'll just store a bool
            foreach ($TokenName in $TokenNames) {
                $LocalFunctions[$TokenName] = $true
            }
            
        }

        ##############################################################################
        #.SYNOPSIS
        # Removes references to built-in Cmdlets, functions, variables, etc from
        # the input stream.
        ##############################################################################
        filter Exclude-BuiltInReferences {
            
            if ($Force) { return $_ }

            $Token = $_
            $TokenName = Normalize-Identifier $Token.Content

            # Is it built in?
            # If so, skip it.
            if ($Token.Type -eq 'Command') {
                if ($BuiltInAliases[$TokenName]) { return }
                if ($BuiltInCmdlets[$TokenName]) { return }
                if ($BuiltInFunctions[$TokenName]) { return }
            }
            elseif ($Token.Type -eq 'Variable') {
                if ($BuiltInVariables[$TokenName]) { return }
            }
            
            $Token

        }

        ##############################################################################
        #.SYNOPSIS
        # Removes references to locally defined functions from the input stream.
        ##############################################################################
        filter Exclude-LocalReferences {

            if ($Force) { return $_ }

            $Token = $_
            $TokenName = Normalize-Identifier $Token.Content

            # Is it built in?
            # If so, skip it.
            if ($Token.Type -eq 'Command') {
                if ($LocalFunctions[$TokenName]) { return }
            }
            
            $Token

        }

        ##############################################################################
        #.SYNOPSIS
        # Gets a single command with the specified name, taking into account that the
        # command name may need to have conflicting wildcard characters escaped and
        # avoiding the error when a command does not exist.
        ##############################################################################
        function Get-SafeCommand([String]$Name) {

            $SafeName = [System.Management.Automation.WildcardPattern]::Escape($Name)
            
            $CommandInfo = Get-Command -Name $SafeName -ErrorAction SilentlyContinue | Select -First 1
            if (-not $CommandInfo) { $CommandInfo = $ImportedAliases[$Name] }
            if (-not $CommandInfo) { $CommandInfo = $ImportedFunctions[$Name] }
            if (-not $CommandInfo) { $CommandInfo = $ImportedCmdlets[$Name] }

            $CommandInfo

        }


        ##############################################################################
        #.SYNOPSIS
        # Gets a single variable with the specified name, taking into account that the
        # variable name may need to have conflicting wildcard characters escaped and
        # avoiding the error when a variable does not exist.
        ##############################################################################
        function Get-SafeVariable([String]$Name) {
            $SafeName = [System.Management.Automation.WildcardPattern]::Escape($Name)
            $VariableInfo = Get-Variable -Name $SafeName -Scope Global -ErrorAction SilentlyContinue | Select -First 1
            $VariableInfo            
        }

        ##############################################################################
        #.SYNOPSIS
        # Selects the first instance of each distinct combination of token type and
        # content (function/variable name etc) and includes the line number of the
        # first occurrence.
        #
        #.DESCRIPTION
        # This is a basically just a ugly way of doing:
        # SELECT Type,Content,Min(StartLine) FROM ... GROUP BY Type,Content
        # Which PowerShell cannot easily represent as far as I know
        ##############################################################################
        function Select-UniqueTokens {

            $Input | 
                Group-Object Type,Content |
                Select-Object @(
                    @{N='Type';      E={ $_.Group[0].Type      } },
                    @{N='Content';   E={ $_.Group[0].Content   } },
                    @{N='Script';    E={ $_.Group[0].Script    } }
                    @{N='StartLine'; E={ $_.Group[0].StartLine } }
                 )

        }

        ##############################################################################
        #.SYNOPSIS
        # Creates a new PSObject for holding information about the external dependency
        ##############################################################################
        function New-Dependency($Token) {

            # Create a PSObject to hold the values
            # we will output from this function
            New-Object PSObject |
                Add-Member -PassThru NoteProperty Script ($Token.Script) |
                Add-Member -PassThru NoteProperty Module ($null) |
                Add-Member -PassThru NoteProperty Type ($Token.Type) |
                Add-Member -PassThru NoteProperty Name (Normalize-Identifier $Token.Content) |
                Add-Member -PassThru NoteProperty Target ($null) |
                Add-Member -PassThru NoteProperty Resolved ($false) |
                Add-Member -PassThru NoteProperty File ($null)

        }
    
    } # begin

    process {

        if ($PSCmdlet.ParameterSetName -eq 'Selection') {
            if (-not $PSISE) { throw 'The Selection parameter set is not valid outside of the PowerShell ISE.' }
            if (-not $PSISE.CurrentOpenedFile) { throw 'There is no file currently opened.' }
            if (-not $PSISE.CurrentOpenedFile.IsSaved) { throw 'Please save the currently active document first.' }
            if ($PSISE.CurrentOpenedFile.IsUntitled) { throw 'Please save the currently active document first.' }
            $ResolvedPaths = @(Resolve-Path -LiteralPath $PSISE.CurrentOpenedFile.FullPath)
        }
        elseif ($PSCmdlet.ParameterSetName -match '^(Literal)?Path$') {
            switch ($PSCmdlet.ParameterSetName) {
                Path        { $ResolvedPaths = @(Resolve-Path -Path $Path) }
                LiteralPath { $ResolvedPaths = @(Resolve-Path -LiteralPath $LiteralPath) }
            }
        }        
        
        # Discover imported modules and function definitions
        Discover-BuiltInCommands
        Discover-ModuleImports
        Discover-LocalFunctions
        
        
        # Parse the source code
        # Gives back command and variable references
        $Tokens = @(
            Get-PSTokenProxy Command,Variable |
                Exclude-BuiltInReferences |
                Exclude-LocalReferences |
                Select-UniqueTokens
        )
        
        
        foreach ($Token in $Tokens) {

            $Dependency = New-Dependency $Token

            # HANDLE VARIABLE REFERENCES
            if ($Token.Type -eq 'Variable') {

                if ($VariableInfo = Get-SafeVariable $Dependency.Name) {

                    $Dependency.Module = $VariableInfo.ModuleName
                    $Dependency.Resolved = $true

                }
                else {
                
                    # Skip this dependency
                    # Could not find this variable in global state
                    # So we can only assume that the variable is
                    # localized somewhere and cannot really be
                    # resolved as an external dependency
                    # TODO: maybe look for a setter or arg name
                    # to determine if it's really external or not
                    
                    continue

                }

            
            } # Token Type = Variable

            # HANDLE COMMAND REFERENCES
            if ($Token.Type -eq 'Command') {
                
                if ($CommandInfo = Get-SafeCommand $Dependency.Name) {

                    $Dependency.Type= $CommandInfo.CommandType
                    $Dependency.Resolved = $true

                    # Is it an alias?
                    # If so, we want to resolve the target
                    if ($CommandInfo.CommandType -eq 'Alias') {
                        
                        # Is the alias resolved?
                        if ($CommandInfo.ResolvedCommandName) {
                        
                            # Is alias the same name as the target?
                            # If so, this is generally a disambiguating alias and can be ignored.
                            if ($CommandInfo.Name -eq $CommandInfo.ResolvedCommandName) {
                                if ($BuiltInAliases[$CommandInfo.ResolvedCommandName]) { continue }
                                if ($BuiltInCmdlets[$CommandInfo.ResolvedCommandName]) { continue }
                                if ($BuiltInFunctions[$CommandInfo.ResolvedCommandName]) { continue }
                            }

                            $Dependency.Target = $CommandInfo.ResolvedCommandName
                            $CommandInfo = $CommandInfo.ResolvedCommand
                            
                        }
                        else {

                            # The alias points to an unresolved command
                            $Dependency.Resolved = $false
                            
                        }
                        
                    } # Command Type = Alias
                    
                    # Command Source Info
                    # Note that in the case of resolved aliases, CommandInfo is now
                    # pointing to the resolved command and modules/paths/etc will reflect that
                    if ($CommandInfo.ModuleName) { $Dependency.Module = $CommandInfo.ModuleName }
                    if ($CommandInfo.ScriptBlock.File) { $Dependency.File = $CommandInfo.ScriptBlock.File }
                    if ($CommandInfo.Path) { $Dependency.File = $CommandInfo.Path }
                    if ($CommandInfo.DLL) { $Dependency.File = $CommandInfo.DLL }
                
                } # Is Command Is Resolved
                    
            } # Token Type = Command

            if ($Unresolved -and $Dependency.Resolved) { continue }

            [Void]$Dependencies.Add($Dependency)
            
        } # foreach Token

    } # process
    
    end {
    
        # returns all output at the end
        $Dependencies | Sort Script,Module,Type,Name
    
    } # end
    
}