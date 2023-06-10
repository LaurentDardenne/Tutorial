#requires -version 2.0
##########################################################################
#                               Add-Lib V2
#
# Version : 1.1.0
#
# Date    : 22 ao�t 2010
#
# Nom     : Replace-String.ps1
#
# Usage   : . .\Replace-String.ps1; Replace-String -?
#
##########################################################################
Function Replace-String{
<#
.SYNOPSIS
    Remplace toutes les occurrences d'un mod�le de caract�re, d�fini par 
    une cha�ne de caract�re simple ou par une expression r�guli�re, par une 
    cha�ne de caract�res de remplacement.
 
.DESCRIPTION
    La fonction Replace-String remplace dans une cha�ne de caract�res toutes 
    les occurrences d'une cha�ne de caract�res par une autre cha�ne de caract�res.
    Le contenu de la cha�ne recherch�e peut-�tre soit une cha�ne de caract�re 
    simple soit une expression r�guli�re. 
. 
    Le param�trage du mod�le de caract�re et de la cha�ne de caract�res de 
    remplacement se fait via une hashtable. Celle-ci permet un remplacement 
    multiple sur une m�me cha�ne de caract�res. Ces multiples remplacements se 
    font les uns � la suite des autres et pas en une seule fois.
    Chaque op�ration de remplacement re�oit la cha�ne r�sultante du 
    remplacement pr�c�dent. 

.PARAMETER InputObject
    Cha�ne � modifier.
    Peut r�f�rencer une valeur de type [Object], dans ce cas l'objet sera 
    converti en [String] sauf si le param�tre -Property est renseign�.

.PARAMETER Hashtable
    Hashtable contenant les textes � rechercher et celui de leur remplacement 
    respectif  :
     $MyHashtable."TexteARechercher"="TexteDeRemplacement"
     $MyHashtable."AncienTexte"="NouveauTexte"
    Sont autoris�es toutes les instances de classe impl�mentant l'interface 
    [System.Collections.IDictionary].
.  
. 
    Chaque entr�e de la hashtable est une paire nom-valeur :
     � Le nom contient la cha�ne � rechercher, c'est une simple cha�ne de 
       caract�res qui peut contenir une expression r�guli�re.
       Il peut �tre de type [Object], dans ce cas l'objet sera 
       converti en [String], m�me si c'est une collection d'objets.
       Si la variable $OFS est d�clar�e elle sera utilis�e lors de cette 
       conversion.
     � La valeur contient la cha�ne de remplacement et peut r�f�rencer :
        - une simple cha�ne de caract�res qui peut contenir une capture 
          nomm�e, exemple :
           $HT."(Texte)"='$1 AjoutTexteS�par�ParUnEspace'
           $HT."(Groupe1Captur�)=(Groupe2Captur�)"='$2=$1' 
           $HT."(?<NomCapture>Texte)"='${NomCapture}AjoutTexteSansEspace'
          Cette valeur peut �tre $null ou contenir une cha�ne vide.
.           
          Note : Pour utiliser '$1" comme cha�ne ce remplacement et non pas 
          comme r�f�rence � une capture nomm�e, vous devez �chapper le signe 
          dollar ainsi '$$1'.
.
        - un Scriptblock, implicitement de type [System.Text.RegularExpressions.MatchEvaluator] : 
            #Remplace le caract�re ':' par '<:>'
           $h.":"={"<$($args[0])>"}
.          
          Dans ce cas, pour chaque occurrence de remplacement trouv�e, on 
          �value le remplacement en ex�cutant le Scriptblock qui re�oit dans 
          $args[0] l'occurence trouv�e et renvoie comme r�sultat une cha�ne 
          de caract�res.
          Les conversions de cha�nes de caract�res en dates, contenues dans
          le scriptblock, se font en utilisant les informations de la 
          classe .NET InvariantCulture (US).
.          
          Note : En cas d'exception d�clench�e dans le scriptblock, 
          n'h�sitez pas � consulter le contenu de son membre nomm� 
          InnerException. 
.
        -une hashtable, les cl�s reconnues sont :
           -- Replace  Contient la valeur de remplacement.
                       Une cha�ne vide est autoris�e, mais pas la valeur 
                       $null.
                       Cette cl� est obligatoire.
                       Son type est [String] ou [ScriptBlock].
.                       
           -- Max      Nombre maximal de fois o� le remplacement aura lieu. 
                       Sa valeur par d�faut est -1 (on remplace toutes les
                       occurrences trouv�es) et ne doit pas �tre inf�rieure
                       � -1.
                       Pour une valeur $null ou une cha�ne vide on affecte 
                       la valeur par d�faut.
.                       
                       Cette cl� est optionnelle et s'applique uniquement 
                       aux expressions r�guli�res.
                       Son type est [Integer], sinon une tentative de 
                       conversion est effectu�e. 
.
           -- StartAt  Position du caract�re, dans la cha�ne d'entr�e, o� 
                       la recherche d�butera.
                       Sa valeur par d�faut est z�ro (d�but de cha�ne) et 
                       doit �tre sup�rieure � z�ro.
                       Pour une valeur $null ou une cha�ne vide on affecte 
                       la valeur par d�faut.
.                       
                       Cette cl� est optionnelle et s'applique uniquement 
                       aux expressions r�guli�res.
                       Son type est [Integer], sinon une tentative de 
                       conversion est effectu�e. 
.
           -- Options  L'expression r�guli�re est cr��e avec les options 
                       sp�cifi�es.
                       Sa valeur par d�faut est "IgnoreCase" (la correspondance 
                       ne respecte pas la casse).
                       Si vous sp�cifiez cette cl�, l'option "IgnoreCase" 
                       est �cras�e par la nouvelle valeur.
                       Pour une valeur $null ou une cha�ne vide on affecte 
                       la valeur par d�faut.
                       Peut contenir une valeur de type [Object], dans ce 
                       cas l'objet sera converti en [String]. Si la variable
                       $OFS est d�clar�e elle sera utilis�e lors de cette 
                       conversion.
.                       
                       Cette cl� est optionnelle et s'applique uniquement
                       aux expressions r�guli�res.
                       Son type est [System.Text.RegularExpressions.RegexOptions].
.
                       Note: En lieu et place de cette cl�/valeur, il est 
                       possible d'utiliser une construction d'options inline 
                       dans le corps de l'expression r�guli�re (voir un des 
                       exemples).
                       Ces options inlines sont prioritaires et 
                       compl�mentaires par rapport � celles d�finies par 
                       cette cl�.                
