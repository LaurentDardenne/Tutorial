function New-Exception($Exception,$Message=$null) {
#Cr�e et renvoi un objet exception pour l'utiliser avec $PSCmdlet.WriteError()

   #Le constructeur de la classe de l'exception trapp�e est inaccessible  
  if ($Exception.GetType().IsNotPublic)
   {
     $ExceptionClassName="System.Exception"
      #On m�morise l'exception courante. 
     $InnerException=$Exception
   }
  else
   { 
     $ExceptionClassName=$Exception.GetType().FullName
     $InnerException=$Null
   }
  if ($Message -eq $null)
   {$Message=$Exception.Message}
    
   #Recr�e l'exception trapp�e avec un message personnalis� 
	New-Object $ExceptionClassName($Message,$InnerException)       
} #New-Exception