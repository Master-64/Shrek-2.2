// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22HUDItem_Coins extends HudItemCoins
	Config(SH22);


var float fHUDItemScale, HUDPos[2];
var Texture GlowTextures[5];
var int iOldCoinCount, iGlowFrame;
var bool bGlowIncrease;
var KWHeroController PC;
var Pawn HP, ICP;
var KWHud HUD;
var BaseCam Cam;
var MUtils U;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	U = GetUtils();
	
	iOldCoinCount = U.GetInventoryCount(class'CoinCollection');
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
	local string sCountDisplay;
	local float Pos[2], fXTextLen, fYTextLen, fTextX, fTextY;
	local int iCoinCount;
	
	C.SetDrawColor(255, 255, 255, 255);
	
	fHUDItemScale = U.GetHUDScale(C);
	
	iCoinCount = U.GetInventoryCount(class'CoinCollection');
	
	sCountDisplay = string(iCoinCount);
	
	Pos[0] = float(C.SizeX) - (textureIcon.USize * fHUDItemScale) - (25.6 * fHUDItemScale);
	Pos[1] = 0.020833333 * float(C.SizeY);
	
	HUDPos[0] = Pos[0];
	HUDPos[1] = Pos[1];
	
	C.SetPos(Pos[0], Pos[1]);
	C.DrawTile(textureIcon, textureIcon.USize * fHUDItemScale, textureIcon.VSize * fHUDItemScale, 0, 0, textureIcon.USize, textureIcon.VSize);
	
	if(fHUDItemScale > 0.75)
	{
		C.Font = parentHUD.GetHudTextFont(C);
	}
	else
	{
		C.Font = parentHUD.GetSmallHudTextFont(C);
	}
	
	C.TextSize(sCountDisplay, fXTextLen, fYTextLen);
	
	Pos[0] += 105.0 * fHUDItemScale;
	Pos[1] += 40.0 * fHUDItemScale;
	
	fTextX = Pos[0] - (fXTextLen / 2.0);
	fTextY = Pos[1] - (fYTextLen / 2.0);
	
	U.DrawShadowText(C, sCountDisplay, U.MakeColor(255, 255, 255, 255), U.MakeColor(0, 0, 0, 255), fTextX, fTextY, 2);
	
	if(iCoinCount > iOldCoinCount)
	{
		if(IsInState('DoGlow'))
		{
			iGlowFrame = 0;
			bGlowIncrease = true;
		}
		
		GotoState('DoGlow');
	}
	
	iOldCoinCount = iCoinCount;
	
	RenderGlow(C);
}

function RenderGlow(Canvas C);

state DoGlow
{
	event BeginState()
	{
		iGlowFrame = 0;
		bGlowIncrease = true;
		
		SetTimer(0.02, true);
	}
	
	function RenderGlow(Canvas C)
	{
		C.SetPos(HUDPos[0] + (106.0 * fHUDItemScale), HUDPos[1]);
		C.DrawTile(GlowTextures[iGlowFrame], (textureIcon.USize / 1.5) * fHUDItemScale, (textureIcon.VSize / 1.5) * fHUDItemScale, 0, 0, GlowTextures[0].USize, GlowTextures[0].VSize);
	}
	
	event Timer()
	{
		if(bGlowIncrease)
		{
			iGlowFrame++;
			
			if(iGlowFrame == 4)
			{
				bGlowIncrease = false;
			}            
		}
		else
		{
			iGlowFrame--;
			
			if(iGlowFrame < 0)
			{
				SetTimer(0.0, false);
				
				GotoState('');
			}
		}
	}
}


defaultproperties
{
	fHUDItemScale=1.0
	GlowTextures(0)=Texture'SH_Hud.hit_flash.A_Health_1Glow'
	GlowTextures(1)=Texture'SH_Hud.hit_flash.A_Health_2Glow'
	GlowTextures(2)=Texture'SH_Hud.hit_flash.A_Health_3Glow'
	GlowTextures(3)=Texture'SH_Hud.hit_flash.A_Health_4Glow'
	GlowTextures(4)=Texture'SH_Hud.hit_flash.A_Health_5Glow'
	DrawType=DT_None
	StaticMesh=none
	bDisplayCount=false
}