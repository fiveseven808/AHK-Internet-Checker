; ahk internet checkertem

/*

check if you have ip
check gateway

prereq for the first 2
check google dns ip addresses
check dns
	- check google.com
	- chec cisco.com
*/
#SingleInstance,force
Gui,Add,Text,x140 y19 w130 h15 Center,AHK Internet Checker
Gui,Add,Text,x200 y49 w130 h15 vGUI_IP,IP Address: %myIP%
Gui,Add,Progress,x70 y49 w120 h20 vIP_Prog,1
Gui,Add,Text,x200 y79 w150 h15 vGUI_Gateway,My Gateway: %mygateway%
Gui,Add,Progress,x70 y79 w120 h20 vGateway_Prog,1
Gui,Add,Text,x200 y109 w150 h15 vGUI_DNS,DNS (%myDNS%): %DNSstatus%
Gui,Add,Progress,x70 y109 w120 h20 vDNS_Prog,1
Gui,Add,Text,x200 y139 w180 h15 vGUI_MSDNS,MSNCST DNS:%NCSTDNS%
Gui,Add,Progress,x70 y139 w120 h20 vMSDNS_Prog,1
Gui,Add,Text,x200 y169 w150 h15 vGUI_MSFile,MSNSCT File:%NCSTFile%
Gui,Add,Progress,x70 y169 w120 h20 vMSFile_Prog,1
Gui,Add,Text,x200 y199 w150 h15 vGUI_groupshare,GroupShares: %googlestatus%
Gui,Add,Progress,x70 y199 w120 h20 vGroupShare_Prog,1
Gui,Add,Text,x200 y229 w150 h15 vGUI_cisco,cisco.com: %ciscostatus%
Gui,Add,Text,x200 y229 w150 h15 vGUI_Intranet,Gateway Ping: %ciscostatus%
Gui,Add,Progress,x70 y229 w120 h20 vIntranet_Prog,1
Gui,Add,Text,x200 y259 w150 h15 vGUI_JDrive,J Drive: %j_status%
Gui,Add,Progress,x70 y259 w120 h20 vJDrive_Prog,1
Gui,Add,Checkbox,x30 y199 w15 h15 vGUI_GSCheck gGUIbx_Refresh Checked
Gui,Add,Checkbox,x30 y229 w15 h15 vGUI_SPCheck gGUIbx_Refresh Checked
Gui,Add,Checkbox,x30 y259 w15 h15 vGUI_JDCheck gGUIbx_Refresh Checked
Gui,Add,Checkbox,x70 y299 w100 h15 vGUI_AutoRefresh gGUIbx_Refresh,Auto Refresh
Gui,Add,Checkbox,x70 y329 w120 h15 gGUIbx_Notify,Notify When Online
Gui,Add,Edit,x230 y299 w100 h20 vGUI_RefreshInterval,10
Gui,Add,Text,x180 y329 w200 h15 Center,Refresh Rate in seconds
Gui,Add,Button,x160 y369 w100 h30 gMain,Refresh Now
Gui,Show,x693 y244 w401 h421 ,





#include iptools.ahk
GuiControlGet, AutoRefresh,,GUI_AutoRefresh
GuiControlGet, GSCheck,,GUI_GSCheck
GuiControlGet, SPCheck,,GUI_SPCheck
GuiControlGet, JDCheck,,GUI_JDCheck


