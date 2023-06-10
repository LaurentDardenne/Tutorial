#Joel -Jaykul- Bennett
# http://social.technet.microsoft.com/Forums/en-US/winserverpowershell/thread/19d27481-1acc-412c-9085-9f89d00fa4e9

function TestWarningA {[CmdletBinding()]param()
   # This has no effect on the WarningVariable, but without it the warnings are displayed in the host
   if($PSBoundParameters.ContainsKey("WarningAction")) 
    { $local:WarningPreference = $PSBoundParameters['WarningAction'] }

   Write-Host "Script A: $WarningPreference"

   #$PSCmdlet.WriteWarning("WriteWarning A1")  # this is the only thing affected by -WarningAction
   if($PSBoundParameters.ContainsKey("WarningVariable")){
      Write-Warning "Write-Warning A2" -WarningVariable $("+$($PSBoundParameters['WarningVariable'].TrimStart('+'))")
   } else {
      Write-Warning "Write-Warning A2"
   }
   
   $PSCmdlet.WriteError(
         (new-object System.Management.Automation.ErrorRecord( 
              (new-object System.Exception "WriteError A1"), "TestError", "NotSpecified", $null)))
   Write-Error "Write-Error A2"
   
   if($PSBoundParameters.ContainsKey("WarningVariable")){
      TestWarningB -WarningVariable $("+$($PSBoundParameters['WarningVariable'].TrimStart('+'))")
   } else {
      TestWarningB
   }
   
}

function TestWarningB {[CmdletBinding()]param()

   Write-Host "Script B: $WarningPreference $($PSBoundParameters['WarningVariable'])"
   
   $PSCmdlet.WriteWarning("WriteWarning B1")
   if($PSBoundParameters.ContainsKey("WarningVariable")){
      Write-Warning "Write-Warning B2" -WarningVariable $("+$($PSBoundParameters['WarningVariable'].TrimStart('+'))")
   } else {
      Write-Warning "Write-Warning B2"
   }
   
   $PSCmdlet.WriteError( 
      (new-object System.Management.Automation.ErrorRecord( 
        (new-object System.Exception "WriteErrorB1"), "TestError", "NotSpecified", $null)) )
   Write-Error "Write-Error B2"
}

TestWarningA -WarningAction:SilentlyContinue -WarningVariable wv -ErrorAction:SilentlyContinue -ErrorVariable ev