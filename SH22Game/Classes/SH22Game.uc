// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Game extends MGame
	Config(SH22);


event PostBeginPlay()
{
	super.PostBeginPlay();
}


defaultproperties
{
	HUDType="SH22Game.SH22HUD"
	GameName="Shrek 2.2"
	DefaultPlayerClassName="SHGame.Shrek"
	PlayerControllerClassName="SHGame.ShrekController"
	MapPrefix="SH22"
	BeaconName="SH22"
	MaxPlayers=64
	Acronym="SH22"
}