Main:
	Gosub ResetGUIProgress
	GuiControl,, IP_Prog, 50
	GuiControl,, Gateway_Prog, 50
	My_IP := Get_My_IP()
	;Msgbox % My_IP.IP "," My_IP.GW "," My_IP.DNS
	myIP := My_IP.IP
	mygateway := My_IP.GW
	myDNS := My_IP.DNS
	GuiControl, text, GUI_IP, IP Address: %myIP%
	GuiControl, text, GUI_Gateway, My Gateway: %mygateway%
	GuiControl,, IP_Prog, 100
	GuiControl,, Gateway_Prog, 100
	
	
	GuiControl,, MSDNS_Prog, 50
	NCSTDNS := Ping_addr("dns.msftncsi.com")
	GuiControl, text, GUI_MSDNS, MSNCST DNS: %NCSTDNS%
	if (NCSTDNS != "131.107.255.255"){
		NCSTDNS := "FAILED"
	}
	ChangeProgressColor("MSDNS_Prog", NCSTDNS)
	GuiControl,, MSDNS_Prog, 100
	
	;file is different... DOWNLOAD THIS
	GuiControl,, MSFile_Prog, 50
	UrlDownloadToFile, http://www.msftncsi.com/ncsi.txt, ncsi.txt
	;msgbox, errorlevel= %errorlevel%
	if not ErrorLevel {
		FileGetSize, ncsisize, ncsi.txt
		if (ncsisize != 14) {
			NCSTFile := "FAILED"
			;msgbox, NCSI size is wrong! Read ncsi.txt file!
			;some sort of failure. could be httpservice unavaliable in the file
		} else {
			NCSTFile := "OK!"
			FileDelete ncsi.txt
		}
	} else {
		NCSTFile := "FAILED"
	}
	GuiControl, text, GUI_MSFile, MSNCST File: %NCSTFile%
	ChangeProgressColor("MSFile_Prog", NCSTFile)
	GuiControl,, MSFile_Prog, 100
	
	GuiControl,, DNS_Prog, 50
	DNSstatus := Ping_addr(myDNS)
	GuiControl, text, GUI_DNS, DNS (%myDNS%): %DNSstatus%
	ChangeProgressColor("DNS_Prog", DNSstatus)
	GuiControl,, DNS_Prog, 100
	
	/*
	GuiControl,, Google_Prog, 50
	googlestatus := Ping_addr("google.com")
	GuiControl, text, GUI_google, google.com: %googlestatus%
	ChangeProgressColor("Google_Prog", googlestatus)
	GuiControl,, Google_Prog, 100
	*/
	If (GSCheck = 1){ 
	check_groupshares() 
	}
	
	
	;GuiControl,, Intranet_Prog, 50
	;ciscostatus := Ping_addr("cisco.com")
	If (SPCheck = 1){ 
		intranet_status := check_intranet()
		}
	If (JDCheck = 1){
		check_jdrive() 
	}
	;GuiControl, text, GUI_cisco, cisco.com: %intranet_status%
	;ChangeProgressColor("Cisco_Prog", ciscostatus)
	;GuiControl,, Cisco_Prog, 100
Return

GUIbx_Refresh:
	AutoRChange := AutoRefresh
	GuiControlGet, RefreshInterval,,GUI_RefreshInterval
	GuiControlGet, AutoRefresh,,GUI_AutoRefresh
	GuiControlGet, GSCheck,,GUI_GSCheck
	GuiControlGet, SPCheck,,GUI_SPCheck
	GuiControlGet, JDCheck,,GUI_JDCheck
	;msgbox, gs = %GSCheck%`nsp=%SPCheck%`njd=%JDCheck%
	If (AutoRChange != AutoRefresh){
		If (AutoRefresh = 1)
		{
			IntervalSec := RefreshInterval * 1000
			SetTimer, Main, %IntervalSec%
			msgbox, Internet Checker will now check every %RefreshInterval% Seconds
		} else {
			SetTimer, Main, Off
			msgbox, Internet Checker has disabled autochecking
		}
	}
	;msgbox, IntervalSec = %IntervalSec% ar = %AutoRefresh%
	
return

GUIbx_Notify:
Return

ResetGUIProgress:
	ChangeProgressColor("IP_Prog", "Reset")
	GuiControl,, IP_Prog, 1
	ChangeProgressColor("Gateway_Prog", "Reset")
	GuiControl,, Gateway_Prog, 1
	ChangeProgressColor("Q8_Prog", "Reset")
	GuiControl,, Q8_Prog, 1
	ChangeProgressColor("DNS_Prog", "Reset")
	GuiControl,, DNS_Prog, 5
	ChangeProgressColor("GroupShare_Prog", "Reset")
	GuiControl,, GroupShare_Prog, 1
	ChangeProgressColor("Intranet_Prog", "Reset")
	GuiControl,, Intranet_Prog, 1
	ChangeProgressColor("JDrive_Prog", "Reset")
	GuiControl,, JDrive_Prog, 1
