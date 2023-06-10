################################################################################ 
#
#  Nom     : Test-Winform-WMIDotnet-CréationEvent.ps1
#  Version : 0.1
#  Auteur  :
#  Date    : le 21/08/2009
@"
Historique :
(Soit substitution CVS)
$Log$
(soit substitution SVN)
$LastChangedDate$
$Rev$
"@>$Null 
#
################################################################################
$NumberFile=1
 #Supprime les précédents fichiers crée
 #On ne surveille que la création de fichier
del "C:\Temp\PSTest*.txt"
[reflection.assembly]::loadwithpartialname("WMIEvent")

# Chargement des assemblies externes
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][Reflection.Assembly]::LoadWithPartialName("System.Drawing")

$btnStopProcess = new-object System.Windows.Forms.Button
$btnStartProcess = new-object System.Windows.Forms.Button
$btnStopAllWatching = new-object System.Windows.Forms.Button
$btnRunProcess = new-object System.Windows.Forms.Button
$btnCreateNewFile = new-object System.Windows.Forms.Button
$btnClose = new-object System.Windows.Forms.Button
$btnUnknownEvent = new-object System.Windows.Forms.Button
#
# btnStopProcess
#
$btnStopProcess.Location = new-object System.Drawing.Point(13, 13)
$btnStopProcess.Name = "btnStopProcess"
$btnStopProcess.Size = new-object System.Drawing.Size(175, 23)
$btnStopProcess.TabIndex = 0
$btnStopProcess.Text = "Arrêt surveillance process"
$btnStopProcess.UseVisualStyleBackColor = $true
function OnClick_btnStopProcess($Sender,$e){
   #Arrête la surveillance des process notepad
	$Event=New-object WMIEvent.PoshStopWatchingEvent("Process",
                                                   $pid,
                                                   ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                   [WMIEvent.PoshTransmissionActor]::PowerShell)
  #déclenche l'événement WMI
  $Event.Fire()
}

$btnStopProcess.Add_Click( { OnClick_btnStopProcess $btnStopProcess $EventArgs} )
#
# btnStartProcess
#
$btnStartProcess.Location = new-object System.Drawing.Point(13, 52)
$btnStartProcess.Name = "btnStartProcess"
$btnStartProcess.Size = new-object System.Drawing.Size(175, 23)
$btnStartProcess.TabIndex = 1
$btnStartProcess.Text = "Démarrage surveillance process"
$btnStartProcess.UseVisualStyleBackColor = $true
function OnClick_btnStartProcess($Sender,$e){
	 #Redémarre la surveillance des process notepad
 $Event=New-object WMIEvent.PoshOperationEvent("StartWatching Process",
                                               $pid,
                                               ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                               [WMIEvent.PoshTransmissionActor]::PowerShell)
                                              
 $Event.Fire()
}

$btnStartProcess.Add_Click( { OnClick_btnStartProcess $btnStartProcess $EventArgs} )
#
# btnStopAllWatching
#
$btnStopAllWatching.Location = new-object System.Drawing.Point(12, 98)
$btnStopAllWatching.Name = "btnStopAllWatching"
$btnStopAllWatching.Size = new-object System.Drawing.Size(175, 23)
$btnStopAllWatching.TabIndex = 2
$btnStopAllWatching.Text = "Arrêt de toutes les surveillances"
$btnStopAllWatching.UseVisualStyleBackColor = $true
function OnClick_btnStopAllWatching($Sender,$e){
   #Arrête la surveillance, ici la session PS de surveillance quittera la boucle While  
	$StopWatching=New-object WMIEvent.PoshStopWatchingEvent("AllWatching",
                                                          $pid,
                                                          ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                                          [WMIEvent.PoshTransmissionActor]::PowerShell)
  $StopWatching.Fire()
}

$btnStopAllWatching.Add_Click( { OnClick_btnStopAllWatching $btnStopAllWatching $EventArgs} )
#
# btnRunProcess
#
$btnRunProcess.Location = new-object System.Drawing.Point(254, 12)
$btnRunProcess.Name = "btnRunProcess"
$btnRunProcess.Size = new-object System.Drawing.Size(173, 23)
$btnRunProcess.TabIndex = 3
$btnRunProcess.Text = "Nouvelle instance Notepad"
$btnRunProcess.UseVisualStyleBackColor = $true
function OnClick_btnRunProcess($Sender,$e){
	[diagnostics.process]::start("Notepad.exe")
}

