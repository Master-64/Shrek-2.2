// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22MainMenuPage extends MGUIPage
	Config(SH22);


var automated config GUIButton SaveSlot0, SaveSlot1, SaveSlot2, SaveSlot3, SaveSlot4, SaveSlot5, OptionButton, DeleteSaveButton, QuitButton, CustomAdventuresButton, CheatsButton, MultiplayerButton;
var automated GUIButton SaveSlots[6], MainButtons[3], SideButtons[3];
var automated config GUILabel GameBuildLabel, ActivisionLabel;
var automated config GUIImage GameLogo;
var localized string lhStartGame, lOption, lhOption, lDeleteSave, lhDeleteSave, lDeleteSavePrompt, lQuit, lhQuit, lAreYouSure, lhAreYouSure, lCustomAdventures, lhCustomAdventures, lCheats, lhCheats, lMultiplayer, lhMultiplayer, lActivisionLabel;
var config string sFirstLevel;
var bool bPanic, bDeleteSaveButtonState;
var int iPanicButtonCounter;


event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	
	super.InitComponent(MyController, MyOwner);
	
	__OnClick__Delegate = InternalOnClick;
	__OnKeyEvent__Delegate = InternalOnKeyEvent;
	
	TabFooter.WinLeft = 0.493;
	TabFooter.WinTop = 0.9;
	
	GameBuildLabel.Caption = Localize("General", "Product", "game");
	ActivisionLabel.Caption = lActivisionLabel;
	
	SaveSlots[0] = SaveSlot0;
	SaveSlots[1] = SaveSlot1;
	SaveSlots[2] = SaveSlot2;
	SaveSlots[3] = SaveSlot3;
	SaveSlots[4] = SaveSlot4;
	SaveSlots[5] = SaveSlot5;
	
	MainButtons[0] = OptionButton;
	MainButtons[1] = DeleteSaveButton;
	MainButtons[2] = QuitButton;
	
	SideButtons[0] = CustomAdventuresButton;
	SideButtons[1] = CheatsButton;
	SideButtons[2] = MultiplayerButton;
	
	for(i = 0; i < 6; i++)
	{
		CenterComponent(SaveSlots[i]);
	}
	
	for(i = 0; i < 3; i++)
	{
		CenterComponent(MainButtons[i]);
	}
	
	for(i = 0; i < 3; i++)
	{
		CenterComponent(SideButtons[i]);
	}
	
	CenterComponent(GameBuildLabel);
	CenterComponent(ActivisionLabel);
	CenterComponent(TabFooter);
	
	OptionButton.Caption = lOption;
	OptionButton.Hint = lhOption;
	DeleteSaveButton.Caption = lDeleteSave;
	DeleteSaveButton.Hint = lhDeleteSave;
	QuitButton.Caption = lQuit;
	QuitButton.Hint = lhQuit;
	CustomAdventuresButton.Caption = lCustomAdventures;
	CustomAdventuresButton.Hint = lhCustomAdventures;
	CheatsButton.Caption = lCheats;
	CheatsButton.Hint = lhCheats;
	MultiplayerButton.Caption = lMultiplayer;
	MultiplayerButton.Hint = lhMultiplayer;
	
	UpdateSaveIcons();
	
	SetTimer(0.1, true);
}

