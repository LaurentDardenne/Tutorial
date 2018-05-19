#from :
# http://learningpcs.blogspot.fr/2012/08/powershell-v3-powershellorg-forums-and.html#!/2012/08/powershell-v3-powershellorg-forums-and.html
$userClass = {
   # Use the param block to define the properties for "constructor". The entire script block is
   # the constructor, defining properties and methods on the objects dynamically.
   [CmdletBinding()]
   param(
      [Parameter(Position=0,Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({$_ -eq $_.Trim()})]
      [System.String]
      $FirstName,

      [Parameter(Position=1,Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({$_ -eq $_.Trim()})]
      [System.String]
      $LastName
   )

   # First turn off default exporting so that you can control what is public and what is private.
   Export-ModuleMember

   # Here we define our constructor parameters as read-only public variables
   Set-Variable -Name FirstName -Option ReadOnly
   Set-Variable -Name LastName -Option ReadOnly
   Export-ModuleMember -Variable FirstName,LastName

   # We also need to calculate a read-only public FullName variable based on those values.
   Set-Variable -Name FullName -Option ReadOnly -Value "$FirstName $LastName"
   Export-ModuleMember -Variable FullName
 
   # Now lets set up an internal private method to do some work for us
   function UpdateEmailAddress {
      [CmdletBinding()]
      param()
      $FirstName.ToLower().SubString(0,1) + ($LastName -replace '[^a-z]').ToLower().SubString(0,[System.Math]::Min($LastName.Length,7)) + '@poshoholicstudios.com'
   }

   # Now we can create a public EmailAddress variable that is defined by using the private function as part of the "constructor".
   Set-Variable -Name EmailAddress -Option ReadOnly -Value (UpdateEmailAddress)
   Export-ModuleMember -Variable EmailAddress

   # But what if they get married and change their last name? We can use a public method for that
   # since the public property is read-only
   function ChangeLastName {
      [CmdletBinding()]
      [OutputType([System.Void])]
      param(
         [Parameter(Position=0,Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [ValidateScript({$_ -eq $_.Trim()})]
         [System.String]
         $NewLastName
      )
      Set-Variable -Scope script -Name LastName -Value $NewLastName -Force
      Set-Variable -Scope script -Name EmailAddress -Value (UpdateEmailAddress) -Force
   }
   Export-ModuleMember -Function ChangeLastName
}
 
# Create our object
$me = New-Module -AsCustomObject -ScriptBlock $userClass -ArgumentList Kirk,Munro

# Look at the properties it has.
$me

# Look at the public properties and methods it has. Note that this approach automatically
# defines NoteProperty and ScriptMethod members. The key difference here is control over
# visibility of the members and methods, plus being able to create read-only properties.
# Note that the UpdateEmailAddress method is not displayed because it is private.
$me | Get-Member

# Now let's try changing FirstName (that's read-only, remember?). This will not work.
$me.FirstName = 'Poshoholic'

# Here's the email address before we change the last name
$me.EmailAddress

# Now we can change the last name.
$me.ChangeLastName('Poshoholic')

# And here's the email address after we change the last name
$me.EmailAddress
