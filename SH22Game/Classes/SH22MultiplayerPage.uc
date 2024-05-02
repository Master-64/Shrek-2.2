// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22MultiplayerPage extends MGUIPage
	Config(SH22);


var automated config GUIEditBox UsernameBox, IPAddressBox, PortBox;
var automated config GUILabel UsernameLabel, IPAddressLabel, PortLabel, CharacterSelectLabel;
var automated config SHGUIComboBox CharacterSelect;
var automated config GUIButton Back, Connect;
var localized string lUsernameBox, lhUsernameBox, lIPAddressBox, lhIPAddressBox, lPortBox, lhPortBox, lCharacterSelect, lhCharacterSelect, lBack, lhBack, lConnect, lhConnect;


event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	
	super.InitComponent(MyController, MyOwner);
	
	__OnClick__Delegate = InternalOnClick;
	__OnKeyEvent__Delegate = InternalOnKeyEvent;
	__OnKeyType__Delegate = InternalOnKeyType;
	
	for(i = 0; i < Controls.Length; i++)
	{
		Controls[i].__OnChange__Delegate = InternalOnChange;
	}
	
	TabFooter.WinLeft = 0.493;
	TabFooter.WinTop = 0.9;
	
	CenterComponent(UsernameBox);
	CenterComponent(IPAddressBox);
	CenterComponent(PortBox);
	CenterComponent(CharacterSelect);
	CenterComponent(UsernameLabel);
	CenterComponent(IPAddressLabel);
	CenterComponent(PortLabel);
	CenterComponent(CharacterSelectLabel);
	CenterComponent(Back);
	CenterComponent(Connect);
	CenterComponent(TabFooter);
	
	UsernameLabel.Caption = lUsernameBox;
	UsernameBox.Hint = lhUsernameBox;
	IPAddressLabel.Caption = lIPAddressBox;
	IPAddressBox.Hint = lhIPAddressBox;
	PortLabel.Caption = lPortBox;
	PortBox.Hint = lhPortBox;
	CharacterSelectLabel.Caption = lCharacterSelect;
	CharacterSelect.Edit.Hint = lhCharacterSelect;
	Back.Caption = lBack;
	Back.Hint = lhBack;
	Connect.Caption = lConnect;
	Connect.Hint = lhConnect;
	
	CharacterSelect.AddItem("Shrek");
	CharacterSelect.AddItem("Donkey");
	CharacterSelect.AddItem("Puss in Boots");
	CharacterSelect.AddItem("Steed");
	CharacterSelect.AddItem("Shrek (Human)");
	CharacterSelect.AddItem("Mongo");
}

event bool InternalOnClick(GUIComponent Sender)
{
	super.InternalOnClick(Sender);
	
	switch(Sender)
	{
		case Back:
			Controller.ReplaceMenu("SH22Game.SH22MainMenuPage");
			
			break;
		case Connect:
			// Initialize a connection
			// ...
			
			break;
		default:
			break;
	}
	
	return true;
}

event InternalOnChange(GUIComponent Sender)
{
	if(!Controller.bCurMenuInitialized)
	{
		return;
	}
	
	switch(Sender)
	{
		case CharacterSelect:
			// Change character
			
			break;
		case UsernameBox:
			// Change username
			
			break;
		case IPAddressBox:
			// Change IP address
			
			break;
		case PortBox:
			// Change port
			
			break;
		default:
			break;
	}
}

event bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
	return super.InternalOnKeyEvent(Key, State, Delta);
}

function bool InternalOnKeyType(out byte Key, optional string Unicode)
{
	return false;
}

event InternalOnLoadINI(GUIComponent Sender, string S)
{
	switch(Sender)
	{
		case UsernameBox:
			UsernameBox.SetText("Unknown Player");
			
			break;
		case IPAddressBox:
			IPAddressBox.SetText("127.0.0.1");
			
			break;
		case PortBox:
			PortBox.SetText("6400");
			
			break;
		case CharacterSelect:
			CharacterSelect.SetText("Shrek");
			
			break;
		default:
			break;
	}
}

event string InternalOnSaveINI(GUIComponent Sender) // Only here to prevent throwing an error
{
	return "";
}


defaultproperties
{
	Begin Object Name=btnBack0 Class=GUIButton
		StyleName="SHBTNBackStyle"
		bNeverFocus=true
		WinTop=0.8
		WinLeft=0.15
		WinWidth=0.1
		WinHeight=0.1
		OnClick=InternalOnClick
	End Object
	Back=btnBack0
	Begin Object Name=btnConnect0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.6
		WinLeft=0.6
		WinWidth=0.1
		WinHeight=0.1
		OnClick=InternalOnClick
	End Object
	Connect=btnConnect0
	Begin Object Name=ebUsername0 Class=GUIEditBox
		StyleName="SHSolidBox"
		MaxWidth=16
		IniOption="@INTERNAL"
		IniDefault="Unknown Player"
		WinTop=0.3
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnKeyEvent=InternalOnKeyEvent
		OnKeyType=InternalOnKeyType
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	UsernameBox=ebUsername0
	Begin Object Name=lblUsername0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.25
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	UsernameLabel=lblUsername0
	Begin Object Name=ebIPAddress0 Class=GUIEditBox
		StyleName="SHSolidBox"
		bFloatOnly=true
		IniOption="@INTERNAL"
		IniDefault="127.0.0.1"
		WinTop=0.4
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnKeyEvent=InternalOnKeyEvent
		OnKeyType=InternalOnKeyType
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	IPAddressBox=ebIPAddress0
	Begin Object Name=lblIPAddress0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
	End Object
	IPAddressLabel=lblIPAddress0
	Begin Object Name=ebPort0 Class=GUIEditBox
		StyleName="SHSolidBox"
		MaxWidth=5
		bIntOnly=true
		IniOption="@INTERNAL"
		IniDefault="6400"
		WinTop=0.4
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnKeyEvent=InternalOnKeyEvent
		OnKeyType=InternalOnKeyType
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	PortBox=ebPort0
	Begin Object Name=lblPort0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
	End Object
	PortLabel=lblPort0
	Begin Object Name=cbCharacterSelect0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="Shrek"
		WinTop=0.6
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	CharacterSelect=cbCharacterSelect0
	Begin Object Name=lblCharacterSelect0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.55
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
	End Object
	CharacterSelectLabel=lblCharacterSelect0
	bEscapeClosesPage=false
}