.                       
         Si la hashtable ne contient pas de cl� nomm�e 'Replace', la fonction 
         �met une erreur non-bloquante. 
         Si une des cl�s 'Max','StartAt' et 'Options' est absente, elle est 
         ins�r�e avec sa valeur par d�faut.
         La pr�sence de noms de cl�s inconnues ne provoque pas d'erreur.
.
         Rappel : Les r�gles de conversion de .NET s'appliquent.
         Par exemple pour :
          [double] $Start=1,6
          $h."a"=@{Replace="X";StartAt=$Start}
         o� $Start contient une valeur de type [Double], celle-ci sera 
         arrondie, ici � 2.         

.PARAMETER ReplaceInfo
    Indique que la fonction retourne un objet personnalis� [PSReplaceInfo].
    Celui-ci contient les membres suivants :  
     -[ArrayList] Replaces  : Contient le r�sultat d'ex�cution de chaque 
                              entr�e du param�tre -Hashtable. 
     -[Boolean]   isSuccess : Indique si un remplacement a eu lieu, que 
                              $InputObject ait un contenu diff�rent ou pas.
     -            Value     : Contient la valeur de retour de $InputObject,
                              qu'il y ait eu ou non de modifications .
.
    Le membre Replaces contient une liste d'objets personnalis�s de type 
    [PSReplaceInfoItem]. A chaque cl� du param�tre -Hashtable correspond 
    un objet personnalis�.
    L'ordre d'insertion dans la liste suit celui de l'ex�cution.
.    
    PSReplaceInfoItem contient les membres suivants :
      - [String]  Old       : Contient la ligne avant la modification.
                              Si -Property est pr�cis�, ce champ contiendra 
                              toujours $null.
      - [String]  New       : Si le remplacement r�ussi, contient la ligne 
                              apr�s la modification, sinon contient $null.
                              Si -Property est pr�cis�, ce champ contiendra 
                              toujours $null.
      - [String]  Pattern   : Contient le pattern de recherche.
      - [Boolean] isSuccess : Indique s'il y a eu un remplacement.
                              Dans le cas o� on remplace une occurrence 'A' 
                              par 'A', une expression r�guli�re permet de
                              savoir si un remplacement a eu lieu, m�me � 
                              l'identique. Si vous utilisez -SimpleReplace 
                              ce n'est plus le cas, cette propri�t� contiendra 
                              $false.   
    Notez que si le param�tre -Property est pr�cis�, une seule op�ration sera 
    enregistr�e dans le tableau Replaces, les noms des propri�t�s trait�es 
    ne sont pas m�moris�s.       
.
    Note : 
    Attention � la consommation m�moire si $InputObject est une cha�ne de
    caract�re de taille importante.
    Si vous m�morisez le r�sultat dans une variable, l'objet contenu dans
    le champ PSReplaceInfo.Value sera toujours r�f�renc�.
    Pensez � supprimer rapidement cette variable afin de ne pas retarder la 
    lib�ration automatique des objets r�f�renc�s.      

.PARAMETER Property
    Sp�cifie le ou les noms des propri�t�s d'un objet concern�es lors du 
    remplacement. Seules sont trait�s les propri�t�s de type [string] 
    poss�dant un assesseur en �criture (Setter).
    Pour chaque propri�t� on effectue tous les remplacements pr�cis�s dans 
    le param�tre -Hashtable, tout en tenant compte de la valeur des param�tres
    -Unique et -SimpleReplace.
    On r��met l'objet re�u, apr�s avoir modifi� les propri�t�s indiqu�es.
    Le param�tre -Inputobject n'est donc pas converti en type [String].
    Une erreur non-bloquante sera d�clench�e si l'op�ration ne peut aboutir.
.     
    Les jokers sont autoris�s dans les noms de propri�t�s.
    Comme les objets re�us peuvent �tre de diff�rents types, le traitement 
    des propri�t�s inexistante ne g�n�re pas d'erreur.   
         
.PARAMETER Unique
    Pas de recherche/remplacement multiple.
.
    L'ex�cution ne concerne qu'une seule op�ration de recherche et de 
    remplacement, la premi�re qui r�ussit, m�me si le param�tre -Hashtable 
    contient plusieurs entr�es.
    Si le param�tre -Property est pr�cis�, l'op�ration unique se fera sur 
    toutes les propri�t�s indiqu�es.
    Ce param�tre ne remplace pas l'information pr�cis�e par la cl� 'Max'. 
.
    Note : La pr�sence du switch -Whatif influence le comportement du switch 
    -Unique. Puisque -Whatif n'effectue aucun traitement, on ne peut pas 
    savoir si un remplacement a eu lieu, dans ce cas le traitement de 
    toutes les cl�s sera simul�.
    
.PARAMETER SimpleReplace
    Utilise une correspondance simple plut�t qu'une correspondance d'expression 
    r�guli�re. La recherche et le remplacement utilisent la m�thode 
    String.Replace() en lieu et place d'une expression r�guli�re.
    ATTENTION cette derni�re m�thode effectue une recherche de mots en 
    respectant la casse et tenant compte de la culture.
