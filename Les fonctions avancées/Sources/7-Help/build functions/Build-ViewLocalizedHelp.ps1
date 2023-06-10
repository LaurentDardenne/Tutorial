 #Construit le squellette
. .\new-XML.ps1
. .\View-Localized.ps1

$xml=.\new-MAML View-Localized
$xml.Declaration.ToString() | out-file View-Localized-Help.xml -encoding "UTF8"
$xml.ToString() | out-file View-Localized-Help.xml -encoding "UTF8" -append


