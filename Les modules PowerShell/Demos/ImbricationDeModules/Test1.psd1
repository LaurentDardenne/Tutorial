@{

# Script module or binary module file associated with this manifest

ModuleToProcess = 'test.psm1'


# Version number of this module.

ModuleVersion = '1.0.0.0'


# ID used to uniquely identify this module

GUID = '{573616f3-e411-40a4-a063-5a66a6473f76}'


# Modules to import as nested modules of the module specified in

# ModuleToProcess

NestedModules = @('.\Nested\Nested.psd1','.\Nested2\Nested2.psd1')


# Functions to export from this module

FunctionsToExport = '*'


# Cmdlets to export from this module

CmdletsToExport = '*'


# Variables to export from this module

VariablesToExport = '*'


# Aliases to export from this module

AliasesToExport = '*'


# List of all modules packaged with this module

ModuleList = @()


# List of all files packaged with this module

FileList = @(

    '.\Test.psm1'

    '.\Test.psd1'

)


# Private data to pass to the module specified in ModuleToProcess

PrivateData = ''

}