.    
    L'usage de ce switch ne permet pas d'utiliser toutes les fonctionnalit�s 
    du param�tre -Hashtable, ex :  @{Replace="X";Max=n;StartAt=n;Options="Compiled"}. 
    Si vous couplez ce param�tre avec ce type de hashtable, seule la cl� 
    'Replace' sera prise en compte. 
    Un avertissement est g�n�r�, pour l'�viter utiliser le param�trage 
    suivant :
     -WarningAction:SilentlyContinue #bug en v2
     ou
     $WarningPreference="SilentlyContinue"

.EXAMPLE
    $S= "Caract�res : 33 \d\d"
    $h=@{}
    $h."a"="?"
    $h."\d"='X'
    Replace-String -i $s $h 
.        
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la cha�ne $S, 
    elles remplacent toutes les lettres 'a' par le caract�re '?' et tous 
    les chiffres par la lettre 'X'.
.
    La hashtable $h contient deux entr�es, chaque cl� est utilis�e comme 
    �tant la cha�ne � rechercher et la valeur de cette cl� est utilis�e 
    comme cha�ne de remplacement. Dans ce cas on effectue deux op�rations 
    de remplacement sur chaque cha�ne de caract�re re�u. 
.       
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
    C?r?ct�res : XX \d\d
. 
.         
    La hashtable $H contenant deux entr�es, Replace-String effectuera deux 
    op�rations de remplacement sur la cha�ne $S. 
.    
    Ces deux op�rations sont �quivalentes � la suite d'instructions suivantes :
    $Resultat=$S -replace "a",'?'
    $Resultat=$Resultat -replace "\d",'X'
    $Resultat
    
.EXAMPLE
    $S= "Caract�res : 33 \d\d"
    $h=@{}
    $h."a"="?"
    $h."\d"='X'
    Replace-String -i $s $h -SimpleReplace
.        
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la cha�ne $S, 
    elles remplacent toutes les lettres 'a' par le caract�re '?', tous les 
    chiffres ne seront pas remplac�s par la lettre 'X', mais toutes les 
    combinaisons de caract�res "\d" le seront, car le switch SimpleReplace 
    est pr�cis�. Dans ce cas, la valeur de la cl� est consid�r�e comme une 
    simple cha�ne de caract�res et pas comme une expression r�guli�re. 
.    
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
    C?r?ct�res : 33 XX
.         
    La hashtable $H contenant deux entr�es, Replace-String effectuera deux 
    op�rations de remplacement sur la cha�ne $S. 
.    
    Ces deux op�rations sont �quivalentes � la suite d'instructions suivantes :
    $Resultat=$S.Replace("a",'?')
    $Resultat=$Resultat.Replace("\d",'X')
    $Resultat    
     #ou 
    $Resultat=$S.Replace("a",'?').Replace("\d",'X')
    
.EXAMPLE
    $S= "Caract�res : 33"
    $h=@{}
    $h."a"="?"
    $h."\d"='X'
    Replace-String -i $s $h -Unique 
. 
    Description
    -----------
    Ces commandes effectuent un seul remplacement dans la cha�ne $S, elles 
    remplacent toutes les lettres 'a' par le caract�re '?'.
. 
    L'usage du param�tre -Unique arr�te le traitement, pour l'objet en cours, 
    d�s qu'une op�ration de recherche et remplacement r�ussit.
.    
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
    C?r?ct�res : 33 

.EXAMPLE
    $S= "Caract�res : 33"
    $h=@{}
    $h."a"="?"
     #Substitution � l'aide de capture nomm�e
    $h."(?<Chiffre>\d)"='${Chiffre}X'
    $S|Replace-String $h 
    
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la cha�ne $S, 
    elles remplacent toutes les lettres 'a' par le caract�re '?' et tous 
    les chiffres par la sous-cha�ne trouv�e, correspondant au groupe 
    (?<Chiffre>\d), suivie de la lettre 'X'.
.
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
    C?r?ct�res : 3X3X   
.
    L'utilisation d'une capture nomm�e, en lieu et place d'un num�ro de 
    groupe, comme $h."\d"='$1 X', �vite de s�parer le texte du nom de groupe 
    par au moins un caract�re espace.
    Le parsing par le moteur des expressions r�guli�res reconnait $1, mais 
    pas $1X.      
    
.EXAMPLE
    $S= "Caract�res : 33"
    $h=@{}
    $h."a"="?"
    $h."(?<Chiffre>\d)"='${Chiffre}X'
    $h.":"={ Write-Warning "Call delegate"; return "<$($args[0])>"}    
    $S|Replace-String $h 
    
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la cha�ne $S, 
    elles remplacent :
     -toutes les lettres 'a' par le caract�re '?', 
     -tous les chiffres par la sous-cha�ne trouv�e, correspondant au groupe
     (?<Chiffre>\d), suivie de la lettre 'X', 
     -et tous les caract�res ':' par le r�sultat de l'ex�cution du 
     ScriptBlock {"<$($args[0])>"}.
.
    Le Scriptblock est implicitement cast� en un d�l�gu� du type 
    [System.Text.RegularExpressions.MatchEvaluator]. 
.
    Son usage permet, pour chaque occurrence trouv�e, d'�valuer le remplacement 
    � l'aide d'instructions du langage PowerShell.
    Son ex�cution renvoie comme r�sultat une cha�ne de caract�res.
    Il est possible d'y r�f�rencer des variables globales (voir les r�gles 
    de port�e de PowerShell) ou l'objet r�f�renc� par le param�tre 
    $InputObject.
.                
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
    C?r?ct�res <:> 3X3X          
       
.EXAMPLE
    $S= "CAract�res : 33"
    $h=@{}
    $h."a"=@{Replace="?";StartAt=3;Options="IgnoreCase"} 
    $h."\d"=@{Replace='X';Max=1}
    $S|Replace-String $h 
    
    Description
    -----------
    Ces commandes effectuent un remplacement multiple dans la cha�ne $S.
    On param�tre chaque expression r�guli�re � l'aide d'une hashtable 
    'normalis�e'.
