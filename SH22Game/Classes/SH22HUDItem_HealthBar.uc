// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22HUDItem_HealthBar extends HudItemHealthBar
	Config(SH22);


var float fHUDItemScale, fOldPlayerHealth;
var KWHeroController PC;
var Pawn HP, ICP;
var KWHud HUD;
var BaseCam Cam;
var MUtils U;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	U = GetUtils();
	
	fOldPlayerHealth = U.GetHealth(U.GetHP());
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

function UpdateIconSizing(Canvas C)
{
	Bar_L = 96 * fHUDItemScale;
	Bar_T = 46 * fHUDItemScale;
	Bar_W = (146 + ((NumIcons - 1) * 30)) * fHUDItemScale;
	Bar_H = 17.92 * fHUDItemScale;
	Icon_L = 25.6 * fHUDItemScale;
	Icon_T = 19.2 * fHUDItemScale;
	Icon_W = 512 * fHUDItemScale;
	Icon_H = 128 * fHUDItemScale;
}

function UpdateGlowSizing(Canvas C)
{
	Glow_L = 50 * fHUDItemScale;
	Glow_T = 44 * fHUDItemScale;
	Glow_W = (230.4 + ((NumIcons - 1) * 30)) * fHUDItemScale;
	Glow_H = 21.504 * fHUDItemScale;
}

event RenderHud(Canvas C)
{
	local float fPlayerHealth, fMaxPlayerHealth;
	
	C.SetDrawColor(255, 255, 255, 255);
	
	fHUDItemScale = U.GetHUDScale(C);
	
	SetHealthStatusVars();
	
	if(C.SizeX != LastCanvasSizeX || UpdateRequired)
	{
		LastCanvasSizeX = C.SizeX;
		UpdateSizing(C);
	}
	
	C.SetPos(Bar_L, Bar_T);
	C.DrawTile(textureback, Bar_W, Bar_H, 0, 0, 64, 64);
	C.SetPos(Bar_L, Bar_T);
	
	fPlayerHealth = U.GetHealth(U.GetHP());
	fMaxPlayerHealth = U.GetMaxHealth(U.GetHP());
	
	if(fPlayerHealth < fMaxPlayerHealth / 3.0 || fPlayerHealth < 50.0)
	{
		C.DrawTile(texturelow, Bar_W * (fPlayerHealth / fMaxPlayerHealth), Bar_H, 0, 0, 64 * (fPlayerHealth / fMaxPlayerHealth), 64);        
	}
	else
	{
		C.DrawTile(textureHealth, Bar_W * (fPlayerHealth / fMaxPlayerHealth), Bar_H, 0, 0, 64 * (fPlayerHealth / fMaxPlayerHealth), 64);
	}
	
	C.SetPos(Icon_L, Icon_T);
	C.DrawTile(textureIcon, Icon_W, Icon_H, 0, 0, 512, 128);
	
	if(fOldPlayerHealth != fPlayerHealth)
	{
		GotoState('DoGlow');
	}
	
	fOldPlayerHealth = fPlayerHealth;
	
	RenderGlow(C);
}

function UpdateHealthIconStatus()
{
	SetHealthStatusVars();
}

function SetHealthStatusVars()
{
	// KnowWonder code port + tweaks for 2.2 compatibility
	
	local int newnumicons, realhealth;
	
	newnumicons = Clamp(U.GetInventoryCount(class'ShamrockCollection') + 1, 1, 9);
	
	if(newnumicons != NumIcons)
	{
		textureIcon = Texture(DynamicLoadObject(BarIcons[newnumicons - 1], class'Texture'));
		
		UpdateRequired = true;
	}
	
	NumIcons = newnumicons;
	realhealth = int(U.GetHealth(U.GetHP()));
	
	if(realhealth < 0.0)
	{
		realhealth = 0.0;
	}
	
	PlayerHealth = float(realhealth) / (100.0 * float(NumIcons));
}

function RenderGlow(Canvas C);

state DoGlow
{
	event BeginState()
	{
		GlowIncrease = true;
		GlowFrame = 0;
		
		SetTimer(0.02, true);
	}
	
	function RenderGlow(Canvas C)
	{
		C.SetPos(Glow_L, Glow_T);
		C.DrawTile(Glow[GlowFrame], Glow_W, Glow_H, 0, 0, 128, 128);
	}
	
	event Timer()
	{
		if(GlowIncrease)
		{
			GlowFrame++;
			
			if(GlowFrame == 4)
			{
				GlowIncrease = false;
			}            
		}
		else
		{
			GlowFrame--;
			
			if(GlowFrame < 0)
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
	BarIcons(0)="SH_Hud.lifemeter_bar.lifebar_container150"
	BarIcons(1)="SH_Hud.lifemeter_bar.lifebar_container180"
	BarIcons(2)="SH_Hud.lifemeter_bar.lifebar_container210"
	BarIcons(3)="SH_Hud.lifemeter_bar.lifebar_container240"
	BarIcons(4)="SH_Hud.lifemeter_bar.lifebar_container270"
	BarIcons(5)="SH_Hud.lifemeter_bar.lifebar_container300"
	BarIcons(6)="SH_Hud.lifemeter_bar.lifebar_container330"
	BarIcons(7)="SH_Hud.lifemeter_bar.lifebar_container360"
	BarIcons(8)="SH_Hud.lifemeter_bar.lifebar_container390"
}