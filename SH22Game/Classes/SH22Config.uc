// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Config extends MInfo
	Config(SH22Config);


enum EShadowDetailMode
{
    DM_SuperHigh,
    DM_High,
    DM_Low,
    DM_None
};

enum EViewDistanceMode
{
    DM_Infinite,
    DM_VeryFar,
    DM_Far,
    DM_Medium,
    DM_Short
};

var config string sDifficultyMode;
var config bool bAutoLevelCamera, bAutoFieldOfView, bSecretDifficultyModeUnlocked;
var config EShadowDetailMode ShadowDetail;
var config EViewDistanceMode ViewDistance;
var SH22Manager M;


event PostBeginPlay()
{
	super.PostBeginPlay();
}


defaultproperties
{
	sDifficultyMode="Classic"
	ShadowDetail=DM_High
}