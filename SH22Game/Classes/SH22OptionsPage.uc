// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22OptionsPage extends MGUIPage
	Config(SH22);


const iKeyBindCount = 8;

enum ECurrentMenu
{
	CM_Input,
	CM_Game,
	CM_Video,
	CM_Sound
};

struct KeyActions
{
	var byte bKey;
	var string Key, Action;
};

struct dgVoodooVariablesStruct
{
	var string FPSLimit, Filtering, Antialiasing, VRAM, Brightness, Contrast, Color, DisableAndPassThru, Bilinear2DOperations, FastVideoMemoryAccess;
};

var ECurrentMenu CurrentMenu;
var GUIComponent KeyToBind;
var array<KeyActions> KeyBinds;
var dgVoodooVariablesStruct dgVoodooVariables;
var array<string> sKeyBindActions;
var array<int> iCurrentKeyBindActions;
var bool bAdvancedVideoOptionsChanged;
var localized string lNoKeyAction, lDifficultyMode1, lDifficultyMode2, lDifficultyMode3, lDifficultyMode4, lObjectDetailHigh, lObjectDetailMedium, lObjectDetailLow, lShadowDetailSuperHigh, lShadowDetailHigh, lShadowDetailLow, lShadowDetailNone, lViewDistanceInfinite, lViewDistanceVeryFar, lViewDistanceFar, lViewDistanceMedium, lViewDistanceShort, lFramerateLimitUncapped, lTrue, lFalse;
var config array<int> iFramerateCaps;
var config array<string> sSupportedResolutions;

// Core options menu
var automated config GUIButton InputTab, GameTab, VideoTab, SoundTab, Back;
var automated config GUIComponent CoreOptions[5];
var localized string lInputTab, lhInputTab, lGameTab, lhGameTab, lVideoTab, lhVideoTab, lSoundTab, lhSoundTab, lBack, lhBack;

// Input options
var automated config GUIButton KeyForward, KeyBackward, KeyLeft, KeyRight, KeyAttack, KeyJump, KeyEscape, KeySkipCutscene, ResetKeys;
var automated config GUISlider MouseSensitivity;
var automated config GUIComponent InputOptions[10];
var automated config GUILabel KeyForwardLabel, KeyBackwardLabel, KeyLeftLabel, KeyRightLabel, KeyAttackLabel, KeyJumpLabel, KeyEscapeLabel, KeySkipCutsceneLabel, ResetKeysLabel, MouseSensitivityLabel, InputLabels[10];
var localized string lKeyForward, lhKeyForward, lKeyBackward, lhKeyBackward, lKeyLeft, lhKeyLeft, lKeyRight, lhKeyRight, lKeyAttack, lhKeyAttack, lKeyJump, lhKeyJump, lKeyEscape, lhKeyEscape, lKeySkipCutscene, lhKeySkipCutscene, lMouseSensitivity, lhMouseSensitivity, lResetKeys, lhResetKeys;

// Game options
var automated config SHGUIComboBox DifficultyModes;
var automated config GUISlider FieldOfView;
var automated config GUIButton AutoLevelCamera, DisableIntroMovies;
var automated config GUIComponent GameOptions[4];
var automated config GUILabel DifficultyModesLabel, FieldOfViewLabel, AutoLevelCameraLabel, DisableIntroMoviesLabel, GameLabels[4];
var localized string lDifficultyModes, lhDifficultyModes, lFieldOfView, lhFieldOfView, lAutoLevelCamera, lhAutoLevelCamera, lDisableIntroMovies, lhDisableIntroMovies;

// Video options
var automated config SHGUIComboBox ScreenResolution, ObjectDetail, ShadowDetail, ViewDistance;
var automated config GUIButton AdvancedSettings;
var automated config GUIComponent VideoOptions[5];
var automated config GUILabel ScreenResolutionLabel, ObjectDetailLabel, ShadowDetailLabel, ViewDistanceLabel, AdvancedSettingsLabel, VideoLabels[5];
var localized string lScreenResolution, lhScreenResolution, lObjectDetail, lhObjectDetail, lShadowDetail, lhShadowDetail, lViewDistance, lhViewDistance, lAdvancedSettings, lhAdvancedSettings;

// Advanced video options
var automated config SHGUIComboBox FramerateLimit, TextureFiltering, Antialiasing, VRAMAllocation;
var automated config GUISlider ScreenBrightness, ScreenContrast, ScreenColorVibrancy;
var automated config GUIButton PerformanceMode, CompatibilityMode;
var automated config GUIComponent AdvancedVideoOptions[9];
var automated config GUILabel FramerateLimitLabel, TextureFilteringLabel, AntialiasingLabel, VRAMAllocationLabel, ScreenBrightnessLabel, ScreenContrastLabel, ScreenColorVibrancyLabel, PerformanceModeLabel, CompatibilityModeLabel, AdvancedVideoLabels[9];
var localized string lFramerateLimit, lhFramerateLimit, lTextureFiltering, lhTextureFiltering, lAntialiasing, lhAntialiasing, lVRAMAllocation, lhVRAMAllocation, lScreenBrightness, lhScreenBrightness, lScreenContrast, lhScreenContrast, lScreenColorVibrancy, lhScreenColorVibrancy, lPerformanceMode, lhPerformanceMode, lCompatibilityMode, lhCompatibilityMode;

