#requires -version 2.0
##########################################################################
#                               Add-Lib V2
#
# Version : 1.1.0
#
# Date    : 22 août 2010
#
# Nom     : Replace-String.ps1
#
# Usage   : . .\Replace-String.ps1; Replace-String -?
#
##########################################################################
Function Replace-String{
<#
.SYNOPSIS
    Remplace toutes les occurrences d'un modèle de caractère, défini par 
    une chaîne de caractère simple ou par une expression régulière, par une 
    chaîne de caractères de remplacement.
 
.DESCRIPTION
    La fonction Replace-String remplace dans une chaîne de caractères toutes 
    les occurrences d'une chaîne de caractères par une autre chaîne de caractères.
    Le contenu de la chaîne recherchée peut-être soit une chaîne de caractère 
    simple soit une expression régulière. 
. 
    Le paramétrage du modèle de caractère et de la chaîne de caractères de 
    remplacement se fait via une hashtable. Celle-ci permet un remplacement 
    multiple sur une même chaîne de caractères. Ces multiples remplacements se 
    font les uns à la suite des autres et pas en une seule fois.
    Chaque opération de remplacement reçoit la chaîne résultante du 
    remplacement précédent. 

.PARAMETER InputObject
    Chaîne à modifier.
    Peut référencer une valeur de type [Object], dans ce cas l'objet sera 
    converti en [String] sauf si le paramètre -Property est renseigné.

.PARAMETER Hashtable
    Hashtable contenant les textes à rechercher et celui de leur remplacement 
    respectif  :
     $MyHashtable."TexteARechercher"="TexteDeRemplacement"
     $MyHashtable."AncienTexte"="NouveauTexte"
    Sont autorisées toutes les instances de classe implémentant l'interface 
    [System.Collections.IDictionary].
.  
. 
    Chaque entrée de la hashtable est une paire nom-valeur :
     ° Le nom contient la chaîne à rechercher, c'est une simple chaîne de 
       caractères qui peut contenir une expression régulière.
       Il peut être de type [Object], dans ce cas l'objet sera 
       converti en [String], même si c'est une collection d'objets.
       Si la variable $OFS est déclarée elle sera utilisée lors de cette 
       conversion.
     ° La valeur contient la chaîne de remplacement et peut référencer :
        - une simple chaîne de caractères qui peut contenir une capture 
          nommée, exemple :
           $HT."(Texte)"='$1 AjoutTexteSéparéParUnEspace'
           $HT."(Groupe1Capturé)=(Groupe2Capturé)"='$2=$1' 
           $HT."(?<NomCapture>Texte)"='${NomCapture}AjoutTexteSansEspace'
          Cette valeur peut être $null ou contenir une chaîne vide.
.           
          Note : Pour utiliser '$1" comme chaîne ce remplacement et non pas 
          comme référence à une capture nommée, vous devez échapper le signe 
          dollar ainsi '$$1'.
.
        - un Scriptblock, implicitement de type [System.Text.RegularExpressions.MatchEvaluator] : 
            #Remplace le caractère ':' par '<:>'
           $h.":"={"<$($args[0])>"}
.          
          Dans ce cas, pour chaque occurrence de remplacement trouvée, on 
          évalue le remplacement en exécutant le Scriptblock qui reçoit dans 
          $args[0] l'occurence trouvée et renvoie comme résultat une chaîne 
          de caractères.
          Les conversions de chaînes de caractères en dates, contenues dans
          le scriptblock, se font en utilisant les informations de la 
          classe .NET InvariantCulture (US).
.          
          Note : En cas d'exception déclenchée dans le scriptblock, 
          n'hésitez pas à consulter le contenu de son membre nommé 
          InnerException. 
.
        -une hashtable, les clés reconnues sont :
           -- Replace  Contient la valeur de remplacement.
                       Une chaîne vide est autorisée, mais pas la valeur 
                       $null.
                       Cette clé est obligatoire.
                       Son type est [String] ou [ScriptBlock].
.                       
           -- Max      Nombre maximal de fois où le remplacement aura lieu. 
                       Sa valeur par défaut est -1 (on remplace toutes les
                       occurrences trouvées) et ne doit pas être inférieure
                       à -1.
                       Pour une valeur $null ou une chaîne vide on affecte 
                       la valeur par défaut.
.                       
                       Cette clé est optionnelle et s'applique uniquement 
                       aux expressions régulières.
                       Son type est [Integer], sinon une tentative de 
                       conversion est effectuée. 
.
           -- StartAt  Position du caractère, dans la chaîne d'entrée, où 
                       la recherche débutera.
                       Sa valeur par défaut est zéro (début de chaîne) et 
                       doit être supérieure à zéro.
                       Pour une valeur $null ou une chaîne vide on affecte 
                       la valeur par défaut.
.                       
                       Cette clé est optionnelle et s'applique uniquement 
                       aux expressions régulières.
                       Son type est [Integer], sinon une tentative de 
                       conversion est effectuée. 
.
           -- Options  L'expression régulière est créée avec les options 
                       spécifiées.
                       Sa valeur par défaut est "IgnoreCase" (la correspondance 
                       ne respecte pas la casse).
                       Si vous spécifiez cette clé, l'option "IgnoreCase" 
                       est écrasée par la nouvelle valeur.
                       Pour une valeur $null ou une chaîne vide on affecte 
                       la valeur par défaut.
                       Peut contenir une valeur de type [Object], dans ce 
                       cas l'objet sera converti en [String]. Si la variable
                       $OFS est déclarée elle sera utilisée lors de cette 
                       conversion.
.                       
                       Cette clé est optionnelle et s'applique uniquement
                       aux expressions régulières.
                       Son type est [System.Text.RegularExpressions.RegexOptions].
.
                       Note: En lieu et place de cette clé/valeur, il est 
                       possible d'utiliser une construction d'options inline 
                       dans le corps de l'expression régulière (voir un des 
                       exemples).
                       Ces options inlines sont prioritaires et 
                       complémentaires par rapport à celles définies par 
                       cette clé.                
.                       
         Si la hashtable ne contient pas de clé nommée 'Replace', la fonction 
         émet une erreur non-bloquante. 
         Si une des clés 'Max','StartAt' et 'Options' est absente, elle est 
         insérée avec sa valeur par défaut.
         La présence de noms de clés inconnues ne provoque pas d'erreur.
.
         Rappel : Les règles de conversion de .NET s'appliquent.
         Par exemple pour :
          [double] $Start=1,6
          $h."a"=@{Replace="X";StartAt=$Start}
         où $Start contient une valeur de type [Double], celle-ci sera 
         arrondie, ici à 2.         

.PARAMETER ReplaceInfo
    Indique que la fonction retourne un objet personnalisé [PSReplaceInfo].
    Celui-ci contient les membres suivants :  
     -[ArrayList] Replaces  : Contient le résultat d'exécution de chaque 
                              entrée du paramètre -Hashtable. 
     -[Boolean]   isSuccess : Indique si un remplacement a eu lieu, que 
                              $InputObject ait un contenu différent ou pas.
     -            Value     : Contient la valeur de retour de $InputObject,
                              qu'il y ait eu ou non de modifications .
.
    Le membre Replaces contient une liste d'objets personnalisés de type 
    [PSReplaceInfoItem]. A chaque clé du paramètre -Hashtable correspond 
    un objet personnalisé.
    L'ordre d'insertion dans la liste suit celui de l'exécution.
.    
    PSReplaceInfoItem contient les membres suivants :
      - [String]  Old       : Contient la ligne avant la modification.
                              Si -Property est précisé, ce champ contiendra 
                              toujours $null.
      - [String]  New       : Si le remplacement réussi, contient la ligne 
                              après la modification, sinon contient $null.
                              Si -Property est précisé, ce champ contiendra 
                              toujours $null.
      - [String]  Pattern   : Contient le pattern de recherche.
      - [Boolean] isSuccess : Indique s'il y a eu un remplacement.
                              Dans le cas où on remplace une occurrence 'A' 
                              par 'A', une expression régulière permet de
                              savoir si un remplacement a eu lieu, même à 
                              l'identique. Si vous utilisez -SimpleReplace 
                              ce n'est plus le cas, cette propriété contiendra 
                              $false.   
    Notez que si le paramètre -Property est précisé, une seule opération sera 
    enregistrée dans le tableau Replaces, les noms des propriétés traitées 
    ne sont pas mémorisés.       
