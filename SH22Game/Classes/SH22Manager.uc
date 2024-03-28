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
	
	U.CC("Set MHeroPawn bModifiedBumplines True");
	U.CC("Set SHHeroPawn SaveCameraNoSnapRotation" @ string(!C.bAutoLevelCamera));
	U.CC("Set SHHeroPawn CameraNoSnapRotation" @ string(!C.bAutoLevelCamera));
	
	InitDifficultyMode();
	InitViewDistance();
	InitShadowDetail();
	
	SetTimer(0.01, false);
}

event Timer()
{
	if(CanDisableIntroMovies())
	{
		U.ChangeLevel(class'SHFEGUIPage'.default.FEMenuLevel);
	}
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

function InitDifficultyMode()
{
	local MHeroPawn MHP;
	local JumpMagnet JM;
	local MEnergyKeg EK;
	local MShamrock SR;
	
	bPlayerRegeneration = C.DifficultyMode == DM_Relaxed;
	
	U.CC("Set MHeroPawn bLandSlowdown" @ U.BoolToString(C.DifficultyMode == DM_Relaxed));
	
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
				MHP.fDamageMultiplier *= 3.0;
			}
			
			// Buff level difficulty
			// ...
			
			break;
		case DM_INeedAHero:
			foreach DynamicActors(class'MHeroPawn', MHP)
			{
				MHP.fDamageMultiplier *= 6.4;
			}
			
			// Master_64: No idea if this works correctly but I'm not going to check until it's needed
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

function InitViewDistance()
{
	local MPatcher P;
	local ZoneInfo ZI;
	local float fFogMultiplier;
	local int i;
	
	switch(C.ViewDistance)
	{
		case DM_Infinite:
			break;
		case DM_VeryFar:
			fFogMultiplier = 2.2;
			
			break;
		case DM_Far:
			fFogMultiplier = 1.0;
			
			break;
		case DM_Medium:
			fFogMultiplier = 0.64;
			
			break;
		case DM_Short:
			fFogMultiplier = 0.42;
			
			break;
	}
	
	foreach AllActors(class'MPatcher', P)
	{
		if(P.PatchesToApply.bEnforceFogForZoneInfo && P.OptionalOptions.FogActions.Length != 0)
		{
			for(i = 0; i < P.OptionalOptions.FogActions.Length; i++)
			{
				if(fFogMultiplier == 0.0)
				{
					P.OptionalOptions.FogActions.Remove(i, 1);
					
					i--;
					
					continue;
				}
				
				if(fFogMultiplier < 1.0)
				{
					P.OptionalOptions.FogActions[i].DistanceFogStart *= fFogMultiplier;
				}
				
				P.OptionalOptions.FogActions[i].DistanceFogEnd *= fFogMultiplier;
			}
		}
	}
	
	foreach AllActors(class'ZoneInfo', ZI)
	{
		if(fFogMultiplier == 0.0)
		{
			ZI.bDistanceFog = false;
			
			continue;
		}
		
		if(fFogMultiplier < 1.0)
		{
			ZI.DistanceFogStart *= fFogMultiplier;
		}
		
		ZI.DistanceFogEnd *= fFogMultiplier;
	}
}

function InitShadowDetail()
{
	local KWPawn KWP;
	local SHPropsStatic SHPS;
	
	switch(C.ShadowDetail)
	{
		case DM_SuperHigh:
			U.CC("Set KWPawn bUseBlobShadow False");
			U.CC("Set KWPawn bActorShadows True");
			U.CC("Set SHPropsStatic bUseBlobShadow False");
			U.CC("Set SHPropsStatic bActorShadows True");
			
			// bActorShadows corrections
			U.CC("Set GenericGeyser bActorShadows False");
			U.CC("Set LaserBeam bActorShadows False");
			U.CC("Set PotionBottles bActorShadows False");
			U.CC("Set PumpkinDonkey bActorShadows False");
			U.CC("Set RasingGas bActorShadows False");
			U.CC("Set RasingGasStopper bActorShadows False");
			U.CC("Set SHMenuProps bActorShadows False");
			
			break;
		case DM_High:
			U.CC("Set KWPawn bUseBlobShadow False");
			U.CC("Set KWPawn bActorShadows False");
			U.CC("Set SHPropsStatic bUseBlobShadow False");
			U.CC("Set SHPropsStatic bActorShadows False");
			
			// bUseBlobShadow corrections
			U.CC("Set Bat bUseBlobShadow True");
			U.CC("Set Rat bUseBlobShadow True");
			U.CC("Set SHEnemy bUseBlobShadow True");
			U.CC("Set SavePointFairy bUseBlobShadow True");
			U.CC("Set Spider bUseBlobShadow True");
			U.CC("Set WheelStealer bUseBlobShadow True");
			
			// bActorShadows corrections
			U.CC("Set Bat bActorShadows True");
			U.CC("Set BossPIB bActorShadows True");
			U.CC("Set CastleHallKnight bActorShadows False");
			U.CC("Set HazMatShrek bActorShadows True");
			U.CC("Set MHazMatShrek bActorShadows True");
			U.CC("Set Rat bActorShadows True");
			U.CC("Set SHEnemy bActorShadows True");
			U.CC("Set SHHeroPawn bActorShadows True");
			U.CC("Set SavePointFairy bActorShadows True");
			U.CC("Set Spider bActorShadows True");
			U.CC("Set SwingAttachment bActorShadows True");
			U.CC("Set WheelStealer bActorShadows True");
			
			break;
		case DM_Low:
			U.CC("Set KWPawn bUseBlobShadow True");
			U.CC("Set KWPawn bActorShadows False");
			U.CC("Set SHPropsStatic bUseBlobShadow True");
			U.CC("Set SHPropsStatic bActorShadows False");
			
			// bActorShadows corrections
			U.CC("Set Bat bActorShadows True");
			U.CC("Set BossPIB bActorShadows True");
			U.CC("Set CastleHallKnight bActorShadows False");
			U.CC("Set HazMatShrek bActorShadows True");
			U.CC("Set MHazMatShrek bActorShadows True");
			U.CC("Set Rat bActorShadows True");
			U.CC("Set SHEnemy bActorShadows True");
			U.CC("Set SHHeroPawn bActorShadows True");
			U.CC("Set SavePointFairy bActorShadows True");
			U.CC("Set Spider bActorShadows True");
			U.CC("Set SwingAttachment bActorShadows True");
			U.CC("Set WheelStealer bActorShadows True");
			
			break;
		case DM_None:
			break;
	}
	
	U.CC("Set KWGame NoShadows" @ U.BoolToString(C.ShadowDetail == DM_None));
	U.CC("Set KWPawn bNoShadows" @ U.BoolToString(C.ShadowDetail == DM_None));
	U.CC("Set SHPropsStatic bNoShadows" @ U.BoolToString(C.ShadowDetail == DM_None));
	
	foreach AllActors(class'KWPawn', KWP)
	{
		KWP.KWRemoveShadow();
		KWP.KWAddShadow();
	}
	
	foreach AllActors(class'SHPropsStatic', SHPS)
	{
		SHPS.SHPropsStaticRemoveShadow();
		SHPS.SHPropsStaticAddShadow();
	}
}

function bool CanDisableIntroMovies()
{
	return U.GetCurrentMap() ~= "0_Preamble" && C.bDisableIntroMovies;
}


defaultproperties
{
	
}