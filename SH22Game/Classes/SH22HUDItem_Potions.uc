// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22HUDItem_Potions extends HudItemPotion
	Config(SH22);


var float fHUDItemScale, HUDPos[2];
var KWHeroController PC;
var Pawn HP, ICP;
var KWHud HUD;
var BaseCam Cam;
var MUtils U;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	U = GetUtils();
	
	PC = U.GetPC();
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

function int GetPotionCount()
{
	switch(SHHeroController(PC).PotionSelected)
	{
		case 0:
			return U.GetInventoryCount(class'Potion1Collection');
			
			break;
		case 5:
			return U.GetInventoryCount(class'Potion2Collection');
			
			break;
		case 2:
			return U.GetInventoryCount(class'Potion3Collection');
			
			break;
		case 3:
			return U.GetInventoryCount(class'Potion4Collection');
			
			break;
		case 4:
			return U.GetInventoryCount(class'Potion5Collection');
			
			break;
		case 1:
			return U.GetInventoryCount(class'Potion6Collection');
			
			break;
		case 6:
			return U.GetInventoryCount(class'Potion7Collection');
			
			break;
		case 7:
			return U.GetInventoryCount(class'Potion8Collection');
			
			break;
		case 8:
			return U.GetInventoryCount(class'Potion9Collection');
			
			break;
		case 9:
			return -1;
			
			break;
		default:
			break;
	}
}

event RenderHud(Canvas C)
{
	local string sCountDisplay;
	local float Pos[2], fXTextLen, fYTextLen, fTextX, fTextY;
	local int iPotionCount;
	
	C.SetDrawColor(255, 255, 255, 255);
	
	fHUDItemScale = U.GetHUDScale(C);
	
	iPotionCount = GetPotionCount();
	
	sCountDisplay = string(iPotionCount);
	
	if(CanUseThePotions() || SHHeroController(PC).PotionSelected == 9)
	{
		textureIcon = PotionTX[SHHeroController(PC).PotionSelected];
	}
	else
	{
		textureIcon = PotionTX[SHHeroController(PC).PotionSelected + 10];
	}
	
	Pos[0] = float(C.SizeX) - (textureIcon.USize * fHUDItemScale) - (256.0 * fHUDItemScale);
	Pos[1] = 0.020833333 * float(C.SizeY);
	
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
	
	Pos[0] += 182.0 * fHUDItemScale;
	Pos[1] += 95.0 * fHUDItemScale;
	
	fTextX = Pos[0] - (fXTextLen / 2.0);
	fTextY = Pos[1] - (fYTextLen / 2.0);
	
	if(SHHeroController(PC).PotionSelected != 9)
	{
		U.DrawShadowText(C, sCountDisplay, U.MakeColor(255, 255, 255, 255), U.MakeColor(0, 0, 0, 255), fTextX, fTextY, 2);
	}
}


defaultproperties
{
	fHUDItemScale=1.0
	DrawType=DT_None
	StaticMesh=none
	bDisplayCount=false
}