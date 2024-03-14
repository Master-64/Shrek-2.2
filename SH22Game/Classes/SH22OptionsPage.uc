// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22OptionsPage extends MGUIPage
	Config(SH22);


var Tab_OptionsGame GameTab;
var Tab_OptionsSound SoundTab;
var Tab_OptionsVideo VideoTab;
var automated config GUITabControl TabOptions;
var automated config GUIButton BackButton;
var localized string lGameTab, lhGameTab, lVideoTab, lhVideoTab, lSoundTab, lhSoundTab, lBack, lhBack;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i, j;
	
	super.InitComponent(MyController, MyOwner);
	
	GameTab = Tab_OptionsGame(TabOptions.AddTab(lGameTab, "SHGame.Tab_OptionsGame",, lhGameTab, true));
	VideoTab = Tab_OptionsVideo(TabOptions.AddTab(lVideoTab, "SHGame.Tab_OptionsVideo",, lhVideoTab, true));
	SoundTab = Tab_OptionsSound(TabOptions.AddTab(lSoundTab, "SHGame.Tab_OptionsSound",, lhSoundTab, true));
	
	TabOptions.bDockPanels = true;
	TabOptions.ActiveTab = GameTab.MyButton;
	TabOptions.ActiveTab.ChangeActiveState(true, true);
	
	CenterComponent(BackButton);
	
	BackButton.Caption = lBack;
	BackButton.Hint = lhBack;
	
	for(i = 0; i < TabOptions.TabStack.Length; i++)
	{
		for(j = 0; j < TabOptions.TabStack[i].MyPanel.Controls.Length; j++)
		{
			TabOptions.TabStack[i].MyPanel.Controls[j].StyleName = "SHSolidBox";
		}
		
		TabOptions.TabStack[i].StyleName = "SHSolidBox";
	}
	
	TabOptions.ActiveTab.StyleName = "SHSolidBox";
	SoundTab.DisablePage();
}

function TabChange(GUIComponent Sender)
{
	local int i, j;
	
	if(!Controller.bCurMenuInitialized || GUITabButton(Sender) == none)
	{
		return;
	}
	
	GameTab.RefreshPage();
	VideoTab.RefreshPage();
	SoundTab.RefreshPage();
	
	for(i = 0; i < TabOptions.TabStack.Length; i++)
	{
		if(TabOptions.TabStack[i] == Sender)
		{
			continue;
		}
		
		for(j = 0; j < TabOptions.TabStack[i].MyPanel.Controls.Length; j++)
		{
			TabOptions.TabStack[i].MyPanel.Controls[j].bVisible = false;
			
			continue;
		}
	}
}

function bool InternalOnClick(GUIComponent Sender)
{
	super.InternalOnClick(Sender);
	
	switch(Sender)
	{
		case BackButton:
			Controller.ReplaceMenu("SH22Game.SH22MainMenuPage");
			
			break;
		default:
			break;
	}
	
	return true;
}

event bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
	return super.InternalOnKeyEvent(Key, State, Delta);
}


defaultproperties
{
	Begin Object Name=tcChange Class=GUITabControl
		BackgroundStyleName="SHSolidBox"
		StyleName="SHSolidBox"
		bAcceptsInput=true
		WinTop=0.1
		WinLeft=0.4
		WinWidth=0.225
		WinHeight=0.5
		TabHeight=0.06
		OnChange=TabChange
	End Object
	TabOptions=tcChange
	Begin Object Name=btnBack0 Class=GUIButton
		StyleName="SHBTNBackStyle"
		bNeverFocus=true
		WinTop=0.8
		WinLeft=0.15
		WinWidth=0.1
		WinHeight=0.1
		OnClick=InternalOnClick
	End Object
	BackButton=btnBack0
	bEscapeClosesPage=false
}