return

Ping_addr(address)
{	
	tempcompread := address
	#include getip.ahk
	;ComputerUpAddr might be a useful thing? 
	;msgbox, ping line addr %IpAddress%
	if (address = "dns.msftncsi.com") {
		return %IpAddress%
	}
	if (CompOn = 1) {
		return PingTime
	} else {
		return "FAILED"
	}
	
}

check_intranet()
{
	GuiControl,, Intranet_Prog, 50
	;runwait, spchk\MapDrive.vbs
	sleep 500
	Fileread, resultsvar, spchk\WebResults.txt 
	;msgbox, %resultsvar%
	if not ErrorLevel {
		FileGetSize, ncsisize, spchk\WebResults.txt 
		if (ncsisize < 1) {
			NCSTFile := "FAILED"
			msgbox, spchk\WebResults.txt  size is too small! Read spchk\WebResults.txt  file!
		} else {
			NCSTFile := "OK!"
			FileDelete spchk\WebResults.txt 
		}
	} else {
		NCSTFile := "FAILED"
	}
	GuiControl, text, GUI_Intranet, Sharepoint Up: %NCSTFile%
	ChangeProgressColor("Intranet_Prog", NCSTFile)
	GuiControl,, Intranet_Prog, 100
	return NCSTFile
}

check_groupshares()
{
	GuiControl,, GroupShare_Prog, 50
	Fileread, resultsvar, G:\Group Shares\REDACTED\Tips and Tricks\Scripts\TestFile.txt 
	;msgbox, %resultsvar%
	if not ErrorLevel {
		FileGetSize, ncsisize, G:\Group Shares\REDACTED\Tips and Tricks\Scripts\TestFile.txt 
		if (ncsisize < 1) {
			NCSTFile := "FAILED"
			msgbox, TestFile size is too small! Read file!
		} else {
			NCSTFile := "OK!"
		}
	} else {
		NCSTFile := "FAILED"
	}
	If (NCSTFile = "FAILED"){
		GuiControl,, GroupShare_Prog, 75
		Fileread, resultsvar, \\SEVERADDRESSREDACTED\groupshares$\REDACTED\Tips and Tricks\Scripts\TestFile.txt 
		if not ErrorLevel {
			FileGetSize, ncsisize, \\SEVERADDRESSREDACTED\groupshares$\REDACTED\Tips and Tricks\Scripts\TestFile.txt 
			if (ncsisize < 1) {
				NCSTFile := "FAILED"
				msgbox, TestFile size is too small! Read file!
			} else {
				NCSTFile := "Workaround"
			}
		}
	}
	GuiControl, text, GUI_groupshare, GroupShares Up: %NCSTFile%
	ChangeProgressColor("GroupShare_Prog", NCSTFile)
	GuiControl,, GroupShare_Prog, 100
	return NCSTFile
}

check_jdrive()
{
	GuiControl,, JDrive_Prog, 50
	Fileread, resultsvar, J:\TestFile.txt 
	;msgbox, %resultsvar%
	if not ErrorLevel {
		FileGetSize, ncsisize, J:\TestFile.txt 
		if (ncsisize < 1) {
			NCSTFile := "FAILED"
			msgbox, TestFile size is too small! Read file!
		} else {
			NCSTFile := "OK!"
		}
	} else {
		NCSTFile := "FAILED"
	}
	GuiControl, text, GUI_JDrive,J Drive: %NCSTFile%
	ChangeProgressColor("JDrive_Prog", NCSTFile)
	GuiControl,, JDrive_Prog, 100
	return NCSTFile
}

ChangeProgressColor(guivar,statusvar)
{
	If (statusvar = "FAILED"){
		GuiControl,+cRed, %guivar%, 100 
	} 
	else if (statusvar = "Workaround"){
		GuiControl,+cYellow, %guivar%, 100
	}
	else {
		GuiControl,+cGreen, %guivar%, 100
	}
	If (statusvar = "Reset") {
		GuiControl,+cGray, %guivar%
	}
}


ESC::
	Reload
Return

GuiClose:
ExitApp