function UpdateSaveIcons()
{
	local string Image;
	
	PC = U.GetPC();
	
	if(!PC.IsA('SHHeroController'))
	{
		return;
	}
	
	if(U.SaveGameExists(0))
	{
		Image = SHHeroController(PC).Save0Image;
		SaveSlots[0].Caption = "1";
		
		if(class'savegameinfo'.default.Save0Name != "")
		{
			SaveSlots[0].Hint = class'savegameinfo'.default.Save0Name @ "--" @ class'savegameinfo'.default.Save0Date;
		}
		else
		{
			SaveSlots[0].Hint = lhStartGame;
		}
	}
	else
	{
		Image = "storybookanimTX.box_button";
		SaveSlots[0].Caption = "";
		SaveSlots[0].Hint = lhStartGame;
		class'savegameinfo'.default.Save0Name = "";
		class'savegameinfo'.default.Save0Date = "";
	}
	
	STY_SH_BTN0Save(Controller.GetStyle("SHBTN0SaveStyle")).Images[0] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN0Save(Controller.GetStyle("SHBTN0SaveStyle")).Images[1] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN0Save(Controller.GetStyle("SHBTN0SaveStyle")).Images[2] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN0Save(Controller.GetStyle("SHBTN0SaveStyle")).Images[3] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN0Save(Controller.GetStyle("SHBTN0SaveStyle")).Images[4] = Texture(DynamicLoadObject(Image, class'Texture'));
	
	if(U.SaveGameExists(1))
	{
		Image = SHHeroController(PC).Save1Image;
		SaveSlots[1].Caption = "2";
		
		if(class'savegameinfo'.default.Save1Name != "")
		{
			SaveSlots[1].Hint = class'savegameinfo'.default.Save1Name @ "--" @ class'savegameinfo'.default.Save1Date;
		}
		else
		{
			SaveSlots[1].Hint = lhStartGame;
		}
	}
	else
	{
		Image = "storybookanimTX.box_button";
		SaveSlots[1].Caption = "";
		SaveSlots[1].Hint = lhStartGame;
		class'savegameinfo'.default.Save1Name = "";
		class'savegameinfo'.default.Save1Date = "";
	}
	
	STY_SH_BTN1Save(Controller.GetStyle("SHBTN1SaveStyle")).Images[0] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN1Save(Controller.GetStyle("SHBTN1SaveStyle")).Images[1] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN1Save(Controller.GetStyle("SHBTN1SaveStyle")).Images[2] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN1Save(Controller.GetStyle("SHBTN1SaveStyle")).Images[3] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN1Save(Controller.GetStyle("SHBTN1SaveStyle")).Images[4] = Texture(DynamicLoadObject(Image, class'Texture'));
	
	if(U.SaveGameExists(2))
	{
		Image = SHHeroController(PC).Save2Image;
		SaveSlots[2].Caption = "3";
		
		if(class'savegameinfo'.default.Save2Name != "")
		{
			SaveSlots[2].Hint = class'savegameinfo'.default.Save2Name @ "--" @ class'savegameinfo'.default.Save2Date;
		}
		else
		{
			SaveSlots[2].Hint = lhStartGame;
		}
	}
	else
	{
		Image = "storybookanimTX.box_button";
		SaveSlots[2].Caption = "";
		SaveSlots[2].Hint = lhStartGame;
		class'savegameinfo'.default.Save2Name = "";
		class'savegameinfo'.default.Save2Date = "";
	}
	
	STY_SH_BTN2Save(Controller.GetStyle("SHBTN2SaveStyle")).Images[0] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN2Save(Controller.GetStyle("SHBTN2SaveStyle")).Images[1] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN2Save(Controller.GetStyle("SHBTN2SaveStyle")).Images[2] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN2Save(Controller.GetStyle("SHBTN2SaveStyle")).Images[3] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN2Save(Controller.GetStyle("SHBTN2SaveStyle")).Images[4] = Texture(DynamicLoadObject(Image, class'Texture'));
	
	if(U.SaveGameExists(3))
	{
		Image = SHHeroController(PC).Save3Image;
		SaveSlots[3].Caption = "4";
		
		if(class'savegameinfo'.default.Save3Name != "")
		{
			SaveSlots[3].Hint = class'savegameinfo'.default.Save3Name @ "--" @ class'savegameinfo'.default.Save3Date;
		}
		else
		{
			SaveSlots[3].Hint = lhStartGame;
		}
	}
	else
	{
		Image = "storybookanimTX.box_button";
		SaveSlots[3].Caption = "";
		SaveSlots[3].Hint = lhStartGame;
		class'savegameinfo'.default.Save3Name = "";
		class'savegameinfo'.default.Save3Date = "";
	}
	
	STY_SH_BTN3Save(Controller.GetStyle("SHBTN3SaveStyle")).Images[0] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN3Save(Controller.GetStyle("SHBTN3SaveStyle")).Images[1] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN3Save(Controller.GetStyle("SHBTN3SaveStyle")).Images[2] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN3Save(Controller.GetStyle("SHBTN3SaveStyle")).Images[3] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN3Save(Controller.GetStyle("SHBTN3SaveStyle")).Images[4] = Texture(DynamicLoadObject(Image, class'Texture'));
	
	if(U.SaveGameExists(4))
	{
		Image = SHHeroController(PC).Save4Image;
		SaveSlots[4].Caption = "5";
		
		if(class'savegameinfo'.default.Save4Name != "")
		{
			SaveSlots[4].Hint = class'savegameinfo'.default.Save4Name @ "--" @ class'savegameinfo'.default.Save4Date;
		}
		else
		{
			SaveSlots[4].Hint = lhStartGame;
		}
	}
	else
	{
		Image = "storybookanimTX.box_button";
		SaveSlots[4].Caption = "";
		SaveSlots[4].Hint = lhStartGame;
		class'savegameinfo'.default.Save4Name = "";
		class'savegameinfo'.default.Save4Date = "";
	}
	
	STY_SH_BTN4Save(Controller.GetStyle("SHBTN4SaveStyle")).Images[0] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN4Save(Controller.GetStyle("SHBTN4SaveStyle")).Images[1] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN4Save(Controller.GetStyle("SHBTN4SaveStyle")).Images[2] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN4Save(Controller.GetStyle("SHBTN4SaveStyle")).Images[3] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN4Save(Controller.GetStyle("SHBTN4SaveStyle")).Images[4] = Texture(DynamicLoadObject(Image, class'Texture'));
	
	if(U.SaveGameExists(5))
	{
		Image = SHHeroController(PC).Save5Image;
		SaveSlots[5].Caption = "6";
		
		if(class'savegameinfo'.default.Save5Name != "")
		{
			SaveSlots[5].Hint = class'savegameinfo'.default.Save5Name @ "--" @ class'savegameinfo'.default.Save5Date;
		}
		else
		{
			SaveSlots[5].Hint = lhStartGame;
		}
	}
	else
	{
		Image = "storybookanimTX.box_button";
		SaveSlots[5].Caption = "";
		SaveSlots[5].Hint = lhStartGame;
		class'savegameinfo'.default.Save5Name = "";
		class'savegameinfo'.default.Save5Date = "";
	}
	
	STY_SH_BTN5Save(Controller.GetStyle("SHBTN5SaveStyle")).Images[0] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN5Save(Controller.GetStyle("SHBTN5SaveStyle")).Images[1] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN5Save(Controller.GetStyle("SHBTN5SaveStyle")).Images[2] = Texture(DynamicLoadObject(Image $ "_hili", class'Texture'));
	STY_SH_BTN5Save(Controller.GetStyle("SHBTN5SaveStyle")).Images[3] = Texture(DynamicLoadObject(Image, class'Texture'));
	STY_SH_BTN5Save(Controller.GetStyle("SHBTN5SaveStyle")).Images[4] = Texture(DynamicLoadObject(Image, class'Texture'));
	
	class'savegameinfo'.static.StaticSaveConfig();
}