.
    Note : 
    Attention à la consommation mémoire si $InputObject est une chaîne de
    caractère de taille importante.
    Si vous mémorisez le résultat dans une variable, l'objet contenu dans
    le champ PSReplaceInfo.Value sera toujours référencé.
    Pensez à supprimer rapidement cette variable afin de ne pas retarder la 
    libération automatique des objets référencés.      

.PARAMETER Property
    Spécifie le ou les noms des propriétés d'un objet concernées lors du 
    remplacement. Seules sont traités les propriétés de type [string] 
    possédant un assesseur en écriture (Setter).
    Pour chaque propriété on effectue tous les remplacements précisés dans 
    le paramètre -Hashtable, tout en tenant compte de la valeur des paramètres
    -Unique et -SimpleReplace.
    On réémet l'objet reçu, après avoir modifié les propriétés indiquées.
    Le paramètre -Inputobject n'est donc pas converti en type [String].
    Une erreur non-bloquante sera déclenchée si l'opération ne peut aboutir.
.     
    Les jokers sont autorisés dans les noms de propriétés.
    Comme les objets reçus peuvent être de différents types, le traitement 
    des propriétés inexistante ne génére pas d'erreur.   
         
.PARAMETER Unique
    Pas de recherche/remplacement multiple.
.
    L'exécution ne concerne qu'une seule opération de recherche et de 
    remplacement, la première qui réussit, même si le paramètre -Hashtable 
    contient plusieurs entrées.
    Si le paramètre -Property est précisé, l'opération unique se fera sur 
    toutes les propriétés indiquées.
    Ce paramètre ne remplace pas l'information précisée par la clé 'Max'. 
.
    Note : La présence du switch -Whatif influence le comportement du switch 
    -Unique. Puisque -Whatif n'effectue aucun traitement, on ne peut pas 
    savoir si un remplacement a eu lieu, dans ce cas le traitement de 
    toutes les clés sera simulé.
    
.PARAMETER SimpleReplace
    Utilise une correspondance simple plutôt qu'une correspondance d'expression 
    régulière. La recherche et le remplacement utilisent la méthode 
    String.Replace() en lieu et place d'une expression régulière.
    ATTENTION cette dernière méthode effectue une recherche de mots en 
    respectant la casse et tenant compte de la culture.
.    
    L'usage de ce switch ne permet pas d'utiliser toutes les fonctionnalités 
    du paramètre -Hashtable, ex :  @{Replace="X";Max=n;StartAt=n;Options="Compiled"}. 
    Si vous couplez ce paramètre avec ce type de hashtable, seule la clé 
    'Replace' sera prise en compte. 
    Un avertissement est généré, pour l'éviter utiliser le paramétrage 
    suivant :
     -WarningAction:SilentlyContinue #bug en v2
     ou
     $WarningPreference="SilentlyContinue"

.EXAMPLE
    $S= "Caractères : 33 \d\d"
    $h=@{}
    $h."a"="?"
    $h."\d"='X'
    Replace-String -i $s $h 
.        
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la chaîne $S, 
    elles remplacent toutes les lettres 'a' par le caractère '?' et tous 
    les chiffres par la lettre 'X'.
.
    La hashtable $h contient deux entrées, chaque clé est utilisée comme 
    étant la chaîne à rechercher et la valeur de cette clé est utilisée 
    comme chaîne de remplacement. Dans ce cas on effectue deux opérations 
    de remplacement sur chaque chaîne de caractère reçu. 
.       
    Le résultat, de type chaîne de caractères, est égal à : 
    C?r?ctères : XX \d\d
. 
.         
    La hashtable $H contenant deux entrées, Replace-String effectuera deux 
    opérations de remplacement sur la chaîne $S. 
.    
    Ces deux opérations sont équivalentes à la suite d'instructions suivantes :
    $Resultat=$S -replace "a",'?'
    $Resultat=$Resultat -replace "\d",'X'
    $Resultat
    
.EXAMPLE
    $S= "Caractères : 33 \d\d"
    $h=@{}
    $h."a"="?"
    $h."\d"='X'
    Replace-String -i $s $h -SimpleReplace
.        
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la chaîne $S, 
    elles remplacent toutes les lettres 'a' par le caractère '?', tous les 
    chiffres ne seront pas remplacés par la lettre 'X', mais toutes les 
    combinaisons de caractères "\d" le seront, car le switch SimpleReplace 
    est précisé. Dans ce cas, la valeur de la clé est considérée comme une 
    simple chaîne de caractères et pas comme une expression régulière. 
.    
    Le résultat, de type chaîne de caractères, est égal à : 
    C?r?ctères : 33 XX
.         
    La hashtable $H contenant deux entrées, Replace-String effectuera deux 
    opérations de remplacement sur la chaîne $S. 
.    
    Ces deux opérations sont équivalentes à la suite d'instructions suivantes :
    $Resultat=$S.Replace("a",'?')
    $Resultat=$Resultat.Replace("\d",'X')
    $Resultat    
     #ou 
    $Resultat=$S.Replace("a",'?').Replace("\d",'X')
    
.EXAMPLE
    $S= "Caractères : 33"
    $h=@{}
    $h."a"="?"
    $h."\d"='X'
    Replace-String -i $s $h -Unique 
. 
    Description
    -----------
    Ces commandes effectuent un seul remplacement dans la chaîne $S, elles 
    remplacent toutes les lettres 'a' par le caractère '?'.
. 
    L'usage du paramètre -Unique arrête le traitement, pour l'objet en cours, 
    dés qu'une opération de recherche et remplacement réussit.
.    
    Le résultat, de type chaîne de caractères, est égal à : 
    C?r?ctères : 33 

.EXAMPLE
    $S= "Caractères : 33"
    $h=@{}
    $h."a"="?"
     #Substitution à l'aide de capture nommée
    $h."(?<Chiffre>\d)"='${Chiffre}X'
    $S|Replace-String $h 
    
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la chaîne $S, 
    elles remplacent toutes les lettres 'a' par le caractère '?' et tous 
    les chiffres par la sous-chaîne trouvée, correspondant au groupe 
    (?<Chiffre>\d), suivie de la lettre 'X'.
.
    Le résultat, de type chaîne de caractères, est égal à : 
    C?r?ctères : 3X3X   
.
    L'utilisation d'une capture nommée, en lieu et place d'un numéro de 
    groupe, comme $h."\d"='$1 X', évite de séparer le texte du nom de groupe 
    par au moins un caractère espace.
    Le parsing par le moteur des expressions régulières reconnait $1, mais 
    pas $1X.      
    
.EXAMPLE
    $S= "Caractères : 33"
    $h=@{}
    $h."a"="?"
    $h."(?<Chiffre>\d)"='${Chiffre}X'
    $h.":"={ Write-Warning "Call delegate"; return "<$($args[0])>"}    
    $S|Replace-String $h 
    
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la chaîne $S, 
    elles remplacent :
     -toutes les lettres 'a' par le caractère '?', 
     -tous les chiffres par la sous-chaîne trouvée, correspondant au groupe
     (?<Chiffre>\d), suivie de la lettre 'X', 
     -et tous les caractères ':' par le résultat de l'exécution du 
     ScriptBlock {"<$($args[0])>"}.
.
    Le Scriptblock est implicitement casté en un délégué du type 
    [System.Text.RegularExpressions.MatchEvaluator]. 
.
    Son usage permet, pour chaque occurrence trouvée, d'évaluer le remplacement 
    à l'aide d'instructions du langage PowerShell.
    Son exécution renvoie comme résultat une chaîne de caractères.
    Il est possible d'y référencer des variables globales (voir les règles 
    de portée de PowerShell) ou l'objet référencé par le paramètre 
    $InputObject.
.                
    Le résultat, de type chaîne de caractères, est égal à : 
    C?r?ctères <:> 3X3X          
       
.EXAMPLE
    $S= "CAractères : 33"
    $h=@{}
    $h."a"=@{Replace="?";StartAt=3;Options="IgnoreCase"} 
    $h."\d"=@{Replace='X';Max=1}
    $S|Replace-String $h 
    
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la chaîne $S.
    On paramètre chaque expression régulière à l'aide d'une hashtable 
    'normalisée'.
