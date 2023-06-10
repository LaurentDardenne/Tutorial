# Create-Sequence.ps1
# Cr�e un objet s�quence similaire � une s�quence Oracle

# L'appel de Nextval n'est pas n�cessaire CurrVal est accessible d�s que l'objet cr��
   

#Propri�t�s en ReadOnly: 
#-----------------------------------------------------------------------------------------
#Doc US : http://www.acs.ilstu.edu/docs/oracle/server.101/b10759/statements_6014.htm
# Name         : Nom de la s�quence.
#
# CurrVal      : Contient la valeur courante. 
#
# Increment_By : Sp�cifie l'interval entre les num�ros de la s�quence. 
#                Cette valeur enti�re peut �tre n'importe quel nombre entier positif ou n�gatif de type .NET INT, mais elle ne peut pas �tre 0. 
#                L'absolu de cette valeur doit �tre moins (ou �gal) que la diff�rence de MAXVALUE et de MINVALUE. 
#                Si cette valeur est n�gative, alors le s�quence est descendante (ordre d�croissant). 
#                Si la valeur est positive, alors la s�quence est ascendante (ordres croissant). 
#                Si vous omettez ce param�tre la valeur de l'interval est par d�faut de 1.
#
# Start_With   : Sp�cifie le premier nombre de la s�quence � produire. 
#                Employez ce param�tre pour d�marrer une s�quence ascendante � une valeur plus grande que son minimum ou pour  
#                d�marrer une s�quence descendante � une valeur moindre que son maximum. Pour des s�quences ascendantes, 
#                la valeur par d�faut est la valeur minimum de la s�quence. Pour des s�quences descendantes, la valeur par d�faut 
#                est la valeur maximum de la s�quence.
#                Note :
#                 Cette valeur n'est pas n�cessairement la valeur � laquelle une s�quence ascendante cyclique red�marre une fois 
#                 sa valeur maximum ou minimum atteinte. 
#
# MaxValue     : Sp�cifie la valeur maximum que la s�quence peut produire. 
#                MAXVALUE doit �tre �gal ou plus grand que le valeur du param�tre START_WITH et doit �tre plus grand que MINVALUE.
#
# MinValue     : Sp�cifie la valeur minimum de la s�quence. 
#                MINVALUE doit �tre inf�rieur ou �gal � le valeur du param�tre START_WITH  et doit �tre inf�rieure � MAXVALUE.
#
# Cycle        : Indique que la s�quence continue � produire des valeurs une fois atteinte sa valeur maximum ou minimum. 
#                Une fois qu'une s�quence ascendante a atteint sa valeur maximum, elle reprend � sa valeur minimum. 
#                Une fois qu'une s�quence descendante a atteint sa valeur minimum, elle reprend � sa valeur maximum.
#                Par d�faut une s�quence ne produit plus de valeurs une fois atteinte sa valeur maximum ou minimum. 
#
# Comment      : Commentaire.
#
#M�thodes :
#-----------------------------------------------------------------------------------------
# NextVal: Incr�mente la s�quence et retourne la nouvelle valeur.



# ** Le fonctionnment de cet objet s�quence est similaire � celui d'une s�quence Oracle sans pour autant �tre identique.

# Si vous ne sp�cifiez aucun param�tre, autre que le nom obligatoire, alors vous cr�ez une s�quence ascendante qui 
# d�bute � 1 et est incr�ment�e de 1 jusqu'� sa limite sup�rieure ([int]::MaxValue). 
# Si vous sp�cifiez seulement INCREMENT_BY -1 vous cr�ez une s�quence d�scendante qui d�bute � -1 et 
# est d�cr�ment�e de 1 jusqu'� sa limite inf�rieure ([int]::MinValue).

# Pour cr�er une s�quence ascendante qui incr�mente sans limite (autre que celle du type .NET INT), omettez le param�tre MAXVALUE. 
# Pour cr�er une s�quence descendante qui d�cr�mente sans limite, omettez le param�tre MINVALUE.

# Pour cr�er une s�quence ascendante qui s'arr�te � une limite pr�d�finie, sp�cifiez une valeur pour le param�tre MAXVALUE. 
# Pour cr�er une s�quence descendante qui s'arr�te � une limite pr�d�finie, sp�cifiez une valeur pour le param�tre MINVALUE. 
# Si vous ne pr�cisez pas le param�tre -CYCLE, n'importe quelle tentative de produire un num�ro de s�quence une fois que la s�quence 
# a atteint sa limite d�clenchera une erreur.

