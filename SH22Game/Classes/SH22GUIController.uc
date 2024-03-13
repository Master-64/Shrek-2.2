// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22GUIController extends SHGUIController
	Config(SH22);


exec function OnGameMinimize()
{
	ConsoleCommand("PAUSESOUNDS");
	ConsoleCommand("ShowMininized");
}

exec function OnGameMaximize()
{
	ConsoleCommand("UNPAUSESOUNDS");
	
	if(ActivePage == none)
	{
		ConsoleCommand("ShowMaximized");
	}
}


defaultproperties
{
	SHFontNames(0)="SHGame.FONT_SH_Button"
	SHFontNames(1)="SHGame.FONT_SH_ButtonBig"
	SHFontNames(2)="SHGame.FONT_SH_ButtonHuge"
	SHFontNames(3)="SHGame.FONT_SH_Pigae"
	SHFontNames(4)="SHGame.FONT_SH_18Pigae"
	SHFontNames(5)="SHGame.FONT_SH_14Pigae"
	SHFontNames(6)="SHGame.FONT_SH_24Pigae"
	SHFontNames(7)="SHGame.FONT_SH_48Pigae"
	SHFontNames(8)="SHGame.FONT_SH_12Auptimagh"
	SHFontNames(9)="SHGame.FONT_SH_14Auptimagh"
	SHFontNames(10)="SHGame.FONT_SH_18Auptimagh"
	SHFontNames(11)="SHGame.FONT_SH_10Auptimagh"
	SHFontNames(12)="SHGame.FONT_SH_24Auptimagh"
	SHStyleNames(0)="SHGame.STY_SH_SolidBox"
	SHStyleNames(1)="SHGame.STY_SH_FadeStyle"
	SHStyleNames(2)="SHGame.STY_SH_BTNOptions"
	SHStyleNames(3)="SHGame.STY_SH_BTNDelete"
	SHStyleNames(4)="SHGame.STY_SH_BTNQuit"
	SHStyleNames(5)="SHGame.STY_SH_BTNLabel"
	SHStyleNames(6)="SHGame.STY_SH_BTN0Save"
	SHStyleNames(7)="SHGame.STY_SH_BTN1Save"
	SHStyleNames(8)="SHGame.STY_SH_BTN2Save"
	SHStyleNames(9)="SHGame.STY_SH_BTN3Save"
	SHStyleNames(10)="SHGame.STY_SH_BTN4Save"
	SHStyleNames(11)="SHGame.STY_SH_BTN5Save"
	SHStyleNames(12)="SHGame.STY_SH_NoFadeLabel"
	SHStyleNames(13)="SHGame.STY_IG_BTNPlay"
	SHStyleNames(14)="SHGame.STY_IG_BTNWantedPoster"
	SHStyleNames(15)="SHGame.STY_IG_BTNOptions"
	SHStyleNames(16)="SHGame.STY_IG_BTNMainMenu"
	SHStyleNames(17)="SHGame.STY_IG_BTNQuit"
	SHStyleNames(18)="SHGame.STY_SH_BTNYes"
	SHStyleNames(19)="SHGame.STY_SH_BTNNo"
	SHStyleNames(20)="SHGame.STY_SH_BTNLabel2sh"
	SHStyleNames(21)="SHGame.STY_SH_BTNBack"
	SHStyleNames(22)="SHGame.STY_SH_TabOptions1BTN"
	SHStyleNames(23)="SHGame.STY_IG_BTN0Poster"
	SHStyleNames(24)="SHGame.STY_IG_BTN1Poster"
	SHStyleNames(25)="SHGame.STY_IG_BTN2Poster"
	SHStyleNames(26)="SHGame.STY_IG_BTN3Poster"
	SHStyleNames(27)="SHGame.STY_IG_BTN4Poster"
	SHStyleNames(28)="SHGame.STY_IG_BTN5Poster"
	SHStyleNames(29)="SHGame.STY_IG_BTN6Poster"
	SHStyleNames(30)="SHGame.STY_IG_BTN7Poster"
	SHStyleNames(31)="SHGame.STY_IG_BTN8Poster"
	SHStyleNames(32)="SHGame.STY_IG_BTN9Poster"
	SHStyleNames(33)="SHGame.STY_IG_BTN10Poster"
	SHStyleNames(34)="SHGame.STY_IG_BTN11Poster"
	SHStyleNames(35)="SHGame.STY_SH_TabOptions2BTN"
	SHStyleNames(36)="SHGame.STY_SH_TabOptions3BTN"
	SHStyleNames(37)="SHGame.STY_SH_NoFadeBox"
	SHStyleNames(38)="SHGame.STY_SH_NoFadeBoxBigFont"
	SHStyleNames(39)="SHGame.STY_FGM_Accept"
	SHStyleNames(40)="SHGame.STY_FGM_Cancel"
	SHStyleNames(41)="SHGame.STY_FGM_Buy"
	SHStyleNames(42)="SHGame.STY_FGM_HugeFont"
	SHStyleNames(43)="SHGame.STY_SHNoBackground"
	SHStyleNames(44)="SHGame.STY_SH18Pigae"
	SHStyleNames(45)="SHGame.STY_SH14Pigae"
	SHStyleNames(46)="SHGame.STY_FGM_CoinCount"
	SHStyleNames(47)="SHGame.STY_SH18Auptimagh"
	SHStyleNames(48)="SHGame.STY_SH14Auptimagh"
	SHStyleNames(49)="SHGame.STY_SH14AuptimaghRed"
	SHStyleNames(50)="SHGame.STY_SH12AuptimaghBlack"
	SHStyleNames(51)="SHGame.STY_FGM_Help"
	SHStyleNames(52)="SHGame.STY_SH_OptionsBtn"
	SHStyleNames(53)="SHGame.STY_SH_AcceptBK"
	SHStyleNames(54)="SHGame.STY_SH_OptionsBtnSolid"
	SHStyleNames(55)="SHGame.STY_SHAuptimaghRed"
	SHStyleNames(56)="SHGame.STY_SH_Hint"
	SHStyleNames(57)="SHGame.STY_SH_DeleteLabel"
	SHStyleNames(58)="SHGame.STY_SH_Slider"
	SHStyleNames(59)="SHGame.STY_IG_BTNLoad"
	SHStyleNames(60)="SHGame.STY_SH_BTNLabel3sh"
	SHStyleNames(61)="SHGame.STY_SH_BTNLabel4sh"
	SHStyleNames(62)="SHGame.STY_PS_1Potion"
	SHStyleNames(63)="SHGame.STY_PS_2Potion"
	SHStyleNames(64)="SHGame.STY_PS_3Potion"
	SHStyleNames(65)="SHGame.STY_PS_4Potion"
	SHStyleNames(66)="SHGame.STY_PS_5Potion"
	SHStyleNames(67)="SHGame.STY_PS_6Potion"
	SHStyleNames(68)="SHGame.STY_PS_7Potion"
	SHStyleNames(69)="SHGame.STY_PS_8Potion"
	SHStyleNames(70)="SHGame.STY_PS_9Potion"
	SHStyleNames(71)="SHGame.STY_SH14AuptimaghBlack"
	SHStyleNames(72)="SHGame.STY_FGM_Potions"
	SHStyleNames(73)="SHGame.STY_FGM_1Potion"
	SHStyleNames(74)="SHGame.STY_FGM_2Potion"
	SHStyleNames(75)="SHGame.STY_FGM_3Potion"
	SHStyleNames(76)="SHGame.STY_FGM_4Potion"
	SHStyleNames(77)="SHGame.STY_FGM_5Potion"
	SHStyleNames(78)="SHGame.STY_FGM_6Potion"
	SHStyleNames(79)="SHGame.STY_FGM_7Potion"
	SHStyleNames(80)="SHGame.STY_FGM_8Potion"
	SHStyleNames(81)="SHGame.STY_FGM_9Potion"
	SHStyleNames(82)="SHGame.STY_SH12AuptimaghWhite"
	SHStyleNames(83)="SHGame.STY_SH_optionlabel"
	SHStyleNames(84)="SHGame.STY_SH12Auptimagh"
	SHStyleNames(85)="SHGame.STY_PS_PotionSelect"
	SHStyleNames(86)="SHGame.STY_SH14AuptimaghWhite"
	SHStyleNames(87)="SHGame.STY_SH_Options12Box"
}