.    
    Pour l'expression régulière "a" on remplace toutes les lettres 'a', 
    situées après le troisième caractère, par le caractère '?'. La recherche
    est insensible à la casse, on ne tient pas compte des majuscules et de 
    minuscules, les caractères 'A' et 'a' sont concernés.
    Pour l'expression régulière "\d" on remplace un seul chiffre, le premier 
    trouvé, par la lettre 'X'.               
.
    Pour les clés de la hashtable 'normalisée' qui sont indéfinies, on 
    utilisera les valeurs par défaut. La seconde clé est donc égale à :
     $h."\d"=@{Replace='X';Max=1;StartAt=0;Options="IgnoreCase"}
.        
    Le résultat, de type chaîne de caractères, est égal à : 
    CAr?ctères : X3
    
.EXAMPLE
    $S="( Date ) Test d'effet de bord : modification de mot"
    
    $h=@{}
    $h."Date"=(Get-Date).ToString("dddd d MMMM yyyy")
    $h."mot"="Date"
    $s|Replace-String $h -unique|Write-host -Fore White
    $s|Replace-String $h|Write-host -Fore White 
    #
    #
    $od=new-object System.Collections.Specialized.OrderedDictionary
    $od."Date"=(Get-Date).ToString("dddd d MMMM yyyy")
    $od."mot"="Date"
    $s|Replace-String $od -unique|Write-host -Fore Green
    $s|Replace-String $od|Write-host -Fore Green
    
    Description
    -----------
    Ces deux exemples effectuent un remplacement multiple dans la chaîne $S.
    Les éléments d'une hashtable, déclarée par @{}, ne sont par ordonnés, ce 
    qui fait que l'ordre d'exécution des expressions régulières peut ne pas 
    respecter celui de l'insertion.
.
    Dans le premier exemple, cela peut provoquer un effet de bord. Si on 
    exécute les deux expressions régulières, la seconde modifie également 
    la seconde occurrence du terme 'Date' qui a précédemment été insérée 
    lors du remplacement de l'occurrence du terme 'mot'.
    Dans ce cas, on peut utiliser le switch -Unique afin d'éviter cet effet 
    de bord indésirable.
.
    Le second exemple utilise une hashtable ordonnée qui nous assure d'
    exécuter les expressions régulières dans l'ordre de leur insertion.
.
    Les résultats, de type chaîne de caractères, sont respectivement : 
    ( NomJour nn NomMois année ) Test d'effet de bord : modification de NomJour nn NomMois année  
    ( NomJour nn NomMois année ) Test d'effet de bord : modification de Date  

.EXAMPLE
    $S=@"
#  Version :  1.1.0 b
#
#     Date    :     30 Octobre 2009
"@
    $NumberVersion="1.2.1"
    $Version="# Version : $Numberversion"
    
    $od=new-object System.Collections.Specialized.OrderedDictionary
     # \s* recherche les espaces et les tabulations
     #On échappe le caractère diése(#)
    $od.'(?im-s)^\s*\#\s*Version\s*:(.*)$'=$Version
    # équivalent à :
    #$od.'^\s*\#\s*Version\s*:(.*)$'=@{Replace=$Version;Options="IgnoreCase,MultiLine"} 
    $LongDatePattern=[System.Threading.Thread]::CurrentThread.CurrentCulture.DateTimeFormat.LongDatePattern
    $od.'(?im-s)^\s*\#\s*Date\s*:(.*)$'="# Date    : $(Get-Date -format $LongDatePattern)"
    $S|Replace-String $od
   
    Description
    -----------
    Ces instructions effectuent un remplacement multiple dans la chaîne $S.
    On utilise une construction d'options inline '(?im-s)', celle-ci active 
    l'option 'IgnoreCase' et 'Multiline', et désactive l'option 'Singleline'.
    Ces options inlines sont prioritaires et complémentaires par rapport à 
    celles définies dans la clé 'Options' d'une entrée du paramètre 
    -Hashtable.
.
    La Here-String $S est une chaîne de caractères contenant des retours 
    chariot(CR+LF), on doit donc spécifier le mode multiligne (?m) qui 
    modifie la signification de ^ et $ dans l'expression régulière, de 
    telle sorte qu'ils correspondent, respectivement, au début et à la fin 
    de n'importe quelle ligne et non simplement au début et à la fin de la 
    chaîne complète.
.    
    Le résultat, de type chaîne de caractères, est égal à : 
# Version : 1.2.1
#
# Date    : NomDeJour xx NomDeMois Année 
.
.   Note :  
    Sous PS v2, un bug fait qu'une nouvelle ligne dans une Here-String est 
    représentée par l'unique caractère "`n" et pas par la suite de caractères 
    "`r`n".

.EXAMPLE
    $S=@"
@echo OFF
 rem Otto Matt 
 rem
set ORACLE_BASE=D:\Oracle
set ORACLE_HOME=%ORACLE_BASE%\ora81
set ORACLE_SID=#SID#

%ORACLE_HOME%\bin\oradim -new -sid #SID# -intpwd %lINTPWD% -startmode manual -pfile "%ORACLE_BASE%\admin\#SID#\pfile\init#SID#.ora"
rem ...
%ORACLE_HOME%\bin\oradim -edit -sid #SID# -startmode auto  
"@
    $h=@{}
    $h."#SID#"="BaseTest"
    $Result=$S|Replace-String $h -ReplaceInfo -SimpleReplace
    $Result|ft
    $Result.Replaces[0]|fl
    $Result|Set-Content C:\Temp\NewOrabase.cmd -Force
    Type C:\temp\NewOrabase.cmd
#   En une ligne :     
#    $S|Replace-String $h -ReplaceInfo -SimpleReplace|
#     Set-Content C:\Temp\NewOrabase.cmd -Force
   
    Description
    -----------
    Ces instructions effectuent un remplacement simple dans la chaîne $S.
    On utilise ici Replace-String pour générer un script batch à partir
    d'un template (gabarit ou modèle de conception).
    Toutes les occurrences du texte '#SID#' sont remplacées par la chaîne 
    'BaseTest'. Le résultat de la fonction est un objet personnalisé de type
    [PSReplaceInfo].
.
    Ce résultat peut être émis directement vers le cmdlet Set-Content, car 
    le membre 'Value' de la variable $Result est automatiquement lié au 
    paramètre -Value du cmdlet Set-Content.  

.EXAMPLE
    $S="Un petit deux-roues, c'est trois fois rien."
    $Alternatives=@("un","deux","trois")
     #En regex '|' est le métacaractère 
     #pour les alternatives.
    $ofs="|"
    $h=@{}
    $h.$Alternatives={
       switch ($args[0].Groups[0].Value) {
        "un"    {"1"; break}
        "deux"  {"2"; break}
        "trois" {"3"; break}
      }#switch
    }#$s
    $S|Replace-String $h
    $ofs=""
    
    Description
    -----------
    Ces instructions effectuent un remplacement multiple dans la chaîne $S.
    On utilise ici un tableau de chaînes qui se seront transformées, à 
    l'aide de la variable PowerShell $OFS, en une chaîne d'expression 
    régulière contenant une alternative "un|deux|trois". On lui associe un 
    Scriptblock dans lequel on déterminera, selon l'occurrence trouvée, la 
    valeur correspondante à renvoyer.
.    
    Le résultat, de type chaîne de caractères, est égal à : 
    1 petit 2-roues, c'est 3 fois rien.

.EXAMPLE
     #Paramètrage
    $NumberVersion="1.2.1"
    $Version="# Version : $Numberversion"
     #La date est substituée une seule fois lors
     #de la création de la hashtable. 
    $Modifications= @{
       "^\s*\#\s*Version\s*:(.*)$"=$Version;
       '^\s*\#\s*Date\s*:(.*)$'="# Date    : $(Get-Date -format 'd MMMM yyyy')"
    }
    $RunWinMerge=$False
    
    #Fichiers de test :
    # http://projets.developpez.com/projects/add-lib/files
    
    cd "C:\Temp\Replace-String\TestReplace"
     #Cherche et remplace dans tous les fichiers d'une arborescence, sauf les .bak
     #Chaque fichier est recopié en .bak avant les modifications
    Get-ChildItem "$PWD" *.ps1 -exclude *.bak -recurse| 
     Where-Object {!$_.PSIsContainer} |
     ForEach-Object {
       $CurrentFile=$_ 
       $BackupFile="$($CurrentFile).bak" 
       Copy-Item $CurrentFile $BackupFile 
       
       Get-Content $BackupFile|
        Replace-String $Modifications|
        Set-Content -path $CurrentFile
       
        #compare le résultat à l'aide de Winmerge
      if ($RunWinMerge)
       {Microsoft.PowerShell.Management\start-process  "C:\Program Files\WinMerge\WinMergeU.exe" -Argument "/maximize /e /s /u $BackupFile $CurrentFile"  -wait}  
    } #foreach

    Description
    -----------
    Ces instructions effectuent un remplacement multiple sur le contenu 
    d'un ensemble de fichiers '.ps1'.
    On remplace dans l'entête de chaque fichier le numéro de version et la 
    date. Avant le traitement, chaque fichier .ps1 est recopié en .bak dans
    le même répertoire. Une fois le traitement d'un fichier effectué, on 
    peut visualiser les différences à l'aide de l'utilitaire WinMerge.   