event Timer()
{
	if(bPanic)
	{
		Panicking();
	}
}

function StartPanic()
{
	bPanic = true;
	iPanicButtonCounter = 0;
}

event Panicking()
{
	iPanicButtonCounter++;
	
	if(iPanicButtonCounter >= 30)
	{
		bPanic = false;
		iPanicButtonCounter = 0;
		
		PanicEnd();
	}
}

event PanicEnd()
{
	QuitButton.Caption = lQuit;
	QuitButton.Hint = lhQuit;
	
	bDeleteSaveButtonState = false;
	DeleteSaveButton.bAcceptsInput = true;
	DeleteSaveButton.Caption = lDeleteSave;
}

event bool InternalOnClick(GUIComponent Sender)
{
	local int i;
	
	super.InternalOnClick(Sender);
	
	switch(Sender)
	{
		case OptionButton:
			Controller.ReplaceMenu("SH22Game.SH22OptionsPage");
			
			break;
		case DeleteSaveButton:
			bDeleteSaveButtonState = !bDeleteSaveButtonState;
			DeleteSaveButton.bAcceptsInput = !bDeleteSaveButtonState;
			DeleteSaveButton.Caption = lDeleteSavePrompt;
			
			StartPanic();
			
			break;
		case QuitButton:
			if(bPanic)
			{
				ClosePage();
				U.Quit();
				
				return true;
			}
			
			QuitButton.Caption = lAreYouSure;
			QuitButton.Hint = lhAreYouSure;
			
			StartPanic();
			
			break;
		default:
			break;
	}
	
	for(i = 0; i < 6; i++)
	{
		if(SaveSlots[i] == Sender)
		{
			if(!bDeleteSaveButtonState)
			{
				class'SHFEGUIPage'.default.GameSlot = i;
				class'SHFEGUIPage'.static.StaticSaveConfig();
				
				if(!U.SaveGameExists(i))
				{
					KWGame(U.Level.Game).SetGameState("GSTATE000");
					U.ChangeLevel(sFirstLevel, false);
				}
				else
				{
					U.LoadAGame(i);
				}
				
				ClosePage();
			}
			else if(U.SaveGameExists(i) && bPanic)
			{
				U.KWDeleteSaveGame(i);
				
				PC = U.GetPC();
				
				if(!PC.IsA('SHHeroController'))
				{
					UpdateSaveIcons();
					
					return true;
				}
				
				switch(i)
				{
					case 0:
						SHHeroController(PC).Save0Image = "storybookanimTX.box_button";
						
						break;
					case 1:
						SHHeroController(PC).Save1Image = "storybookanimTX.box_button";
						
						break;
					case 2:
						SHHeroController(PC).Save2Image = "storybookanimTX.box_button";
						
						break;
					case 3:
						SHHeroController(PC).Save3Image = "storybookanimTX.box_button";
						
						break;
					case 4:
						SHHeroController(PC).Save4Image = "storybookanimTX.box_button";
						
						break;
					case 5:
						SHHeroController(PC).Save5Image = "storybookanimTX.box_button";
						
						break;
				}
				
				SHHeroController(PC).SaveConfig();
				
				UpdateSaveIcons();
			}
			
			break;
		}
	}
	
	return true;
}

event bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
	return super.InternalOnKeyEvent(Key, State, Delta);
}


defaultproperties
{
	Begin Object Name=lblGameBuild0 Class=GUILabel
		StyleName="FontSH10Auptimagh"
		TextAlign=TXTA_Right
		WinTop=0.98
		WinLeft=0.85
		WinWidth=0.3
		WinHeight=0.05
	End Object
	GameBuildLabel=lblGameBuild0
	Begin Object Name=lblActivision0 Class=GUILabel
		StyleName="FontSH10Auptimagh"
		TextAlign=TXTA_Left
		bMultiLine=true
		WinTop=0.98
		WinLeft=0.15
		WinWidth=0.3
		WinHeight=0.1
	End Object
	ActivisionLabel=lblActivision0
	Begin Object Name=btnSaveSlot0 Class=GUIButton
		StyleName="SHBTN0SaveStyle"
		WinTop=0.3
		WinLeft=0.375
		WinWidth=0.1
		WinHeight=0.177778
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	SaveSlot0=btnSaveSlot0
	Begin Object Name=btnSaveSlot1 Class=GUIButton
		StyleName="SHBTN1SaveStyle"
		WinTop=0.3
		WinLeft=0.5
		WinWidth=0.1
		WinHeight=0.177778
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	SaveSlot1=btnSaveSlot1
	Begin Object Name=btnSaveSlot2 Class=GUIButton
		StyleName="SHBTN2SaveStyle"
		WinTop=0.3
		WinLeft=0.625
		WinWidth=0.1
		WinHeight=0.177778
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	SaveSlot2=btnSaveSlot2
	Begin Object Name=btnSaveSlot3 Class=GUIButton
		StyleName="SHBTN3SaveStyle"
		WinTop=0.5
		WinLeft=0.375
		WinWidth=0.1
		WinHeight=0.177778
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	SaveSlot3=btnSaveSlot3
	Begin Object Name=btnSaveSlot4 Class=GUIButton
		StyleName="SHBTN4SaveStyle"
		WinTop=0.5
		WinLeft=0.5
		WinWidth=0.1
		WinHeight=0.177778
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	SaveSlot4=btnSaveSlot4
	Begin Object Name=btnSaveSlot5 Class=GUIButton
		StyleName="SHBTN5SaveStyle"
		WinTop=0.5
		WinLeft=0.625
		WinWidth=0.1
		WinHeight=0.177778
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	SaveSlot5=btnSaveSlot5
	Begin Object Name=btnOption0 Class=GUIButton
		StyleName="SHBTNOptionsStyle"
		WinTop=0.65
		WinLeft=0.5
		WinWidth=0.3
		WinHeight=0.06
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	OptionButton=btnOption0
	Begin Object Name=btnDeleteSave0 Class=GUIButton
		StyleName="SHBTNDeleteStyle"
		WinTop=0.75
		WinLeft=0.5
		WinWidth=0.3
		WinHeight=0.06
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	DeleteSaveButton=btnDeleteSave0
	Begin Object Name=btnQuit0 Class=GUIButton
		StyleName="SHBTNQuitStyle"
		WinTop=0.85
		WinLeft=0.5
		WinWidth=0.3
		WinHeight=0.06
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	QuitButton=btnQuit0
	Begin Object Name=btnCustomMaps0 Class=GUIButton
		StyleName="SHBTNYesStyle"
		WinTop=0.5
		WinLeft=0.9
		WinWidth=0.2
		WinHeight=0.06
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	CustomAdventuresButton=btnCustomMaps0
	Begin Object Name=btnCheats0 Class=GUIButton
		StyleName="SHBTNYesStyle"
		WinTop=0.56
		WinLeft=0.9
		WinWidth=0.2
		WinHeight=0.06
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	CheatsButton=btnCheats0
	Begin Object Name=btnMultiplayer0 Class=GUIButton
		StyleName="SHBTNYesStyle"
		WinTop=0.44
		WinLeft=0.9
		WinWidth=0.2
		WinHeight=0.06
		bNeverFocus=true
		OnClick=InternalOnClick
	End Object
	MultiplayerButton=btnMultiplayer0
	Begin Object Name=imgLogo0 Class=GUIImage
		Image=Texture'SH22_Tex.Logo_Text'
		ImageAlign=IMGA_Center
		WinTop=0.1
		WinLeft=0.5
		WinWidth=1.0
		WinHeight=1.0
	End Object
	GameLogo=imgLogo0
	bEscapeClosesPage=false
	sFirstLevel="1_Storybook_Chapter_1"
}