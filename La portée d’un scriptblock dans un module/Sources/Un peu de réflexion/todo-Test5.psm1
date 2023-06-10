$maVar='Portée du module.'

$SbPrivate={
     Write-Warning "Dans SbPrivate maVar=$MaVar. Crée la variable `FromModule dans la portée de l'appelant"
      #le SB est exécuté dans sa propre portée, on adresse celle du parent, c'est à dire l'état de session appelant le module      
     New-Variable -Name 'FromModule' -Value 'Créée par un module' -scope 1
} 

$SessionStateProperty = [ScriptBlock].GetProperty('SessionState',([System.Reflection.BindingFlags]'NonPublic,Instance'))
$SessionState = $SessionStateProperty.GetValue((Get-sbOuter), $null)

#todo sauvegarde de l'original
#https://msdn.microsoft.com/en-us/library/dd182403(v=vs.85).aspx
$SessionState.InvokeCommand.InvokeScript($SessionState, $SbPrivate, @())
#C'est similaire mais en interne :
#             SessionStateInternal _oldSessionState = _context.EngineSessionState;
#             try
#             {
#                 _context.EngineSessionState = sessionState.Internal;
#                 return InvokeScript(scriptBlock, false, PipelineResultTypes.None, null, args);
#             }
#             finally
#             {
#                 _context.EngineSessionState = _oldSessionState;
# }
