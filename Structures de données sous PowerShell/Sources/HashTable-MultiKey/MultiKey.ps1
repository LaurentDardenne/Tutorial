http://www.e-naxos.com/Blog/post/2008/09/Utiliser-des-cles-composees-dans-les-dictionnaires.aspx

$sb={
$ScriptPath="G:\PS\MultiKey\MultiKey\bin\Debug"
[void][System.Reflection.Assembly]::LoadFile((Join-Path $ScriptPath "MultiKey.dll"))

 #Test of IEquatable in ComposedKey
$k1 = new-object MultiKey.ComposedKey("Olivier", 589);
$k2 = new-object MultiKey.ComposedKey("Bill", 9744);
$k3 = new-object MultiKey.ComposedKey("Olivier", 589);

"{0} =? {1} : {2}" -F $k1,$k2,($k1 -eq $k2)
"{0} =? {1} : {2}" -F $k1,$k3,($k1 -eq $k3)
"{0} =? {1} : {2}" -F $k2,$k1,($k2 -eq $k1)
"{0} =? {1} : {2}" -F $k2,$k2,($k2 -eq $k2)
"{0} =? {1} : {2}" -F $k2,$k3,($k2 -eq $k3)
            
 #Build a dictionnary using the composed key
$dict = @{ $(new-object MultiKey.ComposedKey("Olivier",145))="resource A";
           $(new-object MultiKey.ComposedKey("Yoda", 854))="resource B";
           $(new-object MultiKey.ComposedKey("Valérie", 9845))="resource C";
           $(new-object MultiKey.ComposedKey("Obiwan", 326))="resource D"
         }

 #Find associated resources by key
$fk1 = new-object MultiKey.ComposedKey("Yoda", 854)
$s=$dict.ContainsKey($fk1)|% {if ($_) {$dict[$fk1]} else { "No Resource Found"}}
 #must return 'resource B'
"Key '{0}' is associated with resource '{1}'" -F $fk1,$s

$fk2 = new-object MultiKey.ComposedKey("Yoda", 999)
$s2 =$dict.ContainsKey($fk2)|% {if ($_) {$dict[$fk2]} else { "No Resource Found"}} 

 #must return 'No Resource Found'
"Key '{0}' is associated with resource '{1}'" -F $fk2, $s2

 #Pause
}

&$sb
$dict.$fk1

$Name="Yoda";$Number=854
$dict.$(new-object MultiKey.ComposedKey($Name, $Number))


$dict = @{ $(new-object MultiKey.ComposedKey("Olivier",145))="resource A";
           $(new-object MultiKey.ComposedKey("Yoda", 854))="resource B";
           $(new-object MultiKey.ComposedKey("Olivier", 9845))="resource C";
           $(new-object MultiKey.ComposedKey("Obiwan", 326))="resource D"
         }
$dict|% {$_.keys|where {$_.name -eq "Olivier"}}
        