// Sound options
var automated config GUISlider GameVolume, MusicVolume;
var automated config GUIButton RestartSoundDriver;
var automated config GUIComponent SoundOptions[3];
var automated config GUILabel GameVolumeLabel, MusicVolumeLabel, RestartSoundDriverLabel, SoundLabels[3];
var localized string lGameVolume, lhGameVolume, lMusicVolume, lhMusicVolume, lRestartSoundDriver, lhRestartSoundDriver;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	
	super.InitComponent(MyController, MyOwner);
	
	__OnClick__Delegate = InternalOnClick;
	__OnKeyEvent__Delegate = InternalOnKeyEvent;
	
	for(i = 0; i < Controls.Length; i++)
	{
		Controls[i].__OnChange__Delegate = InternalOnChange;
	}
	
	TabFooter.WinLeft = 0.493;
	TabFooter.WinTop = 0.9;
	
	GetdgVoodooVariables();
	
	// Sort and center all GUI components
	CoreOptions[0] = InputTab;
	CoreOptions[1] = GameTab;
	CoreOptions[2] = VideoTab;
	CoreOptions[3] = SoundTab;
	CoreOptions[4] = Back;
	
	for(i = 0; i < 5; i++)
	{
		CenterComponent(CoreOptions[i]);
	}
	
	InputOptions[0] = KeyForward;
	InputOptions[1] = KeyBackward;
	InputOptions[2] = KeyLeft;
	InputOptions[3] = KeyRight;
	InputOptions[4] = KeyAttack;
	InputOptions[5] = KeyJump;
	InputOptions[6] = KeyEscape;
	InputOptions[7] = KeySkipCutscene;
	InputOptions[8] = ResetKeys;
	InputOptions[9] = MouseSensitivity;
	InputLabels[0] = KeyForwardLabel;
	InputLabels[1] = KeyBackwardLabel;
	InputLabels[2] = KeyLeftLabel;
	InputLabels[3] = KeyRightLabel;
	InputLabels[4] = KeyAttackLabel;
	InputLabels[5] = KeyJumpLabel;
	InputLabels[6] = KeyEscapeLabel;
	InputLabels[7] = KeySkipCutsceneLabel;
	InputLabels[8] = ResetKeysLabel;
	InputLabels[9] = MouseSensitivityLabel;
	
	for(i = 0; i < 10; i++)
	{
		CenterComponent(InputOptions[i]);
		CenterComponent(InputLabels[i]);
	}
	
	GameOptions[0] = DifficultyModes;
	GameOptions[1] = FieldOfView;
	GameOptions[2] = AutoLevelCamera;
	GameOptions[3] = DisableIntroMovies;
	GameLabels[0] = DifficultyModesLabel;
	GameLabels[1] = FieldOfViewLabel;
	GameLabels[2] = AutoLevelCameraLabel;
	GameLabels[3] = DisableIntroMoviesLabel;
	
	for(i = 0; i < 4; i++)
	{
		CenterComponent(GameOptions[i]);
		CenterComponent(GameLabels[i]);
	}
	
	VideoOptions[0] = ScreenResolution;
	VideoOptions[1] = ObjectDetail;
	VideoOptions[2] = ShadowDetail;
	VideoOptions[3] = ViewDistance;
	VideoOptions[4] = AdvancedSettings;
	VideoLabels[0] = ScreenResolutionLabel;
	VideoLabels[1] = ObjectDetailLabel;
	VideoLabels[2] = ShadowDetailLabel;
	VideoLabels[3] = ViewDistanceLabel;
	VideoLabels[4] = AdvancedSettingsLabel;
	
	for(i = 0; i < 5; i++)
	{
		CenterComponent(VideoOptions[i]);
		CenterComponent(VideoLabels[i]);
	}
	
	AdvancedVideoOptions[0] = FramerateLimit;
	AdvancedVideoOptions[1] = TextureFiltering;
	AdvancedVideoOptions[2] = Antialiasing;
	AdvancedVideoOptions[3] = VRAMAllocation;
	AdvancedVideoOptions[4] = ScreenBrightness;
	AdvancedVideoOptions[5] = ScreenContrast;
	AdvancedVideoOptions[6] = ScreenColorVibrancy;
	AdvancedVideoOptions[7] = PerformanceMode;
	AdvancedVideoOptions[8] = CompatibilityMode;
	AdvancedVideoLabels[0] = FramerateLimitLabel;
	AdvancedVideoLabels[1] = TextureFilteringLabel;
	AdvancedVideoLabels[2] = AntialiasingLabel;
	AdvancedVideoLabels[3] = VRAMAllocationLabel;
	AdvancedVideoLabels[4] = ScreenBrightnessLabel;
	AdvancedVideoLabels[5] = ScreenContrastLabel;
	AdvancedVideoLabels[6] = ScreenColorVibrancyLabel;
	AdvancedVideoLabels[7] = PerformanceModeLabel;
	AdvancedVideoLabels[8] = CompatibilityModeLabel;
	
	for(i = 0; i < 9; i++)
	{
		CenterComponent(AdvancedVideoOptions[i]);
		CenterComponent(AdvancedVideoLabels[i]);
	}
	
	SoundOptions[0] = GameVolume;
	SoundOptions[1] = MusicVolume;
	SoundOptions[2] = RestartSoundDriver;
	SoundLabels[0] = GameVolumeLabel;
	SoundLabels[1] = MusicVolumeLabel;
	SoundLabels[3] = RestartSoundDriverLabel;
	
	for(i = 0; i < 3; i++)
	{
		CenterComponent(SoundOptions[i]);
		CenterComponent(SoundLabels[i]);
	}
	
	CenterComponent(TabFooter);
	
	// Localize all GUI components
	InputTab.Caption = lInputTab;
	InputTab.Hint = lhInputTab;
	GameTab.Caption = lGameTab;
	GameTab.Hint = lhGameTab;
	VideoTab.Caption = lVideoTab;
	VideoTab.Hint = lhVideoTab;
	SoundTab.Caption = lSoundTab;
	SoundTab.Hint = lhSoundTab;
	Back.Caption = lBack;
	Back.Hint = lhBack;
	
	KeyForwardLabel.Caption = lKeyForward;
	KeyForward.Hint = lhKeyForward;
	KeyBackwardLabel.Caption = lKeyBackward;
	KeyBackward.Hint = lhKeyBackward;
	KeyLeftLabel.Caption = lKeyLeft;
	KeyLeft.Hint = lhKeyLeft;
	KeyRightLabel.Caption = lKeyRight;
	KeyRight.Hint = lhKeyRight;
	KeyAttackLabel.Caption = lKeyAttack;
	KeyAttack.Hint = lhKeyAttack;
	KeyJumpLabel.Caption = lKeyJump;
	KeyJump.Hint = lhKeyJump;
	KeyEscapeLabel.Caption = lKeyEscape;
	KeyEscape.Hint = lhKeyEscape;
	KeySkipCutsceneLabel.Caption = lKeySkipCutscene;
	KeySkipCutscene.Hint = lhKeySkipCutscene;
	ResetKeys.Caption = lResetKeys;
	ResetKeys.Hint = lhResetKeys;
	MouseSensitivityLabel.Caption = lMouseSensitivity;
	MouseSensitivity.Hint = lhMouseSensitivity;
	
	DifficultyModesLabel.Caption = lDifficultyModes;
	DifficultyModes.Edit.Hint = lhDifficultyModes;
	FieldOfViewLabel.Caption = lFieldOfView;
	FieldOfView.Hint = lhFieldOfView;
	AutoLevelCameraLabel.Caption = lAutoLevelCamera;
	AutoLevelCamera.Hint = lhAutoLevelCamera;
	DisableIntroMoviesLabel.Caption = lDisableIntroMovies;
	DisableIntroMovies.Hint = lhDisableIntroMovies;
	
	ScreenResolutionLabel.Caption = lScreenResolution;
	ScreenResolution.Edit.Hint = lhScreenResolution;
	ObjectDetailLabel.Caption = lObjectDetail;
	ObjectDetail.Edit.Hint = lhObjectDetail;
	ShadowDetailLabel.Caption = lShadowDetail;
	ShadowDetail.Edit.Hint = lhShadowDetail;
	ViewDistanceLabel.Caption = lViewDistance;
	ViewDistance.Edit.Hint = lhViewDistance;
	AdvancedSettings.Caption = lAdvancedSettings;
	AdvancedSettings.Hint = lhAdvancedSettings;
	
	FramerateLimitLabel.Caption = lFramerateLimit;
	FramerateLimit.Edit.Hint = lhFramerateLimit;
	TextureFilteringLabel.Caption = lTextureFiltering;
	TextureFiltering.Edit.Hint = lhTextureFiltering;
	AntialiasingLabel.Caption = lAntialiasing;
	Antialiasing.Edit.Hint = lhAntialiasing;
	VRAMAllocationLabel.Caption = lVRAMAllocation;
	VRAMAllocation.Edit.Hint = lhVRAMAllocation;
	ScreenBrightnessLabel.Caption = lScreenBrightness;
	ScreenBrightness.Hint = lhScreenBrightness;
	ScreenContrastLabel.Caption = lScreenContrast;
	ScreenContrast.Hint = lhScreenContrast;
	ScreenColorVibrancyLabel.Caption = lScreenColorVibrancy;
	ScreenColorVibrancy.Hint = lhScreenColorVibrancy;
	PerformanceModeLabel.Caption = lPerformanceMode;
	PerformanceMode.Hint = lhPerformanceMode;
	CompatibilityModeLabel.Caption = lCompatibilityMode;
	CompatibilityMode.Hint = lhCompatibilityMode;
	
	GameVolumeLabel.Caption = lGameVolume;
	GameVolume.Hint = lhGameVolume;
	MusicVolumeLabel.Caption = lMusicVolume;
	MusicVolume.Hint = lhMusicVolume;
	RestartSoundDriver.Caption = lRestartSoundDriver;
	RestartSoundDriver.Hint = lhRestartSoundDriver;
	
	// Initialize all slider GUIs
	MouseSensitivity.SetValue(class'PlayerInput'.default.MouseSensitivity);
	FieldOfView.SetValue(class'SH22Config'.default.fDefaultFOV);
	ScreenBrightness.SetValue(int(dgVoodooVariables.Brightness));
	ScreenContrast.SetValue(int(dgVoodooVariables.Contrast));
	ScreenColorVibrancy.SetValue(int(dgVoodooVariables.Color));
	GameVolume.SetValue(float(U.CC("Get ini:Engine.Engine.AudioDevice SoundVolume")));
	MusicVolume.SetValue(float(U.CC("Get ini:Engine.Engine.AudioDevice MusicVolume")));
	
	// Initialize all combo box GUIs
	DifficultyModes.AddItem(lDifficultyMode1);
	DifficultyModes.AddItem(lDifficultyMode2);
	DifficultyModes.AddItem(lDifficultyMode3);
	
	if(class'SH22Config'.default.bSecretDifficultyModeUnlocked)
	{
		DifficultyModes.AddItem(lDifficultyMode4);
	}
	
	for(i = 0; i < sSupportedResolutions.Length; i++)
	{
		ScreenResolution.AddItem(sSupportedResolutions[i]);
	}
	
	ObjectDetail.AddItem(lObjectDetailHigh);
	ObjectDetail.AddItem(lObjectDetailMedium);
	ObjectDetail.AddItem(lObjectDetailLow);
	
	ShadowDetail.AddItem(lShadowDetailSuperHigh);
	ShadowDetail.AddItem(lShadowDetailHigh);
	ShadowDetail.AddItem(lShadowDetailLow);
	ShadowDetail.AddItem(lShadowDetailNone);
	
	ViewDistance.AddItem(lViewDistanceInfinite);
	ViewDistance.AddItem(lViewDistanceVeryFar);
	ViewDistance.AddItem(lViewDistanceFar);
	ViewDistance.AddItem(lViewDistanceMedium);
	ViewDistance.AddItem(lViewDistanceShort);
	
	FramerateLimit.AddItem(lFramerateLimitUncapped);
	
	for(i = 0; i < iFramerateCaps.Length; i++)
	{
		FramerateLimit.AddItem(string(iFramerateCaps[i]));
	}
	
	TextureFiltering.AddItem("Anisotropic 1x");
	TextureFiltering.AddItem("Anisotropic 2x");
	TextureFiltering.AddItem("Anisotropic 4x");
	TextureFiltering.AddItem("Anisotropic 8x");
	TextureFiltering.AddItem("Anisotropic 16x");
	
	Antialiasing.AddItem("Disabled");
	Antialiasing.AddItem("MSAA 2x");
	Antialiasing.AddItem("MSAA 4x");
	Antialiasing.AddItem("MSAA 8x");
	
	VRAMAllocation.AddItem("64 MB");
	VRAMAllocation.AddItem("128 MB");
	VRAMAllocation.AddItem("256 MB");
	VRAMAllocation.AddItem("512 MB");
	VRAMAllocation.AddItem("1024 MB");
	
	// Miscellaneous initialization
	AutoLevelCamera.Caption = U.BoolToString(class'SH22Config'.default.bAutoLevelCamera);
	DisableIntroMovies.Caption = U.BoolToString(class'SH22Config'.default.bDisableIntroMovies);
	PerformanceMode.Caption = U.BoolToString(bool(dgVoodooVariables.Bilinear2DOperations));
	CompatibilityMode.Caption = U.BoolToString(bool(dgVoodooVariables.DisableAndPassThru));
	
	GetKeyBindings();
	UpdateKeyBindings();
	
	// Finalizing initialization
	ChangeMenu(CM_Input);
}

