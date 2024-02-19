// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22HUDItem_TimesUp extends HudItemTimesUp
	Config(SH22);


var float fHUDItemScale;
var KWHeroController PC;
var Pawn HP, ICP;
var KWHud HUD;
var BaseCam Cam;
var MUtils U;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	U = GetUtils();
}

function MUtils GetUtils()
{
	local MUtils Ut;
	
	foreach DynamicActors(class'MUtils', Ut)
	{
		return Ut;
	}
	
	return Spawn(class'MUtils');
}

event RenderHud(Canvas C)
{
	local float Pos[2];
	
	C.SetDrawColor(255, 255, 255, 255);
	
	fHUDItemScale = (float(C.SizeY) / 768.0 + float(C.SizeX) / 1024.0) / 2.0;
	
	Pos[0] = (float(C.SizeX) / 2.0) - ((textureIcon.USize / 2) * fHUDItemScale);
	Pos[1] = (float(C.SizeY) / 2.0) - ((textureIcon.VSize / 2) * fHUDItemScale);
	
	C.SetPos(Pos[0], Pos[1]);
	C.DrawTile(textureIcon, textureIcon.USize * fHUDItemScale, textureIcon.VSize * fHUDItemScale, 0, 0, textureIcon.USize, textureIcon.VSize);
}

auto state Invisible
{
	event RenderHud(Canvas Canvas)
	{
		return;
	}
}

state Visible{}


defaultproperties
{
	fHUDItemScale=1.0
	DrawType=DT_None
	StaticMesh=none
}