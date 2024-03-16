// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Game extends MGame
	Config(SH22);


var SH22Manager M;

event PostBeginPlay()
{
	super.PostBeginPlay();
	
	M = Spawn(class'SH22Manager');
}

event PlayerController Login(string Portal, string Options, out string Error)
{
	return super.Login(Portal, Options, Error);
}


defaultproperties
{
	HUDType="SH22Game.SH22HUD"
	GameName="Shrek 2.2"
	DefaultPlayerClassName="MPak.MShrek"
	PlayerControllerClassName="MPak.MController"
	MapPrefix="SH22"
	BeaconName="SH22"
	MaxPlayers=64
	Acronym="SH22"
}