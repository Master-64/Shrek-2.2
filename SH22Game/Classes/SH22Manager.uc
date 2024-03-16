// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Manager extends MInfo
	Config(SH22);


var SH22Config C;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	C = Spawn(class'SH22Config');
	C.M = self;
}


defaultproperties
{
	
}