.    
    Pour l'expression r�guli�re "a" on remplace toutes les lettres 'a', 
    situ�es apr�s le troisi�me caract�re, par le caract�re '?'. La recherche
    est insensible � la casse, on ne tient pas compte des majuscules et de 
    minuscules, les caract�res 'A' et 'a' sont concern�s.
    Pour l'expression r�guli�re "\d" on remplace un seul chiffre, le premier 
    trouv�, par la lettre 'X'.               
.
    Pour les cl�s de la hashtable 'normalis�e' qui sont ind�finies, on 
    utilisera les valeurs par d�faut. La seconde cl� est donc �gale � :
     $h."\d"=@{Replace='X';Max=1;StartAt=0;Options="IgnoreCase"}
.        
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
    CAr?ct�res : X3
    
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
    Ces deux exemples effectuent un remplacement multiple dans la cha�ne $S.
    Les �l�ments d'une hashtable, d�clar�e par @{}, ne sont par ordonn�s, ce 
    qui fait que l'ordre d'ex�cution des expressions r�guli�res peut ne pas 
    respecter celui de l'insertion.
.
    Dans le premier exemple, cela peut provoquer un effet de bord. Si on 
    ex�cute les deux expressions r�guli�res, la seconde modifie �galement 
    la seconde occurrence du terme 'Date' qui a pr�c�demment �t� ins�r�e 
    lors du remplacement de l'occurrence du terme 'mot'.
    Dans ce cas, on peut utiliser le switch -Unique afin d'�viter cet effet 
    de bord ind�sirable.
.
    Le second exemple utilise une hashtable ordonn�e qui nous assure d'
    ex�cuter les expressions r�guli�res dans l'ordre de leur insertion.
.
    Les r�sultats, de type cha�ne de caract�res, sont respectivement : 
    ( NomJour nn NomMois ann�e ) Test d'effet de bord : modification de NomJour nn NomMois ann�e  
    ( NomJour nn NomMois ann�e ) Test d'effet de bord : modification de Date  

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
     #On �chappe le caract�re di�se(#)
    $od.'(?im-s)^\s*\#\s*Version\s*:(.*)$'=$Version
    # �quivalent � :
    #$od.'^\s*\#\s*Version\s*:(.*)$'=@{Replace=$Version;Options="IgnoreCase,MultiLine"} 
    $LongDatePattern=[System.Threading.Thread]::CurrentThread.CurrentCulture.DateTimeFormat.LongDatePattern
    $od.'(?im-s)^\s*\#\s*Date\s*:(.*)$'="# Date    : $(Get-Date -format $LongDatePattern)"
    $S|Replace-String $od
   
    Description
    -----------
    Ces instructions effectuent un remplacement multiple dans la cha�ne $S.
    On utilise une construction d'options inline '(?im-s)', celle-ci active 
    l'option 'IgnoreCase' et 'Multiline', et d�sactive l'option 'Singleline'.
    Ces options inlines sont prioritaires et compl�mentaires par rapport � 
    celles d�finies dans la cl� 'Options' d'une entr�e du param�tre 
    -Hashtable.
.
    La Here-String $S est une cha�ne de caract�res contenant des retours 
    chariot(CR+LF), on doit donc sp�cifier le mode multiligne (?m) qui 
    modifie la signification de ^ et $ dans l'expression r�guli�re, de 
    telle sorte qu'ils correspondent, respectivement, au d�but et � la fin 
    de n'importe quelle ligne et non simplement au d�but et � la fin de la 
    cha�ne compl�te.
.    
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
# Version : 1.2.1
#
# Date    : NomDeJour xx NomDeMois Ann�e 
.
.   Note :  
    Sous PS v2, un bug fait qu'une nouvelle ligne dans une Here-String est 
    repr�sent�e par l'unique caract�re "`n" et pas par la suite de caract�res 
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
    Ces instructions effectuent un remplacement simple dans la cha�ne $S.
    On utilise ici Replace-String pour g�n�rer un script batch � partir
    d'un template (gabarit ou mod�le de conception).
    Toutes les occurrences du texte '#SID#' sont remplac�es par la cha�ne 
    'BaseTest'. Le r�sultat de la fonction est un objet personnalis� de type
    [PSReplaceInfo].
.
    Ce r�sultat peut �tre �mis directement vers le cmdlet Set-Content, car 
    le membre 'Value' de la variable $Result est automatiquement li� au 
    param�tre -Value du cmdlet Set-Content.  

.EXAMPLE
    $S="Un petit deux-roues, c'est trois fois rien."
    $Alternatives=@("un","deux","trois")
     #En regex '|' est le m�tacaract�re 
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
    Ces instructions effectuent un remplacement multiple dans la cha�ne $S.
    On utilise ici un tableau de cha�nes qui se seront transform�es, � 
    l'aide de la variable PowerShell $OFS, en une cha�ne d'expression 
    r�guli�re contenant une alternative "un|deux|trois". On lui associe un 
    Scriptblock dans lequel on d�terminera, selon l'occurrence trouv�e, la 
    valeur correspondante � renvoyer.
.    
    Le r�sultat, de type cha�ne de caract�res, est �gal � : 
    1 petit 2-roues, c'est 3 fois rien.