function ChangeMenu(ECurrentMenu NewMenu) // Changes the current menu
{
	local int i;
	local bool bShow;
	
	bShow = NewMenu == CM_Input;
	
	for(i = 0; i < 10; i++)
	{
		InputOptions[i].SetVisibility(bShow);
		InputOptions[i].bAcceptsInput = bShow;
		InputOptions[i].SetFocus(none);
		InputLabels[i].SetVisibility(bShow);
	}
	
	bShow = NewMenu == CM_Game;
	
	for(i = 0; i < 4; i++)
	{
		GameOptions[i].SetVisibility(bShow);
		GameOptions[i].bAcceptsInput = bShow;
		GameOptions[i].SetFocus(none);
		GameLabels[i].SetVisibility(bShow);
	}
	
	bShow = NewMenu == CM_Video;
	
	for(i = 0; i < 5; i++)
	{
		VideoOptions[i].SetVisibility(bShow);
		VideoOptions[i].bAcceptsInput = bShow;
		VideoOptions[i].SetFocus(none);
		VideoLabels[i].SetVisibility(bShow);
	}
	
	bShow = NewMenu == CM_Sound;
	
	for(i = 0; i < 3; i++)
	{
		SoundOptions[i].SetVisibility(bShow);
		SoundOptions[i].bAcceptsInput = bShow;
		SoundOptions[i].SetFocus(none);
		SoundLabels[i].SetVisibility(bShow);
	}
	
	for(i = 0; i < 9; i++)
	{
		AdvancedVideoOptions[i].SetVisibility(false);
		AdvancedVideoOptions[i].bAcceptsInput = false;
		AdvancedVideoOptions[i].SetFocus(none);
		AdvancedVideoLabels[i].SetVisibility(false);
	}
	
	CurrentMenu = NewMenu;
}

