function Resolve-Error($ErrorRecord=$Error[0])
{ #Affiche toutes les informations de la dernière erreur rencontrée
     #http://blogs.msdn.com/powershell/archive/2006/12/07/resolve-error.aspx
   $ErrorRecord | Format-List * -Force
   $ErrorRecord.InvocationInfo |Format-List *
   $Exception = $ErrorRecord.Exception
   for ($i = 0; $Exception; $i++, ($Exception = $Exception.InnerException))
   {   "$i" * 80
       $Exception |Format-List * -Force
   }
}
Set-Alias rver Resolve-Error