.EXAMPLE
    $AllObjects=dir Variable:
    $AllObjects| Ft Name,Description|More
      $h=@{}
      $h."^$"={"Nouvelle description de la variable $($InputObject.Name)"}
       #PowerShell V2 FR
      $h."(^Nombre|^Indique|^Entraîne)(.*)$"='POWERSHELL $1$2'
      $Result=$AllObjects|Replace-String $h -property "Description" -ReplaceInfo -Unique
    $AllObjects| Ft Name,Description|More  

    Description
    -----------
    Ces instructions effectuent un remplacement unique sur le contenu d'une 
    propriété d'un objet, ici de type [PSVariable].
    La première expression régulière recherche les objets dont la propriété 
    'Description', de type [string], n'est pas renseignée. 
    La seconde modifie celles contenant en début de chaîne un des trois mots 
    précisés dans une alternative. La chaîne de remplacement reconstruit le 
    contenu en insérant le mot 'PowerShell' en début de chaîne.
.    
    Le contenu de la propriété 'Description' d'un objet de type 
    [PSVariable] n'est pas persistant, cette opération ne présente donc 
    aucun risque. 

.EXAMPLE
    try {
       Reg Save HKEY_CURRENT_USER\Environment C:\temp\RegistryHiveTest.hiv
       REG LOAD HKU\PowerShell_TEST C:\temp\RegistryHiveTest.hiv
       new-Psdrive -name Test -Psprovider Registry -root HKEY_USERS\PowerShell_Test
       cd Test:
       $key = Get-Item $pwd
       $values = Get-ItemProperty $key.PSPath
       $key.Property.GetEnumerator()|
         Foreach { 
           New-Object PSObject -Property @{
             Path=$key.PSPath; 
             Name="$_"; 
             Value=$values."$_"
           }#Property 
         }|
         Replace-String @{"C:\\"="D:\"} -Property Value|
         Set-ItemProperty -name {$_.Name} -Whatif
     }#try
    finally 
     { 
       cd C:
       Remove-PSDrive Test
       key=$null;values=$null
      [GC]::Collect(GC]::MaxGeneration)
      REG UNLOAD HKU\PowerShell_TEST
    }#finally

    Description
    -----------
    La première instruction crée une sauvegarde des informations de la ruche 
    'HKEY_CURRENT_USER\Environment', la seconde charge la sauvegarde dans
    une nouvelle ruche nommée 'HKEY_USer\PowerShell_TEST' et la troisième 
    crée un drive PowerShell nommé 'Test'.
.
    Les instructions suivantes récupèrent les clés de registre et leurs 
    valeurs. À partir de celles-ci on crée autant d'objets personnalisés 
    qu'il y a de clés. Les noms des membres de cet objet personnalisé 
    correspondent à des noms de paramètres du cmdlet Set-ItemProperty qui 
    acceptent l'entrée de pipeline (ValueFromPipelineByPropertyName). 
.   
    Ensuite, à l'aide de Replace-String, on recherche et remplace dans la 
    propriété 'Value' de chaque objet créé, les occurrences de 'C:\' par 
    'D:\'. 
    Replace-String émet directement les objets vers le cmdlet 
    Set-ItemProperty.
    Et enfin, celui-ci lit les informations à mettre à jour à partir des 
    propriétés de l'objet personnalisé reçu.
.
    Pour terminer, on supprime le drive PowerShell et on décharge la ruche 
    de test.
    Note:
     Sous PowerShell l'usage de Set-ItemProperty (à priori) empêche la 
     libération de la ruche chargée, on obtient l'erreur 'Access Denied'.
     Pour finaliser cette opération, on doit fermer la console PowerShell 
     et exécuter cmd.exe afin d'y libérer correctement la ruche :
      Cmd /k "REG UNLOAD HKU\PowerShell_TEST"        
 
.INPUTS
    System.Management.Automation.PSObject
     Vous pouvez diriger tout objet ayant une méthode ToString vers 
     Replace-String.

.OUTPUTS
    System.String
    System.Object
    System.PSReplaceInfo 

     Replace-String retourne tous les objets qu'il soient modifiés ou pas.

.NOTES
    Vous pouvez consulter la documentation Française sur les expressions
    régulières, via les liens suivants :
.   
    Options des expressions régulières  : 
     http://msdn.microsoft.com/fr-fr/library/yd1hzczs(v=VS.80).aspx
     http://msdn.microsoft.com/fr-fr/library/yd1hzczs(v=VS.100).aspx
.    
    Éléments du langage des expressions régulières :
     http://msdn.microsoft.com/fr-fr/library/az24scfc(v=VS.80).aspx
.
    Compilation et réutilisation de regex :
     http://msdn.microsoft.com/fr-fr/library/8zbs0h2f(vs.80).aspx     
.
.
    Au coeur des dictionnaires en .Net 2.0 :
     http://mehdi-fekih.developpez.com/articles/dotnet/dictionnaires
.
    Outil de création d'expression régulière, info et Tips
    pour PowerShell :
     http://powershell-scripting.com/index.php?option=com_joomlaboard&Itemid=76&func=view&catid=4&id=3731  
.
.
    Il est possible d'utiliser la librairie de regex du projet PSCX :
     "un deux deux trois"|Replace-String @{$PSCX:RegexLib.RepeatedWord="Deux"}
     #renvoi
     #un deux trois
.
		Author:  Laurent Dardenne
		Version:  1.1
		Date: 22/08/2010

.LINK
    http://projets.developpez.com/projects/add-libv2/wiki/Replace-String

.COMPONENT
    expression régulière
    
.ROLE
    Server Administrator
    Windows Administrator
    Power User
    User

.FUNCTIONALITY
    Global

