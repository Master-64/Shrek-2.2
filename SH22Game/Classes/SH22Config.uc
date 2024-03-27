// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Config extends MInfo
	Config(SH22Config);


enum EDifficultyMode
{
    DM_Relaxed,
    DM_Classic,
    DM_Knight,
    DM_INeedAHero
};

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

var config float fDefaultFOV;
var config EDifficultyMode DifficultyMode;
var config bool bAutoLevelCamera, bSecretDifficultyModeUnlocked, bDisableIntroMovies;
var config EShadowDetailMode ShadowDetail;
var config EViewDistanceMode ViewDistance;
var SH22Manager M;


event PostBeginPlay()
{
	super.PostBeginPlay();
}

function float GetFOV()
{
	return U.CalculateHorizontalFOV(fDefaultFOV);
}


defaultproperties
{
	fDefaultFOV=69.0
	DifficultyMode=DM_Classic
	ShadowDetail=DM_High
}