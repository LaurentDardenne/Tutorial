function New-Exception($Exception,$Message=$null) {
#Crée et renvoi un objet exception pour l'utiliser avec $PSCmdlet.WriteError()

   #Le constructeur de la classe de l'exception trappée est inaccessible  
  if ($Exception.GetType().IsNotPublic)
   {
     $ExceptionClassName="System.Exception"
      #On mémorise l'exception courante. 
     $InnerException=$Exception
   }
  else
   { 
     $ExceptionClassName=$Exception.GetType().FullName
     $InnerException=$Null
   }
  if ($Message -eq $null)
   {$Message=$Exception.Message}
    
   #Recrée l'exception trappée avec un message personnalisé 
	New-Object $ExceptionClassName($Message,$InnerException)       
} #New-Exception