.EXAMPLE
     #Param�trage
    $NumberVersion="1.2.1"
    $Version="# Version : $Numberversion"
     #La date est substitu�e une seule fois lors
     #de la cr�ation de la hashtable. 
    $Modifications= @{
       "^\s*\#\s*Version\s*:(.*)$"=$Version;
       '^\s*\#\s*Date\s*:(.*)$'="# Date    : $(Get-Date -format 'd MMMM yyyy')"
    }
    $RunWinMerge=$False
    
    #Fichiers de test :
    # http://projets.developpez.com/projects/add-lib/files
    
    cd "C:\Temp\Replace-String\TestReplace"
     #Cherche et remplace dans tous les fichiers d'une arborescence, sauf les .bak
     #Chaque fichier est recopi� en .bak avant les modifications
    Get-ChildItem "$PWD" *.ps1 -exclude *.bak -recurse| 
     Where-Object {!$_.PSIsContainer} |
     ForEach-Object {
       $CurrentFile=$_ 
       $BackupFile="$($CurrentFile).bak" 
       Copy-Item $CurrentFile $BackupFile 
       
       Get-Content $BackupFile|
        Replace-String $Modifications|
        Set-Content -path $CurrentFile
       
        #compare le r�sultat � l'aide de Winmerge
      if ($RunWinMerge)
       {Microsoft.PowerShell.Management\start-process  "C:\Program Files\WinMerge\WinMergeU.exe" -Argument "/maximize /e /s /u $BackupFile $CurrentFile"  -wait}  
    } #foreach

    Description
    -----------
    Ces instructions effectuent un remplacement multiple sur le contenu 
    d'un ensemble de fichiers '.ps1'.
    On remplace dans l'ent�te de chaque fichier le num�ro de version et la 
    date. Avant le traitement, chaque fichier .ps1 est recopi� en .bak dans
    le m�me r�pertoire. Une fois le traitement d'un fichier effectu�, on 
    peut visualiser les diff�rences � l'aide de l'utilitaire WinMerge.   

.EXAMPLE
    $AllObjects=dir Variable:
    $AllObjects| Ft Name,Description|More
      $h=@{}
      $h."^$"={"Nouvelle description de la variable $($InputObject.Name)"}
       #PowerShell V2 FR
      $h."(^Nombre|^Indique|^Entra�ne)(.*)$"='POWERSHELL $1$2'
      $Result=$AllObjects|Replace-String $h -property "Description" -ReplaceInfo -Unique
    $AllObjects| Ft Name,Description|More  

    Description
    -----------
    Ces instructions effectuent un remplacement unique sur le contenu d'une 
    propri�t� d'un objet, ici de type [PSVariable].
    La premi�re expression r�guli�re recherche les objets dont la propri�t� 
    'Description', de type [string], n'est pas renseign�e. 
    La seconde modifie celles contenant en d�but de cha�ne un des trois mots 
    pr�cis�s dans une alternative. La cha�ne de remplacement reconstruit le 
    contenu en ins�rant le mot 'PowerShell' en d�but de cha�ne.
.    
    Le contenu de la propri�t� 'Description' d'un objet de type 
    [PSVariable] n'est pas persistant, cette op�ration ne pr�sente donc 
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
    La premi�re instruction cr�e une sauvegarde des informations de la ruche 
    'HKEY_CURRENT_USER\Environment', la seconde charge la sauvegarde dans
    une nouvelle ruche nomm�e 'HKEY_USer\PowerShell_TEST' et la troisi�me 
    cr�e un drive PowerShell nomm� 'Test'.
.
    Les instructions suivantes r�cup�rent les cl�s de registre et leurs 
    valeurs. � partir de celles-ci on cr�e autant d'objets personnalis�s 
    qu'il y a de cl�s. Les noms des membres de cet objet personnalis� 
    correspondent � des noms de param�tres du cmdlet Set-ItemProperty qui 
    acceptent l'entr�e de pipeline (ValueFromPipelineByPropertyName). 
.   
    Ensuite, � l'aide de Replace-String, on recherche et remplace dans la 
    propri�t� 'Value' de chaque objet cr��, les occurrences de 'C:\' par 
    'D:\'. 
    Replace-String �met directement les objets vers le cmdlet 
    Set-ItemProperty.
    Et enfin, celui-ci lit les informations � mettre � jour � partir des 
    propri�t�s de l'objet personnalis� re�u.
.
    Pour terminer, on supprime le drive PowerShell et on d�charge la ruche 
    de test.
    Note:
     Sous PowerShell l'usage de Set-ItemProperty (� priori) emp�che la 
     lib�ration de la ruche charg�e, on obtient l'erreur 'Access Denied'.
     Pour finaliser cette op�ration, on doit fermer la console PowerShell 
     et ex�cuter cmd.exe afin d'y lib�rer correctement la ruche :
      Cmd /k "REG UNLOAD HKU\PowerShell_TEST"        
 
.INPUTS
    System.Management.Automation.PSObject
     Vous pouvez diriger tout objet ayant une m�thode ToString vers 
     Replace-String.

.OUTPUTS
    System.String
    System.Object
    System.PSReplaceInfo 

     Replace-String retourne tous les objets qu'il soient modifi�s ou pas.

.NOTES
    Vous pouvez consulter la documentation Fran�aise sur les expressions
    r�guli�res, via les liens suivants :
.   
    Options des expressions r�guli�res  : 
     http://msdn.microsoft.com/fr-fr/library/yd1hzczs(v=VS.80).aspx
     http://msdn.microsoft.com/fr-fr/library/yd1hzczs(v=VS.100).aspx
.    
    �l�ments du langage des expressions r�guli�res :
     http://msdn.microsoft.com/fr-fr/library/az24scfc(v=VS.80).aspx
.
    Compilation et r�utilisation de regex :
     http://msdn.microsoft.com/fr-fr/library/8zbs0h2f(vs.80).aspx     
.
.
    Au coeur des dictionnaires en .Net 2.0 :
     http://mehdi-fekih.developpez.com/articles/dotnet/dictionnaires