event bool InternalOnClick(GUIComponent Sender)
{
	local int i;
	
	super.InternalOnClick(Sender);
	
	switch(Sender)
	{
		case InputTab:
			ChangeMenu(CM_Input);
			
			break;
		case GameTab:
			ChangeMenu(CM_Game);
			
			break;
		case VideoTab:
			ChangeMenu(CM_Video);
			
			break;
		case SoundTab:
			ChangeMenu(CM_Sound);
			
			break;
		case Back:
			if(bAdvancedVideoOptionsChanged)
			{
				WritedgVoodooVariables();
				
				return true;
			}
			
			Controller.ReplaceMenu("SH22Game.SH22MainMenuPage");
			
			break;
		case KeyForward:
		case KeyBackward:
		case KeyLeft:
		case KeyRight:
		case KeyAttack:
		case KeyJump:
		case KeyEscape:
		case KeySkipCutscene:
			KeyToBind = Sender;
			
			SetTimer(3.0, false);
			
			break;
		case ResetKeys:
			ResetKeyBindings();
			GetKeyBindings();
			UpdateKeyBindings();
			
			break;
		case AutoLevelCamera:
			class'SH22Config'.default.bAutoLevelCamera = !class'SH22Config'.default.bAutoLevelCamera;
			class'SH22Config'.static.StaticSaveConfig();
			
			AutoLevelCamera.Caption = U.BoolToString(class'SH22Config'.default.bAutoLevelCamera);
			
			break;
		case DisableIntroMovies:
			class'SH22Config'.default.bDisableIntroMovies = !class'SH22Config'.default.bDisableIntroMovies;
			class'SH22Config'.static.StaticSaveConfig();
			
			DisableIntroMovies.Caption = U.BoolToString(class'SH22Config'.default.bDisableIntroMovies);
			
			break;
		case AdvancedSettings:
			for(i = 0; i < 9; i++)
			{
				AdvancedVideoOptions[i].SetVisibility(true);
				AdvancedVideoOptions[i].bAcceptsInput = true;
				AdvancedVideoLabels[i].SetVisibility(true);
			}
			
			AdvancedSettings.SetVisibility(false);
			AdvancedSettingsLabel.SetVisibility(false);
			
			break;
		case PerformanceMode:
			dgVoodooVariables.Bilinear2DOperations = U.BoolToString(!bool(dgVoodooVariables.Bilinear2DOperations));
			dgVoodooVariables.FastVideoMemoryAccess = U.BoolToString(!bool(dgVoodooVariables.FastVideoMemoryAccess));
			
			PerformanceMode.Caption = U.BoolToString(bool(dgVoodooVariables.Bilinear2DOperations));
			
			bAdvancedVideoOptionsChanged = true;
			
			break;
		case CompatibilityMode:
			dgVoodooVariables.DisableAndPassThru = U.BoolToString(!bool(dgVoodooVariables.DisableAndPassThru));
			
			CompatibilityMode.Caption = U.BoolToString(bool(dgVoodooVariables.DisableAndPassThru));
			
			bAdvancedVideoOptionsChanged = true;
			
			break;
		case RestartSoundDriver:
			U.RestartSound();
			
			break;
		default:
			break;
	}
	
	return true;
}

event Timer()
{
	KeyToBind = none;
}

