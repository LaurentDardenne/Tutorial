Write-Warning "Modifiez dans le scipt le nom du chemin ou placez-vous dans le répertoire contenant la DLL"
return

Add-type -Path "$Pwd\AlphaFS.dll"

Function New-AlphaFsACL{
  param(
     [Parameter(Mandatory=$True,position=0)]
    $Path,
     [Parameter(position=1)]
    $AccessRules=$null
  )

 [pscustomobject]@{
   PSTypeName='AlphaFsACL';
   Path=$Path; 
   AccessRules=$AccessRules
   }
}# New-AlphaFsACL

Function ConvertTo-SecurityIdentifier{
 param ( 
    [Parameter(Mandatory=$True,position=0)]
   [System.Security.Principal.IdentityReference] $IdentityReference,
   
   [switch]$Translate
 )
   $objSID = New-Object System.Security.Principal.SecurityIdentifier($IdentityReference)
   if ($Translate)
   { $objSID.Translate([System.Security.Principal.NTAccount]) }
   else
   { $objSID }
}#ConvertTo-SecurityIdentifier

function Get-AlphaFsACL {
 param (
     [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="Path")]
   [string]$Path,
   
    [Parameter(Position=1)]
   [System.Security.AccessControl.AccessControlSections] $AccessControlSections=[System.Security.AccessControl.AccessControlSections]::Access
 )
 process {
  $Entry = new-object Alphaleonis.Win32.Filesystem.FileInfo($Path)
  $EntryACL = $Entry.GetAccessControl($AccessControlSections)
 
  [pscustomobject]@{
    PSTypeName='AlphaFsACL';
    Path=$Path; 
    AccessRules=$EntryAcl.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
  }
 }#process
} #Get-AlphaFsACL

function Get-AlphaFsFilesSystemEntries{
<#
.SYNOPSIS
   Gets the files or directories with long paths, that is, paths that exceed 259 characters.
#>   
 Param (
    #Specifies a path to one location.
   [ValidateNotNull()] 
  [string] $path, 
  
    #The search pattern. A combinaison of '*' or '?'. 
   [ValidateNotNullOrEmpty()]
  [string] $searchPattern,
   
    #Specifies whether to search the current directory, or the current directory and all subdirectories. 
    # AllDirectories   : Includes the current directory and all its subdirectories in a search operation. This option includes reparse points such as mounted drives and symbolic links in the search.
    # TopDirectoryOnly : Includes only the current directory in a search operation. 
  [System.IO.SearchOption] $searchOption=[System.IO.SearchOption]::AllDirectories,
   
    #if set return only the directories, if not, return only the files.
  [switch] $Directories
 )

 $dirs = new-object System.Collections.Generic.Stack[string]
 $path=[Alphaleonis.Win32.Filesystem.Path]::GetLongPath($path)
 
 if ($path.EndsWith([System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::Ordinal) -and $path.EndsWith([System.IO.Path]::AltDirectorySeparatorChar, [System.StringComparison]::Ordinal))
 { $dirs.Push($path) }
 else
 { $dirs.Push($path + [System.IO.Path]::DirectorySeparatorChar) }

 while ($dirs.Count -gt  0)
 {
    $tmpDir = $dirs.Pop()

    if ($searchOption -eq 'AllDirectories')
    {
       Write-debug '$searchOption -eq AllDirectories' #<%REMOVE%>
       try { 
         $dirEnumerator = new-object Alphaleonis.Win32.Filesystem.FileSystemEntryEnumerator($null, ($tmpDir + "*"),$true)
         while ($dirEnumerator.MoveNext())
         {
            if ($dirEnumerator.Current.IsDirectory)
            {  
               Write-debug "dir $($tmpDir + $dirEnumerator.Current.FileName + [System.IO.Path]::DirectorySeparatorChar)"  #<%REMOVE%>
               $dirs.Push(($tmpDir + $dirEnumerator.Current.FileName + [System.IO.Path]::DirectorySeparatorChar)) 
            }
         }
       } finally {
          #On référence l'objet itérateur et pas l'itération de l'objet %-)
          if ($dirEnumerator.PsBase -ne $null) 
          { $dirEnumerator.Dispose() }
       }
    }

    if ($directories)
    {
      Write-debug 'If directories'  #<%REMOVE%>
      try { 
          $enumerator = new-object Alphaleonis.Win32.Filesystem.FileSystemEntryEnumerator($null, ($tmpDir + $searchPattern),$true)
          while ($enumerator.MoveNext())
          {
             if ($enumerator.Current.IsDirectory)
             {
                Write-debug "file $($tmpDir + $enumerator.Current.FileName)" #<%REMOVE%>
                Write-Output ($tmpDir + $enumerator.Current.FileName)
             }
          }
       } finally {
          if ($enumerator.PsBase -ne $null) 
          { $enumerator.Dispose() }
       }       
    }
    else
    {
       Write-debug "else directories" #<%REMOVE%>
       try { 
          $enumerator = new-object Alphaleonis.Win32.Filesystem.FileSystemEntryEnumerator($null, ($tmpDir + $searchPattern),$false)
          while ($enumerator.MoveNext())
          {
             if ($enumerator.Current.IsFile)
             {
                Write-debug "file $($tmpDir + $enumerator.Current.FileName)"  #<%REMOVE%>
                Write-Output ($tmpDir + $enumerator.Current.FileName)
             }
          }
       } finally {
          if ($enumerator.PsBase -ne $null) 
          { $enumerator.Dispose() }
       }
    }
 }
}#Get-AlphaFsFilesSystemEntries

$SelectedProperties=@(
  @{N='Path';E={$Path} },
  @{N='FileSystemRights';E={$_.FileSystemRights} }, 
  @{N='IsInherited';E={$_.IsInherited} },
  @{N='IdentityReference';E={$_.IdentityReference} },
  @{N='User';E={ ConvertTo-SecurityIdentifier $_.IdentityReference -Translate} }
)

del 'c:\temp\LgPath*'
#(new-object Alphaleonis.Win32.Filesystem.DirectoryInfo('C:\temp\001')),
$Files=Get-AlphaFsFilesSystemEntries -path c:\temp\001 -searchPattern '*' -Directories|
  Get-AlphaFsACL|
  Foreach-Object {
   $Path=$_.Path
   $_.AccessRules|
    Select-Object $SelectedProperties
  }

$Files  


