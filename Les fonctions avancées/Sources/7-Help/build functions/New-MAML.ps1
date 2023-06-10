#Requires -version 2.0
#Generates External MAML Powershell help file for any loaded cmdlet or function
#Note: Requires Joel Bennet's New-XML script from http: //www.poshcode.com/1244
#place New-XML in same directory as New-MAML
#Once the XML/MAML file is generated, you'll need to fill in the TODO items and the parameters options
#that are defaulted to false. The position parameter option will need to be changed in the generated MAML also.
#Example Usage to generate a test-ispath.ps1-help.xml file:
#PS C:\Users\u00\bin> $xml = ./new-maml test-ispath
#PS C:\Users\u00\bin> $xml.Declaration.ToString() | out-file ./test-ispath.ps1-help.xml -encoding "UTF8"
#PS C:\Users\u00\bin> $xml.ToString() | out-file ./test-ispath.ps1-help.xml -encoding "UTF8" -append
#For compiled cmdlets place the MAML file in the same directory as the binary module or snapin dll
#For script modules/functions include a reference to the External MAML file for each function
#Note: You can use the same MAML file for multiple functions, example:
#
## .ExternalHelp C:\Users\u00\bin\test-ispath.ps1-help.xml
## function test-ipath


param ($commandName)
$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)
. $scriptRoot\New-XML.ps1

[XNamespace]$helpItems="http://msh"
[XNamespace]$maml="http://schemas.microsoft.com/maml/2004/10"
[XNamespace]$command="http://schemas.microsoft.com/maml/dev/command/2004/10"
[XNamespace]$dev="http://schemas.microsoft.com/maml/dev/2004/10"
$parameters =  get-command $commandName | %{$commandName=$_.Name;$_.parameters} | %{$_.Values}

New-Xml helpItems -schema "maml" {
    xe ($command + "command") -maml $maml -command $command -dev $dev {
            xe ($command + "details") {
                xe ($command + "name") {"$commandName"}
                xe ($maml + "description") {
                    xe ($maml + "para") {"TODO Add Short description"}
                }
                xe ($maml + "copyright") {
                    xe ($maml + "para") {}
                }
                xe ($command + "verb") {"$(($CommandName -split '-')[0])"}
                xe ($command + "noun") {"$(($commandName -split '-')[1])"}
                xe ($dev + "version") {}
            }
            xe ($maml + "description") {
                xe ($maml + "para") {"TODO Add Long description"}
            }
            xe ($command + "syntax") {
                xe ($command + "syntaxItem") {
                $parameters | foreach { 
                    xe ($command + "name") {"$commandName"}
                        xe ($command + "parameter") -require "false" -variableLength "false" -globbing "false" -pipelineInput "false" -postion "0" {
                            xe ($maml + "name") {"$($_.Name)"}
                            xe ($maml + "description") {
                                xe ($maml + "para") {"TODO Add $($_.Name) Description"}
                            }
                            xe ($command + "parameterValue") -required "false" -variableLength "false" {"$($_.ParameterType.Name)"}
                        }
                    }
                }
            }
            xe ($command + "parameters") {
                $parameters | foreach { 
                xe ($command + "parameter") -required "false" -variableLength "false" -globbing "false" -pipelineInput "false (ByValue)" -position "0" {
                    xe ($maml + "name") {"$($_.Name)"}
		    xe ($maml + "description") {
			xe ($maml + "para") {"TODO Add $($_.Name) Description"}
                    }
		    xe ($command + "parameterValue") -required "true" -variableLength "false" {"$($_.ParameterType.Name)"}
                    xe ($dev + "type") {
                        xe ($maml + "name") {"$($_.ParameterType.Name)"}
			xe ($maml + "uri"){}
                    }
		    xe ($dev + "defaultValue") {}
                }
                }
            }
	    xe ($command + "inputTypes") {
                xe ($command + "inputType") {
                    xe ($dev + "type") {
                        xe ($maml + "name") {"TODO Add $commandName inputType"}
                        xe ($maml + "uri") {}
                        xe ($maml + "description") {
                            xe ($maml + "para") {}
                        }
                    }
			xe ($maml + "description") {}
                }
            }
	    xe ($command + "returnValues") {
		xe ($command + "returnValue") {
		    xe ($dev + "type") {
		        xe ($maml + "name") {"TODO Add $commandName returnType"}
                        xe ($maml + "uri") {}
                        xe ($maml + "description") {
                            xe ($maml + "para") {}
                        }
                    }
		    xe ($maml + "description") {}
		}
	    }
            xe ($command + "terminatingErrors") {}
	    xe ($command + "nonTerminatingErrors") {}
	    xe ($maml + "alertSet") {
		xe ($maml + "title") {}
		xe ($maml + "alert") {
		    xe ($maml + "para") {}
                }
            }
            xe ($command + "examples") {
		xe ($command + "example") {
                    xe ($maml + "title") {"--------------  EXAMPLE 1 --------------"}
                    xe ($maml + "introduction") {
                        xe ($maml + "para") {"C:\PS&gt;"}
                    }
                    xe ($dev + "code") {"TODO Add $commandName Example code"}
                    xe ($dev + "remarks") {
                        xe ($maml + "para") {"TODO Add $commandName Example Comment"}
                        xe ($maml + "para") {}
                        xe ($maml + "para") {}
                        xe ($maml + "para") {}
                        xe ($maml + "para") {}
                    }
                    xe ($command + "commandLines") {
                        xe ($command + "commandLine") {
                            xe ($command + "commandText") {}
                        }
                    }
                }
            }   
            xe ($maml + "relatedLinks") {
                xe ($maml + "navigationLink") {
		    xe ($maml + "linkText") {"$commandName"}
		    xe ($maml + "uri") {}
                }
            }
        }
    }