event InternalOnChange(GUIComponent Sender)
{
	if(!Controller.bCurMenuInitialized)
	{
		return;
	}
	
	switch(Sender)
	{
		case MouseSensitivity:
			U.CC("Set PlayerInput MouseSensitivity" @ string(MouseSensitivity.Value));
			class'PlayerInput'.default.MouseSensitivity = MouseSensitivity.Value;
			class'PlayerInput'.static.StaticSaveConfig();
			
			break;
		case DifficultyModes:
			switch(DifficultyModes.Edit.GetText())
			{
				case lDifficultyMode1:
					class'SH22Config'.default.DifficultyMode = DM_Relaxed;
					
					break;
				case lDifficultyMode2:
					class'SH22Config'.default.DifficultyMode = DM_Classic;
					
					break;
				case lDifficultyMode3:
					class'SH22Config'.default.DifficultyMode = DM_Knight;
					
					break;
				case lDifficultyMode4:
					class'SH22Config'.default.DifficultyMode = DM_INeedAHero;
					
					break;
			}
			
			class'SH22Config'.static.StaticSaveConfig();
			
			break;
		case FieldOfView:
			class'SH22Config'.default.fDefaultFOV = FieldOfView.Value;
			class'SH22Config'.static.StaticSaveConfig();
			
			break;
		case ScreenResolution:
			U.CC("SetRes" @ ScreenResolution.Edit.GetText());
			
			break;
		case ObjectDetail:
			switch(ObjectDetail.Edit.GetText())
			{
				case lObjectDetailHigh:
					U.CC("Set ini:Engine.Engine.RenderDevice SuperHighDetailActors True");
					U.CC("Set ini:Engine.Engine.RenderDevice HighDetailActors True");
					U.Level.DetailChange(DM_SuperHigh);
					
					break;
				case lObjectDetailMedium:
					U.CC("Set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
					U.CC("Set ini:Engine.Engine.RenderDevice HighDetailActors True");
					U.Level.DetailChange(DM_High);
					
					break;
				case lObjectDetailLow:
					U.CC("Set ini:Engine.Engine.RenderDevice SuperHighDetailActors False");
					U.CC("Set ini:Engine.Engine.RenderDevice HighDetailActors False");
					U.Level.DetailChange(DM_Low);
					
					break;
			}
			
			break;
		case ShadowDetail:
			switch(ShadowDetail.Edit.GetText())
			{
				case lShadowDetailSuperHigh:
					class'SH22Config'.default.ShadowDetail = DM_SuperHigh;
					
					break;
				case lShadowDetailHigh:
					class'SH22Config'.default.ShadowDetail = DM_High;
					
					break;
				case lShadowDetailLow:
					class'SH22Config'.default.ShadowDetail = DM_Low;
					
					break;
				case lShadowDetailNone:
					class'SH22Config'.default.ShadowDetail = DM_None;
					
					break;
			}
			
			class'SH22Config'.static.StaticSaveConfig();
			
			break;
		case ViewDistance:
			switch(ViewDistance.Edit.GetText())
			{
				case lViewDistanceInfinite:
					class'SH22Config'.default.ViewDistance = DM_Infinite;
					
					break;
				case lViewDistanceVeryFar:
					class'SH22Config'.default.ViewDistance = DM_VeryFar;
					
					break;
				case lViewDistanceFar:
					class'SH22Config'.default.ViewDistance = DM_Far;
					
					break;
				case lViewDistanceMedium:
					class'SH22Config'.default.ViewDistance = DM_Medium;
					
					break;
				case lViewDistanceShort:
					class'SH22Config'.default.ViewDistance = DM_Short;
					
					break;
			}
			
			class'SH22Config'.static.StaticSaveConfig();
			
			break;
		case FramerateLimit:
		case TextureFiltering:
		case Antialiasing:
		case VRAMAllocation:
		case ScreenBrightness:
		case ScreenContrast:
		case ScreenColorVibrancy:
			bAdvancedVideoOptionsChanged = true;
			
			break;
		case GameVolume:
			U.CC("Set ini:Engine.Engine.AudioDevice SoundVolume" @ string(GameVolume.Value));
			
			break;
		case MusicVolume:
			U.CC("Set ini:Engine.Engine.AudioDevice MusicVolume" @ string(MusicVolume.Value));
			
			break;
		default:
			break;
	}
}

event bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
	local string sBind;
	local int i;
	
	if(State == 1 && KeyToBind != none && (Key > 231 || Key < 228))
	{
		switch(KeyToBind)
		{
			case KeyForward:
				sBind = "MoveForward";
				
				break;
			case KeyBackward:
				sBind = "MoveBackward";
				
				break;
			case KeyLeft:
				sBind = "StrafeLeft";
				
				break;
			case KeyRight:
				sBind = "StrafeRight";
				
				break;
			case KeyAttack:
				sBind = "Fire";
				
				break;
			case KeyJump:
				sBind = "Jump";
				
				break;
			case KeyEscape:
				sBind = "EscHandler";
				
				break;
			case KeySkipCutscene:
				sBind = "BypassCutscene";
				
				break;
			default:
				break;
		}
		
		// Remove the old bind before making a new one
		// Master_64: This logic is heavily flawed and needs to be re-worked, since this will never correctly work
		for(i = 0; i < iKeyBindCount; i++)
		{
			if(Key == iCurrentKeyBindActions[i])
			{
				U.CC("Set Input" @ U.CC("KeyName" @ string(iCurrentKeyBindActions[i])));
				
				break;
			}
		}
		
		// Now let's make the new bind
		U.CC("Set Input" @ U.CC("KeyName" @ string(Key)) @ sBind);
		
		GUIButton(KeyToBind).Caption = U.CC("KeyName" @ string(Key));
		KeyToBind = none;
		
		GetKeyBindings();
		UpdateKeyBindings();
	}
	
	return super.InternalOnKeyEvent(Key, State, Delta);
}

event InternalOnLoadINI(GUIComponent Sender, string S)
{
	switch(Sender)
	{
		case DifficultyModes:
			switch(class'SH22Config'.default.DifficultyMode)
			{
				case DM_Relaxed:
					DifficultyModes.SetText(lDifficultyMode1);
					
					break;
				case DM_Classic:
					DifficultyModes.SetText(lDifficultyMode2);
					
					break;
				case DM_Knight:
					DifficultyModes.SetText(lDifficultyMode3);
					
					break;
				case DM_INeedAHero:
					DifficultyModes.SetText(lDifficultyMode4);
					
					break;
			}
			
			break;
		case ScreenResolution:
			ScreenResolution.SetText(U.CC("GetCurrentRes"));
			
			break;
		case ObjectDetail:
			switch(GetObjectDetail())
			{
				case 2:
					ObjectDetail.SetText(lObjectDetailHigh);
					
					break;
				case 1:
					ObjectDetail.SetText(lObjectDetailMedium);
					
					break;
				case 0:
					ObjectDetail.SetText(lObjectDetailLow);
					
					break;
			}
			
			break;
		case ShadowDetail:
			switch(class'SH22Config'.default.ShadowDetail)
			{
				case DM_SuperHigh:
					ShadowDetail.SetText(lShadowDetailSuperHigh);
					
					break;
				case DM_High:
					ShadowDetail.SetText(lShadowDetailHigh);
					
					break;
				case DM_Low:
					ShadowDetail.SetText(lShadowDetailLow);
					
					break;
				case DM_None:
					ShadowDetail.SetText(lShadowDetailNone);
					
					break;
			}
			
			break;
		case ViewDistance:
			switch(class'SH22Config'.default.ViewDistance)
			{
				case DM_Infinite:
					ViewDistance.SetText(lViewDistanceInfinite);
					
					break;
				case DM_VeryFar:
					ViewDistance.SetText(lViewDistanceVeryFar);
					
					break;
				case DM_Far:
					ViewDistance.SetText(lViewDistanceFar);
					
					break;
				case DM_Medium:
					ViewDistance.SetText(lViewDistanceMedium);
					
					break;
				case DM_Short:
					ViewDistance.SetText(lViewDistanceShort);
					
					break;
			}
			
			break;
		case FramerateLimit:
			if(int(dgVoodooVariables.FPSLimit) == 0)
			{
				FramerateLimit.SetText("Uncapped");
			}
			else
			{
				FramerateLimit.SetText(dgVoodooVariables.FPSLimit);
			}
			
			break;
		case TextureFiltering:
			TextureFiltering.SetText("Anisotropic" @ dgVoodooVariables.Filtering $ "x");
			
			break;
		case Antialiasing:
			if(dgVoodooVariables.Antialiasing ~= "appdriven")
			{
				Antialiasing.SetText("Disabled");
			}
			else
			{
				Antialiasing.SetText("MSAA" @ dgVoodooVariables.Antialiasing);
			}
			
			break;
		case VRAMAllocation:
			VRAMAllocation.SetText(dgVoodooVariables.VRAM @ "MB");
			
			break;
		default:
			break;
	}
}

event string InternalOnSaveINI(GUIComponent Sender) // Only here to prevent throwing an error
{
	return "";
}

function byte GetObjectDetail() // Returns with the current object detail (0 = Low, 1 = Medium, 2 = High)
{
	local byte B;
	
	B += byte(bool(U.CC("Get ini:Engine.Engine.RenderDevice SuperHighDetailActors")));
	B += byte(bool(U.CC("Get ini:Engine.Engine.RenderDevice HighDetailActors")));
	
	return B;
}

