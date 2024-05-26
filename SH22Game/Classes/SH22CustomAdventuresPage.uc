// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22CustomAdventuresPage extends MGUIPage
	Config(SH22);


var array<string> sAvailableMaps;
var int iSelectedLevel;

// Core menu
var automated config GUIButton Back, Begin;
var automated config GUIComponent CoreGUI[2];
var localized string lBack, lhBack, lBegin, lhBegin;

// Level select
var automated config GUILabel LevelSelectLabel;
var automated config SHGUIComboBox LevelSelect;
var automated config GUIComponent LevelGUI[2];
var localized string lLevelSelect, lhLevelSelect;


event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	
	super.InitComponent(MyController, MyOwner);
	
	__OnClick__Delegate = InternalOnClick;
	
	for(i = 0; i < Controls.Length; i++)
	{
		Controls[i].__OnChange__Delegate = InternalOnChange;
	}
	
	TabFooter.WinLeft = 0.493;
	TabFooter.WinTop = 0.9;
	
	CenterComponent(TabFooter);
	
	CoreGUI[0] = Back;
	CoreGUI[1] = Begin;
	
	for(i = 0; i < 2; i++)
	{
		CenterComponent(CoreGUI[i]);
	}
	
	LevelGUI[0] = LevelSelect;
	LevelGUI[1] = LevelSelectLabel;
	
	for(i = 0; i < 2; i++)
	{
		CenterComponent(LevelGUI[i]);
	}
	
	Back.Caption = lBack;
	Back.Hint = lhBack;
	Begin.Caption = lBegin;
	Begin.Hint = lhBegin;
	LevelSelectLabel.Caption = lLevelSelect;
	LevelSelect.Edit.Hint = lhLevelSelect;
	
	sAvailableMaps = U.GetAvailableMaps();
	
	// Remove all stock maps from the map list
	for(i = 0; i < sAvailableMaps.Length; i++)
	{
		if(IsStockMap(sAvailableMaps[i]))
		{
			sAvailableMaps.Remove(i, 1);
			
			i--;
		}
	}
	
	for(i = 0; i < sAvailableMaps.Length; i++)
	{
		LevelSelect.AddItem(sAvailableMaps[i]);
	}
}

event bool InternalOnClick(GUIComponent Sender)
{
	super.InternalOnClick(Sender);
	
	switch(Sender)
	{
		case Back:
			Controller.ReplaceMenu("SH22Game.SH22MainMenuPage");
			
			break;
		case Begin:
			if(LevelSelect.Edit.GetText() == "No Custom Adventures Found")
			{
				break;
			}
			
			U.ChangeLevel(LevelSelect.Edit.GetText());
			
			break;
		default:
			break;
	}
	
	return true;
}

event InternalOnChange(GUIComponent Sender)
{
	local int i;
	
	if(!Controller.bCurMenuInitialized)
	{
		return;
	}
	
	switch(Sender)
	{
		case LevelSelect:
			for(i = 0; i < sAvailableMaps.Length; i++)
			{
				iSelectedLevel = 0;
				
				if(sAvailableMaps[i] == LevelSelect.Edit.GetText())
				{
					iSelectedLevel = i;
					
					break;
				}
			}
			
			break;
		default:
			break;
	}
}

event InternalOnLoadINI(GUIComponent Sender, string S)
{
	switch(Sender)
	{
		case LevelSelect:
			LevelSelect.SetText(sAvailableMaps[iSelectedLevel]);
			
			break;
		default:
			break;
	}
}

event string InternalOnSaveINI(GUIComponent Sender) // Only here to prevent throwing an error
{
	return "";
}

function bool IsStockMap(string sMapName)
{
	sMapName = Caps(sMapName);
	
	return sMapName == "DEVMAP" || sMapName == "0_PREAMBLE" || sMapName == "0_STORYBOOK_MAIN_MENU" || sMapName == "1_STORYBOOK_CHAPTER_1" || sMapName == "1_SHREKS_SWAMP_1" || sMapName == "1_SHREKS_SWAMP_2" || sMapName == "1_SHREKS_SWAMP_3" || sMapName == "2_CARRIAGE_HIJACK_1" || sMapName == "3_THE_HUNT_PART1" || sMapName == "3_THE_HUNT_PART2" || sMapName == "3_THE_HUNT_PART3" || sMapName == "3_THE_HUNT_PART4" || sMapName == "4_FGM_OFFICE" || sMapName == "4_FGM_PIB" || sMapName == "5_FGM_DONKEY" || sMapName == "6_HAMLET" || sMapName == "6_HAMLET_END" || sMapName == "6_HAMLET_MINE" || sMapName == "7_PRISON_DONKEY" || sMapName == "8_PRISON_PIB" || sMapName == "9_PRISON_SHREK" || sMapName == "10_CASTLE_SIEGE" || sMapName == "11_FGM_BATTLE" || sMapName == "BEANSTALK_BONUS" || sMapName == "BEANSTALK_BONUS_DAWN" || sMapName == "BEANSTALK_BONUS_KNIGHT" || sMapName == "BOOK_FRONTEND" || sMapName == "BOOK_STORY_1" || sMapName == "BOOK_STORY_2" || sMapName == "BOOK_STORY_3" || sMapName == "BOOK_STORY_4" || sMapName == "BOOK_STORYBOOK" || sMapName == "CREDITS" || sMapName == "ENTRY" || sMapName == "SH2_PREAMBLE";
}


defaultproperties
{
	Begin Object Name=btnBack0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.8
		WinLeft=0.15
		WinWidth=0.1
		WinHeight=0.1
		OnClick=InternalOnClick
	End Object
	Back=btnBack0
	Begin Object Name=btnBegin0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.5
		WinLeft=0.7
		WinWidth=0.1
		WinHeight=0.1
		OnClick=InternalOnClick
	End Object
	Begin=btnBegin0
	Begin Object Name=cbLevelSelect0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="No Custom Adventures Found"
		WinTop=0.5
		WinLeft=0.44
		WinWidth=0.4
		WinHeight=0.05
		OnClick=InternalOnClick
		OnChange=InternalOnChange
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	LevelSelect=cbLevelSelect0
	Begin Object Name=lblLevelSelect0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.45
		WinLeft=0.44
		WinWidth=0.2
		WinHeight=0.05
	End Object
	LevelSelectLabel=lblLevelSelect0
	bEscapeClosesPage=false
}