.
    Outil de cr�ation d'expression r�guli�re, info et Tips
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
    expression r�guli�re
    
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
           #si on n'utilise pas le pipe on doit pr�ciser son nom -InputObject ou -I
           #le param�tre suivant sera consid�r� comme �tant en position 0, car innomm� 
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
     #Section DATA + ConvertFrom-StringData probl�me d'analyse avec le caract�re = 
    $TextMsgs =@{ 
                                         #fr-FR
       WellFormedKeyNullOrEmptyValue  = "La cl� n'existe pas ou sa valeur est `$null"
       WellFormedInvalidCast          = "La valeur de la cl� {0} ne peut pas �tre convertie en {1}."
       WellFormedInvalidValueNotLower = "La valeur de la cl� ne peut pas �tre inf�rieur � -1."
       WellFormedInvalidValueNotZero  = "La valeur de la cl� doit �tre sup�rieure � z�ro."
       ReplaceSimpleEmptyString       = "L'option SimpleReplace ne permet pas une cha�ne de recherche vide."
       ReplaceRegExCreate             = "[Construction de regex] {0}"
       ReplaceRegExStarAt             = "{0}`r`nStartAt({1}) est sup�rieure � la longueur de la cha�ne({2})"
       ReplaceObjectPropertyNotString = "La propri�t� n'est pas du type string."
       ReplaceObjectPropertyReadOnly = "La propri�t� est en lecture seule."
       #ReplaceRegexObjectPropertyError  = $_.Exception.Message
       #ReplaceStringObjectPropertyError = $_.Exception.Message
       #StringReplaceRegexError          = $_.Exception.Message
       ReplaceSimpleScriptBlockError  = "{0}={{{1}}}`r`n{2}"
       ObjectReplaceShouldProcess     = "Objet [{0}] Propri�t�: {1}"
       StringReplaceShouldProcess     = "{0} par {1}"
       WarningSwitchSimpleReplace     = "Le switch SimpleReplace n'utilise pas toutes les fonctionnalit�s d'une hashtable de type @{Replace='X';Max=n;StartAt=n,Options='Y'}.`r`n Utilisez une simple cha�ne de caract�res."
       WarningConverTo                = "La conversion, par ConverTo(), renvoi une cha�ne vide.`r`n{0}"
       
    } #TextMsgs
   
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
   
     Function Test-InputObjectProperty($CurrentProperty) {
      #Valide les pr�requis d'une propri�t� d'objet
      #Doit exister, �tre de type [String] et �tre en �criture.
         #On ne traite que les propri�t�s de type [string]
       if ($CurrentProperty.TypeNameOfValue -ne "System.String")
        {throw (New-Object System.ArgumentException($TextMsgs.ReplaceObjectPropertyNotString,$CurrentProperty.Name)) }                       
         #On ne traite que les propri�t�s proposant un setter
       if (-not $CurrentProperty.IsSettable)
        {throw (New-Object System.ArgumentException($TextMsgs.ReplaceObjectPropertyReadOnly,$CurrentProperty.Name)) } 
     }#Test-InputObjectProperty
     
    function ConvertTo-String($Value){
       #Conversion PowerShell
       #Par exemple converti $T=@("un","Deux") en "un deux"
       # ce qui est �quivalent � "$T"
       #Au lieu de System.Object[] si on utilise $InputObject.ToString()
       #De plus un PSObject peut ne pas avoir de m�thode ToString()
     [System.Management.Automation.LanguagePrimitives]::ConvertTo($Value,
                                                                   [string],
                                                                   [System.Globalization.CultureInfo]::InvariantCulture)
    }#ConvertTo-String
    
    function Convert-DictionnaryEntry($Parameters) 
    {   #Converti un DictionnaryEntry en une string "cl�=valeur cl�=valeur..." 
      "$($Parameters.GetEnumerator()|% {"$($_.key)=$($_.value)"})"
    }#Convert-DictionnaryEntry
  
    function New-ObjectReplaceInfo{ 
       #Cr�e un objet contenant le r�sultat d'un remplacement
       #Permet d'�mettre la cha�ne modifi�e et de savoir si 
       # une modification a eu lieu.
      $Result=New-Object PSObject -Property @{
         #Contient le r�sultat d'ex�cution de chaque entr�e
        Replaces=New-Object System.Collections.ArrayList(6)
         #Indique si $InputObject a �t� modifi� ou non 
        isSuccess=$False
         #Contient la valeur de retour de $InputObject,
         #qu'il ait �t� modifi� ou non. 
        Value=$Null 
      }
     $Result.PsObject.TypeNames[0] = "PSReplaceInfo"
     $Result
    }#New-ObjectReplaceInfo
  
    function isParameterWellFormed($Parameters) {
     #Renvoi true si l'entr�e de hashtable $Parameters est correcte
     #la recherche pr�liminaire par ContainsKey est dict� par la possible 
     #d�claration de set-strictmode -version 2.0
    #Replace 
      if (-not $Parameters.ContainsKey('Replace') -or ($Parameters.Replace -eq $null))
      {  #[string]::Empty est valide, m�me pour la cl�
  			 $PSCmdlet.WriteError(
          (New-Object System.Management.Automation.ErrorRecord(
              #inverse nomParam,msg 
     				 (New-Object System.ArgumentNullException('Replace',$TextMsgs.WellFormedKeyNullOrEmptyValue)), 
               "WellFormedKeyNullOrEmptyValue", 
               "InvalidData",
               $ParameterString # Si $ErrorView="CategoryView" l'information est affich�e
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
          #La pr�sence d'espaces ne g�ne pas la conversion.
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
            #Analyse la valeur de l'entr�e courante de $Hashtable
            #puis la transforme en un type hashtable 'normalis�e' 
         if ($Parameters -is [System.Collections.IDictionary])
          {  #On ne modifie pas la hashtable d'origine
             #Les objets r�f�renc�s ne sont pas clon�, on duplique l'adresse.
            $Parameters=$Parameters.Clone()
            
            $ParameterString="$($_.Key) = @{$(Convert-DictionnaryEntry $Parameters)}"
            $WrongDictionnaryEntry=-not (isParameterWellFormed $Parameters)
            if ($WrongDictionnaryEntry -and ($DebugPreference -eq "Continue"))
            { $PSCmdlet.WriteDebug("[DictionaryEntry][Error]$ParameterString")}
            
            if ($SimpleReplace) 
             { $PSCmdlet.WriteWarning($TextMsgs.WarningSwitchSimpleReplace) }  
          }#-is [System.Collections.IDictionary] 
         else 
          {   #Dans tous les cas on utilise une hashtable normalis�e
              #pour r�cup�rer les param�tres.
             if ($Parameters -eq $null)
              {$Parameters=[String]::Empty}  
             $Parameters=@{Replace=$Parameters;Max=-1;StartAt=0;Options="IgnoreCase"}
          } 

         if  ($_.Key -isnot [String])
          { 
             #La cl� peut �tre un objet,
             #on tente une conversion de la cl� en [string].
             #On laisse la possibilit� de dupliquer les cl�s
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
                 #Construit une expression r�guli�re dont le pattern est 
                 #le nom de la cl� de l'entr�e courante de $TabKeyValue
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
                 $PSCmdlet.WriteDebug("Regex erron�e, remplacement suivant.")
                 $RegExError=$True 
               }
             }
            if (-not $RegExError)
               #Si on utilise un simple arraylist 
               # les propri�t�s personnalis�es sont perdues
             { [void]$TabKeyValue.Add($DEntry) }
          } #sinon on ne cr�e pas l'entr�e invalide
       }#Foreach       
    }#BuildList
    
    $PSCmdlet.WriteDebug("ParameterSetName :$($PsCmdlet.ParameterSetName)")  
     #Manipule-t-on une cha�ne ou un objet ?
    [Switch] $AsObject= $PSBoundParameters.ContainsKey('Property')
    $PSCmdlet.WriteDebug("AsObject: $AsObject")
    
     #On doit explicitement rechercher 
     #la pr�sence des param�tres communs
    [Switch] $Whatif= $null
    [void]$PSBoundParameters.TryGetValue('Whatif',[REF]$Whatif)
    
    $PSCmdlet.WriteDebug("Whatif: $WhatIf")
    $PSCmdlet.WriteDebug("ReplaceInfo: $ReplaceInfo")
     if ($AsObject) # Si set-strictmode -version 2.0 
      {$PSCmdlet.WriteDebug("Properties : $Property")} 
    
      #On construit une liste afin de filtrer les �l�ments invalides
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
    #Si $TabKeyValue ne contient aucun �l�ment,
    #on construit tout de m�me l'object ReplaceInfo 
     
    if ($InputObject -isnot [String]) 
    {  #Si on ne manipule pas les propri�t�s d'un objet,
       #on force la conversion en [string]. 
      if ($AsObject -eq $false)
       {
         $ObjTemp=$InputObject
         [string]$InputObject= ConvertTo-String $InputObject
         If ($InputObject -eq [String]::Empty)
          { $PSCmdlet.WriteWarning(($TextMsgs.WarningConverTo -F $ObjTemp))}   
       } 
    }
     #on cr�e l'objet contenant 
     #la collection de r�sultats d�taill�s
    if ($ReplaceInfo)
     {$Resultat=New-ObjectReplaceInfo}  
    
     #Savoir si au moins une op�ration de remplacement a r�ussie.
    [Boolean] $AllSuccessReplace=$false     
    
    for ($i=0; $i -lt $TabKeyValue.Count; $i++) {
       #$Key contient la cha�ne � rechercher
      $Key=$TabKeyValue[$i].Key

       #$parameters contient les informations de remplacement
      $Parameters=$TabKeyValue[$i].Value
      
       #L'op�ration de remplacement courante a-t-elle r�ussie ?
      [Boolean] $CurrentSuccessReplace=$false
      
      if ($ReplaceInfo)
       {  #Cr�e, pour la cl� courante, un objet r�sultat 
         if ($AsObject)
            #on ne cr�e pas de r�f�rence sur l'objet, 
            #car les champs Old et New pointe sur le m�me objet.
            #Seul les champs pattern et Key sont renseign�s.  
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
      {  #R�cup�re la cha�ne de remplacement
        if ($Parameters.Replace -is [ScriptBlock]) 
         { try {
              #$ReplaceValue contiendra la cha�ne de remplacement
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
         
          #On traite des propri�t�s d'un objet
        if ($AsObject)  
         { 
            $Property|
              #pr�requis: Le nom de la propri�t� courante ne pas doit pas �tre null ni vide.
              #On recherche les propri�t�s � chaque fois, on laisse ainis la possibilit� au 
              # code d'un scriptblock de modifier/ajouter des propri�t�s dynamiquement sur 
              # le param�tre $InputObject.
              #Celui-ci doit �tre de type PSObject pour �tre modifi� directement, sinon
              #seul l'objet renvoy� sera concern�. 
             Foreach-object {
                $PSCmdlet.WriteDebug("[Traitement des wildcards] $_")
                # Ex : Pour PS* on r�cup�re plusieurs propri�t�s
                #La liste contient toutes les propri�t�s ( .NET + PS).
                #Si la propri�t� courante ne match pas, on it�re sur les �l�ments de $Property 
               $InputObject.PSObject.Properties.Match($_)|
               Foreach-Object { 
                  $PSCmdlet.WriteDebug("[Wildcard property]$_")
                  $CurrentProperty=$_
                  $CurrentPropertyName=$CurrentProperty.Name
                  try {
                      #Si -Whatif n'est pas pr�cis� on ex�cute le traitement
                    if ($PSCmdlet.ShouldProcess(($TextMsgs.ObjectReplaceShouldProcess -F $InputObject.GetType().Name,$CurrentPropertyName)))
                     {                     
                        #Logiquement il ne devrait y avoir qu'un bloc ShouldProcess
                        #englobant tous les traitements, ici cela permet d'afficher 
                        #le d�tails des op�rations imbriqu�es tout en pr�cisant 
                        #les valeurs effectives utilis�es lors du remplacement. 
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
                      #La propri�t� est en R/O,
                      #La propri�t� n'est pas du type String, etc. 
                      
                      #Par d�faut recr�e l'exception trapp�e avec un message personnalis� 
                     $PSCmdlet.WriteError(
                      (New-Object System.Management.Automation.ErrorRecord (
                           #Recr�e l'exception trapp�e avec un message personnalis� 
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
         
         #R�cup�re la cha�ne de remplacement
        if  (($Parameters.Replace -isnot [String]) -and ($Parameters.Replace -isnot [ScriptBlock])) 
         {
             #Appel soit 
             #  Regex.Replace (String, String, Int32, Int32)  
             # soit
             #  Regex.Replace (String, MatchEvaluator, Int32, Int32)
             # 
             #On �vite, selon le type du param�tre fourni, un possible probl�me 
             #de cast lors de l'ex�cution interne de la recherche de la signature 
             #la plus adapt�e (Distance Algorithm). 
             # cf. ([regex]"\d").Replace.OverloadDefinitions 
             # "test 123"|Replace-String @{"\d"=get-date}
             # Error : Impossible de convertir l'argument ��1�� (valeur ��17/07/2010 13:31:56��) de ��Replace�� 
             #  en type ��System.Text.RegularExpressions.MatchEvaluator���
             #
             #InvalidCastException :
             #Cette exception se produit lorsqu'une conversion particuli�re n'est pas prise en charge.
             #Un InvalidCastException est lev� pour les conversions suivantes :
             # - Conversions de DateTime en tout autre type sauf String.
             # ...
             #Autre solution :
             # "test 123"|Replace-String @{"\d"=@(get-date)}
             #Mais cette solution apporte un autre probl�me, dans ce cas on utilise plus la culture courante,
             # mais celle US, car le scriptblock est ex�cut� dans un contexte o� les conversions de cha�nes de 
             #caract�res en dates se font en utilisant les informations de la classe .NET InvariantCulture.
             #cf. http://janel.spaces.live.com/blog/cns!9B5AA3F6FA0088C2!185.entry      
           $PSCmdlet.WriteDebug( "`t[ConverTo] $($Parameters.Replace.GetType())")
           [string]$ReplaceValue=ConvertTo-String $Parameters.Replace
         } #Replace via RegEx
        else 
         {$ReplaceValue=$Parameters.Replace }

          #On traite des propri�t�s d'un objet
        if ($AsObject)
         { 
            $Property|
               # Le nom de la propri�t� courante ne pas doit pas �tre null ni vide.
              Foreach-object {
                $PSCmdlet.WriteDebug("[Traitement des wildcards]$_")
                # Ex : Pour PS* on r�cup�re plusieurs propri�t�s 
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
                            #On ne peut rechercher au del� de la longueur de la cha�ne.
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
                         #On ne m�morise pas les infos de remplacement (replaceInfo) pour les propri�t�s,
                         #seulement pour les cl�s (pattern)
                        if (-not $CurrentSuccessReplace)
                         {$CurrentSuccessReplace=$isMatch }
                      }#ShouldProcess
                  } catch {
                      $isMatch=$False #l'erreur peut provenir du ScriptBlock (MachtEvaluator)
                      #La propri�t� est en R/O, 
                      #La propri�t� n'est pas du type String, etc. 
                      $PSCmdlet.WriteError(
                       (New-Object System.Management.Automation.ErrorRecord (
                            #Recr�e l'exception trapp�e avec un message personnalis� 
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
                  #On ne peut rechercher au del� de la longueur de la cha�ne.
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
                               #Recr�e l'exception trapp�e avec un message personnalis� 
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
      #contenant le r�sultat de l'op�ration courante.
     if ($ReplaceInfo)
     { 
         #Si Whatif est pr�cis� l'op�ration n'est pas effectu�e
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

      #Est-ce qu'on effectue une seule op�ration de remplacement ?
     if ($Unique -and $CurrentSuccessReplace)
      {
        $PSCmdlet.WriteDebug("-Unique d�tect� et le dernier remplacement a r�ussi. Break.")
        break #oui, on quitte le bloc For
      } 
   }# For $TabKeyValue.Count
   
   if (-not $Whatif)
   {
       #Emission du r�sultat
       #On a effectu� n traitements sur une seule ligne ou un seul object
      if ($ReplaceInfo)
      { 
        $Resultat.isSuccess=$AllSuccessReplace
        $Resultat.Value=$InputObject
         #En cas d'�mission sur un cmdlet, utilisant Value comme
         #propri�t� de binding (ValueFromPipelineByPropertyName),
         #on red�clare la m�thode ToString afin que l'objet $Resultat 
         #renvoie le contenu de son membre Value comme donn�e � lier.
        $Resultat=$Resultat|Add-member ScriptMethod ToString {$this.Value} -Force -Passthru
          #Passe un tableau d'objet contenant un �l�ment, un objet.
          #PS �num�re le tableau et renvoi un seul objet.
          #
          #Dans ce contexte ceci est valable, m�me
          #si l'objet est un IEnumerable.
        $PSCmdlet.WriteObject(@($Resultat),$true) 
      }#$ReplaceInfo
     else
      {$PSCmdlet.WriteObject(@($InputObject),$true)}

  }
  $PSCmdlet.WriteDebug("[Pipeline] Next object.")
 }#process
}#Replace-String

new-alias rpls Replace-String  -description "Fonction auto-document�e Replace-String" -force 

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