.FORWARDHELPCATEGORY <Function>
#>

  [CmdletBinding(DefaultParameterSetName = "asString",SupportsShouldProcess=$True)]
  [OutputType("asString", [String])] 
  [OutputType("asReplaceInfo", [PSObject])]  
  [OutputType("asObject", [Object])]
  param (
          [ValidateNotNull()]
          [AllowEmptyString()]
           #pas de position 
           #si on n'utilise pas le pipe on doit préciser son nom -InputObject ou -I
           #le paramètre suivant sera considéré comme étant en position 0, car innommé 
          [Parameter(Mandatory=$true,ValueFromPipeline = $true)]
        [System.Management.Automation.PSObject] $InputObject,
         
          [ValidateNotNullOrEmpty()]
          [Parameter(Position=0, Mandatory=$true)]
        [System.Collections.IDictionary] $Hashtable,

         [ValidateNotNullOrEmpty()]
         [Parameter(Position=1, ParameterSetName="asObject")]
        [string[]] $Property,
        
        [switch] $Unique,
        [switch] $SimpleReplace,
        [switch] $ReplaceInfo)


  begin {
     #Section DATA + ConvertFrom-StringData problème d'analyse avec le caractère = 
    $TextMsgs =@{ 
                                         #fr-FR
       WellFormedKeyNullOrEmptyValue  = "La clé n'existe pas ou sa valeur est `$null"
       WellFormedInvalidCast          = "La valeur de la clé {0} ne peut pas être convertie en {1}."
       WellFormedInvalidValueNotLower = "La valeur de la clé ne peut pas être inférieur à -1."
       WellFormedInvalidValueNotZero  = "La valeur de la clé doit être supérieure à zéro."
       ReplaceSimpleEmptyString       = "L'option SimpleReplace ne permet pas une chaîne de recherche vide."
       ReplaceRegExCreate             = "[Construction de regex] {0}"
       ReplaceRegExStarAt             = "{0}`r`nStartAt({1}) est supérieure à la longueur de la chaîne({2})"
       ReplaceObjectPropertyNotString = "La propriété n'est pas du type string."
       ReplaceObjectPropertyReadOnly = "La propriété est en lecture seule."
       #ReplaceRegexObjectPropertyError  = $_.Exception.Message
       #ReplaceStringObjectPropertyError = $_.Exception.Message
       #StringReplaceRegexError          = $_.Exception.Message
       ReplaceSimpleScriptBlockError  = "{0}={{{1}}}`r`n{2}"
       ObjectReplaceShouldProcess     = "Objet [{0}] Propriété : {1}"
       StringReplaceShouldProcess     = "{0} par {1}"
       WarningSwitchSimpleReplace     = "Le switch SimpleReplace n'utilise pas toutes les fonctionnalités d'une hashtable de type @{Replace='X';Max=n;StartAt=n,Options='Y'}.`r`n Utilisez une simple chaîne de caractères."
       WarningConverTo                = "La conversion, par ConverTo(), renvoi une chaîne vide.`r`n{0}"
       
    } #TextMsgs
   
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
   
     Function Test-InputObjectProperty($CurrentProperty) {
      #Valide les prérequis d'une propriété d'objet
      #Doit exister, être de type [String] et être en écriture.
         #On ne traite que les propriétés de type [string]
       if ($CurrentProperty.TypeNameOfValue -ne "System.String")
        {throw (New-Object System.ArgumentException($TextMsgs.ReplaceObjectPropertyNotString,$CurrentProperty.Name)) }                       
         #On ne traite que les propriétés proposant un setter
       if (-not $CurrentProperty.IsSettable)
        {throw (New-Object System.ArgumentException($TextMsgs.ReplaceObjectPropertyReadOnly,$CurrentProperty.Name)) } 
     }#Test-InputObjectProperty
     
    function ConvertTo-String($Value){
       #Conversion PowerShell
       #Par exemple converti $T=@("un","Deux") en "un deux"
       # ce qui est équivalent à "$T"
       #Au lieu de System.Object[] si on utilise $InputObject.ToString()
       #De plus un PSObject peut ne pas avoir de méthode ToString()
     [System.Management.Automation.LanguagePrimitives]::ConvertTo($Value,
                                                                   [string],
                                                                   [System.Globalization.CultureInfo]::InvariantCulture)
    }#ConvertTo-String
    
    function Convert-DictionnaryEntry($Parameters) 
    {   #Converti un DictionnaryEntry en une string "clé=valeur clé=valeur..." 
      "$($Parameters.GetEnumerator()|% {"$($_.key)=$($_.value)"})"
    }#Convert-DictionnaryEntry
  
    function New-ObjectReplaceInfo{ 
       #Crée un objet contenant le résultat d'un remplacement
       #Permet d'émettre la chaîne modifiée et de savoir si 
       # une modification a eu lieu.
      $Result=New-Object PSObject -Property @{
         #Contient le résultat d'exécution de chaque entrée
        Replaces=New-Object System.Collections.ArrayList(6)
         #Indique si $InputObject a été modifié ou non 
        isSuccess=$False
         #Contient la valeur de retour de $InputObject,
         #qu'il ait été modifié ou non. 
        Value=$Null 
      }
     $Result.PsObject.TypeNames[0] = "PSReplaceInfo"
     $Result
    }#New-ObjectReplaceInfo
  
    function isParameterWellFormed($Parameters) {
     #Renvoi true si l'entrée de hashtable $Parameters est correcte
     #la recherche préliminaire par ContainsKey est dicté par la possible 
     #déclaration de set-strictmode -version 2.0
    #Replace 
      if (-not $Parameters.ContainsKey('Replace') -or ($Parameters.Replace -eq $null))
      {  #[string]::Empty est valide, même pour la clé
  			 $PSCmdlet.WriteError(
          (New-Object System.Management.Automation.ErrorRecord(
              #inverse nomParam,msg 
     				 (New-Object System.ArgumentNullException('Replace',$TextMsgs.WellFormedKeyNullOrEmptyValue)), 
               "WellFormedKeyNullOrEmptyValue", 
               "InvalidData",
               $ParameterString # Si $ErrorView="CategoryView" l'information est affichée
           )
          ) 
         )#WriteError
         return $false
      }
      else
       {
         $Parameters.Replace=$Parameters.Replace -as [string]
         if ($Parameters.Replace -eq $null)
          { 
      			$PSCmdlet.WriteError(
             (New-Object System.Management.Automation.ErrorRecord( 
         			 (New-Object System.InvalidCastException ($TextMsgs.WellFormedInvalidCast -F "Replace",'[String]')), 
         			   "WellFormedInvalidCast", 
         			   "InvalidType",
         			   $ParameterString
               )
              ) 
             )#WriteError
            return $false
          }
       }
    #Max
      if (-not $Parameters.ContainsKey('Max') -or ($Parameters.Max -eq $null -or $Parameters.Max -eq [String]::Empty)) 
       {$Parameters.Max=-1}
      else
       {
         $Parameters.Max=$Parameters.Max -as [int]
         if ($Parameters.Max -eq $null)
          { 
            $PSCmdlet.WriteError(
              (New-Object System.Management.Automation.ErrorRecord( 
         				 (New-Object System.InvalidCastException ($TextMsgs.WellFormedInvalidCast -F 'Max','[int]')), 
                   "WellFormedInvalidCast", 
                   "InvalidData",
                   $ParameterString
         		 	 	 ) 
              )
            )#WriteError 
            return $false
          }
        elseif ($Parameters.Max -lt -1)
          { 
            $PSCmdlet.WriteError(
             (New-Object System.Management.Automation.ErrorRecord( 
     				  (New-Object System.ArgumentException($TextMsgs.WellFormedInvalidValueNotLower,'Max')), 
                "WellFormedInvalidValueNotLower", 
                "InvalidData",
                $ParameterString
     				  ) 
             )
            )#WriteError
            return $false  
          }
       }
    #StartAt
      if (-not $Parameters.ContainsKey('StartAt') -or ($Parameters.StartAt -eq $null)) 
       {$Parameters.StartAt=0}
      else
       { 
         $Parameters.StartAt=$Parameters.StartAt -as [int]
          #si StartAt=[String]::Empty -> StartAt=0
         if ($Parameters.StartAt -eq $null)
          { 
            $PSCmdlet.WriteError(
              (New-Object System.Management.Automation.ErrorRecord( 
         				(New-Object System.InvalidCastException ($TextMsgs.WellFormedInvalidCast -F 'StartAt','[int]')), 
         			 	  "WellFormedInvalidCast", 
         				  "InvalidData",
         				  $ParameterString
         				)  
              )
            )#WriteError 
            return $false  
          }
         elseif ($Parameters.StartAt -lt 0)
          { 
            $PSCmdlet.WriteError(
              (New-Object System.Management.Automation.ErrorRecord( 
         			 (New-Object System.ArgumentException($TextMsgs.WellFormedInvalidValueNotZero,'StartAt')), 
         				  "WellFormedInvalidValueNotZero", 
         				  "InvalidData",
         				  $ParameterString
               )
              )
            )#WriteError  
            return $false  
          }
       }
    #Options
      if (-not $Parameters.ContainsKey('Options') -or (($Parameters.Options -eq $null) -or ($Parameters.Options -eq [String]::Empty))) 
       {$Parameters.Options="IgnoreCase"}
      else 
       {
          #La présence d'espaces ne gêne pas la conversion.
         $Parameters.Options=(ConvertTo-String $Parameters.Options) -as [System.Text.RegularExpressions.RegexOptions]
         if ($Parameters.Options -eq $null)
          { 
            $PSCmdlet.WriteError(
              (New-Object System.Management.Automation.ErrorRecord( 
         			 (New-Object System.InvalidCastException ($TextMsgs.WellFormedInvalidCast -F 'Options','[System.Text.RegularExpressions.RegexOptions]')), 
                 "WellFormedInvalidCast", 
                 "InvalidData",
                 $ParameterString
         			 )  
              )
            )#WriteError 
            return $false
          }
       }
      return $true
    }#isParameterWellFormed
    
    function BuildList {
       #Construit une liste avec des DictionaryEntry valides
     $Hashtable.GetEnumerator()|
       Foreach {
         $Parameters=$_.Value
         $WrongDictionnaryEntry=$false
            #Analyse la valeur de l'entrée courante de $Hashtable
            #puis la transforme en un type hashtable 'normalisée' 
         if ($Parameters -is [System.Collections.IDictionary])
          {  #On ne modifie pas la hashtable d'origine
             #Les objets référencés ne sont pas cloné, on duplique l'adresse.
            $Parameters=$Parameters.Clone()
            
            $ParameterString="$($_.Key) = @{$(Convert-DictionnaryEntry $Parameters)}"
            $WrongDictionnaryEntry=-not (isParameterWellFormed $Parameters)
            if ($WrongDictionnaryEntry -and ($DebugPreference -eq "Continue"))
            { $PSCmdlet.WriteDebug("[DictionaryEntry][Error]$ParameterString")}
            
            if ($SimpleReplace) 
             { $PSCmdlet.WriteWarning($TextMsgs.WarningSwitchSimpleReplace) }  
          }#-is [System.Collections.IDictionary] 
         else 
          {   #Dans tous les cas on utilise une hashtable normalisée
              #pour récupèrer les paramètres.
             if ($Parameters -eq $null)
              {$Parameters=[String]::Empty}  
             $Parameters=@{Replace=$Parameters;Max=-1;StartAt=0;Options="IgnoreCase"}
          } 

         if  ($_.Key -isnot [String])
          { 
             #La clé peut être un objet,
             #on tente une conversion de la clé en [string].
             #On laisse la possibilité de dupliquer les clés
             #issues de cette conversion.
           [string]$Key= ConvertTo-String $_.Key
           if ($Key -eq [string]::Empty)
            { $PSCmdlet.WriteWarning(($TextMsgs.WarningConverTo -F $_.Key))}
          }
         else
          {$key=$_.Key}
        
         if ($SimpleReplace -and ($Key -eq [String]::Empty))
          {
            $WrongDictionnaryEntry =$true
            $PSCmdlet.WriteError(
              (New-Object System.Management.Automation.ErrorRecord( 
         				 (New-Object System.ArgumentException($TextMsgs.ReplaceSimpleEmptyString,'Replace')), 
                   "ReplaceSimpleEmptyString", 
                   "InvalidData",
                   (Convert-DictionnaryEntry $Parameters)
                 )  
              )
            )#WriteError
          }
          
         if (-not $WrongDictionnaryEntry ) 
          {  
            $DEntry=new-object System.Collections.DictionaryEntry($Key,$Parameters)
            $RegExError=$False
             #Construit les regex
            if (-not $SimpleReplace)
             {
                 #Construit une expression régulière dont le pattern est 
                 #le nom de la clé de l'entrée courante de $TabKeyValue
               try
               { 
                 $Expression=New-Object System.Text.RegularExpressions.RegEx($Key,$Parameters.Options)
                 $DEntry=$DEntry|Add-Member NoteProperty RegEx $Expression -PassThru
               }catch {
                 $PSCmdlet.WriteError(
                  (New-Object System.Management.Automation.ErrorRecord(
             				 (New-Exception $_.Exception ($TextMsgs.ReplaceRegExCreate -F $_.Exception.Message)), 
                       "ReplaceRegExCreate", 
                       "InvalidOperation",
                       ("[{0}]" -f $Key)
                     )  
                  )
                 )#WriteError
                 $PSCmdlet.WriteDebug("Regex erronée, remplacement suivant.")
                 $RegExError=$True 
               }
             }
            if (-not $RegExError)
               #Si on utilise un simple arraylist 
               # les propriétés personnalisées sont perdues
             { [void]$TabKeyValue.Add($DEntry) }
          } #sinon on ne crée pas l'entrée invalide
       }#Foreach       
    }#BuildList
    
    $PSCmdlet.WriteDebug("ParameterSetName :$($PsCmdlet.ParameterSetName)")  
     #Manipule-t-on une chaîne ou un objet ?
    [Switch] $AsObject= $PSBoundParameters.ContainsKey('Property')
    $PSCmdlet.WriteDebug("AsObject: $AsObject")
    
     #On doit explicitement rechercher 
     #la présence des paramètres communs
    [Switch] $Whatif= $null
    [void]$PSBoundParameters.TryGetValue('Whatif',[REF]$Whatif)
    
    $PSCmdlet.WriteDebug("Whatif: $WhatIf")
    $PSCmdlet.WriteDebug("ReplaceInfo: $ReplaceInfo")
     if ($AsObject) # Si set-strictmode -version 2.0 
      {$PSCmdlet.WriteDebug("Properties : $Property")} 
    
      #On construit une liste afin de filtrer les éléments invalides
      #et faciliter l'usage de break/continue dans la boucle du 
      #traitement principal du bloc process.
    $TabKeyValue=New-Object 'System.Collections.Generic.List[PSObject]'
    BuildList 
    if ($DebugPreference -eq "Continue") 
    { 
       $TabKeyValue|
        Foreach-Object {
          if ($_.value -is [System.Collections.IDictionary])
           {$h=$_.value.GetEnumerator()|% {"$($_.key)=$($_.value)"}}
          else
           {$h=$_.value}
          $PSCmdlet.WriteDebug("[DictionaryEntry]$($_.key)=$h")
        }
    }
  }#begin

  process {
    #Si $TabKeyValue ne contient aucun élément,
    #on construit tout de même l'object ReplaceInfo 
     
    if ($InputObject -isnot [String]) 
    {  #Si on ne manipule pas les propriétés d'un objet,
       #on force la conversion en [string]. 
      if ($AsObject -eq $false)
       {
         $ObjTemp=$InputObject
         [string]$InputObject= ConvertTo-String $InputObject
         If ($InputObject -eq [String]::Empty)
          { $PSCmdlet.WriteWarning(($TextMsgs.WarningConverTo -F $ObjTemp))}   
       } 
    }
     #on crée l'objet contenant 
     #la collection de résultats détaillés
    if ($ReplaceInfo)
     {$Resultat=New-ObjectReplaceInfo}  
    
     #Savoir si au moins une opération de remplacement a réussie.
    [Boolean] $AllSuccessReplace=$false     
    
    for ($i=0; $i -lt $TabKeyValue.Count; $i++) {
       #$Key contient la chaîne à rechercher
      $Key=$TabKeyValue[$i].Key

       #$parameters contient les informations de remplacement
      $Parameters=$TabKeyValue[$i].Value
      
       #L'opération de remplacement courante a-t-elle réussie ?
      [Boolean] $CurrentSuccessReplace=$false
      
      if ($ReplaceInfo)
       {  #Crée, pour la clé courante, un objet résultat 
         if ($AsObject)
            #on ne crée pas de référence sur l'objet, 
            #car les champs Old et New pointe sur le même objet.
            #Seul les champs pattern et Key sont renseignés.  
          {$CurrentListItem=New-Object PSObject -Property @{Old=$Null;New=$Null;isSuccess=$False;Pattern=$Key} }
         else
          {$CurrentListItem=New-Object PSObject -Property @{Old=$InputObject;New=$null;isSuccess=$False;Pattern=$Key} } 
         $CurrentListItem.PsObject.TypeNames[0] = "PSReplaceInfoItem"
       }

      $PSCmdlet.WriteDebug(@"
[InputObject][$($InputObject.Gettype().Fullname)]$InputObject
On remplace $Key avec $(Convert-DictionnaryEntry $Parameters)
"@)      
      if ($SimpleReplace) 
      {  #Récupère la chaîne de remplacement
        if ($Parameters.Replace -is [ScriptBlock]) 
         { try {
              #$ReplaceValue contiendra la chaîne de remplacement
             $ReplaceValue=&$Parameters.Replace
             $PSCmdlet.WriteDebug("`t[ScriptBlock] $($Parameters.Replace)`r`n$ReplaceValue") 
           } catch {
               $PSCmdlet.WriteError(
                (New-Object System.Management.Automation.ErrorRecord (
           				 (New-Exception $_.Exception ($TextMsgs.ReplaceSimpleScriptBlockError -F $Key,$Parameters.Replace.ToString(),$_)), 
                     "ReplaceSimpleScriptBlockError", 
                      "InvalidOperation",
                      ("[{0}]" -f $Parameters.Replace)
                   )   
                )
               )#WriteError
              continue   
           }#catch
         }#-is [ScriptBlock]
        else 
         {$ReplaceValue=$Parameters.Replace} 
         
          #On traite des propriétés d'un objet
        if ($AsObject)  
         { 
            $Property|
              #prérequis: Le nom de la propriété courante ne pas doit pas être null ni vide.
              #On recherche les propriétés à chaque fois, on laisse ainis la possibilité au 
              # code d'un scriptblock de modifier/ajouter des propriétés dynamiquement sur 
              # le paramètre $InputObject.
              #Celui-ci doit être de type PSObject pour être modifié directement, sinon
              #seul l'objet renvoyé sera concerné. 
             Foreach-object {
                $PSCmdlet.WriteDebug("[Traitement des wildcards] $_")
                # Ex : Pour PS* on récupère plusieurs propriétés
                #La liste contient toutes les propriétés ( .NET + PS).
                #Si la propriété courante ne match pas, on itère sur les éléments de $Property 
               $InputObject.PSObject.Properties.Match($_)|
               Foreach-Object { 
                  $PSCmdlet.WriteDebug("[Wildcard property]$_")
                  $CurrentProperty=$_
                  $CurrentPropertyName=$CurrentProperty.Name
                  try {
                      #Si -Whatif n'est pas précisé on exécute le traitement
                    if ($PSCmdlet.ShouldProcess(($TextMsgs.ObjectReplaceShouldProcess -F $InputObject.GetType().Name,$CurrentPropertyName)))
                     {                     
                        #Logiquement il ne devrait y avoir qu'un bloc ShouldProcess
                        #englobant tous les traitements, ici cela permet d'afficher 
                        #le détails des opérations imbriquées tout en précisant 
                        #les valeurs effectives utilisées lors du remplacement. 
                       Test-InputObjectProperty $CurrentProperty
                       $PSCmdlet.WriteDebug("`t[String-Before][Object] : $InputObject.$CurrentPropertyName")
                       $OriginalProperty=$InputObject.$CurrentPropertyName
                         $InputObject.$CurrentPropertyName=$OriginalProperty.Replace($Key,$ReplaceValue)
                         #On affecte une seule fois la valeur $true 
                       if (-not $CurrentSuccessReplace)
                        {$CurrentSuccessReplace= -not ($OriginalProperty -eq $InputObject.$CurrentPropertyName) } 
                       $PSCmdlet.WriteDebug("`t[String-After][Object] : $InputObject.$CurrentPropertyName")
                     }#ShouldProcess
                  } catch {
                      #La propriété est en R/O,
                      #La propriété n'est pas du type String, etc. 
                      
                      #Par défaut recrée l'exception trappée avec un message personnalisé 
                     $PSCmdlet.WriteError(
                      (New-Object System.Management.Automation.ErrorRecord (
                           #Recrée l'exception trappée avec un message personnalisé 
                 				  $_.Exception, 
                          "ReplaceStringObjectPropertyError", 
                          "InvalidOperation",
                          $InputObject
                 				)  
                      )
                     )#WriteError
                   }#catch
              }#Foreach $CurrentPropertyName
            }#Foreach  $Property
         } #AsObject 
        else
         { 
           if ($PSCmdlet.ShouldProcess(($TextMsgs.StringReplaceShouldProcess -F $Key,$ReplaceValue)))
            {                     
               $OriginalStr=$InputObject
               $InputObject=$InputObject.Replace($Key,$ReplaceValue)
               $CurrentSuccessReplace= -not ($OriginalStr -eq $InputObject) 
              $PSCmdlet.WriteDebug("`t[String] : $InputObject")
            }#ShouldProcess  
         }
      }#SimpleReplace
      else
      {    #Replace via RegEx
        $Expression=($TabKeyValue[$i]).Regex
        $PSCmdlet.WriteDebug("`t[Regex] : $($expression.ToString()) $($Expression|select *)")
         
         #Récupère la chaîne de remplacement
        if  (($Parameters.Replace -isnot [String]) -and ($Parameters.Replace -isnot [ScriptBlock])) 
         {
             #Appel soit 
             #  Regex.Replace (String, String, Int32, Int32)  
             # soit
             #  Regex.Replace (String, MatchEvaluator, Int32, Int32)
             # 
             #On évite, selon le type du paramètre fourni, un possible problème 
             #de cast lors de l'exécution interne de la recherche de la signature 
             #la plus adaptée (Distance Algorithm). 
             # cf. ([regex]"\d").Replace.OverloadDefinitions 
             # "test 123"|Replace-String @{"\d"=get-date}
             # Error : Impossible de convertir l'argument « 1 » (valeur « 17/07/2010 13:31:56 ») de « Replace » 
             #  en type « System.Text.RegularExpressions.MatchEvaluator » 
             #
             #InvalidCastException :
             #Cette exception se produit lorsqu'une conversion particulière n'est pas prise en charge.
             #Un InvalidCastException est levé pour les conversions suivantes :
             # - Conversions de DateTime en tout autre type sauf String.
             # ...
             #Autre solution :
             # "test 123"|Replace-String @{"\d"=@(get-date)}
             #Mais cette solution apporte un autre problème, dans ce cas on utilise plus la culture courante,
             # mais celle US, car le scriptblock est exécuté dans un contexte où les conversions de chaînes de 
             #caractères en dates se font en utilisant les informations de la classe .NET InvariantCulture.
             #cf. http://janel.spaces.live.com/blog/cns!9B5AA3F6FA0088C2!185.entry      
           $PSCmdlet.WriteDebug( "`t[ConverTo] $($Parameters.Replace.GetType())")
           [string]$ReplaceValue=ConvertTo-String $Parameters.Replace
         } #Replace via RegEx
        else 
         {$ReplaceValue=$Parameters.Replace }

          #On traite des propriétés d'un objet
        if ($AsObject)
         { 
            $Property|
               # Le nom de la propriété courante ne pas doit pas être null ni vide.
              Foreach-object {
                $PSCmdlet.WriteDebug("[Traitement des wildcards]$_")
                # Ex : Pour PS* on récupère plusieurs propriétés 
               $InputObject.PSObject.Properties.Match($_)|
               Foreach-object { 
                  $PSCmdlet.WriteDebug("[Wildcard property]$_")
                  $CurrentProperty=$_
                  $CurrentPropertyName=$CurrentProperty.Name
                   try {
                     if ($PSCmdlet.ShouldProcess(($TextMsgs.ObjectReplaceShouldProcess -F $InputObject.GetType().Name,$CurrentPropertyName)))
                      { 
                        Test-InputObjectProperty $CurrentProperty
                        $PSCmdlet.WriteDebug("`t[RegEx-Before][Object] $CurrentPropertyName : $($InputObject.$CurrentPropertyName)")
                            #On ne peut rechercher au delà de la longueur de la chaîne.
                        if (($InputObject.$CurrentPropertyName).Length -ge $Parameters.StartAt)
                         {
                           $isMatch=$Expression.isMatch($InputObject.$CurrentPropertyName,$Parameters.StartAt)
                           if ($isMatch)
                            {
                              $InputObject.$CurrentPropertyName=$Expression.Replace($InputObject.$CurrentPropertyName,$ReplaceValue,$Parameters.Max,$Parameters.StartAt)
                              $PSCmdlet.WriteDebug("`t[RegEx-After][Object] $CurrentPropertyName : $($InputObject.$CurrentPropertyName)")
                            }
                         }
                        else
                         {
                           $PSCmdlet.WriteWarning(($TextMsgs.ReplaceRegExStarAt -F $InputObject.$CurrentPropertyName,$Parameters.StartAt,$InputObject.$CurrentPropertyName.Length))
                           $PSCmdlet.WriteDebug($msg)
                           $isMatch=$false
                         }
                        $PSCmdlet.WriteDebug("`t[RegEx][Object] ismatch : $ismatch")
                         #On ne mémorise pas les infos de remplacement (replaceInfo) pour les propriétés,
                         #seulement pour les clés (pattern)
                        if (-not $CurrentSuccessReplace)
                         {$CurrentSuccessReplace=$isMatch }
                      }#ShouldProcess
                  } catch {
                      $isMatch=$False #l'erreur peut provenir du ScriptBlock (MachtEvaluator)
                      #La propriété est en R/O, 
                      #La propriété n'est pas du type String, etc. 
                      $PSCmdlet.WriteError(
                       (New-Object System.Management.Automation.ErrorRecord (
                            #Recrée l'exception trappée avec un message personnalisé 
                 			  	 $_.Exception,                       
                           "ReplaceRegexObjectPropertyError", 
                           "InvalidOperation",
                           $InputObject
                          )  
                       )
                      )#WriteError
                  } #catch
              }#Foreach $CurrentPropertyName
            }#Foreach  $Property
         } #AsObject
        else
         {        
            if ($PSCmdlet.ShouldProcess(($TextMsgs.StringReplaceShouldProcess -F $Key,$ReplaceValue)))
             { 
                $PSCmdlet.WriteDebug("`t[RegEx-Before] : $InputObject")
                  #On ne peut rechercher au delà de la longueur de la chaîne.
                if ($InputObject.Length -ge $Parameters.StartAt)
                 {
                   $isMatch=$Expression.isMatch($InputObject,$Parameters.StartAt)
                   if ($isMatch)
                    { try {
                        $InputObject=$Expression.Replace($InputObject,$ReplaceValue,$Parameters.Max,$Parameters.StartAt) 
                        $PSCmdlet.WriteDebug("`t[RegEx-After] : $InputObject")
                      } catch {
                         $isMatch=$False #l'erreur peut provenir du ScriptBlock (MachtEvaluator)
                         $PSCmdlet.WriteError(
                          (New-Object System.Management.Automation.ErrorRecord (
                               #Recrée l'exception trappée avec un message personnalisé 
                     		  	 $_.Exception,                         
                             "StringReplaceRegexError", 
                             "InvalidOperation",
                             ("[{0}]" -f $InputObject)
                             )  
                          )
                         )#WriteError
                      } #catch                        
                    }#$ismatch
                 }                
                else 
                 {                          
                   $PSCmdlet.WriteWarning(($TextMsgs.ReplaceRegExStarAt -F $InputObject,$Parameters.StartAt,$InputObject.Length))
                   $PSCmdlet.WriteDebug("`t$Msg")
                   $isMatch=$false
                 }
                $PSCmdlet.WriteDebug("`t[RegEx] ismatch : $ismatch")
                $CurrentSuccessReplace=$isMatch
             }#ShouldProcess
         } 
      }#Replace via RegEx

      #On construit la liste PSReplaceInfo.PSReplaceInfoItem 
      #contenant le résultat de l'opération courante.
     if ($ReplaceInfo)
     { 
         #Si Whatif est précisé l'opération n'est pas effectuée
         #On ne renvoit rien dans le pipeline
        if (-not $Whatif)
        {
          if (($AsObject -eq $False) -and $CurrentSuccessReplace)
           { $CurrentListItem.New=$InputObject }            
           #On affecte une seule fois la valeur $true 
          if (-not $AllSuccessReplace)
           {$AllSuccessReplace=$CurrentSuccessReplace}
           $CurrentListItem.isSuccess=$CurrentSuccessReplace
           [void]$Resultat.Replaces.Add($CurrentListItem)
           $PSCmdlet.WriteDebug("[ReplaceInfo] : $($CurrentListItem|Select *)")
       }#$Whatif
     }#$ReplaceInfo

      #Est-ce qu'on effectue une seule opération de remplacement ?
     if ($Unique -and $CurrentSuccessReplace)
      {
        $PSCmdlet.WriteDebug("-Unique détecté et le dernier remplacement a réussi. Break.")
        break #oui, on quitte le bloc For
      } 
   }# For $TabKeyValue.Count
   
   if (-not $Whatif)
   {
       #Emission du résultat
       #On a effectué n traitements sur une seule ligne ou un seul object
      if ($ReplaceInfo)
      { 
        $Resultat.isSuccess=$AllSuccessReplace
        $Resultat.Value=$InputObject
         #En cas d'émission sur un cmdlet, utilisant Value comme
         #propriété de binding (ValueFromPipelineByPropertyName),
         #on redéclare la méthode ToString afin que l'objet $Resultat 
         #renvoie le contenu de son membre Value comme donnée à lier.
        $Resultat=$Resultat|Add-member ScriptMethod ToString {$this.Value} -Force -Passthru
          #Passe un tableau d'objet contenant un élément, un objet.
          #PS énumére le tableau et renvoi un seul objet.
          #
          #Dans ce contexte ceci est valable, même
          #si l'objet est un IEnumerable.
        $PSCmdlet.WriteObject(@($Resultat),$true) 
      }#$ReplaceInfo
     else
      {$PSCmdlet.WriteObject(@($InputObject),$true)}

  }
  $PSCmdlet.WriteDebug("[Pipeline] Next object.")
 }#process
}#Replace-String

