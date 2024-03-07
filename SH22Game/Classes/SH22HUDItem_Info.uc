// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22HUDItem_Info extends MHUDItem
	Config(SH22);


var string sInfoString;


event PreBeginPlay()
{
	sInfoString = Localize("All", "menuitems_165", "HPMenu");
	
	super.PreBeginPlay();
}

function DrawHudItem(Canvas C)
{
	local int iCurrX, iCurrY;
	local float fXTextLen, fYTextLen;
	
	C.Font = parentHUD.GetSmallHudTextFont(C);
	C.TextSize(sInfoString, fXTextLen, fYTextLen);
	
	iCurrX = (C.SizeX / 2) - (fXTextLen / 2);
	iCurrY = fYTextLen / 8;
	
	C.SetPos(iCurrX, iCurrY);
	U.DrawShadowText(C, sInfoString, class'Canvas'.static.MakeColor(0, 255, 0), class'Canvas'.static.MakeColor(0, 0, 0), iCurrX, iCurrY, 2.0);
}

state Invisible
{
	function RenderHud(Canvas Canvas)
	{
		return;
	}
}

auto state Visible
{
}


defaultproperties
{
	bHideDuringCutscene=false
}