# Pour cr�er une s�quence qui red�marre/boucle apr�s avoir atteint une limite pr�d�finie, indiquez le param�tre CYCLE. Dans ce cas 
# vous devez obligatoirement sp�cifiez une valeur pour les param�tres MAXVALUE ou MINVALUE. 

#Valeur par d�faut d'une s�quence ascendante :
# $Sq=Create-Sequence "SEQ_Test"  ;$Sq
#
# Name         : SEQ_Test
# CurrVal      : 1
# Increment_By : 1
# MaxValue     : 2147483647
# MinValue     : 1
# Start_With   : 1
# Cycle        : False
# Comment      :

#Valeur par d�faut d'une s�quence descendante :
# $Sq=Create-Sequence "SEQ_Test" -inc -1  ;$Sq
# 
# Name         : SEQ_Test
# CurrVal      : -1
# Increment_By : -1
# MaxValue     : -1
# MinValue     : -2147483648
# Start_With   : -1
# Cycle        : False
# Comment      :

#Exemple :
# $DebugPreference = "Continue"
# $Sq= Create-Sequence "SEQ_Test"
# $Sq.Currval
# $Sq.NextVal()
# $Sq.Currval

Function Create-Sequence
{
  #Tous les param�tres sont contraint, i.e. on pr�cise un type. 
 param([String] $Sequence_Name, 
       [String] $Comment,
       [int] $Increment_By=1,
       [int] $MaxValue,
       [int] $MinValue,
       [int] $Start_With,            
       [switch] $Cycle)
  
  write-Debug "[Valeurs des param�tres]"
  write-Debug "Sequence_Name $Sequence_Name"
  write-Debug "Comment $Comment"
  write-Debug "Increment_By $Increment_By" 
  write-Debug "MaxValue $MaxValue"
  write-Debug "MinValue $MinValue"
  write-Debug "Start_With $Start_With"  
  write-Debug "Cycle $Cycle"        

  if (($MyInvocation.UnBoundArguments).count -ne 0)
   {Throw "Le ou les param�tres suivants sont inconnus : $($MyInvocation.UnBoundArguments)."}
  
 if (($Sequence_Name -eq $null) -or ($Sequence_Name -eq [String]::Empty))
  {Throw "Nom de s�quence invalide. La valeur de Sequence_Name doit �tre renseign�e."}

 write-Debug "Test isTypeEqual termin�."
 
#Les param�tres de type contraint sont initialis�s � une valeur par d�faut, par exemple pour les entiers � z�ro, 
#on ne peut donc pas les tester sur la valeur $null afin de d�terminer si un param�tre est pr�sent ou non sur la ligne de commande. 
#Et dans certains cas la valeur attribu�e par d�faut peut ne pas �tre souhaitable. 
#L'objet $MyInvocation.CommandLineParameters peut nous aider � tester ces cas de figure.        
 if (($MyInvocation.CommandLineParameters.Increment_By -ne $null) -and ($Increment_By -eq 0) ) 
  {Throw "La valeur de Increment_By doit �tre un entier diff�rent de z�ro."}
     
# Valeur par d�faut
# Si on ne sp�cifie aucun param�tre alors on cr�e une s�quence ascendante qui d�bute � 1
# est incr�ment�e de 1 sans limite de valeur sup�rieure (autre que celle du type utilis�)   
#Si on sp�cifie seulement -Increment_By -1 on cr�e une s�quence descendante qui d�bute � -1
# est d�cr�ment�e de -1 sans limite de valeur inf�rieure (autre que celle du type utilis�)
 write-Debug ""
 write-Debug "Les valeurs par d�faut pour la s�quence de type sont :"

#Ici si $Increment_By n'est pas renseign� il vaut par d�faut 1, on ne peut donc avoir 0 comme valeur renvoy�e par la m�thode Sign 
$local:Signe=[System.Math]::Sign($Increment_By)      
 write-Debug "`tIncrement_By $Increment_By"
 write-Debug "`tSigne $Signe (1= positif  -1= n�gatif)"
 
 if ( ($Signe -eq 1) -and
      ($MyInvocation.CommandLineParameters.Start_With -eq $null) -and
      ($MyInvocation.CommandLineParameters.MaxValue -eq $null) -and 
      ($MyInvocation.CommandLineParameters.MinValue -eq $null)
     )
      { write-Debug "`tS�quence ascendante. Valeur par d�faut."
        $Start_With=1     
        $MaxValue=[int]::MaxValue
        $MinValue=1
      }
 elseif 
    ( ($Signe -eq -1) -and
      ($MyInvocation.CommandLineParameters.Start_With -eq $null) -and
      ($MyInvocation.CommandLineParameters.MaxValue -eq $null) -and
      ($MyInvocation.CommandLineParameters.MinValue -eq $null)
     )
      { write-Debug "`tS�quence descendante. Valeur par d�faut."
        $Start_With=-1     
        $MaxValue=-1
        $MinValue=[int]::MinValue
      }
 else
  { 
    write-Debug "`t* Pas de valeur par d�faut. *"
 
    # Si MaxValue n'est pas sp�cifi� on indique la valeur maximum pour une s�quence ascendante 
    # sinon 1 pour une s�quence descendante    
   if ($MyInvocation.CommandLineParameters.MaxValue -eq $null)
    { $MaxValue=[int]::MaxValue 
      if ($local:Signe -eq -1)
       {$MaxValue=-1 }
    }
    # Si MinValue n'est pas sp�cifi� on indique la valeur 1 pour une s�quence ascendante 
    # sinon la valeur minimum  pour une s�quence descendante    
   if ($MyInvocation.CommandLineParameters.MinValue -eq $null)
    { $MinValue=1
      if ($Signe -eq -1)
       {$MinValue=[int]::MinValue }
    }
     
     # Si Start_With n'est pas sp�cifi� on indique, pour une s�quence ascendante, la valeur minimum de la s�quence 
     # ou pour une s�quence descendante la valeur maximum de la s�quence.
   if ($MyInvocation.CommandLineParameters.Start_With -eq $null) 
    {
     switch ($local:Signe)
      { 
        1  {$Start_With=$MinValue}
       -1  {$Start_With=$MaxValue}
      }#switch    
    }#If
 }#else 
 
 write-Debug "Start_With $Start_With"
 write-Debug "MaxValue $MaxValue"
 write-Debug "MinValue $MinValue"

 if ($MyInvocation.CommandLineParameters.Increment_By -ne $null)
  { 
   if ($Cycle.Ispresent) 
    { #Dans ce cas selon le signe du param�tre $Increment_By on doit pr�ciser soit Minvalue soit MaxValue  
     switch ($local:Signe)
      { 
       1  { if ($MyInvocation.CommandLineParameters.MinValue -eq $null) 
             { Throw "S�quence ascendante cyclique pour laquelle vous devez sp�cifier MinValue."}
          }
      -1  { if ($MyInvocation.CommandLineParameters.MaxValue -eq $null)
            { Throw "S�quence descendante cyclique pour laquelle vous devez sp�cifier MaxValue."}
          }
      default  { Throw "Analyse erron�e!"}
      }#switch
    }#if cycle
  }#if increment
 write-Debug "Test de la variable Cycle termin�."      
 write-Debug "[Test de validit� de la s�quence]"     

 # MINVALUE must be less than or equal to START WITH and must be less than MAXVALUE. 
 if (!($MinValue -le $Start_With ))
  { Throw "Start_With($Start_With) ne peut pas �tre inf�rieur � MinValue($MinValue)."}
 elseif (!($MinValue -lt $MaxValue))
  { Throw "MinValue($MinValue) doit �tre inf�rieure � MaxValue($MaxValue)."}
 # MAXVALUE must be equal to or greater than START WITH and must be greater than MINVALUE.
 if (!($MaxValue -ge $Start_With))
   { Throw "Start_With($Start_With) ne peut pas �tre sup�rieur � MaxValue($MaxValue)."}
 elseif (!($MaxValue -gt $MinValue))
  { Throw "MaxValue($MaxValue) doit �tre sup�rieure � MinValue($MinValue)."}
  
  #On test s'il est possible d'it�rer au moins une fois.
  #La construction suivant est valide mais pour un seul chiffre :
  # $Sq=Create-Sequence $N $C -inc 1 -min 0 -max 5 -start 5
  # $Sq=Create-Sequence $N $C -inc -1 -min 0 -max 2 -start 0
    
  #Start_with n'est pas pris en compte dans ce calcul, on autorise donc un s�quence proposant un seul nombre.
  #Si dans ce cas on pr�cise le switch -Cycle on a bien plusieurs it�rations :
  # $Sq=Create-Sequence $N $C -inc 1 -min 0 -max 5 -start 5 -cycle

  #On cast $Increment_By car sa valeur peut �tre �gale � [int]::MinValue, d'o� une exception lors de l'appel � Abs
  # La documentation Oracle pr�cise l'op�rateur -lt mais dans ce cas la s�quence suivante est impossible :
  #  Create-Sequence $N $C -min 1 -max 2 
 if (!([system.Math]::Abs([Long]$Increment_By) -le ($MaxValue-$MinValue)) )
  { Throw "Increment_By($Increment_By) doit �tre inf�rieur ou �gale � MaxValue($MaxValue) moins MinValue($MinValue)."} 

#Cr�ation de la s�quence
 $Sequence= new-object System.Management.Automation.PsObject
 # Ajout des propri�t�s en R/O, le code est cr�� dynamiquement
$MakeReadOnlyMember=@"
`$Sequence | add-member ScriptProperty Name         -value {"$Sequence_Name"}   -Passthru|`
             add-member ScriptProperty Comment      -value {"$Comment"}         -Passthru|`
             add-member ScriptProperty Increment_By -value {[int]$Increment_By} -Passthru|`
             add-member ScriptProperty MaxValue     -value {[int]$MaxValue}     -Passthru|`
             add-member ScriptProperty MinValue     -value {[int]$MinValue}     -Passthru|`
             add-member ScriptProperty Start_With   -value {[int]$Start_With}   -Passthru|`
             add-member ScriptProperty Cycle        -value {`$$Cycle}           -Passthru|`
             add-member ScriptProperty CurrVal      -value {[int]$Start_With}
"@
  Invoke-Expression $MakeReadOnlyMember
  
  #La m�thode NextVal renvoie en fin de traitement la valeur courante du membre Currval
 $Sequence | add-member ScriptMethod NextVal {   
                          $NewValue=$this.CurrVal + $this.Increment_By
                          write-debug "this $this"
                          write-debug "NewValue $NewValue"
                           
                           #D�claration param�tr�e pour la red�finition du membre CurrVal
                           #Le param�tre -Force annule et remplace la d�finition du membre sp�cifi�
                          $RazMember="`$this | add-member -Force ScriptProperty CurrVal  -value {0}"
                                                                                                  
                          switch ([System.Math]::Sign($this.Increment_By))
                          {  
                              #MAXVALUE cannot be made to be less than the current value
                             1  { if ($NewValue -gt  $this.MaxValue)
                                  { write-debug "Borne maximum atteinte."
                                    
                                    if ($this.Cycle -eq $true) #Dans ce cas on recommence
                                     { #On construit (par formatage) la d�finition du membre CurrVal 
                                       #puis on reconstruit le membre.
                                      Invoke-Expression ($RazMember -F "{[int]$this.MinValue}")
                                     } 
                                    else {Throw "La s�quence $($this.Name).Nextval a atteint la valeur maximum autoris�e."}
                                  }
                                  else { Invoke-Expression ($RazMember -F "{[int]$NewValue}")}
                                }#S�quence ascendante

                              #MINVALUE cannot be made to exceed the current value 
                            -1  { if ($NewValue -lt  $this.MinValue)
                                  { write-debug "Borne minimum atteinte."
                                    if ($this.Cycle -eq $true)
                                     {Invoke-Expression ($RazMember -F "{[int]$this.MaxValue}") }
                                    else {Throw "La s�quence $($this.Name).Nextval a atteint la valeur minimum autoris�e."}
                                  }
                                  else {Invoke-Expression ($RazMember -F "{[int]$NewValue}") }
                                }#S�quence descendante
                             else {Throw "Erreur dans la m�thode Nextval."}    
                          }#switch
                           #Renvoi la nouvelle valeur
                          $this.CurrVal
                          write-debug "this $this"
                        }

 write-Debug "[Valeurs de la s�quence]"
 write-Debug "Sequence_Name $Sequence_Name"
 write-Debug "Comment $Comment"
 write-Debug "Increment_By $Increment_By" 
 write-Debug "MaxValue $MaxValue"
 write-Debug "MinValue $MinValue"
 write-Debug "Start_With $Start_With"  
 write-Debug "Cycle $Cycle"        
 write-Debug "Current $Current"
 write-Debug "----"
 write-Debug  $Sequence

  #Sp�cifie l'affichage des propri�t�s par d�faut
  #On �vite ainsi l'usage d'un fichier de type .ps1xml
  #From http://poshoholic.com/2008/07/05/essential-powershell-define-default-properties-for-custom-objects/
 $DefaultProperties =@(
  'Name',
  'CurrVal', 
  'Increment_By',
  'MaxValue',
  'MinValue',
  'Start_With',
  'Cycle',
  'Comment')
 $DefaultPropertySet=New System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet',[string[]]$DefaultProperties)
 $PSStandardMembers=[System.Management.Automation.PSMemberInfo[]]@($DefaultPropertySet)
 $Sequence|Add-Member MemberSet PSStandardMembers $PSStandardMembers

 return $Sequence
}