new-alias rpls Replace-String  -description "Fonction auto-documentée Replace-String" -force 

# SIG # Begin signature block
# MIIFQgYJKoZIhvcNAQcCoIIFMzCCBS8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9eTi37zc2JFGLVGuXJRJX3rJ
# 7QigggL8MIIC+DCCAmWgAwIBAgIQZI2R9vsp1r1NJ8DQJzb16TAJBgUrDgMCHQUA
# MHsxeTB3BgNVBAMecABMAGEAdQByAGUAbgB0ACAARABhAHIAZABlAG4AbgBlACAA
# YQB1AHQAbwByAGkAdADpACAAZABlACAAYwBlAHIAdABpAGYAaQBjAGEAdABpAG8A
# bgAgAHIAYQBjAGkAbgBlACAAbABvAGMAYQBsAGUwHhcNMDkxMTA1MTMxNzEwWhcN
# MzkxMjMxMjM1OTU5WjA2MTQwMgYDVQQDEytMYXVyZW50IERhcmRlbm5lIGNlcnRp
# ZmljYXQgcG91ciBQb3dlclNoZWxsMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKB
# gQCq1UCTb2WUuRUzvovLptY4pD61EeEJSrtTLh+cKY8i7F/ORpwrR3xtjARrTJNU
# UGh4uP/LftqkO1x++SvDMh2XC+uxtp3JG/ipvF2NPI599uef83tEpKLJG7u9vfXe
# rGYWCnmQFCT2J6wL2W70ATRPN6AVBftFX/SFUFCdHeBu9QIDAQABo4HJMIHGMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMIGuBgNVHQEEgaYwgaOAEB0w3fWBsN0e2nTMjcGF
# f8qhfTB7MXkwdwYDVQQDHnAATABhAHUAcgBlAG4AdAAgAEQAYQByAGQAZQBuAG4A
# ZQAgAGEAdQB0AG8AcgBpAHQA6QAgAGQAZQAgAGMAZQByAHQAaQBmAGkAYwBhAHQA
# aQBvAG4AIAByAGEAYwBpAG4AZQAgAGwAbwBjAGEAbABlghAb5Gp5W/j2oEZ4E3Mn
# LmpOMAkGBSsOAwIdBQADgYEANnFUDS9s9uFY0a1qflrfiaFLbnSo7mg94mZSnFj5
# cfOfxcoFDctNLtXLyYq7TlPHs2lDnVXRX4l5Yq8i828OCmSfddimEC1PQHyFDawN
# JlaBPm57o7m/iPWxkwBj2gqKLNdKk96BOLPgrpr2EigBXkTQP1PRu8/PrUZ/rCiE
# rPExggGwMIIBrAIBATCBjzB7MXkwdwYDVQQDHnAATABhAHUAcgBlAG4AdAAgAEQA
# YQByAGQAZQBuAG4AZQAgAGEAdQB0AG8AcgBpAHQA6QAgAGQAZQAgAGMAZQByAHQA
# aQBmAGkAYwBhAHQAaQBvAG4AIAByAGEAYwBpAG4AZQAgAGwAbwBjAGEAbABlAhBk
# jZH2+ynWvU0nwNAnNvXpMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSLTqEI0sszjKWX6fkKXWDk
# ZrKAAjANBgkqhkiG9w0BAQEFAASBgHXIDSTDrGuTrbVGk59GvFGHVe2DGPVDFXBf
# a9kC1a7aKE8YwOCQs11Ika5+Mvg8ujUSVQDERmeEzSX8n7AdrT8LPjrpwE+pAjTl
# YUF7AYNf2xVqK5GlYAhYom0X3Z0MO1vB5Sao3hzQSR67sPBetebhV93JlR95z6Df
# Io1Ft+i2
# SIG # End signature block