function GetKeyBindings() // Gets all keybindings, also known as updating the variable <KeyBinds>
{
	local int i;
	
	KeyBinds.Remove(0, KeyBinds.Length);
	KeyBinds.Insert(0, 255);
	
	for(i = 0; i < KeyBinds.Length; i++)
	{
		KeyBinds[i].bKey = i;
		KeyBinds[i].Key = U.CC("KeyName" @ string(i));
		KeyBinds[i].Action = U.CC("Get Input" @ KeyBinds[i].Key);
	}
}

function UpdateKeyBindings() // Updates all keybindings. Recommended to run GetKeyBindings() first unless you know what you're doing
{
	local int i, j;
	
	iCurrentKeyBindActions.Remove(0, iCurrentKeyBindActions.Length);
	iCurrentKeyBindActions.Insert(0, iKeyBindCount);
	
	for(j = 0; j < iKeyBindCount; j++)
	{
		for(i = 0; i < 255; i++)
		{
			if(InStr(Caps(KeyBinds[i].Action), Caps(sKeyBindActions[j])) > -1)
			{
				iCurrentKeyBindActions[j] = KeyBinds[i].bKey;
				
				break;
			}
		}
	}
	
	for(i = 0; i < iKeyBindCount; i++)
	{
		if(iCurrentKeyBindActions[i] != 0)
		{
			GUIButton(InputOptions[i]).Caption = KeyBinds[iCurrentKeyBindActions[i]].Key;
		}
		else
		{
			GUIButton(InputOptions[i]).Caption = lNoKeyAction;
		}
	}
}

function ResetKeyBindings() // Resets all keybindings back to their original actions
{
	local string sOldKeyBind, sCurrentKeyBind, sIniKeyName;
	local int i;
	
	for(i = 0; i < 255; i++)
	{
		sIniKeyName = U.CC("KeyName" @ string(i));
		sCurrentKeyBind = U.CC("KeyBinding" @ sIniKeyName);
		sOldKeyBind = U.GetIniEntry("Engine.Input", sIniKeyName, "DefUser.ini");
		
		if(sCurrentKeyBind != sOldKeyBind)
		{            
			U.CC("Set Input" @ sIniKeyName @ sOldKeyBind);
		}
	}
	
	U.CC("Set PlayerInput MouseSensitivity 3.0");
	class'PlayerInput'.default.MouseSensitivity = 3.0;
	class'PlayerInput'.static.StaticSaveConfig();
	
	MouseSensitivity.SetValue(class'PlayerInput'.default.MouseSensitivity);
}

function GetdgVoodooVariables() // Gets the advanced video option values for the GUI components
{
	local array<string> File;
	
	U.LoadStringArray(File, "..\\System\\dgVoodoo.conf");
	
	dgVoodooVariables.FPSLimit = GetdgVoodooVariableValue(File[119]);
	dgVoodooVariables.Filtering = GetdgVoodooVariableValue(File[194]);
	dgVoodooVariables.Antialiasing = GetdgVoodooVariableValue(File[198]);
	dgVoodooVariables.VRAM = GetdgVoodooVariableValue(File[193]);
	dgVoodooVariables.Brightness = GetdgVoodooVariableValue(File[32]);
	dgVoodooVariables.Contrast = GetdgVoodooVariableValue(File[34]);
	dgVoodooVariables.Color = GetdgVoodooVariableValue(File[33]);
	dgVoodooVariables.DisableAndPassThru = GetdgVoodooVariableValue(File[190]);
	dgVoodooVariables.Bilinear2DOperations = GetdgVoodooVariableValue(File[203]);
	dgVoodooVariables.FastVideoMemoryAccess = GetdgVoodooVariableValue(File[207]);
}

function string GetdgVoodooVariableValue(string S) // Gets the individual value from a dgVoodoo.conf file from a provided line
{
	return Mid(S, InStr(S, "= ") + 2);
}

function WritedgVoodooVariables() // Takes the current values of the advanced video options, applies the changes to the configuration file directly, then closes the game since it requires a restart
{
	local array<string> File;
	
	U.LoadStringArray(File, "..\\System\\dgVoodoo.conf");
	
	// Prepare file changes
	dgVoodooVariables.FPSLimit = FramerateLimit.Edit.GetText();
	
	if(dgVoodooVariables.FPSLimit ~= "Uncapped")
	{
		dgVoodooVariables.FPSLimit = "0";
	}
	
	dgVoodooVariables.Filtering = Mid(TextureFiltering.Edit.GetText(), 12, Len(TextureFiltering.Edit.GetText()) - 13);
	
	if(dgVoodooVariables.Filtering ~= "1")
	{
		dgVoodooVariables.Filtering = "appdriven";
	}
	
	if(Antialiasing.Edit.GetText() ~= "Disabled")
	{
		dgVoodooVariables.Antialiasing = "appdriven";
	}
	else
	{
		dgVoodooVariables.Antialiasing = Mid(Antialiasing.Edit.GetText(), 5);
	}
	
	dgVoodooVariables.VRAM = Left(VRAMAllocation.Edit.GetText(), Len(VRAMAllocation.Edit.GetText()) - 3);
	dgVoodooVariables.Brightness = string(int(ScreenBrightness.Value));
	dgVoodooVariables.Contrast = string(int(ScreenContrast.Value));
	dgVoodooVariables.Color = string(int(ScreenColorVibrancy.Value));
	dgVoodooVariables.DisableAndPassThru = U.Lower(CompatibilityMode.Caption);
	dgVoodooVariables.Bilinear2DOperations = U.Lower(PerformanceMode.Caption);
	dgVoodooVariables.FastVideoMemoryAccess = U.Lower(PerformanceMode.Caption);
	
	// Apply the changes to the file
	WritedgVoodooVariableValue(File[119], dgVoodooVariables.FPSLimit);
	WritedgVoodooVariableValue(File[194], dgVoodooVariables.Filtering);
	WritedgVoodooVariableValue(File[198], dgVoodooVariables.Antialiasing);
	WritedgVoodooVariableValue(File[193], dgVoodooVariables.VRAM);
	WritedgVoodooVariableValue(File[32], dgVoodooVariables.Brightness);
	WritedgVoodooVariableValue(File[34], dgVoodooVariables.Contrast);
	WritedgVoodooVariableValue(File[33], dgVoodooVariables.Color);
	WritedgVoodooVariableValue(File[190], dgVoodooVariables.DisableAndPassThru);
	WritedgVoodooVariableValue(File[203], dgVoodooVariables.Bilinear2DOperations);
	WritedgVoodooVariableValue(File[207], dgVoodooVariables.FastVideoMemoryAccess);
	
	// Write the changes to the file
	U.SaveStringArray(File, "..\\System\\dgVoodoo.conf");
	U.Quit();
}