$btnRunProcess.Add_Click( { OnClick_btnRunProcess $btnRunProcess $EventArgs} )
#
# btnCreateNewFile
#
$btnCreateNewFile.Location = new-object System.Drawing.Point(254, 52)
$btnCreateNewFile.Name = "btnCreateNewFile"
$btnCreateNewFile.Size = new-object System.Drawing.Size(173, 23)
$btnCreateNewFile.TabIndex = 4
$btnCreateNewFile.Text = "Nouveau fichier"
$btnCreateNewFile.UseVisualStyleBackColor = $true
function OnClick_btnCreateNewFile($Sender,$e){
 "Création du fichier $NumberFile" > "C:\Temp\PSTest$NumberFile.txt"
 $NumberFile++
}

$btnCreateNewFile.Add_Click( { OnClick_btnCreateNewFile $btnCreateNewFile $EventArgs} )
#
# btnClose
#
$btnClose.Location = new-object System.Drawing.Point(352, 162)
$btnClose.Name = "btnClose"
$btnClose.Size = new-object System.Drawing.Size(75, 23)
$btnClose.TabIndex = 5
$btnClose.Text = "Fermer"
$btnClose.UseVisualStyleBackColor = $true
function OnClick_btnClose($Sender,$e){
	$FrmMain.Close()
}

$btnClose.Add_Click( { OnClick_btnClose $btnClose $EventArgs} )
#
# btnUnknownEvent
#
$btnUnknownEvent.Location = new-object System.Drawing.Point(12, 141)
$btnUnknownEvent.Name = "btnUnknownEvent"
$btnUnknownEvent.Size = new-object System.Drawing.Size(175, 23)
$btnUnknownEvent.TabIndex = 6
$btnUnknownEvent.Text = "Emet un événement inconnu"
$btnUnknownEvent.UseVisualStyleBackColor = $true
function OnClick_btnUnknownEvent($Sender,$e){
  #On émet une événement qui n'est pas prise en compte mais un message le signale 
 $Event=New-object WMIEvent.PoshOperationEvent("Unknown EventName",
                                              $pid,
                                              ([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).InstanceID,
                                              [WMIEvent.PoshTransmissionActor]::PowerShell)
 $Event.Fire()
}

$btnUnknownEvent.Add_Click( { OnClick_btnUnknownEvent $btnUnknownEvent $EventArgs} )
#
$FrmMain = new-object System.Windows.Forms.form
#
$FrmMain.ClientSize = new-object System.Drawing.Size(450, 197)
$FrmMain.Controls.Add($btnUnknownEvent)
$FrmMain.Controls.Add($btnClose)
$FrmMain.Controls.Add($btnCreateNewFile)
$FrmMain.Controls.Add($btnRunProcess)
$FrmMain.Controls.Add($btnStopAllWatching)
$FrmMain.Controls.Add($btnStartProcess)
$FrmMain.Controls.Add($btnStopProcess)
$FrmMain.Name = "FrmMain"
$FrmMain.Text = "Tests WMIEvent"
function OnFormClosing_FrmMain($Sender,$e){ 
	# $this est égal au paramètre sender (object)
	# $_ est égal au paramètre  e (eventarg)

	# Déterminer la raison de la fermeture :
	#   if (($_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

	#Autorise la fermeture
	($_).Cancel= $False
}
$FrmMain.Add_FormClosing( { OnFormClosing_FrmMain $FrmMain $EventArgs} )
$FrmMain.Add_Shown({$FrmMain.Activate()})
 #Libération des ressources
$FrmMain.ShowDialog()
 #Libération de la Form
$FrmMain.Dispose()

# SIG # Begin signature block
# MIIFQgYJKoZIhvcNAQcCoIIFMzCCBS8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUc5H9veC8mV9B7qn3VHBtCl/h
# XGKgggL8MIIC+DCCAmWgAwIBAgIQGpdOSYj2EbRAxGqmgFirkTAJBgUrDgMCHQUA
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
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTSedeF16R3yd59GeMsWxoY
# 6g3uPDANBgkqhkiG9w0BAQEFAASBgF7DqSeO8ZIxNSDEG6UWTJmzXwIzHEBlfE2p
# j0FuX6kJBniBv6UEg1M9BK2zi65Gn2d8Vu+hLhUSrpR3VspHmwP/iGlDQwyK3or2
# GI3u3nijIFWoCjoW6PwdjspSFRZ1FpGWED2TgchTj4nMMEDuHleRtEbpOv7p7Xjc
# pct/tKuJ
# SIG # End signature block
