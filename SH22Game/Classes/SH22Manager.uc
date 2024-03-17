// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Manager extends MInfo
	Config(SH22);


var SH22Config C;

// Difficulty variables
var bool bPlayerRegeneration;
var float fRegenerationTime;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	C = Spawn(class'SH22Config');
	C.M = self;
}

event PostLoadGame(bool bLoadFromSaveGame)
{
	if(bLoadFromSaveGame)
	{
		return;
	}
	
	PC = U.GetPC();
	PC.FOV(C.GetFOV());
	
	InitializeDifficultyMode();
}

event Tick(float DeltaTime)
{
	if(bPlayerRegeneration)
	{
		fRegenerationTime += DeltaTime;
		
		if(fRegenerationTime >= 2.0)
		{
			fRegenerationTime = 0.0;
			
			HP = U.GetHP();
			
			if(U.GetHealth(HP) > 0.0)
			{
				U.AddHealth(HP, U.GetMaxHealth(HP) / 100.0);
			}
		}
	}
}

function InitializeDifficultyMode()
{
	local MHeroPawn MHP;
	local JumpMagnet JM;
	local MEnergyKeg EK;
	local MShamrock SR;
	
	bPlayerRegeneration = C.DifficultyMode == DM_Relaxed;
	
	foreach DynamicActors(class'MHeroPawn', MHP)
	{
		MHP.bLandSlowdown = C.DifficultyMode == DM_Relaxed;
	}
	
	foreach AllActors(class'JumpMagnet', JM)
	{
		JM.SetCollision(C.DifficultyMode == DM_Relaxed, false, false);
	}
	
	switch(C.DifficultyMode)
	{
		case DM_Relaxed:
		case DM_Classic:
			break;
		case DM_Knight:
			foreach DynamicActors(class'MHeroPawn', MHP)
			{
				MHP.fDamageMultiplier = 3.0;
			}
			
			// Buff level difficulty
			// ...
			
			break;
		case DM_INeedAHero:
			foreach DynamicActors(class'MHeroPawn', MHP)
			{
				MHP.fDamageMultiplier = 6.4;
			}
			
			foreach DynamicActors(class'MEnergyKeg', EK)
			{
				U.MFancySpawn(class'MEnergyBar', EK.Location);
				U.FancyDestroy(EK);
			}
			
			foreach DynamicActors(class'MShamrock', SR)
			{
				U.MFancySpawn(class'MMoneyBag', SR.Location);
				U.FancyDestroy(SR);
			}
			
			// Buff level difficulty
			// ...
			
			break;
	}
	
	class'SH22Game'.static.LogEvent("Game difficulty:" @ string(C.DifficultyMode));
}


defaultproperties
{
	
}