Workflow Test { "test"}
$c=gcm Test
$ofs='","' 
$Code="`$WorkflowParameters=@(`"$($c.Parameters.GetEnumerator()|% {$_.key})`")"
iex $code
#$WorkflowParameters

$Type=[Microsoft.PowerShell.Activities.PSWorkflowRuntimeVariable]
$PSWkfwRV=[System.Enum]::GetNames($Type)

Compare-Object $WorkflowParameters $PSWkfwRV -ExcludeDifferent -IncludeEqual

Compare-Object $PSWkfwRV $WorkflowParameters 