function string WritedgVoodooVariableValue(out string S, string sValue) // Outputs through <S> a value change to a provided line with the new value of <sValue>
{
	S = Mid(S, 0, InStr(S, "= ") + 2);
	S = S $ sValue;
	
	return S $ sValue;
}


defaultproperties
{
	Begin Object Name=btnInputTab0 Class=GUIButton
		StyleName="SHOptionLabel"
		bNeverFocus=true
		WinTop=0.1
		WinLeft=0.425
		WinWidth=0.05
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	InputTab=btnInputTab0
	Begin Object Name=btnGameTab0 Class=GUIButton
		StyleName="SHOptionLabel"
		bNeverFocus=true
		WinTop=0.1
		WinLeft=0.475
		WinWidth=0.05
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	GameTab=btnGameTab0
	Begin Object Name=btnVideoTab0 Class=GUIButton
		StyleName="SHOptionLabel"
		bNeverFocus=true
		WinTop=0.1
		WinLeft=0.525
		WinWidth=0.05
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	VideoTab=btnVideoTab0
	Begin Object Name=btnSoundTab0 Class=GUIButton
		StyleName="SHOptionLabel"
		bNeverFocus=true
		WinTop=0.1
		WinLeft=0.575
		WinWidth=0.05
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	SoundTab=btnSoundTab0
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
	Begin Object Name=btnKeyForward0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.2
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeyForward=btnKeyForward0
	Begin Object Name=lblKeyForward0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.2
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeyForwardLabel=lblKeyForward0
	Begin Object Name=btnKeyBackward0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.25
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeyBackward=btnKeyBackward0
	Begin Object Name=lblKeyBackward0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.25
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeyBackwardLabel=lblKeyBackward0
	Begin Object Name=btnKeyLeft0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.3
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeyLeft=btnKeyLeft0
	Begin Object Name=lblKeyLeft0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.3
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeyLeftLabel=lblKeyLeft0
	Begin Object Name=btnKeyRight0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.35
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeyRight=btnKeyRight0
	Begin Object Name=lblKeyRight0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeyRightLabel=lblKeyRight0
	Begin Object Name=btnKeyAttack0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.4
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeyAttack=btnKeyAttack0
	Begin Object Name=lblKeyAttack0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.4
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeyAttackLabel=lblKeyAttack0
	Begin Object Name=btnKeyJump0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.45
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeyJump=btnKeyJump0
	Begin Object Name=lblKeyJump0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.45
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeyJumpLabel=lblKeyJump0
	Begin Object Name=btnKeyEscape0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.5
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeyEscape=btnKeyEscape0
	Begin Object Name=lblKeyEscape0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.5
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeyEscapeLabel=lblKeyEscape0
	Begin Object Name=btnKeySkipCutscene0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.55
		WinLeft=0.65
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	KeySkipCutscene=btnKeySkipCutscene0
	Begin Object Name=lblKeySkipCutscene0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.55
		WinLeft=0.35
		WinWidth=0.2
		WinHeight=0.05
	End Object
	KeySkipCutsceneLabel=lblKeySkipCutscene0
	Begin Object Name=btnResetKeys0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.8
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.08
		OnClick=InternalOnClick
	End Object
	ResetKeys=btnResetKeys0
	Begin Object Name=lblResetKeys0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.7
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ResetKeysLabel=lblResetKeys0
	Begin Object Name=sldMouseSensitivity0 Class=GUISlider
		StyleName="SHSlider"
		CaptionStyleName="SHSlider"
		MinValue=0.1
		MaxValue=10.0
		bNeverFocus=true
		WinTop=0.7
		WinLeft=0.5
		WinWidth=0.25
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	MouseSensitivity=sldMouseSensitivity0
	Begin Object Name=lblMouseSensitivity0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.65
		WinLeft=0.5
		WinWidth=0.25
		WinHeight=0.05
	End Object
	MouseSensitivityLabel=lblMouseSensitivity0
	Begin Object Name=cbDifficultyModes0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="Classic"
		WinTop=0.2
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	DifficultyModes=cbDifficultyModes0
	Begin Object Name=lblDifficultyModes0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.15
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
	End Object
	DifficultyModesLabel=lblDifficultyModes0
	Begin Object Name=sldFieldOfView0 Class=GUISlider
		StyleName="SHSlider"
		CaptionStyleName="SHSlider"
		MinValue=10
		MaxValue=160
		bIntSlider=true
		bNeverFocus=true
		WinTop=0.4
		WinLeft=0.5
		WinWidth=0.4
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	FieldOfView=sldFieldOfView0
	Begin Object Name=lblFieldOfView0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	FieldOfViewLabel=lblFieldOfView0
	Begin Object Name=btnAutoLevelCamera0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.2
		WinLeft=0.6
		WinWidth=0.1
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	AutoLevelCamera=btnAutoLevelCamera0
	Begin Object Name=lblAutoLevelCamera0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.15
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
	End Object
	AutoLevelCameraLabel=lblAutoLevelCamera0
	Begin Object Name=btnDisableIntroMovies0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.6
		WinLeft=0.5
		WinWidth=0.1
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	DisableIntroMovies=btnDisableIntroMovies0
	Begin Object Name=lblDisableIntroMovies0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.55
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	DisableIntroMoviesLabel=lblDisableIntroMovies0
	Begin Object Name=cbScreenResolution0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="1280x720"
		WinTop=0.2
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	ScreenResolution=cbScreenResolution0
	Begin Object Name=lblScreenResolution0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.15
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ScreenResolutionLabel=lblScreenResolution0
	Begin Object Name=cbObjectDetail0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="Medium"
		WinTop=0.4
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	ObjectDetail=cbObjectDetail0
	Begin Object Name=lblObjectDetail0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ObjectDetailLabel=lblObjectDetail0
	Begin Object Name=cbShadowDetail0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="High"
		WinTop=0.4
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	ShadowDetail=cbShadowDetail0
	Begin Object Name=lblShadowDetail0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ShadowDetailLabel=lblShadowDetail0
	Begin Object Name=cbViewDistance0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="Far"
		WinTop=0.2
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	ViewDistance=cbViewDistance0
	Begin Object Name=lblViewDistance0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.15
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ViewDistanceLabel=lblViewDistance0
	Begin Object Name=btnAdvancedSettings0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.65
		WinLeft=0.5
		WinWidth=0.25
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	AdvancedSettings=btnAdvancedSettings0
	Begin Object Name=lblAdvancedSettings0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.6
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	AdvancedSettingsLabel=lblAdvancedSettings0
	Begin Object Name=cbFramerateLimit0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="120"
		WinTop=0.2
		WinLeft=0.2
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	FramerateLimit=cbFramerateLimit0
	Begin Object Name=lblFramerateLimit0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.15
		WinLeft=0.2
		WinWidth=0.2
		WinHeight=0.05
	End Object
	FramerateLimitLabel=lblFramerateLimit0
	Begin Object Name=cbTextureFiltering0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="Anisotropic 4x"
		WinTop=0.2
		WinLeft=0.8
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	TextureFiltering=cbTextureFiltering0
	Begin Object Name=lblTextureFiltering0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.15
		WinLeft=0.8
		WinWidth=0.2
		WinHeight=0.05
	End Object
	TextureFilteringLabel=lblTextureFiltering0
	Begin Object Name=cbAntialiasing0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="MSAA 4x"
		WinTop=0.4
		WinLeft=0.8
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	Antialiasing=cbAntialiasing0
	Begin Object Name=lblAntialiasing0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.8
		WinWidth=0.2
		WinHeight=0.05
	End Object
	AntialiasingLabel=lblAntialiasing0
	Begin Object Name=cbVRAMAllocation0 Class=SHGUIComboBox
		StyleName="SHSolidBox"
		bNeverFocus=true
		bReadOnly=true
		bShowListOnFocus=true
		IniOption="@INTERNAL"
		IniDefault="512 MB"
		WinTop=0.4
		WinLeft=0.2
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
		OnLoadINI=InternalOnLoadINI
		OnSaveINI=InternalOnSaveINI
	End Object
	VRAMAllocation=cbVRAMAllocation0
	Begin Object Name=lblVRAMAllocation0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.2
		WinWidth=0.2
		WinHeight=0.05
	End Object
	VRAMAllocationLabel=lblVRAMAllocation0
	Begin Object Name=sldScreenBrightness0 Class=GUISlider
		StyleName="SHSlider"
		CaptionStyleName="SHSlider"
		MinValue=0
		MaxValue=400
		bIntSlider=true
		bNeverFocus=true
		WinTop=0.6
		WinLeft=0.3
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	ScreenBrightness=sldScreenBrightness0
	Begin Object Name=lblScreenBrightness0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.55
		WinLeft=0.3
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ScreenBrightnessLabel=lblScreenBrightness0
	Begin Object Name=sldScreenContrast0 Class=GUISlider
		StyleName="SHSlider"
		CaptionStyleName="SHSlider"
		MinValue=0
		MaxValue=400
		bIntSlider=true
		bNeverFocus=true
		WinTop=0.6
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	ScreenContrast=sldScreenContrast0
	Begin Object Name=lblScreenContrast0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.55
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ScreenContrastLabel=lblScreenContrast0
	Begin Object Name=sldScreenColorVibrancy0 Class=GUISlider
		StyleName="SHSlider"
		CaptionStyleName="SHSlider"
		MinValue=0
		MaxValue=400
		bIntSlider=true
		bNeverFocus=true
		WinTop=0.6
		WinLeft=0.7
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	ScreenColorVibrancy=sldScreenColorVibrancy0
	Begin Object Name=lblScreenColorVibrancy0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.55
		WinLeft=0.7
		WinWidth=0.2
		WinHeight=0.05
	End Object
	ScreenColorVibrancyLabel=lblScreenColorVibrancy0
	Begin Object Name=btnPerformanceMode0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.8
		WinLeft=0.4
		WinWidth=0.1
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	PerformanceMode=btnPerformanceMode0
	Begin Object Name=lblPerformanceMode0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.75
		WinLeft=0.4
		WinWidth=0.2
		WinHeight=0.05
	End Object
	PerformanceModeLabel=lblPerformanceMode0
	Begin Object Name=btnCompatibilityMode0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.8
		WinLeft=0.6
		WinWidth=0.1
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	CompatibilityMode=btnCompatibilityMode0
	Begin Object Name=lblCompatibilityMode0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.75
		WinLeft=0.6
		WinWidth=0.2
		WinHeight=0.05
	End Object
	CompatibilityModeLabel=lblCompatibilityMode0
	Begin Object Name=sldGameVolume0 Class=GUISlider
		StyleName="SHSlider"
		CaptionStyleName="SHSlider"
		MinValue=0.0
		MaxValue=1.0
		bNeverFocus=true
		WinTop=0.4
		WinLeft=0.5
		WinWidth=0.4
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	GameVolume=sldGameVolume0
	Begin Object Name=lblGameVolume0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.35
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	GameVolumeLabel=lblGameVolume0
	Begin Object Name=sldMusicVolume0 Class=GUISlider
		StyleName="SHSlider"
		CaptionStyleName="SHSlider"
		MinValue=0.0
		MaxValue=1.0
		bNeverFocus=true
		WinTop=0.6
		WinLeft=0.5
		WinWidth=0.4
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	MusicVolume=sldMusicVolume0
	Begin Object Name=lblMusicVolume0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.55
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	MusicVolumeLabel=lblMusicVolume0
	Begin Object Name=btnRestartSoundDriver0 Class=GUIButton
		StyleName="SHSolidBox"
		bNeverFocus=true
		WinTop=0.8
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
		OnClick=InternalOnClick
	End Object
	RestartSoundDriver=btnRestartSoundDriver0
	Begin Object Name=lblRestartSoundDriver0 Class=GUILabel
		StyleName="SHSolidBox"
		TextAlign=TXTA_Center
		WinTop=0.75
		WinLeft=0.5
		WinWidth=0.2
		WinHeight=0.05
	End Object
	RestartSoundDriverLabel=lblRestartSoundDriver0
	sKeyBindActions(0)="MoveForward"
	sKeyBindActions(1)="MoveBackward"
	sKeyBindActions(2)="StrafeLeft"
	sKeyBindActions(3)="StrafeRight"
	sKeyBindActions(4)="Fire"
	sKeyBindActions(5)="Jump"
	sKeyBindActions(6)="EscHandler"
	sKeyBindActions(7)="BypassCutscene"
	sSupportedResolutions(0)="1920x1080"
	sSupportedResolutions(1)="1664x936"
	sSupportedResolutions(2)="1280x720"
	sSupportedResolutions(3)="1440x1080"
	sSupportedResolutions(4)="1024x768"
	sSupportedResolutions(5)="640x480"
	iFramerateCaps(0)=360
	iFramerateCaps(1)=300
	iFramerateCaps(2)=240
	iFramerateCaps(3)=144
	iFramerateCaps(4)=120
	iFramerateCaps(5)=75
	iFramerateCaps(6)=60
	bEscapeClosesPage=false
}