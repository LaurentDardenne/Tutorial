function New-ExceptionClass{
#Adapté de http://poshcode.org/1574
  [CmdletBinding(DefaultParameterSetName = "Namespace")]
 param(
     [ValidateNotNullOrEmpty()]
     [Parameter(Position=0, ParameterSetName="Type")]
  [string[]] $exceptionTypes,

     [ValidateNotNullOrEmpty()]
   [Parameter(Position=0, ParameterSetName="Namespace")]
  [System.Collections.IDictionary] $Namespace,

  [switch] $PassThru 
 )
 
  filter AddException {
    foreach ($exceptionType in $_)
    {
       Write-Debug "Add exception class : $exceptionType"
       [void]$Code.AppendLine($ExecutionContext.InvokeCommand.ExpandString($GenericModuleExceptionSource))
    }          
  }#AddException

  # Generic Default Exception Class for use with WriteError output.
  $GenericModuleExceptionSource = @'
    [Serializable]
    public class ${exceptionType} : System.ApplicationException
    {
        public ${exceptionType}()
        {
        }
    
        public ${exceptionType}(string message) : base(message)
        {
        }
    
        public ${exceptionType}(string message, Exception innerException)
        : base(message, innerException)
        {
        }
        
        protected ${exceptionType}(SerializationInfo info, StreamingContext ctxt)
        : base(info, ctxt)
        {
        }
    }
`r`n
'@
  $Code= New-Object System.Text.StringBuilder
  if (!$Passthru)
  { [void]$Code.AppendLine('using System;') }

  if ($PsCmdlet.ParameterSetName -eq 'Type')
  {  $ExceptionTypes|AddException }
  else
  {
    $Namespace.GetEnumerator()|
     foreach-object {
        [void]$Code.AppendLine("namespace $($_.Key)`r`n{`r`n") 
          $_.Value|AddException                    
        [void]$Code.AppendLine("}`r`n")
     }
  }
  if ($Passthru)
  {$Code.ToString()}
  else
  {
     # Suppresses warning: Generated type defines no public methods of it's own.
    Add-Type -TypeDefinition $Code.ToString() -IgnoreWarnings -warningaction silentlycontinue
  }
}#New-ExceptionClass

$t=Write-output un deux
New-ExceptionClass $t -pass

$NS=@{
 'Module.Posh4Log'=@('un','deux');
 'Module.Validation'=@('trois','quatre')
}   

#ou $NS=new-object System.Collections.Specialized.OrderedDictionary   
New-ExceptionClass $NS -pass
New-ExceptionClass $NS

$Er=New-Object Module.Posh4Log.Un
$er

$Er=New-Object Module.Posh4Log.Un "Erreur dans le script"
$er 
throw $er
rver