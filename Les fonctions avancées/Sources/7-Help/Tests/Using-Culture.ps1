#http://keithhill.spaces.live.com/Blog/cns!5A8D2641E0963A97!7132.entry
# Using-Culture de-DE { .\test.ps1 }
#
#La prise en compte de la nouvelle culture ne fonctionne pas tjrs.
#Par exemple  :
# Get-Help référence la culture de la session PS et pas celle déclarée dans ce script.
# Idem pour  Get-Culture :
#       #Référence la culture du poste
#  $DtPattern=(Get-Culture).DateTimeFormat.ShortDatePattern
#      #Référence la culture du thread
#  $DtPattern=[System.Threading.Thread]::CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern

function Using-Culture ([System.Globalization.CultureInfo]$culture =(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"),
                        [ScriptBlock]$script=(throw "USAGE: Using-Culture -Culture culture -Script {scriptblock}"))
{    
    $OldCulture = [System.Threading.Thread]::CurrentThread.CurrentCulture
    $OldUICulture = [System.Threading.Thread]::CurrentThread.CurrentUICulture
    try {
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture  
        Invoke-Command $script    
    }    
    finally {        
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $OldCulture        
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $OldUICulture    
    }    
}