# SIG # Begin signature block
# MIIFQgYJKoZIhvcNAQcCoIIFMzCCBS8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhevflw0Rn4etFAsnBtI81oB4
# cGygggL8MIIC+DCCAmWgAwIBAgIQGpdOSYj2EbRAxGqmgFirkTAJBgUrDgMCHQUA
# MHsxeTB3BgNVBAMecABMAGEAdQByAGUAbgB0ACAARABhAHIAZABlAG4AbgBlACAA
# YQB1AHQAbwByAGkAdADpACAAZABlACAAYwBlAHIAdABpAGYAaQBjAGEAdABpAG8A
# bgAgAHIAYQBjAGkAbgBlACAAbABvAGMAYQBsAGUwHhcNMDcwNzAxMTMyNjU5WhcN
# MzkxMjMxMjM1OTU5WjA2MTQwMgYDVQQDEytMYXVyZW50IERhcmRlbm5lIGNlcnRp
# ZmljYXQgcG91ciBQb3dlclNoZWxsMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKB
# gQCfu+w77PdPXH8+C41SaR48k/DPql1EPDL8O4gArRwbKH/McvXmXCKEwaWYlFi7
# w8F4CwO/kBswENa+0X3OXLUOK0LyQmJP7VQqA+mT4Up+a5Z3mcsRd1Out+OzfOuR
# hium1zhE1/MlIqEK6hnMl/A/bkc4SCFfdiJeZc83tNkGXwIDAQABo4HJMIHGMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMIGuBgNVHQEEgaYwgaOAEB0w3fWBsN0e2nTMjcGF
# f8qhfTB7MXkwdwYDVQQDHnAATABhAHUAcgBlAG4AdAAgAEQAYQByAGQAZQBuAG4A
# ZQAgAGEAdQB0AG8AcgBpAHQA6QAgAGQAZQAgAGMAZQByAHQAaQBmAGkAYwBhAHQA
# aQBvAG4AIAByAGEAYwBpAG4AZQAgAGwAbwBjAGEAbABlghAb5Gp5W/j2oEZ4E3Mn
# LmpOMAkGBSsOAwIdBQADgYEAoEjrLmRoEscvqLGp6RXFH55NjCul7e118oWxlpHt
# hcme2FZVN0vNB0Xqa+A3YU4QyYhYNeBaJ/gsgv1MC7PnuBR2ek58mTwVa6WlVNrn
# KK8A7P3MRVCOGVYkOiw5xttWFvPPph1YG1CAAwAwSI+nIfJCxyJDceOvvbCoV+US
# FLgxggGwMIIBrAIBATCBjzB7MXkwdwYDVQQDHnAATABhAHUAcgBlAG4AdAAgAEQA
# YQByAGQAZQBuAG4AZQAgAGEAdQB0AG8AcgBpAHQA6QAgAGQAZQAgAGMAZQByAHQA
# aQBmAGkAYwBhAHQAaQBvAG4AIAByAGEAYwBpAG4AZQAgAGwAbwBjAGEAbABlAhAa
# l05JiPYRtEDEaqaAWKuRMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQZ20Yp3aplMijqRGksWuy8
# m5nwkzANBgkqhkiG9w0BAQEFAASBgJP7am7iRbjncSa70RQRqNqyRhmrrRAXBe5J
# DBkrXVV04c0rzjDjJ83WNSq/IpwRPxbFQbF8Qz3orJWvx6d1PhQgBkrSS/F+vD77
# TMMJOe1h6vl6jwHwURqOpwXdKSikBOvC9AT0DCowdMoGmLbkZLW+YMOVmv3OAfum
# mCwTMZ4P
# SIG # End signature block
