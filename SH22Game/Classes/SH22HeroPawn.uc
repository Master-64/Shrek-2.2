// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22HeroPawn extends SHHeroPawn
	Placeable
	Config(SH22);


var() bool bCanMount, bCanWaterJump, bCanAirJump, bCannotJump, bCannotPunch, bCanJumpAttackWhileFalling, bLandSlowdown;
var() int iDoubleJumpCount, iAirJumpCount;
var int iDoubleJumpCounter, iAirJumpCounter;
var(Animation) name _MovementAnims[4];
var(AnimTweaks) float _BaseMovementRate;
var float MJumpZ, fTimeSinceLastTiredDialog;
var class<AIController> AIC;
var KWHeroController PC;
var Pawn HP, ICP;
var KWHud HUD;
var array<KWHudItem> HudItems;
var BaseCam Cam;
var MUtils U;


event PreBeginPlay()
{
	if(bool(GetPropertyText("bSpecialPawn")))
	{
		AddSpecialPawn();
	}
	
	AddPawn();
	
	if(!bGameRelevant && Level.NetMode != NM_Client && !Level.Game.BaseMutator.CheckRelevance(self))
	{
		Destroy();
	}
	
	if(bool(GetPropertyText("bChangeOpacityForCamera")) && U.IsSoftwareRendering())
	{
		SetPropertyText("bChangeOpacityForCamera", "False");
		
		bBlocksCamera = true;
	}
	
	Instigator = self;
	DesiredRotation = Rotation;
	
	if(bDeleteMe)
	{
		return;
	}
	
	if(BaseEyeHeight == 0.0)
	{
		BaseEyeHeight = 0.8 * CollisionHeight;
	}
	
	EyeHeight = BaseEyeHeight;
	
	if(MenuName == "")
	{
		MenuName = GetItemName(string(Class));
	}
}

event PostBeginPlay()
{
	local Actor A;
	local AIScript AIS;
	local int i;
	
	U = GetUtils();
	HP = U.GetHP();
	
	if(HP == self)
	{
		bDontPossess = true;
	}
	
	SplashTime = 0.0;
	SpawnTime = Level.TimeSeconds;
	EyeHeight = BaseEyeHeight;
	OldRotYaw = float(Rotation.Yaw);
	
	if(Level.bStartup && U.GetHealth(self) > 0.0 && !bDontPossess)
	{
		if(AIScriptTag != 'None')
		{
			foreach AllActors(class'AIScript', AIS, AIScriptTag)
			{
				break;
			}
			
			if(AIS != none)
			{
				AIS.SpawnControllerFor(self);
				
				if(Controller != none)
				{
					return;
				}
			}
		}
		
		SetPropertyText("AIC", GetPropertyText("ControllerClass"));
		
		if(AIC != none && Controller == none)
		{
			Controller = Spawn(AIC);
		}
		
		if(Controller != none)
		{
			Controller.Possess(self);
			
			AIController(Controller).Skill += SkillModifier;
		}
	}
	
	if(!bNoDefaultInventory)
	{
		AddDefaultInventory();
	}
	
	SetJumpVars();
	KWAddShadow();
	MaxHealth = U.GetHealth(self);
	GroundSpeed = GroundRunSpeed;
	WalkingPct = GroundWalkSpeed / GroundRunSpeed;
	CreationTime = Level.TimeSeconds;
	
	for(i = 0; i < AttachTypeArray.Length; i++)
	{
		A = Spawn(AttachTypeArray[i], self);
		
		if(A != none)
		{
			A.SetPhysics(PHYS_Trailer);
			A.SetCollision(false, false, false);
			A.bCollideWorld = false;
			AttachedActorArray.Insert(AttachedActorArray.Length, 1);
			AttachedActorArray[AttachedActorArray.Length - 1] = A;
		}
	}
	
	AnimBlendParams(ATTACKCHANNEL_LOWER, 0.0, 0.0, 0.0, LOWER_BODY_BONE);
	AnimBlendParams(ATTACKCHANNEL_UPPER, 0.0, 0.0, 0.0, UPPER_BODY_BONE);
	AnimBlendParams(ARMCHANNEL_RIGHT, 0.0, 0.0, 0.0, RIGHT_ARM_BONE);
	AnimBlendParams(ARMCHANNEL_LEFT, 0.0, 0.0, 0.0, LEFT_ARM_BONE);
	
	CreateInterestManager();
	CreateEnemyCommentaryManager();
	SaveInfo = Spawn(class'savegameinfo', self);
	CameraNoSnapRotation = SaveCameraNoSnapRotation;
	
	if(NewTag != 'None')
	{
		Tag = NewTag;
	}
	
	bGameFinishedLoading = false;
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

event PossessedBy(Controller C)
{
	Controller = C;
	NetPriority = 3.0;
	
	if(C.PlayerReplicationInfo != none)
	{
		PlayerReplicationInfo = C.PlayerReplicationInfo;
		OwnerName = PlayerReplicationInfo.PlayerName;
	}
	
	if(C.IsA('PlayerController'))
	{
		if(Level.NetMode != NM_Standalone)
		{
			RemoteRole = ROLE_AutonomousProxy;
		}
		
		BecomeViewTarget();
	}
	else
	{
		RemoteRole = default.RemoteRole;
	}
	
	SetOwner(Controller);
	EyeHeight = BaseEyeHeight;
	ChangeAnimation();
	KWAIController = KWAIController(C);
	
	if(nCompanionDebugTag != 'None' && nCompanionDebugTag == Tag)
	{
		bCompanionDebug = true;
	}
}

event ChangeAnimation()
{
	local array<name> MAs;
	local int i;
	
	if(Controller != none && Controller.bControlAnimations)
	{
		return;
	}
	
	PlayWaiting();
	PlayMoving();
	
	GroundSpeed = GroundRunSpeed;
	WalkingPct = GroundWalkSpeed / GroundSpeed;
	
	if(bIsSliding)
	{
		return;
	}
	
	if(bInWater || bInQuicksand)
	{
		for(i = 0; i < 4; i++)
		{
			MAs[i] = WadeAnims[i];
		}
		
		U.HackMovementAnims(self, MAs);
		
		if(bInWater)
		{
			GroundSpeed = WaterGroundSpeed;
		}
		
		if(bInQuicksand)
		{
			GroundSpeed = QuicksandGroundSpeed;
		}
	}
	else
	{
		if(bIsWalking)
		{
			for(i = 0; i < 4; i++)
			{
				MAs[i] = WalkAnims[i];
			}
			
			U.HackMovementAnims(self, MAs);
			
			TurnLeftAnim = default.TurnLeftAnim;
			TurnRightAnim = default.TurnRightAnim;
		}
		else if(IsInState('StatePickupItem'))
		{
			if(HasAnim(CarryForwardAnimName))
			{
				MAs[0] = CarryForwardAnimName;
			}
			else
			{
				MAs[0] = default._MovementAnims[0];
			}
			
			if(HasAnim(CarryBackwardAnimName))
			{
				MAs[1] = CarryBackwardAnimName;
			}
			else
			{
				MAs[1] = default._MovementAnims[1];
			}
			
			if(HasAnim(CarryStrafeLeftAnimName))
			{
				MAs[2] = CarryStrafeLeftAnimName;
			}
			else
			{
				MAs[2] = default._MovementAnims[2];
			}
			
			if(HasAnim(CarryStrafeRightAnimName))
			{
				MAs[3] = CarryStrafeRightAnimName;
			}
			else
			{
				MAs[3] = default._MovementAnims[3];
			}
			
			if(HasAnim(CarryTurnLeftAnim))
			{
				TurnLeftAnim = CarryTurnLeftAnim;
			}
			else
			{
				TurnLeftAnim = default.TurnLeftAnim;
			}
			
			if(HasAnim(CarryTurnRightAnim))
			{
				TurnRightAnim = CarryTurnRightAnim;
			}
			else
			{
				TurnRightAnim = default.TurnRightAnim;
			}
		}
		else
		{
			if(HasAnim(RunAnims[0]))
			{
				MAs[0] = RunAnims[0];
			}
			else
			{
				MAs[0] = default._MovementAnims[0];
			}
			
			if(HasAnim(RunAnims[1]))
			{
				MAs[1] = RunAnims[1];
			}
			else
			{
				MAs[1] = default._MovementAnims[1];
			}
			
			if(HasAnim(RunAnims[2]))
			{
				MAs[2] = RunAnims[2];
			}
			else
			{
				MAs[2] = default._MovementAnims[2];
			}
			
			if(HasAnim(RunAnims[3]))
			{
				MAs[3] = RunAnims[3];
			}
			else
			{
				MAs[3] = default._MovementAnims[3];
			}
			
			TurnLeftAnim = default.TurnLeftAnim;
			TurnRightAnim = default.TurnRightAnim;
		}
		
		U.HackMovementAnims(self, MAs);
	}
	
	IdleAnimName = GetIdleAnimName();
	bPhysicsAnimUpdate = default.bPhysicsAnimUpdate;
}

function ClimbLadder(LadderVolume L)
{
	if(IsHumanControlled())
	{
		OnLadder = L;
		DesiredRotation = OnLadder.WallDir;
		SetPhysics(PHYS_Ladder);
		Controller.GotoState('PlayerClimbing');
	}
}

function EndClimbLadder(LadderVolume OldLadder)
{
	if(Controller != none)
	{
		Controller.EndClimbLadder();
	}
	
	if(Physics == PHYS_Ladder)
	{
		SetPhysics(PHYS_Falling);
		Controller.SetFall();
	}
	
	OnLadder = none;
}

event bool Mount(vector Delta, Actor A)
{
	local MountVolume mv;
	local int i;
	local vector HitLocation, HitNormal;
	local Actor aTrace;
	local ShimmyNode SN;

	if(!bCanMount || aHolding != none || IsInState('Mounting') || IsInState('MountFinish') || IsInState('MountHanging'))
	{
		return false;
	}
	
	foreach TouchingActors(class'ShimmyNode', SN)
	{
		if(SN.bFallDown)
		{
			return false;
		}
	}
	
	if(A == none)
	{
		A = Level;
	}
	else if(A.IsA('LevelInfo'))
	{
		foreach TouchingActors(class'MountVolume', mv)
		{
			break;
		}
		
		if(mv == none)
		{
			return false;
		}
	}
	else if(!A.bIsMountable)
	{
		return false;
	}

	bDoingMountThatTCsShouldFollow = false;
	
	if(IsLeadChar() && Physics == PHYS_Falling)
	{
		for(i = 0; i < 2; i++)
		{
			if(TrailingChar[i] != none && ((Location + Delta - TrailingChar[i].Location) * U.Vec(1.0, 1.0, 0.0) Dot (Delta * U.Vec(1.0, 1.0, 0.0))) > 0.0)
			{
				TrailingChar[i].KWAIController.JumpToLeadCharLoc(true, Delta);
				
				bDoingMountThatTCsShouldFollow = true;
			}
		}
	}
	
	MountDestination = Location + Delta;
	
	if(bUseNewMountCode)
	{
		aTrace = Trace(HitLocation, HitNormal, MountDestination - U.Vec(0.0, 0.0, 100.0), MountDestination, true, U.Vec(CollisionRadius, CollisionRadius, CollisionHeight));
		
		if(aTrace != none)
		{
			MountDestination.Z = HitLocation.Z + 0.8;
		}
	}
	
	MountBase = A;
	SetBase(A);
	Velocity = U.Vec(0.0, 0.0, 0.0);
	Acceleration = U.Vec(0.0, 0.0, 0.0);
	bMountFinished = false;
	
	GotoState('Mounting');
	
	return true;
}

event PreSaveGame()
{
	HP = U.GetHP();
	
	if(HP == self)
	{
		if(SHHeroController(PC).PrePotionMusic != "")
		{
			KWPawn(HP).LastLoopedMusic = SHHeroController(PC).PrePotionMusic;
		}
		else
		{
			KWPawn(HP).LastLoopedMusic = U.GetCurrentMusic();
		}
	}
}

event PostLoadGame(bool bLoadFromSaveGame)
{
	local int bonuslevelcoins, bonuslevelHealth;
	local bonusLevelTransferTimer bt;
	local SaveTimer ST;
	
	PC = U.GetPC();
	HP = U.GetHP();
	
	if(bLoadFromSaveGame)
	{
		KWRemoveShadow();
		KWAddShadow();
		bInitializeAnimation = false;
		PlayWaiting();
		bGameFinishedLoading = false;
		
		if(U.GetCurrentMusic() != KWPawn(HP).LastLoopedMusic)
		{
			U.PlayAMusic(KWPawn(HP).LastLoopedMusic);
		}
	}
	
	RemovePotion();
	bNeedToSave = false;
	
	foreach AllActors(class'Shrek', shrekky)
	{
		break;
	}
	
	if(IsBadStateForSaving())
	{
		if(Controller != none)
		{
			Controller.GotoState('PlayerWalking');
		}
		
		GotoState('StateIdle');
	}
	
	if(HP == self)
	{
		UnPause();
		U.CC("UnpauseSounds");
		
		if(bLoadFromSaveGame)
		{
			bonuslevelcoins = class'SHHeroController'.default.bonuscoins;
			bonuslevelHealth = class'SHHeroController'.default.bonusHealth;
			
			if(bonuslevelcoins > 0)
			{
				U.AddInventory(class'CoinCollection', bonuslevelcoins);
				SHHeroController(PC).bonuscoins = 0;
				SHHeroController(PC).SaveConfig();
				bNeedToSave = true;
			}
			
			if(bonuslevelHealth > 0)
			{
				U.AddHealth(self, bonuslevelHealth);
				SHHeroController(PC).bonusHealth = 0;
				SHHeroController(PC).SaveConfig();
				bNeedToSave = true;
			}
			
			foreach AllActors(class'SaveTimer', ST)
			{
				ST.Destroy();
			}
		}
		
		foreach AllActors(class'bonusLevelTransferTimer', bt)
		{
			bt.Destroy();
		}
		
		if(KWPawn(HP).aBoss != none)
		{
			U.GetHUD().FadeHudItemIn(2);
		}
	}
}

function AddAnimNotifys()
{
	SetUnLitOnLowEndMachine();
}

event TravelPreAccept();

function bool IsBadStateForSaving()
{
	return false;
}

function OnEvent(name EventName)
{
	switch(EventName)
	{
		case 'Restart':
			if(MaxHealth > 0.0)
			{
				U.SetHealth(self, MaxHealth);
			}
			else
			{
				U.SetHealth(self, U.GetMaxHealth(self));
			}
			
			break;
		case 'DestroyCutController':
			if(Controller.IsA('KWCutController'))
			{
				if(Controller.IsInState('Scripting'))
				{
					Controller.UnPossess();
				}
			}
			
			break;
		case 'StartConstantRotation':
			GotoState('stateConstantRotation');
			
			break;
		case 'Destroy':
			U.FancyDestroy(self);
			
			break;
		case 'EnableSpellTarget':
			bProjTarget = true;
			
			break;
		case 'DisableSpellTarget':
			bProjTarget = false;
			
			break;
	}
	
	if(KWAIController != none)
	{
		KWAIController.NotifyOnEvent(EventName);
	}
}

event SetWalking(bool bNewIsWalking)
{
	if(bNewIsWalking != bIsWalking)
	{
		bInitializeAnimation = false;
		bIsWalking = bNewIsWalking;
		ChangeAnimation();
	}
}

function PlayFootStepsSound()
{
	local Sound snd;
	local KWGame.EMaterialType mtype;
	
	if(Physics != PHYS_Walking || VSize2d(Acceleration) < 100.0)
	{
		return;
	}
	
	mtype = TraceMaterial(Location, 1.5 * CollisionHeight);
	
	switch(mtype)
	{
		case MTYPE_Stone:
			snd = GetRandSound(FootstepsStone);
			
			break;
		case MTYPE_Rug:
			snd = GetRandSound(FootstepsRug);
			
			break;
		case MTYPE_Wood:
			snd = GetRandSound(FootstepsWood);
			
			break;
		case MTYPE_Wet:
		case MTYPE_WetCanJump:
			snd = GetRandSound(FootstepsWet);
			
			break;
		case MTYPE_Grass:
			snd = GetRandSound(FootstepsGrass);
			
			break;
		case MTYPE_Metal:
			snd = GetRandSound(FootstepsMetal);
			
			break;
		case MTYPE_Dirt:
			snd = GetRandSound(FootstepsDirt);
			
			break;
		case MTYPE_Hay:
			snd = GetRandSound(FootstepsHay);
			
			break;
		case MTYPE_Leaf:
			snd = GetRandSound(FootstepsLeaf);
			
			break;
		case MTYPE_Snow:
			snd = GetRandSound(FootstepsSnow);
			
			break;
		case MTYPE_Sand:
		case MTYPE_QuickSand:
			snd = GetRandSound(FootstepsSand);
			
			break;
		case MTYPE_Mud:
			snd = GetRandSound(FootstepsMud);
			
			break;
		default:
			snd = GetRandSound(FootstepsNone);
			
			break;
	}
	
	if(bInWater)
	{
		snd = GetRandSound(FootstepsWade);
		PlayOwnedSound(snd, SLOT_None, RandRange(0.5, 1.0), true, 800.0, RandRange(0.7, 1.1));
	}
	
	PlayOwnedSound(snd, SLOT_None, FootstepVolume, true, 800.0, RandRange(0.9, 1.1));
}

function PlayerThrowCarryingActor()
{
    PlayerThrowCarryingActorGeneral(0.0);
}

function OnSaveGame()
{
	local string savedate, strMinute, Filename, saveimage;
	local int Minute;
	
	PC = U.GetPC();
	HP = U.GetHP();
	
	Minute = Level.Minute;
	
	if(Minute < 10)
	{
		strMinute = "0" $ string(Minute);
	}
	else
	{
		strMinute = "" $ string(Minute);
	}
	
	savedate = string(Level.Hour) $ ":" $ strMinute $ "   " $ string(Level.Month) $ "/" $ string(Level.Day) $ "/" $ string(Level.Year);
	Filename = GetURLMap();
	saveimage = Localize("All", "menuitems_144", "HPMenu");
	
	if(InStr(Caps(Filename), "SWAMP") > -1)
	{
		saveimage = Localize("All", "menuitems_144", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HIJACK") > -1)
	{
		saveimage = Localize("All", "menuitems_145", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HUNT_PART1") > -1)
	{
		saveimage = Localize("All", "menuitems_146", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HUNT_PART2") > -1)
	{
		saveimage = Localize("All", "menuitems_147", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HUNT_PART3") > -1)
	{
		saveimage = Localize("All", "menuitems_148", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HUNT_PART4") > -1)
	{
		saveimage = Localize("All", "menuitems_149", "HPMenu");
	}
	else if(InStr(Caps(Filename), "FGM_PIB") > -1)
	{
		saveimage = Localize("All", "menuitems_150", "HPMenu");
	}
	else if(InStr(Caps(Filename), "FGM_DONKEY") > -1)
	{
		saveimage = Localize("All", "menuitems_151", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HAMLET_END") > -1)
	{
		saveimage = Localize("All", "menuitems_154", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HAMLET_MINE") > -1)
	{
		saveimage = Localize("All", "menuitems_153", "HPMenu");
	}
	else if(InStr(Caps(Filename), "HAMLET") > -1)
	{
		saveimage = Localize("All", "menuitems_152", "HPMenu");
	}
	else if(InStr(Caps(Filename), "PRISON_DONKEY") > -1)
	{
		saveimage = Localize("All", "menuitems_156", "HPMenu");
	}
	else if(InStr(Caps(Filename), "PRISON_PIB") > -1)
	{
		saveimage = Localize("All", "menuitems_156a", "HPMenu");
	}
	else if(InStr(Caps(Filename), "PRISON_SHREK") > -1)
	{
		saveimage = Localize("All", "menuitems_157", "HPMenu");
	}
	else if(InStr(Caps(Filename), "CASTLE") > -1)
	{
		saveimage = Localize("All", "menuitems_158", "HPMenu");
	}
	else if(InStr(Caps(Filename), "BATTLE") > -1)
	{
		saveimage = Localize("All", "menuitems_159", "HPMenu");
	}
	
	switch(U.GetCurrentSaveSlot())
	{
		case 1:
			SHHeroPawn(HP).SaveInfo.Save1Date = savedate;
			SHHeroPawn(HP).SaveInfo.Save1Name = saveimage;
			
			break;
		case 2:
			SHHeroPawn(HP).SaveInfo.Save2Date = savedate;
			SHHeroPawn(HP).SaveInfo.Save2Name = saveimage;
			
			break;
		case 3:
			SHHeroPawn(HP).SaveInfo.Save3Date = savedate;
			SHHeroPawn(HP).SaveInfo.Save3Name = saveimage;
			
			break;
		case 4:
			SHHeroPawn(HP).SaveInfo.Save4Date = savedate;
			SHHeroPawn(HP).SaveInfo.Save4Name = saveimage;
			
			break;
		case 5:
			SHHeroPawn(HP).SaveInfo.Save5Date = savedate;
			SHHeroPawn(HP).SaveInfo.Save5Name = saveimage;
			
			break;
		default:
			SHHeroPawn(HP).SaveInfo.Save0Date = savedate;
			SHHeroPawn(HP).SaveInfo.Save0Name = saveimage;
			
			break;
	}
	
	SHHeroPawn(HP).SaveInfo.SaveConfig();
	SHHeroController(PC).SaveGame();
}

function CreateInterestManager()
{
	local SHInterestManager CM;
	
	HP = U.GetHP();
	
	foreach AllActors(class'SHInterestManager', CM)
	{
		InterestMgr = CM;
		
		break;
	}
	
	if(InterestMgr == none)
	{
		InterestMgr = Spawn(class'SHInterestManager', self);
	}
	
	InterestMgr.SetOwner(HP);
}

function CreateEnemyCommentaryManager()
{
	local CommentaryManagerCheer CM;
	
	HP = U.GetHP();
	
	foreach AllActors(class'CommentaryManagerCheer', CM)
	{
		CheerMgr = CM;
		
		break;
	}
	
	if(CheerMgr == none)
	{
		CheerMgr = Spawn(class'CommentaryManagerCheer', self);
	}
	
	CheerMgr.SetOwner(HP);
}

function OnStartedAccelerating()
{
	if(KWAIController != none)
	{
		KWAIController.NotifyOnStartedAccelerating();
	}
	
	if(IsInState('stateHeroDying') || IsInState('Mounting') || IsInState('MountFinish') || IsInState('MountHanging'))
	{
		return;
	}
	
	if(aHolding == none)
	{
		PlayAnim(GetIdleAnimName(),,, 0);
	}
	else
	{
		PlayAnim(GetCarryIdleAnimName(aHolding),,, 0);
	}
}

event AnimNotifyBlendOutLanding()
{
	AnimBlendToAlpha(1, 0.0, fLandingTweenOutTime);
}

event AnimNotifyBlendOutEndAirAttack()
{
	AnimBlendToAlpha(1, 0.0, fLandingTweenOutTime);
	LandAnims[0] = default.LandAnims[0];
	LandAnims[1] = default.LandAnims[1];
	
	if(IsInState('stateStartAirAttack'))
	{
		GotoState('StateIdle');
	}
}

event AnimNotifyBlendOutContinueAirAttack()
{
	AnimBlendToAlpha(1, 0.0, fLandingTweenOutTime);
	LandAnims[0] = default.LandAnims[0];
	LandAnims[1] = default.LandAnims[1];
	
	if(IsInState('stateContinueAirAttack'))
	{
		GotoState('stateAttack1');
	}
}

event AnimNotifyObjectPickup()
{
	ObjectPickup(ActorToCarry, PickupBoneName);
	PlayPickupSound();
	
	if(shpawn(ActorToCarry).PickUpType >= 0)
	{
		ShakeTheGround();
	}
}

function AddFootStepsNotify(MeshAnimation MeshAnim)
{
	local int i;
	local MeshAnimation NewMesh;
	
	if(FootFramesRun.Length > 0 && _MovementAnims[0] != 'None' && HasAnim(_MovementAnims[0]))
	{
		if(MeshAnim == none)
		{
			NewMesh = GetAnimObjectByName(_MovementAnims[0]);            
		}
		else
		{
			NewMesh = MeshAnim;
		}
		
		for(i = 0; i < FootFramesRun.Length; i++)
		{
			AddNotify(NewMesh, _MovementAnims[0], float(FootFramesRun[i]), 'PlayFootStepsSound');
		}
	}
	
	if(FootFramesWalk.Length > 0 && WalkAnims[0] != 'None' && HasAnim(WalkAnims[0]))
	{
		if(MeshAnim == none)
		{
			NewMesh = GetAnimObjectByName(WalkAnims[0]);            
		}
		else
		{
			NewMesh = MeshAnim;
		}
		
		for(i = 0; i < FootFramesWalk.Length; i++)
		{
			AddNotify(NewMesh, WalkAnims[0], float(FootFramesWalk[i]), 'PlayFootStepsSound');
		}
	}
	
	if(FootFramesCarry.Length > 0)
	{
		if(MeshAnim == none)
		{
			NewMesh = GetAnimObjectByName(_MovementAnims[0]);            
		}
		else
		{
			NewMesh = MeshAnim;
		}
		
		for(i = 0; i < FootFramesWalk.Length; i++)
		{
			AddNotify(NewMesh, CarryForwardAnimName, float(FootFramesCarry[i]), 'PlayFootStepsSound');
		}
	}
	
	if(FootFramesWalk.Length == 0)
	{
		return;
	}
	
	if(HasAnim(CarryForwardAnimName))
	{
		for(i = 0; i < FootFramesWalk.Length; i++)
		{
			AddNotify(MeshAnim, CarryForwardAnimName, float(FootFramesWalk[i]), 'PlayFootStepsSound');
		}
	}
	
	if(CarryForwardAnimNames.Length != 0 && HasAnim(CarryForwardAnimNames[0]))
	{
		for(i = 0; i < FootFramesWalk.Length; i++)
		{
			AddNotify(MeshAnim, CarryForwardAnimNames[0], float(FootFramesWalk[i]), 'PlayFootStepsSound');
		}
	}
	
	if(HasAnim(WadeAnims[0]))
	{
		for(i = 0; i < FootFramesWalk.Length; i++)
		{
			AddNotify(MeshAnim, WadeAnims[0], float(FootFramesWalk[i]), 'PlayFootStepsSound');
		}
	}
}

function bool CanPlayLookAroundAnim()
{
	if(LookAroundAnims.Length > 0)
	{
		return true;
	}
	else
	{
		return false;
	}
}

function PlayLookAroundAnim()
{
	local name AnimName;
	
	if(!CanPlayLookAroundAnim())
	{
		return;
	}
	
	AnimName = LookAroundAnims[Rand(LookAroundAnims.Length)];
	PlayAnim(AnimName, RandRange(0.7, 1.0), 0.0);
}

function PlayEndAirAttackFX()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = Trace(HitLocation, HitNormal, Location - U.Vec(0.0, 0.0, 500.0), Location, true, U.Vec(1.0, 1.0, 1.0));
	
	if(HitActor.IsA('LevelInfo') || HitActor.IsA('TerrainInfo'))
	{
		Spawn(EndAirAttackEmitterName,,, HitLocation);
		PlayOwnedSound(EndAirAttackSound, SLOT_None, 1.0, true, 1000.0, 1.0);
	}
}

function MoveShimmy(name SeqName, float AnimFrame, float AnimRate, float DeltaTime)
{
	return;
}

function CreateRibbonEmitters(int animIndex)
{
	DestroyRibbonEmitters();
	
	if(AttackStartBoneNames[animIndex] == 'None' || U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	RibbonEffect = Spawn(RibbonEmitterName, self);
	
	if(RibbonEffect == none)
	{
		return;
	}
	
	RibbonEmitter(RibbonEffect.Emitters[0]).BoneNameStart = AttackStartBoneNames[animIndex];
	RibbonEmitter(RibbonEffect.Emitters[0]).BoneNameEnd = AttackEndBoneNames[animIndex];
	
	if(TexName != none)
	{
		RibbonEmitter(RibbonEffect.Emitters[0]).Texture = TexName;
	}
	
	if(bHasStrengthPotion && PowerfulTexName != none)
	{
		RibbonEmitter(RibbonEffect.Emitters[0]).Texture = PowerfulTexName;
	}
	
	if(AttackStartBoneExtraNames[animIndex] == 'None')
	{
		return;
	}
	
	RibbonExtraEffect = Spawn(RibbonEmitterName, self);
	
	if(RibbonExtraEffect == none)
	{
		return;
	}
	
	RibbonEmitter(RibbonExtraEffect.Emitters[0]).BoneNameStart = AttackStartBoneExtraNames[animIndex];
	RibbonEmitter(RibbonExtraEffect.Emitters[0]).BoneNameEnd = AttackEndBoneExtraNames[animIndex];
	
	if(TexName != none)
	{
		RibbonEmitter(RibbonExtraEffect.Emitters[0]).Texture = TexName;
	}
	
	if(bHasStrengthPotion && PowerfulTexName != none)
	{
		RibbonEmitter(RibbonExtraEffect.Emitters[0]).Texture = PowerfulTexName;
	}
}

function CreateRibbonEmittersForRunAttack()
{
	CreateRibbonEmitters(3);
}

function DestroyRibbonEmitters()
{
	if(RibbonEffect != none)
	{
		RibbonEffect.Destroy();
		RibbonEffect = none;
	}
	
	if(RibbonExtraEffect != none)
	{
		RibbonExtraEffect.Destroy();
		RibbonExtraEffect = none;
	}
}

function OnBounceExtra(bool bCanMoveWhileJumping)
{
	HP = U.GetHP();
	
	if(!bCanMoveWhileJumping)
	{
		bUseBouncePad = true;
	}
	else
	{
		bUseBouncePad = false;
	}
	
	if(bUseBouncePad && HP == self && (IsInState('stateStartAirAttack') || IsInState('stateContinueAirAttack')))
	{
		AnimBlendToAlpha(1, 0.0, fLandingTweenOutTime);
		LandAnims[0] = default.LandAnims[0];
		LandAnims[1] = default.LandAnims[1];
		GotoState('StateIdle');
	}
	
	if(bUseBouncePad && HP == self && Controller != none)
	{
		Controller.GotoState('StateNoPawnMoveCanTurn');
	}
}

function Landed(vector N)
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, TraceStart, TraceEnd, Dir;
	local rotator Rot;
	local BouncePad BP;
	local int i;
	
	HP = U.GetHP();
	
	iAirJumpCounter = 0;
	iDoubleJumpCounter = 0;
	
	if(bUseBouncePad)
	{
		if(Velocity.Z < (-1.0 * MaxFallSpeed))
		{
			Velocity.Z = -1.0 * MaxFallSpeed;
		}
		
		TriggerEvent(LandingEvent, none, none);
	}
	
	if(bUseBouncePad || bUseJumpMagnet)
	{
		FallOrginLocation = Location;
		bUseBouncePad = false;
		bUseJumpMagnet = false;
		
		if(HP == self && Controller != none && Controller.IsInState('StateNoPawnMoveCanTurn'))
		{
			Controller.GotoState('PlayerWalking');
		}
	}
	
	bFallingAutoDecel2d = false;
	
	LandBob = FMin(50.0, 0.055 * Velocity.Z);
	TakeFallingDamage();
	
	if(U.GetHealth(self) > 0.0)
	{
		PlayLanded(Velocity.Z);
	}
	
	bJustLanded = true;
	bDoingDoubleJump = false;
	
	foreach TouchingActors(class'BouncePad', BP)
	{
		if(BP.bEnabled)
		{
			BouncePadHit = BP;
		}
	}
	
	fLastLandedTime = Level.TimeSeconds;
	
	if(bDestroyOnLanded)
	{
		U.FancyDestroy(self);
		
		return;
	}
	
	TraceStart = Location;
	TraceEnd = TraceStart + ((U.Vec(0.0, 0.0, -1.0) * 2.0) * CollisionHeight);
	
	foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, TraceStart, U.Vec(0.0, 0.0, 0.0))
	{
		if(HitActor != none)
		{
			if(HitActor.IsA('LandingObject'))
			{
				LandingObject(HitActor).GotoState('stateLanding');
				
				return;
			}
		}
	}
	
	Rot = Rotation;
	
	for(i = 0; i < 4; i++)
	{
		Dir = vector(Rot);
		TraceStart = Location + (Dir * CollisionRadius);
		TraceEnd = TraceStart + ((U.Vec(0.0, 0.0, -1.0) * 2.0) * CollisionHeight);
		
		foreach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, TraceStart, U.Vec(0.0, 0.0, 0.0))
		{
			if(HitActor != none)
			{
				if(HitActor.IsA('LandingObject'))
				{
					LandingObject(HitActor).GotoState('stateLanding');
					
					return;
				}
			}
		}
		
		Rot.Yaw += 16384;
	}
	
	if(bLandSlowdown)
	{
		Rot = Rotation;
		Rot.Pitch = 0;
		Rot.Roll = 0;
		Rot.Yaw += 32768;
		Dir = vector(Rot);
		Velocity = Dir * 100.0;
	}
}

function SetFuturePlayerLabel()
{
	local Shrek shrk;
	
	foreach AllActors(class'Shrek', shrk)
	{
		shrk.SetPropertyText("FuturePlayerLabel", U.GetHP().GetPropertyText("Label"));
		
		break;
	}
}

function bool PickUpClosestObject()
{
	local shpawn shp, shpClosest;
	local float dist, DistMin, cosA;
	local vector v1, v2;
	local rotator r1, r2;

	DistMin = 1000000.0;
	
	if(IsAttacking())
	{
		return false;
	}
	
	foreach AllActors(class'shpawn', shp)
	{
		if(!shp.bCanBePickedUp)
		{
			continue;
		}
		
		r1 = Rotation;
		r1.Pitch = 0;
		r1.Roll = 0;
		v1 = vector(r1);
		v2 = shp.Location - Location;
		r2 = rotator(v2);
		r2.Pitch = 0;
		r2.Roll = 0;
		v2 = vector(r2);
		cosA = v1 Dot v2;
		
		if(cosA < 0.7)
		{
			continue;
		}
		
		dist = VSize2d(shp.Location - Location);
		
		if(dist > 30.0 + shp.CollisionRadius + CollisionRadius)
		{
			continue;
		}
		
		if(shp.Location.Z - shp.CollisionHeight > Location.Z)
		{
			continue;
		}
		
		if(shp.Location.Z + shp.CollisionHeight < Location.Z - CollisionHeight)
		{
			continue;
		}
		
		if(dist < DistMin)
		{
			DistMin = dist;
			shpClosest = shp;
		}
	}
	
	if(shpClosest != none)
	{
		PickupActor(shpClosest);
		
		return true;
	}
	
	return false;
}

function bool ActivateDriveThrough()
{
	local DriveThrough swtch, Closest;
	local float dist, DistMin;

	DistMin = 1000000.0;
	
	if(IsAttacking())
	{
		return false;
	}
	
	foreach AllActors(class'DriveThrough', swtch)
	{
		dist = VSize2d(swtch.Location - Location);
		
		if(dist > 10.0 + swtch.CollisionRadius + CollisionRadius)
		{
			continue;
		}
		
		if(swtch.Location.Z - swtch.CollisionHeight > Location.Z)
		{
			continue;
		}
		
		if(swtch.Location.Z + swtch.CollisionHeight < Location.Z - CollisionHeight)
		{
			continue;
		}
		
		if(dist < DistMin)
		{
			DistMin = dist;
			Closest = swtch;
		}
	}
	
	if(Closest != none)
	{
		Closest.ActivateVendor();
		
		return true;
	}
	
	return false;
}

function bool ThrowSwitchClosestObject()
{
	local Switch swtch, swtchClosest;
	local float dist, DistMin, cosA, cosB;
	local vector v1, v2, v3;
	local rotator r1, r2, r3;

	DistMin = 1000000.0;
	
	if(IsAttacking())
	{
		return false;
	}
	
	if(IsInState('stateThrowPotion') || IsInState('stateDrinkPotion'))
	{
		return false;
	}
	
	foreach AllActors(class'Switch', swtch)
	{
		if(!swtch.IsInState('StateOff'))
		{
			continue;
		}
		
		r1 = Rotation;
		r1.Pitch = 0;
		r1.Roll = 0;
		r2 = swtch.Rotation;
		r2.Pitch = 0;
		r2.Roll = 0;
		v1 = vector(r1);
		v2 = vector(r2);
		cosA = v1 Dot v2;
		
		if(cosA < 0.7)
		{
			continue;
		}
		
		v3 = swtch.Location - Location;
		r3 = rotator(v3);
		r3.Pitch = 0;
		r3.Roll = 0;
		v3 = vector(r3);
		cosB = v3 Dot v2;
		
		if(cosB < 0.7)
		{
			continue;
		}
		
		dist = VSize2d(swtch.Location - Location);
		
		if(dist > 30.0 + swtch.CollisionRadius + CollisionRadius || swtch.Location.Z - swtch.CollisionHeight > Location.Z || swtch.Location.Z + swtch.CollisionHeight < Location.Z - CollisionHeight)
		{
			continue;
		}
		
		if(dist < DistMin)
		{
			DistMin = dist;
			swtchClosest = swtch;
		}
	}
	
	if(swtchClosest != none)
	{
		return ThrowSwitch(swtchClosest);
	}
	
	return false;
}

function bool ThrowSwitch(Actor Other)
{
	HP = U.GetHP();
	
	if(!(HP == self) || bShrink || Other.IsA('KActor') || Physics != PHYS_Walking || !Controller.IsInState('PlayerWalking') || IsInState('stateThrowPotion') || IsInState('stateDrinkPotion') || IsInState('stateKnockBack') || IsInState('stateKnockForward') || IsInState('stateUpEndFront') || IsInState('stateUpEndBack') || IsInState('statePickupItem') || IsInState('StateCarryItem') || IsInState('stateThrowItem') || IsInState('stateThrowSwitch') || aHolding != none || !Other.IsA('Switch') || SHHeroName != Switch(Other).PlayerName)
	{
		return false;
	}
	
	SwitchActor = Other;
	GotoState('stateThrowSwitch');
	
	return true;
}

function EndAttackAnimation(float tweenTime)
{
	AnimBlendToAlpha(ATTACKCHANNEL_UPPER, 0.0, tweenTime);
	AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 0.0, tweenTime);
}

function PutSwordBackIn();

function StartAttackAnimation(name animseq)
{
	AnimBlendToAlpha(ATTACKCHANNEL_UPPER, 1.0, 0.0);
	PlayAnim(animseq, 1.0, 0.0, ATTACKCHANNEL_UPPER);
	AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
	PlayAnim(animseq, 1.0, 0.0, ATTACKCHANNEL_LOWER);
}

function bool MovingForward()
{
	local vector Vel, Dir;
	local rotator R;
	local float dotprod;
	
	if(VSize2d(Acceleration) == 0.0 || VSize2d(Velocity) == 0.0)
	{
		return false;
	}
	
	Vel = Velocity;
	Vel.Z = 0;
	Vel = Normal(Vel);
	R = Rotation;
	R.Pitch = 0;
	R.Roll = 0;
	Dir = vector(R);
	dotprod = Vel Dot Dir;
	
	if(dotprod >= 0.5)
	{
		return true;
	}
	
	return false;
}

function StartAttack()
{
	HP = U.GetHP();
	
	if(!(HP == self) || bShrink || !Controller.IsInState('PlayerWalking') || IsInState('stateThrowPotion') ||IsInState('stateDrinkPotion') || IsInState('stateKnockBack') || IsInState('stateKnockForward') || IsInState('stateUpEndFront') || IsInState('stateUpEndBack') || IsInState('statePickupItem') || IsInState('StateCarryItem') || IsInState('stateThrowItem') || aHolding != none)
	{
		return;
	}
	
	if(aBoss != none && aBoss.IsA('BossPib') && HasAnim(BossPibAttackAnim) && Physics == PHYS_Walking)
	{
		GotoState('stateBossPibAttack');
		
		return;
	}
	
	if(Physics == PHYS_Walking)
	{
		if(fSpecialAttackTime > 0.0)
		{
			GotoState('stateSpecialAttack');
		}
		else if(MovingForward())
		{
			GotoState('stateRunAttack');
		}
		else
		{
			GotoState('stateStartAttack');
		}
	}
	else if(Physics == PHYS_Falling && (Velocity.Z > 0.0 || bCanJumpAttackWhileFalling) && bCanUseJumpAttack && HasAnim(StartAirAttackAnim) && !bUseBouncePad && !bUseJumpMagnet)
	{
		GotoState('stateStartAirAttack');
	}
}


function bool IsAttacking()
{
	if(IsInState('stateStartAttack') || IsInState('stateAttack1') || IsInState('stateAttack1End') || IsInState('stateAttack2') || IsInState('stateAttack2End') || IsInState('stateAttack3') || IsInState('stateAttack3Attack1') || IsInState('stateStartAirAttack') || IsInState('stateContinueAirAttack') || IsInState('stateSpecialAttack') || IsInState('stateBossPibAttack'))
	{
		return true;
	}
	
	return false;
}

function bool LookAtJumpMagnet(JumpMagnet jm)
{
	local vector v1, v2;
	local rotator r1, r2;
	local float cosB;
	
	r1 = Rotation;
	r1.Pitch = 0;
	r1.Roll = 0;
	v1 = vector(r1);
	v2 = jm.Location - Location;
	r2 = rotator(v2);
	r2.Pitch = 0;
	r2.Roll = 0;
	v2 = vector(r2);
	cosB = v2 Dot v1;
	
	if(cosB > 0.85)
	{
		return true;
	}
	
	return false;
}

function CheckForJumpMagnets()
{
	local JumpMagnet jm, ClosestJM, CurrJM;
	local float fClosestDist, fDist;
	
	HP = U.GetHP();
	
	if(!(HP == self))
	{
		return;
	}
	
	ClosestJM = none;
	fClosestDist = 999999.0;
	
	foreach TouchingActors(class'JumpMagnet', CurrJM)
	{
		if(LookAtJumpMagnet(CurrJM))
		{
			fDist = VSize(CurrJM.Location - Location);
			
			if(fDist < fClosestDist)
			{
				ClosestJM = CurrJM;
				fClosestDist = fDist;
			}
		}
	}
	
	if(ClosestJM == none)
	{
		jm = none;
	}
	else
	{
		jm = ClosestJM;
		ClosestJM = none;
		fClosestDist = 999999.0;
		
		foreach TouchingActors(class'JumpMagnet', CurrJM)
		{
			if(LookAtJumpMagnet(CurrJM) && CurrJM != jm)
			{
				fDist = VSize(CurrJM.Location - Location);
				
				if(fDist < fClosestDist)
				{
					ClosestJM = CurrJM;
					fClosestDist = fDist;
				}
			}
		}
		
		if(ClosestJM != none)
		{
			jm = ClosestJM;
		}
	}
	
	if(jm == none)
	{
		return;
	}
	
	bUseJumpMagnet = true;
	
	if(Controller != none)
	{
		Controller.GotoState('StateNoPawnMoveCanTurn');
	}
	
	Velocity = ComputeTrajectoryByTime(Location, jm.Location, jm.JumpTime);
}

function SetJumpVars()
{
	local float Time, Distance;
	
	SetPropertyText("JumpZ", string(Sqrt((-2.0 * default.fJumpHeight) * PhysicsVolume.default.Gravity.Z)));
	MJumpZ = float(GetPropertyText("JumpZ"));
	DoubleJumpZ = Sqrt((-2.0 * fDoubleJumpHeight) * PhysicsVolume.Gravity.Z);
	Time = -MJumpZ / PhysicsVolume.Gravity.Z;
	Distance = (GroundSpeed * Time) * 2.0;
	fJumpDistScalar = fJumpDist / Distance;
}

function bool CanDoubleJump()
{
	return bool(GetPropertyText("bCanDoubleJump")) && (Velocity.Z > 0.0 || (bCanAirJump && Velocity.Z != 0.0));
}

function bool DoJump(bool bUpdating)
{
	local name animseq;
	local bool retvalue;
	
	if(bFrontEndPlayer || bShrink || IsAttacking() || aHolding != none || bDoingDoubleJump || bUseBouncePad || bUseJumpMagnet || bCannotJump)
	{
		return false;
	}
	
	if(Controller == none)
	{
		return false;
	}
	else if(Controller.IsA('KWCutController'))
	{
		return false;
	}
	
	if((!bInWater && !bInQuicksand) || bCanWaterJump)
	{
		retvalue = KWPawn_DoJump(bUpdating);
		CheckForJumpMagnets();
		
		return retvalue;
	}
	
	if(Acceleration.X == 0.0 || Acceleration.Y == 0.0)
	{
		animseq = GetAnimSequence();
		
		if(animseq != JumpWaterAnim)
		{
			PlayAnim(JumpWaterAnim, RandRange(0.9, 1.1), 0.2);
		}
	}
	
	return false;
}

protected function bool KWPawn_DoJump(bool bUpdating)
{
	local bool bReturn;
	
	if(bIsSliding || aHolding != none || bDoingDoubleJump)
	{
		return false;
	}
	
	bFallingAutoDecel2d = false;
	bReturn = Pawn_DoJump(bUpdating);
	
	if(bReturn)
	{
		Velocity.X *= fJumpDistScalar;
		Velocity.Y *= fJumpDistScalar;
	}
	
	LoopAnim(GetIdleAnimName(),,, 0);
	
	return bReturn;
}

protected function bool Pawn_DoJump(bool bUpdating)
{
	if(!bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
	{
		if(Role == ROLE_Authority)
		{
			if(Level.Game != none && Level.Game.GameDifficulty > 2.0)
			{
				MakeNoise(0.1 * Level.Game.GameDifficulty);
			}
			
			if(bCountJumps && Inventory != none)
			{
				Inventory.OwnerEvent('Jumped');
			}
		}
		
		if(Physics == PHYS_Spider)
		{
			Velocity = MJumpZ * Floor;
		}
		else if(Physics == PHYS_Ladder)
		{
			Velocity.Z = 0.0;
		}
		else if(bIsWalking)
		{
			Velocity.Z = default.MJumpZ;
		}
		else
		{
			Velocity.Z = MJumpZ;
		}
		
		if(Base != none && !Base.bWorldGeometry)
		{
			Velocity.Z += Base.Velocity.Z;
		}
		
		SetPhysics(PHYS_Falling);
		Controller.SetFall();
		
		return true;
	}
	
	return false;
}

function DoDoubleJump(bool bUpdating)
{
	if(bFrontEndPlayer || bShrink || bUseBouncePad || bUseJumpMagnet || bCannotJump || aHolding != none)
	{
		return;
	}
	
	if(Controller == none)
	{
		return;
	}
	else if(Controller.IsA('KWCutController'))
	{
		return;
	}
	
	if((!bCanAirJump || (bCanAirJump && iAirJumpCounter >= iAirJumpCount && iAirJumpCount != -1)) && iDoubleJumpCounter >= iDoubleJumpCount)
	{
		return;
	}
	
	if(Velocity.Z > 0.0 && iDoubleJumpCounter < iDoubleJumpCount)
	{
		iDoubleJumpCounter++;
	}
	else
	{
		iDoubleJumpCounter = iDoubleJumpCount;
	}
	
	iAirJumpCounter++;
	
	bDoingDoubleJump = true;
	Velocity.Z = DoubleJumpZ;
	SetPhysics(PHYS_Falling);
	PlayAnim(GetIdleAnimName(),,, 0);
	PlayDoubleJump();
}

function bool StartQuickThrow()
{
	return false;
}

function DoSomeAction()
{
	local name animseq;
	
	HP = U.GetHp();
	
	if(bFrontEndPlayer || !(HP == self))
	{
		return;
	}
	
	if(Controller == none)
	{
		return;
	}
	else if(Controller.IsA('KWCutController'))
	{
		return;
	}
	
	if((Controller != none && Controller.IsInState('StateNoPawnMoveCanTurn')) || IsInState('stateSwingingDeath') || IsInState('stateThrowPotion') || IsInState('stateDrinkPotion') || IsInState('stateKnockBack') || IsInState('stateKnockForward'))
	{
		return;
	}
	
	if(aHolding != none)
	{
		ThrowCarryingActor();
		
		return;
	}
	
	if(StartQuickThrow())
	{
		GotoState('stateQuickThrowStart');
		
		return;
	}
	
	if(IsInState('stateQuickThrowStart'))
	{
		bPressDuringQuickThrow = true;
		
		return;
	}
	
	if(IsInState('stateRunAttack'))
	{
		if(MovingForward())
		{
			bPressDuringRunAttack = true;
		}
		
		return;
	}
	
	if(PickUpClosestObject())
	{
		return;
	}
	
	if(ThrowSwitchClosestObject())
	{
		return;
	}
	
	if(ActivateDriveThrough())
	{
		return;
	}
	
	if(IsInState('stateThrowSwitch') || IsInState('stateSpecialAttack') || IsInState('stateBossPibAttack') || IsInState('stateStartAttack') || IsInState('stateAttack1End') || IsInState('stateAttack2End') || IsInState('stateAttack3Attack1') || IsInState('stateContinueAirAttack') || bIsSliding)
	{
		return;
	}
	
	if(IsInState('stateStartAirAttack'))
	{
		animseq = GetAnimSequence(1);
		
		if(animseq == EndAirAttackAnim || animseq == ContinueAirAttackAnim)
		{
			return;
		}
		
		GotoState('stateContinueAirAttack');
		
		return;
	}
	
	if(IsInState('stateAttack1'))
	{
		GotoState('stateAttack2');
		
		return;
	}
	
	if(IsInState('stateAttack2'))
	{
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq == StartAttackAnim2)
		{
			GotoState('stateAttack3');
		}
		
		return;
	}
	
	if(IsInState('stateAttack3'))
	{
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq == StartAttackAnim3)
		{
			GotoState('stateAttack3Attack1');
		}
		
		return;
	}
	
	if(!bCannotPunch)
	{
		StartAttack();
	}
}

function PlayAttackSound(array<Sound> sounds)
{
	local Sound snd;

	snd = GetRandSound(sounds);
	
	if(snd == none)
	{
		return;
	}
	
	PlayOwnedSound(snd, SLOT_None, 1.0, false, 800.0, 1.0);
}

function PlayArraySound(array<Sound> sounds, float Probability)
{
	local Sound snd;
	
	if(FRand() > Probability)
	{
		return;
	}
	
	snd = GetRandSound(sounds);
	
	if(snd == none)
	{
		return;
	}
	
	PlayOwnedSound(snd, SLOT_None, 1.0, false, 800.0, 1.0);
}

function PlaySpecialSound(Sound snd)
{
	if(snd == none)
	{
		return;
	}
	
	PlayOwnedSound(snd, SLOT_None, 1.0, true, 800.0, 1.0);
}

function PlayJumpSound()
{
	DeliverRandomDialog(JumpSounds_String, true);
	
	PlayArraySound(JumpSounds, 1.0);
	PlayArraySound(EmoteSoundJump, 0.3);
}

function PlayDoubleJumpSound()
{
	PlayArraySound(DoubleJumpSound, 1.0);
	PlayArraySound(EmoteSoundJump, 0.5);
}

function PlayThrowingSound()
{
	PlayArraySound(SoundThrow, 1.0);
	PlayArraySound(EmoteSoundThrow, 0.4);
}

function KWGame.EMaterialType PlayLandingSound()
{
	PlayArraySound(EmoteSoundLand, 0.5);
	
	return KWPawn_PlayLandingSound();
}

protected function KWGame.EMaterialType KWPawn_PlayLandingSound()
{
    local KWGame.EMaterialType mtype;
    local Sound snd;

    mtype = TraceMaterial(Location, 1.5 * CollisionHeight);
	
    switch(mtype)
    {
        case MTYPE_Stone:
            snd = GetRandSound(LandingStone);
			
            break;
        case MTYPE_Rug:
            snd = GetRandSound(LandingRug);
			
            break;
        case MTYPE_Wood:
            snd = GetRandSound(LandingWood);
			
            break;
        case MTYPE_Wet:
        case MTYPE_WetCanJump:
            snd = GetRandSound(LandingWet);
			
            break;
        case MTYPE_Grass:
            snd = GetRandSound(LandingGrass);
			
            break;
        case MTYPE_Metal:
            snd = GetRandSound(LandingMetal);
			
            break;
        case MTYPE_Dirt:
            snd = GetRandSound(LandingDirt);
			
            break;
        case MTYPE_Hay:
            snd = GetRandSound(LandingHay);
			
            break;
        case MTYPE_Leaf:
            snd = GetRandSound(LandingLeaf);
			
            break;
        case MTYPE_Snow:
            snd = GetRandSound(LandingSnow);
			
            break;
        case MTYPE_Sand:
        case MTYPE_QuickSand:
            snd = GetRandSound(LandingSand);
			
            break;
        case MTYPE_Mud:
            snd = GetRandSound(LandingMud);
			
            break;
        default:
            snd = GetRandSound(LandingNone);
			
            break;
    }
	
    PlayOwnedSound(snd, SLOT_None, 1.0, true, 800.0, RandRange(0.8, 1.1));
	
    return mtype;
}

function PlayPainSound()
{
	PlayArraySound(EmoteSoundPain, 0.2);
}

function PlayClimbingSound()
{
	PlayArraySound(EmoteSoundClimb, 0.5);
}

function PlayShimmySound()
{
	PlayArraySound(EmoteSoundShimmy, 0.2);
	PlayArraySound(SoundShimmy, 1.0);
}

function PlayPickupSound()
{
	PlayArraySound(SoundPickup, 1.0);
}

function PreCutPossess()
{
	HP = U.GetHP();
	
	if(!(HP == self) || !ShHeroController(Controller).bPotionInUse || ShHeroController(Controller).PotionSelected != 5)
	{
		return;
	}
	
	ShHeroController(Controller).PotionEnded();
}

function PreCutUnPossess()
{
	DestroyDelegates();
	
	SetWalking(false);
}

function PostCutUnPossess()
{
	HP = U.GetHP();
	
	if(bUseBouncePad || bUseJumpMagnet)
	{
		bUseBouncePad = false;
		bUseJumpMagnet = false;
	}
	
	if(HP == self && Controller != none && Controller.IsInState('StateNoPawnMoveCanTurn'))
	{
		Controller.GotoState('PlayerWalking');
	}
}

function GoToStateKnock(bool forward)
{
	local bool frwrd;
	
	if(aHolding != none)
	{
		StateBeforeKnockBack = GetStateName();
	}
	else
	{
		StateBeforeKnockBack = 'StateIdle';
	}
	
	if(forward)
	{
		frwrd = false;
		
		if(aHolding != none)
		{
			if(HasAnim(CarryKnockForwardStartAnimName) && HasAnim(CarryKnockForwardEndAnimName))
			{
				frwrd = true;
			}
		}
		else if(HasAnim(KnockForwardStartAnimName) && HasAnim(KnockForwardEndAnimName))
		{
			frwrd = true;
		}
		
		if(frwrd)
		{
			GotoState('stateKnockForward');
		}
		else
		{
			GotoState('stateKnockBack');
		}
	}
	else
	{
		GotoState('stateKnockBack');
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local bool forward;
	
	PC = U.GetPC();
	HP = U.GetHP();
	
	if(U.GetHealth(self) <= 0.0 || AmInvunerable || instigatedBy != none && instigatedBy.IsA('SHHeroPawn') || IsInState('stateKnockBack') || IsInState('stateKnockForward') || IsInState('stateUpEndFront') || IsInState('stateUpEndBack') || IsInState('stateSwingingDeath') || !StateIsInterruptible())
	{
		return;
	}
	
	if(DamageType == class'EnvironmentDamage' && Physics != PHYS_Walking && U.GetHealth(self) - float(Damage) > 0.0)
	{
		bNoKnockback = true;
	}
	else
	{
		Pawn_TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
	}
	
	if(U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	if(HP == self)
	{
		ShrekController(PC).UpdateHealthManagerStatus();
	}
	
	forward = false;
	
	if(DamageType == class'ForwardAttackDamage')
	{
		forward = true;
	}
	
	if(aHolding != none)
	{
		if(aHolding == instigatedBy)
		{
			PlayerThrowCarryingActorGeneral(100.0);
			StateBeforeKnockBack = 'StateIdle';
		}
		
		GoToStateKnock(forward);
	}
	else if(DamageType == class'UpEndFrontDamage')
	{
		GotoState('stateUpEndFront');
	}
	else if(DamageType == class'UpEndBackDamage')
	{
		GotoState('stateUpEndBack');
	}
	else if(DamageType == class'SwingingDeathDamage')
	{
		TearOffMomentum = Momentum;
		
		GotoState('stateSwingingDeath');
	}
	else if(bNoKnockback)
	{
		bNoKnockback = false;
		U.AddHealth(HP, -float(Damage));
		ShrekController(PC).UpdateHealthManagerStatus();
		
		if(Rand(2) == 0)
		{
			PlayPainSound();
		}
		else
		{
			SayHurtBumpLine();
		}
	}
	else
	{
		GoToStateKnock(forward);
	}
}

protected function Pawn_TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;
	
	if(DamageType == none)
	{
		DamageType = class'DamageType';
	}
	
	if(Role < ROLE_Authority)
	{
		return;
	}
	
	bAlreadyDead = U.GetHealth(self) <= 0.0;
	
	if(Physics == PHYS_Walking)
	{
		Momentum.Z = FMax(Momentum.Z, 0.4 * VSize(Momentum));
	}
	
	if(instigatedBy == self || (Controller != none && instigatedBy != none && instigatedBy.Controller != none && instigatedBy.Controller.SameTeamAs(Controller)))
	{
		Momentum *= 0.6;
	}
	
	Momentum = Momentum / Mass;
	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	U.AddHealth(self, -float(actualDamage));
	
	if(HitLocation == U.Vec(0.0, 0.0, 0.0))
	{
		HitLocation = Location;
	}
	
	if(bAlreadyDead)
	{
		ChunkUp(Rotation, DamageType);
		
		return;
	}
	
	PlayHit(float(actualDamage), instigatedBy, HitLocation, DamageType, Momentum);
	
	if(U.GetHealth(self) <= 0.0)
	{
		if(instigatedBy != none)
		{
			Killer = instigatedBy.GetKillerController();
		}
		
		if(bPhysicsAnimUpdate)
		{
			TearOffMomentum = Momentum;
		}
		
		Died(Killer, DamageType, HitLocation);        
	}
	else
	{
		if(instigatedBy != none && instigatedBy != self && Controller != none && instigatedBy.Controller != none && instigatedBy.Controller.SameTeamAs(Controller))
		{
			Momentum *= 0.5;
		}
		
		AddVelocity(Momentum);
		
		if(Controller != none)
		{
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
		}
	}
	
	MakeNoise(1.0);
}

function bool IsTired()
{
	if(Controller != none)
	{
		if(Controller.IsA('KWCutController'))
		{
			return false;
		}
	}
	
	if(U.GetHealth(self) < 50.0)
	{
		return true;
	}
	
	return false;
}

function bool CanPlayFidgets()
{
	if(bIsWalking || isPoisoned || Controller == none)
	{
		return false;
	}
	
	if((!Controller.IsInState('PlayerWalking') && !Controller.IsInState('StateIdle')) || !IsInState('StateIdle') || Physics != PHYS_Walking)
	{
		return false;
	}
	
	if(aBoss != none)
	{
		if(aBoss.IsA('BossPib') || aBoss.IsA('BossFGM') || aBoss.IsA('FatKnight'))
		{
			return false;
		}
	}
	
	if(IsTired() || IsFighting() || bIsBeingAttacked)
	{
		return false;
	}
	
	return true;
}

function MoveKarmaActor(Actor HitActor, float Force)
{
	local vector V;
	local rotator R;
	
	if(!HitActor.IsA('KWKarmaActor'))
	{
		return;
	}
	
	R = Rotation;
	R.Pitch = 0;
	R.Roll = 0;
	V = vector(R);
	HitActor.KAddImpulse(V * Force, HitActor.Location);
}

function ShakeTheGround();

function SayHitKarmaBumpLine();

function HitKarmaActor(Actor HitActor, float Force, array<Sound> SoundArray)
{
	local vector V;
	local rotator R;
	
	if(!HitActor.IsA('KWKarmaActor') || (HitActor.IsA('KarmaSpawning') && HitActor.IsInState('stateSpawning')))
	{
		return;
	}
	
	R = Rotation;
	R.Pitch = 0;
	R.Roll = 0;
	V = vector(R);
	HitActor.KAddImpulse(V * Force, HitActor.Location);
	PlayAttackSound(SoundArray);
	SayHitKarmaBumpLine();
	ShakeTheGround();
	KWKarmaActor(HitActor).bWasHitInThisAttack = true;
	HitActor.TriggerEvent(HitActor.Event, none, none);
	
	if(KWKarmaActor(HitActor).NumberToHit > 0)
	{
		KWKarmaActor(HitActor).NumberToHit--;
	}
	
	if(HitActor.IsA('KarmaSpawning'))
	{
		KarmaSpawning(HitActor).TryToSpawnSomething();
	}
}

function HitSHPawn(Actor HitActor, int hitdamage, array<Sound> SoundArray, class<DamageType> DamageType)
{
	PlayAttackSound(SoundArray);
	HitActor.TakeDamage(hitdamage, self, U.Vec(0.0, 0.0, 0.0), U.Vec(0.0, 0.0, 0.0), DamageType);
	shpawn(HitActor).bWasHitInThisAttack = true;
	PlayArraySound(EmoteSoundVictory, 0.5);
	SayHitBumpLine();
}

function HitSHPropsStatic(Actor HitActor, int hitdamage, array<Sound> SoundArray, class<DamageType> DamageType)
{
	PlayAttackSound(SoundArray);
	HitActor.TakeDamage(hitdamage, self, U.Vec(0, 0, 0), U.Vec(0, 0, 0), DamageType);
	ShPropsStatic(HitActor).bSHPropsStaticWasHitInThisAttack = true;
}

function StartRegularAttack()
{
	local shpawn shp;
	local ShPropsStatic shprst;
	local KWKarmaActor ka;
	
	foreach AllActors(class'shpawn', shp)
	{
		shp.bWasHitInThisAttack = false;
	}
	
	foreach AllActors(class'KWKarmaActor', ka)
	{
		ka.bWasHitInThisAttack = false;
	}
	
	foreach AllActors(class'ShPropsStatic', shprst)
	{
		shprst.bSHPropsStaticWasHitInThisAttack = false;
	}
}

function bool CanDoPickupActor()
{
	if(bShrink)
	{
		return false;
	}
	
	return true;
}

function bool CanUsePotion()
{
	if(U.GetHealth(self) <= 0.0 || aBoss != none || Physics != PHYS_Walking || IsInState('NoMovement') || IsInState('statePickupItem') || IsInState('StateCarryItem') || IsInState('stateThrowItem') || IsInState('stateThrowSwitch') || IsInState('stateKnockBack') || IsInState('stateKnockForward') || IsInState('Mounting') || IsInState('MountFinish') || IsInState('MountHanging') || IsInState('stateThrowPotion') || IsInState('stateDrinkPotion') || IsInState('statePlayerInMovie') || IsAttacking() || Controller.IsInState('PlayerClimbing') || aHolding != none)
	{
		return false;
	}
	
	return true;
}

function bool CanUseBoneForHit()
{
	if(IsInState('stateRunAttack') || AttackInfo.Length == 0)
	{
		return false;
	}
	
	return true;
}

function HitSomebody(int hitdamage, array<Sound> SoundArray, name animseq, float AnimFrame)
{
	local KWKarmaActor ka;
	local shpawn shp;
	local ShPropsStatic shprst;
	local Actor aClosest;
	local vector Dir, dir1, dir2;
	local rotator rot1, rot2;
	local float cosYaw, cosAngle, ADist, AHeight, AAngle, dist, DistMin;
	local int newdamage;

	newdamage = hitdamage;
	
	if(bHasStrengthPotion)
	{
		newdamage *= StrengthPotionScale;
	}
	
	DistMin = 1000000.0;
	ADist = AttackDist;
	AHeight = AttackHeight;
	AAngle = AttackAngle;
	
	foreach AllActors(class'KWKarmaActor', ka)
	{
		if((ka.KarmaType != KType_OnPunchOnly && ka.KarmaType != KType_OnPunchOrBump) || ka.NumberToHit == 0 || ka.bWasHitInThisAttack)
		{
			continue;
		}
		
		Dir = ka.Location - Location;
		dist = VSize2d(Dir);
		
		if(dist > CollisionRadius + ADist + ka.CollisionRadius)
		{
			continue;
		}
		
		if(HitType == HT_FULLBODY)
		{
			if(ka.Location.Z - ka.CollisionHeight > Location.Z + CollisionHeight + AHeight || ka.Location.Z + ka.CollisionHeight < Location.Z - CollisionHeight - AHeight)
			{
				continue;
			}
		}
		else if(HitType == HT_UPPERBODY)
		{
			if(ka.Location.Z - ka.CollisionHeight > Location.Z + CollisionHeight + AHeight || ka.Location.Z + ka.CollisionHeight < Location.Z - AHeight)
			{
				continue;
			}
		}
		else if(HitType == HT_LOWBODY)
		{
			if(ka.Location.Z - ka.CollisionHeight > Location.Z + AHeight || ka.Location.Z + ka.CollisionHeight < Location.Z - CollisionHeight - AHeight)
			{
				continue;
			}
		}
		
		rot1 = Rotation;
		rot1.Pitch = 0;
		rot1.Roll = 0;
		rot2 = rotator(Dir);
		rot2.Pitch = 0;
		rot2.Roll = 0;
		dir1 = vector(rot1);
		dir2 = vector(rot2);
		cosYaw = dir1 Dot dir2;
		cosAngle = Cos((AAngle * Pi) / 180.0);
		
		if(cosYaw < cosAngle)
		{
			continue;
		}
		
		if(dist < DistMin)
		{
			DistMin = dist;
			aClosest = ka;
		}
	}
	
	if(aClosest != none)
	{
		if(!CanUseBoneForHit())
		{
			HitKarmaActor(aClosest, KWKarmaActor(aClosest).ForceFromHit, SoundArray);
		}
		else if(HitByBone(aClosest, animseq, AnimFrame))
		{
			HitKarmaActor(aClosest, KWKarmaActor(aClosest).ForceFromHit, SoundArray);
		}
		
		return;
	}
	
	foreach VisibleCollidingActors(class'shpawn', shp, CollisionRadius + ADist + 200.0, Location, true)
	{
		if(shp.bIsAFriend || !shp.bCouldBeAttacked || shp == self || shp.bWasHitInThisAttack)
		{
			continue;
		}
		
		Dir = shp.Location - Location;
		dist = VSize2d(Dir);
		
		if(dist > CollisionRadius + ADist + shp.CollisionRadius)
		{
			continue;
		}
		
		if(HitType == HT_FULLBODY)
		{
			if(shp.Location.Z - shp.CollisionHeight > Location.Z + CollisionHeight + AHeight || shp.Location.Z + shp.CollisionHeight < Location.Z - CollisionHeight - AHeight)
			{
				continue;
			}
		}
		else if(HitType == HT_UPPERBODY)
		{
			if(shp.Location.Z - shp.CollisionHeight > Location.Z + CollisionHeight + AHeight || shp.Location.Z + shp.CollisionHeight < Location.Z - AHeight)
			{
				continue;
			}
		}
		else if(HitType == HT_LOWBODY)
		{
			if(shp.Location.Z - shp.CollisionHeight > Location.Z + AHeight || shp.Location.Z + shp.CollisionHeight < Location.Z - CollisionHeight - AHeight)
			{
				continue;
			}
		}
		
		rot1 = Rotation;
		rot1.Pitch = 0;
		rot1.Roll = 0;
		rot2 = rotator(Dir);
		rot2.Pitch = 0;
		rot2.Roll = 0;
		dir1 = vector(rot1);
		dir2 = vector(rot2);
		cosYaw = dir1 Dot dir2;
		cosAngle = Cos((AAngle * Pi) / 180.0);
		
		if(cosYaw < cosAngle)
		{
			continue;
		}
		
		if(!CanUseBoneForHit())
		{
			HitSHPawn(shp, newdamage, SoundArray, class'RegularAttackDamage');
			
			continue;
		}
		
		if(HitByBone(shp, animseq, AnimFrame))
		{
			HitSHPawn(shp, newdamage, SoundArray, class'RegularAttackDamage');
		}
	}
	
	foreach VisibleCollidingActors(class'ShPropsStatic', shprst, CollisionRadius + ADist + 200.0, Location, true)
	{
		if(!shprst.bSHPropsStaticCouldBeAttacked || shprst.bSHPropsStaticWasHitInThisAttack)
		{
			continue;
		}
		
		Dir = shprst.Location - Location;
		dist = VSize2d(Dir);
		
		if(dist > CollisionRadius + ADist + shprst.CollisionRadius)
		{
			continue;
		}
		
		if(HitType == HT_FULLBODY)
		{
			if(shprst.Location.Z - shprst.CollisionHeight > Location.Z + CollisionHeight + AHeight || shprst.Location.Z + shprst.CollisionHeight < Location.Z - CollisionHeight - AHeight)
			{
				continue;
			}
		}
		else if(HitType == HT_UPPERBODY)
		{
			if(shprst.Location.Z - shprst.CollisionHeight > Location.Z + CollisionHeight + AHeight || shprst.Location.Z + shprst.CollisionHeight < Location.Z - AHeight)
			{
				continue;
			}
		}
		else if(HitType == HT_LOWBODY)
		{
			if(shprst.Location.Z - shprst.CollisionHeight > Location.Z + AHeight || shprst.Location.Z + shprst.CollisionHeight < Location.Z - CollisionHeight - AHeight)
			{
				continue;
			}
		}
		
		rot1 = Rotation;
		rot1.Pitch = 0;
		rot1.Roll = 0;
		rot2 = rotator(Dir);
		rot2.Pitch = 0;
		rot2.Roll = 0;
		dir1 = vector(rot1);
		dir2 = vector(rot2);
		cosYaw = dir1 Dot dir2;
		cosAngle = Cos((AAngle * Pi) / 180.0);
		
		if(shprst.bSHPropsStaticBreakAnyway)
		{
			cosAngle = 0;
		}
		
		if(cosYaw < cosAngle)
		{
			continue;
		}
		
		if(!CanUseBoneForHit())
		{
			if(IsA('Mongo'))
			{
				HitSHPropsStatic(shprst, newdamage, NoSounds, class'RegularAttackDamage');
			}
			else
			{
				HitSHPropsStatic(shprst, newdamage, SoundArray, class'RegularAttackDamage');
			}
			
			continue;
		}
		
		if(HitByBone(shprst, animseq, AnimFrame))
		{
			if(IsA('Mongo'))
			{
				HitSHPropsStatic(shprst, newdamage, NoSounds, class'RegularAttackDamage');
			}
			else
			{
				HitSHPropsStatic(shprst, newdamage, SoundArray, class'RegularAttackDamage');
			}
			
			continue;
		}
	}
}

function CheckForButton(Actor Other)
{
	local PushButton btn;
	
	if(!Other.IsA('PushButton'))
	{
		return;
	}
	
	btn = PushButton(Other);
	
	if(SHHeroName != btn.PlayerName || !btn.IsInState('stateButtonOff'))
	{
		return;
	}
	
	btn.GotoState('stateButtonDown');
}

function SimpleThrowPotion(int pIndex)
{
	local PotionBottles Potion;
	local vector V;
	local shpawn A;
	local bool potionUsed;
	
	Cam = U.GetCam();

	Spawn(class'PotionTimer');
	
	switch(pIndex)
	{
		case 0:
			Potion = Spawn(class'PotionBottleOne',,, Location);
			
			break;
		case 1:
			Potion = Spawn(class'PotionBottleTwo',,, Location);
			
			break;
		case 2:
			Potion = Spawn(class'PotionBottleThree',,, Location);
			
			break;
		case 3:
			Potion = Spawn(class'PotionBottleFour',,, Location);
			
			break;
		case 4:
			Potion = Spawn(class'PotionBottleFive',,, Location);
			
			break;
		case 5:
			Potion = Spawn(class'PotionBottleSix',,, Location);
			
			break;
		case 6:
			Potion = Spawn(class'PotionBottleSeven',,, Location);
			
			break;
		case 7:
			Potion = Spawn(class'PotionBottleEight',,, Location);
			
			break;
		case 8:
			Potion = Spawn(class'PotionBottleNine',,, Location);
			
			break;
		default:
			return;
	}
	
	Potion.SetCollision(true, true, true);
	Potion.bCollideWorld = true;
	V = Normal(Cam.vForward + U.Vec(0.0, 0.0, 0.5));
	V *= fThrowVelocity;
	Potion.Velocity = V;
	Potion.SetPhysics(PHYS_Falling);
	Potion.SetOwner(none);
	
	if(Potion.Controller != none)
	{
		Potion.Controller.GotoState('stateBeingThrown');
	}
	
	if(pIndex == 0 || pIndex == 5)
	{
		PotionBegin(pIndex);
	}
	else if(pIndex == 2)
	{
		foreach VisibleCollidingActors(class'shpawn', A, 50000.0, Location, true)
		{
			potionUsed = A.PotionBegin(pIndex);
		}
	}
}

function AttachPotion(int pIndex, vector VOffset, rotator rOffset)
{
	switch(pIndex)
	{
		case 0:
			CurrentPotionBottle = Spawn(class'PotionBottleOne',,, Location);
			
			break;
		case 1:
			CurrentPotionBottle = Spawn(class'PotionBottleTwo',,, Location);
			
			break;
		case 2:
			CurrentPotionBottle = Spawn(class'PotionBottleThree',,, Location);
			
			break;
		case 3:
			CurrentPotionBottle = Spawn(class'PotionBottleFour',,, Location);
			
			break;
		case 4:
			CurrentPotionBottle = Spawn(class'PotionBottleFive',,, Location);
			
			break;
		case 5:
			CurrentPotionBottle = Spawn(class'PotionBottleSix',,, Location);
			
			break;
		case 6:
			CurrentPotionBottle = Spawn(class'PotionBottleSeven',,, Location);
			
			break;
		case 7:
			CurrentPotionBottle = Spawn(class'PotionBottleEight',,, Location);
			
			break;
		case 8:
			CurrentPotionBottle = Spawn(class'PotionBottleNine',,, Location);
			
			break;
		default:
			return;
	}
	
	CurrentPotionBottle.SetDrawScale(PotionDrawScale * CurrentPotionBottle.DrawScale);
	AttachToBone(CurrentPotionBottle, ThrowPotionBoneName);
	CurrentPotionBottle.SetRelativeLocation(VOffset);
	CurrentPotionBottle.SetRelativeRotation(rOffset);
	CurrentPotionBottle.SetOwner(self);
}

function PlayThrowPotionSound()
{
	PlayOwnedSound(ThrowPotionSound, SLOT_None, 1.0, true, 1000.0, 1.0);
}

function PlayDrinkPotionSound()
{
	PlayOwnedSound(DrinkPotionSound, SLOT_None, 1.0, true, 1000.0, 1.0);
}

function ThrowPotion()
{
	local vector V;
	local int PotionIndex;
	
	Cam = U.GetCam();
	
	if(CurrentPotionBottle == none || Controller.IsA('KWCutController'))
	{
		return;
	}
	
	PotionIndex = ShHeroController(Controller).PotionSelected;
	CurrentPotionBottle.SetCollision(true, true, true);
	CurrentPotionBottle.bCollideWorld = true;
	V = Normal(Cam.vForward + U.Vec(0.0, 0.0, 0.5));
	V *= fThrowVelocity;
	CurrentPotionBottle.Velocity = V;
	
	if(PotionIndex == 0 || PotionIndex == 2 || PotionIndex == 5)
	{
		CurrentPotionBottle.Velocity = U.Vec(0.0, 0.0, 0.0);
	}
	
	CurrentPotionBottle.SetPhysics(PHYS_Falling);
	CurrentPotionBottle.SetOwner(none);
	
	if(CurrentPotionBottle.Controller != none)
	{
		CurrentPotionBottle.Controller.GotoState('stateBeingThrown');
	}
}

function RemovePotion()
{
	if(CurrentPotionBottle == none)
	{
		return;
	}
	
	CurrentPotionBottle.SetOwner(none);
	CurrentPotionBottle.Destroy();
	CurrentPotionBottle = none;
}

function DrinkPotion()
{
	local int PotionIndex;
	local shpawn A;
	
	if(CurrentPotionBottle == none || Controller.IsA('KWCutController'))
	{
		return;
	}
	
	Spawn(class'PotionTimer');
	PotionIndex = ShHeroController(Controller).PotionSelected;
	
	if(PotionIndex == 0)
	{
		PotionBegin(PotionIndex);
	}
	else if(PotionIndex == 2 || PotionIndex == 5)
	{
		PotionBegin(PotionIndex);
		
		foreach VisibleCollidingActors(class'shpawn', A, 50000.0, Location, true)
		{
			if(A != self)
			{
				A.PotionBegin(PotionIndex);
			}
		}
	}
	
	ThrowPotion();
}

function MoveAheadABit(Vector V)
{
	if(Physics != PHYS_Walking)
	{
		return;
	}
	
	Velocity = U.Vec(0.0, 0.0, 0.0);
	Acceleration = U.Vec(0.0, 0.0, 0.0);
	Move(V);
}

function vector GetRunAttackEmitterLocation()
{
	return Location;
}

event AnimEnd(int Channel)
{
	local name animseq;
	
	if(Channel == 0)
	{
		animseq = GetAnimSequence(0);
		
		if(aHolding != none)
		{
			if(GetAnimSequence(0) == (GetIdleAnimName()) || GetAnimSequence(0) == (GetCarryIdleAnimName(aHolding)))
			{
				PlayAnim(GetCarryIdleAnimName(aHolding), 1.0);
			}
			
			return;
		}
		
		if(animseq != GetIdleAnimName())
		{
			if(IsInState('MountFinish'))
			{
				return;
			}
			
			PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2));
		}
		else
		{
			if(CanPlayFidgets() && Rand(4) == 0)
			{
				if(!CanPlayLookAroundAnim())
				{
					PlayAnim(IdleAnims[Rand(8)], RandRange(0.8, 1.2), 0);
				}
				else if(Rand(4) == 0)
				{
					PlayAnim(IdleAnims[Rand(8)], RandRange(0.8, 1.2), 0);
				}
				else
				{
					PlayLookAroundAnim();
				}
			}
			else
			{
				PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2));
			}
		}
	}
	else
	{
		if(Channel == 1)
		{
			animseq = GetAnimSequence(1);
			
			if(isAJumpAnimation(animseq))
			{
				AnimBlendParams(1, 1.0, 0.0, 0.0, RootBone);
				
				if(animseq == StartAirAttackAnim)
				{
					LoopAnim(LoopAirAttackAnim, fAirStillAnimRate, fAirStillAnimTweenTime, 1.0);
				}
				else
				{
					LoopAnim(AirStillAnim, fAirStillAnimRate, fAirStillAnimTweenTime, 1.0);
				}
			}
		}
		else
		{
			if(Channel == 0)
			{
				animseq = GetAnimSequence(0);
				
				if(CanPlayFidgets() && IsAnIdleAnim(animseq))
				{
					if(FRand() < fChanceToPlayIdle && IdleAnims.Length > 0)
					{
						PlayAnim(IdleAnims[Rand(IdleAnims.Length)], RandRange(0.8, 1.2), 0.3, 0.0);                
					}
					else
					{
						if(animseq == GetIdleAnimName())
						{
							PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2), 0.0, 0.0);                    
						}
						else
						{
							PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2), 0.3, 0.0);
						}
					}
				}        
			}
			else
			{
				if(Channel == 1)
				{
					animseq = GetAnimSequence(1);
					
					if(IsALandingAnim(animseq))
					{
						AnimBlendToAlpha(1, 0.0, fLandingTweenOutTime);
					}            
				}
				else if(Channel == 0)
				{
					PlayWaiting();
				}
			}
		}
	}
}

event Falling()
{
	if(KWAIController != none)
	{
		KWAIController.NotifyFalling();
	}
	
	PlayFalling();
}

function PlayFalling()
{
	local name animseq;
	
	if(IsInState('stateStartAirAttack') || IsInState('stateContinueAirAttack'))
	{
		Velocity.Z -= AirAttackFall;
		
		if(Velocity.Z < -0.8 * MaxFallSpeed)
		{
			Velocity.Z = -0.8 * MaxFallSpeed;
		}
	}
	
	animseq = GetAnimSequence(1);
	
	if(isAJumpAnimation(animseq))
	{
		return;
	}
	
	FallOrginLocation = Location;
	AnimBlendParams(1, 1.0, 0.0, 0.0, RootBone);
	
	if(animseq == StartAirAttackAnim)
	{
		LoopAnim(LoopAirAttackAnim, fAirStillAnimRate, fAirStillAnimTweenTime, 1.0);
	}
	else if(animseq != LoopAirAttackAnim)
	{
		LoopAnim(AirStillAnim, fAirStillAnimRate, fAirStillAnimTweenTime, 1.0);
	}
}

function bool isAJumpAnimation(name animseq)
{
	if(animseq == StartAirAttackAnim || animseq == TakeoffStillAnim || animseq == TakeoffAnims[0] || animseq == TakeoffAnims[1] || animseq == TakeoffAnims[2] || animseq == TakeoffAnims[3] || animseq == DoubleJumpAnims[0] || animseq == DoubleJumpAnims[1] || animseq == DoubleJumpAnims[2] || animseq == DoubleJumpAnims[3])
	{
		return true;
	}
	
	return false;
}

function Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	HP = U.GetHP();
	
	U.SetHealth(self, 0.0);
	
	if(Controller != none && Killer != none)
	{
		Controller.WasKilledBy(Killer);
	}
	
	if(HP == self && aBoss != none && (aBoss.IsA('BossPib') || aBoss.IsA('BossFGM') || aBoss.IsA('FatKnight')))
	{
		BossPawn(aBoss).HeroKilled(self);
		StopBossEncounter();
	}
	
	SetPhysics(PHYS_Falling);
	GotoState('stateHeroDying');
}

function PoisonHero(float pTime, class<Emitter> Effect, name Bone, optional vector EffectOffset, optional rotator EffectRotation)
{
	if(!isPoisoned)
	{
		isPoisoned = true;
		timePoisoned = pTime;
		poisonEmitter = AttachEffectToPawn(Effect, Bone, EffectOffset, EffectRotation);
	}
	else
	{
		timePoisoned += pTime;
		
		if(timePoisoned > maxTimePoisoned)
		{
			timePoisoned = maxTimePoisoned;
		}
	}
}

function HitEverybody(bool EndOfSpecialAttack)
{
	local shpawn shp;
	local ShPropsStatic shprst;
	local float ADist, AHeight, dist;
	local vector Dir;

	ADist = AttackDist;
	AHeight = AttackHeight;
	
	if(EndOfSpecialAttack)
	{
		ADist *= 2.0;
	}
	
	foreach AllActors(class'shpawn', shp)
	{
		if(shp.bIsAFriend || !shp.bCouldBeAttacked || shp == self || shp.bWasHitInThisAttack)
		{
			continue;
		}
		
		Dir = shp.Location - Location;
		dist = VSize2d(Dir);
		
		if(dist > CollisionRadius + ADist + shp.CollisionRadius || shp.Location.Z - shp.CollisionHeight > Location.Z + CollisionHeight + AHeight || shp.Location.Z + shp.CollisionHeight < Location.Z - CollisionHeight - AHeight)
		{
			continue;
		}
		
		HitSHPawn(shp, 4.0, SpecialAttackSounds, class'SpecialAttackDamage');
	}
	
	foreach AllActors(class'ShPropsStatic', shprst)
	{
		if(!shprst.bSHPropsStaticCouldBeAttacked || shprst.bSHPropsStaticWasHitInThisAttack)
		{
			continue;
		}
		
		Dir = shprst.Location - Location;
		dist = VSize2d(Dir);
		
		if(dist > CollisionRadius + ADist + shprst.CollisionRadius || shprst.Location.Z - shprst.CollisionHeight > Location.Z + CollisionHeight + AHeight || shprst.Location.Z + shprst.CollisionHeight < Location.Z - CollisionHeight - AHeight)
		{
			continue;
		}
		
		if(!shp.IsA('BreakableObject'))
		{
			HitSHPropsStatic(shprst, 4, SpecialAttackSounds, class'SpecialAttackDamage');
			
			continue;
		}
		
		if(EndOfSpecialAttack)
		{
			shp.TakeDamage(4.0, self, U.Vec(0.0, 0.0, 0.0), U.Vec(0.0, 0.0, 0.0), class'SpecialAttackDamage');
		}
	}
}

function HealHero()
{
	if(poisonEmitter == none)
	{
		return;
	}
	
	GiveDamageToPlayer(int(poisonDamageAmount), none, U.Vec(0.0, 0.0, 0.0), U.Vec(0.0, 0.0, 0.0), none);
	DetachEffectFromPawn(poisonEmitter);
}

function HeroOutOfQuicksand()
{
	bInQuicksand = false;
	ChangeAnimation();
	GroundSpeed = default.GroundSpeed;
}

function HeroInWater()
{
	local array<name> MAs;
	local int i;
	
	for(i = 0; i < 4; i++)
	{
		MAs[i] = WadeAnims[i];
	}
	
	bInWater = true;
	PlayOwnedSound(InWaterSound, SLOT_None, 1.0, true, 1000.0, 1.0);
	U.HackMovementAnims(self, MAs);
	GroundSpeed = WaterGroundSpeed;
	SetPropertyText("BaseMovementRate", string(WaterGroundSpeed));
	fInWaterTime = 0.0;
	ChangeAnimation();
}

function HeroOutOfWater()
{
	bInWater = false;
	PlayOwnedSound(OutWaterSound, SLOT_None, 1.0, true, 1000.0, 1.0);
	ChangeAnimation();
	GroundSpeed = default.GroundSpeed;
	SetPropertyText("BaseMovementRate", string(_BaseMovementRate));
	
	if(bShrink)
	{
		GroundSpeed *= ShrinkLimit;
		SetPropertyText("BaseMovementRate", string(_BaseMovementRate * ShrinkLimit));
	}
	
	fInWaterTime = 0.0;
	ChangeAnimation();
}

function Bump(Actor Other)
{
	local vector V;
	
	HP = U.GetHP();

	if(Other.IsA('KWKarmaActor'))
	{
		if(KWKarmaActor(Other).KarmaType == KType_OnBumpOnly || KWKarmaActor(Other).KarmaType == KType_OnPunchOrBump)
		{
			V = Normal(Velocity);
			V.Z = 0.0;
			Other.KAddImpulse(V * KWKarmaActor(Other).ForceFromBump, Other.Location);
		}        
	}
	else if(Other.IsA('KActor'))
	{
		Other.KAddImpulse(Normal(Velocity) * 1000.0, Other.Location);
	}
	
	if(bUseBouncePad || bUseJumpMagnet)
	{
		if(HP == self && Controller != none && Controller.IsInState('StateNoPawnMoveCanTurn'))
		{
			Controller.GotoState('PlayerWalking');
		}
	}
	
	if(bNotPushableByPlayer)
	{
		return;
	}
	
	if(!(HP == self) && !IsTrailingChar() && bool(Pawn(Other).GetPropertyText("bIsMainPlayer")) && !Controller.IsA('KWCutController'))
	{
		V = Location - HP.Location;
		V.Z = 0.0;
		V = Normal(V);
		V *= 200.0;
		Velocity = V;
	}
}

function ShrinkCameraSetting(float Scale)
{
	local CamSettings cs;
	
	Cam = U.GetCam();
	
	cs = Cam.CurrentSet;
	cs.vLookAtOffset = CameraSetStandard.vLookAtOffset * Scale;
	cs.fLookAtDistance = CameraSetStandard.fLookAtDistance * Scale;
	cs.fLookAtHeight = CameraSetStandard.fLookAtHeight * Scale;
	cs.vLookAtOffset.Z += ((default.CollisionHeight * (Scale - default.DrawScale)) / default.DrawScale);
	Cam.InitSettings(cs, true, false);
	Cam.CamTarget.SetOffset(cs.vLookAtOffset);
}

function AdjustShrinkCameraSetting(float Scale)
{
	local CamSettings cs;
	local float NewLookAtDistance1, NewLookAtDistance2;
	
	Cam = U.GetCam();
	
	NewLookAtDistance1 = Cam.fDesiredLookAtDistance;
	cs = Cam.CurrentSet;
	NewLookAtDistance2 = CameraSetStandard.fLookAtDistance * Scale;
	
	if(NewLookAtDistance1 == NewLookAtDistance2)
	{
		return;
	}
	
	cs.vLookAtOffset = CameraSetStandard.vLookAtOffset * Scale;
	cs.fLookAtDistance = CameraSetStandard.fLookAtDistance * Scale;
	cs.fLookAtHeight = CameraSetStandard.fLookAtHeight * Scale;
	cs.vLookAtOffset.Z += ((default.CollisionHeight * (Scale - default.DrawScale)) / default.DrawScale);
	Cam.InitSettings(cs, true, false);
	Cam.CamTarget.SetOffset(cs.vLookAtOffset);
}

function UseShrinkPotion(float DeltaTime)
{
	local float Scale;
	
	if(bShrink && DrawScale > default.DrawScale * ShrinkLimit)
	{
		Scale = DrawScale;
		Scale -= (DeltaTime * ShrinkSpeed);
		
		if(Scale <= (default.DrawScale * ShrinkLimit))
		{
			Scale = default.DrawScale * ShrinkLimit;
		}
		
		if(SHWeap != none)
		{
			SHWeap.SetDrawScale(Scale);
		}
		
		SetDrawScale(Scale);
		PrePivot.Z = (default.CollisionHeight * (Scale - default.DrawScale)) / default.DrawScale;
		ShrinkCameraSetting(DrawScale / default.DrawScale);
	}
	
	if(bShrink && DrawScale == default.DrawScale * ShrinkLimit)
	{
		AdjustShrinkCameraSetting(default.DrawScale * ShrinkLimit);
	}
	
	if(!bShrink && DrawScale < default.DrawScale)
	{
		Scale = DrawScale;
		Scale += DeltaTime * ShrinkSpeed;
		
		if(Scale >= default.DrawScale)
		{
			Scale = default.DrawScale;
		}
		
		if(SHWeap != none)
		{
			SHWeap.SetDrawScale(Scale);
		}
		
		SetDrawScale(Scale);
		PrePivot.Z = (default.CollisionHeight * (Scale - default.DrawScale)) / default.DrawScale;
		ShrinkCameraSetting(DrawScale / default.DrawScale);
	}
}

event Tick(float DeltaTime)
{
	local name anim, Anim2, Anim3, NewAnim;
	local float frame2, rate2, frame3, rate3;
	local bool bPlayTurningAnimation;
	local vector V;
	local rotator R;
	
	PC = U.GetPC();
	HP = U.GetHP();
	
	if(IsTired() && HP == self)
	{
		if(!PC.bInCutScene() && fTimeSinceLastTiredDialog >= 10.0)
		{
			if(U.PercentChance(0.003))
			{
				if(U.GetHealth(self) > 0.0)
				{
					InterestMgr.CommentMgr.SayComment(TiredBumpLines, Tag,, true,,, self, "BumpDialog");
					
					fTimeSinceLastTiredDialog = 0.0;
				}
			}
		}
		else
		{
			fTimeSinceLastTiredDialog += DeltaTime;
		}
	}
	
	if(bIsSliding)
	{
		TickSliding(DeltaTime);
	}
	
	if(bCanBlink)
	{
		fBlinkingTime -= DeltaTime;
		
		if(Rand(200) == 0 && fBlinkingTime <= 0.0)
		{
			StartBlinkAnimation();
		}
		
		if(fBlinkingTime < 0.0)
		{
			StopBlinkAnimation();
		}
	}
	
	fDespawnTime += DeltaTime;
	
	if(fDespawnTime >= 1.0)
	{
		fDespawnTime = 0.0;
		
		if(bDespawnable && bDespawned)
		{
			if(!U.GetCam().CameraCanSeeYou(Location))
			{
				Destroy();
			}
		}
	}
	
	if(IsLeadChar())
	{
		if(VSize2d(Acceleration) > 5.0 || vOldLocation != Location)
		{
			SetTargetLocations();
		}
		
		bUseLastLocationArray = true;
	}
	
	if(bUseLastLocationArray)
	{
		TickLastLocationArray(DeltaTime);
	}
	
	if(Acceleration.X != 0.0 || Acceleration.Y != 0.0)
	{
		if(PawnAccelerationTimer == 0.0)
		{
			OnStartedAccelerating();
		}
		
		PawnMotionlessTimer = 0.0;
		PawnAccelerationTimer += DeltaTime;
	}
	else
	{
		if(PawnMotionlessTimer == 0.0)
		{
			OnStoppedAccelerating();
		}
		
		PawnAccelerationTimer = 0.0;
		PawnMotionlessTimer += DeltaTime;
	}
	
	if(Physics == PHYS_Walking)
	{
		vLastGroundPosition = Location;
		vYawAtLastGroundPosition = Rotation.Yaw;
	}
	
	if(ExtraAccelTimer > 0.0)
	{
		ExtraAccelTimer -= DeltaTime;
		
		if(ExtraAccelTimer <= 0.0)
		{
			ExtraAccelTimer = 0.0;
			ConstantAcceleration = U.Vec(0.0, 0.0, 0.0);
		}
	}
	
	if(AdditionalPrePivotDest != AdditionalPrePivot)
	{
		TickPrePivotTweening(DeltaTime);
	}
	
	if(!bUnableToBounce && BouncePadHit != none && U.GetHealth(self) > 0.0)
	{
		DoJump(true);
		BouncePadHit.OnBounce(self);
		OnBounceExtra(BouncePadHit.bCanMoveWhileJumping);
		BouncePadHit = none;
	}
	
	if(Physics == PHYS_Walking && WaterRipples != none)
	{
		PlayWaterRipples(DeltaTime);
	}
	
	if(bTweenGroundSpeed)
	{
		TickGroundSpeedTweening(DeltaTime);
	}
	
	if(Physics == PHYS_Falling && bFallingAutoDecel2d && Acceleration == U.Vec(0.0, 0.0, 0.0) && VSize2d(Velocity) > 10.0)
	{
		Velocity -= (normal2d(Velocity) * 400.0 * DeltaTime);
	}
	
	if(bControlsCameraRot && PC != none && PC.bUseBaseCam)
	{
		U.GetCam().ApplyInput(DeltaTime);
	}
	
	vOldLocation = Location;
	
	if(bInWater)
	{
		fInWaterTime += DeltaTime;
		
		if(fInWaterTime > InWaterBeforeSayingBumpLine)
		{
			SayInWaterBumpLine();
			fInWaterTime = 0.0;
		}
	}
	
	UseShrinkPotion(DeltaTime);
	
	if(Physics != PHYS_Walking && IsInState('StateCarryItem'))
	{
		PlayerThrowCarryingActorGeneral(100.0);
		GotoState('StateIdle');
	}
	
	GetAnimParams(2, Anim2, frame2, rate2);
	GetAnimParams(3, Anim3, frame3, rate3);
	bPlayTurningAnimation = false;
	
	if((Anim2 == TurnRightAnim && rate2 > 0.0) || (Anim3 == TurnLeftAnim && rate3 > 0.0))
	{
		bPlayTurningAnimation = true;
	}
	
	if(bPlayTurningAnimation && IsInState('StateIdle'))
	{
		anim = GetAnimSequence();
		
		if(aHolding != none)
		{
			NewAnim = GetCarryIdleAnimName(aHolding);
			
			if(anim != NewAnim)
			{
				PlayAnim(NewAnim);
			}
		}
		else if(anim != IdleFightAnimName)
		{
			NewAnim = GetIdleAnimName();
			
			if(anim != NewAnim)
			{
				PlayAnim(NewAnim,, 0.2);
			}
		}
	}
	
	if(!(HP == self) && !IsTrailingChar() && Controller != none && !Controller.IsA('KWCutController'))
	{
		V = HP.Location - Location;
		R = rotator(V);
		R.Roll = 0;
		R.Pitch = 0;
		DesiredRotation = R;
		Controller.DesiredRotation = R;
	}
	
	if(fSpecialAttackTime > 0.0)
	{
		fSpecialAttackTime -= DeltaTime;
	}
	else
	{
		fSpecialAttackTime = 0.0;
	}
	
	if(isPoisoned)
	{
		poisonCounter += DeltaTime;
		
		if(poisonCounter >= timePoisoned)
		{
			poisonCounter = 0.0;
			isPoisoned = false;
			HealHero();
		}
		
		damageCounter += DeltaTime;
		
		if(damageCounter >= 1.0)
		{
			if(U.GetHealth(self) - poisonDamageAmount > 0.0)
			{
				damageCounter = 0.0;
				U.AddHealth(self, -poisonDamageAmount);
			}
			else
			{
				poisonCounter = 0.0;
				isPoisoned = false;
				HealHero();
			}
		}
	}
}

function StartBossEncounter(BossEncounterTrigger bet)
{
	local HudItemHealthBossPib hp;
	local Donkey dnk;
	
	HUD = U.GetHUD();

	aBoss = bet.boss;
	HUD.FadeHudItemIn(2);
	
	foreach AllActors(class'HudItemHealthBossPib', hp)
	{
		break;
	}
	
	if(hp != none)
	{
		if(bet.boss.IsA('FatKnight'))
		{
			hp.SetBossTexture(2);
		}
		else
		{
			if(bet.boss.IsA('BanditBoss'))
			{
				hp.SetBossTexture(1);
			}
			else
			{
				hp.SetBossTexture(BossPawn(bet.boss).BossHudType);
			}
		}
	}
	
	if(bet.boss.IsA('BossFGM'))
	{
		CameraNoSnapRotation = true;
	}
	
	if(bet.boss.IsA('BossPib'))
	{
		foreach AllActors(class'Donkey', dnk)
		{
			dnk.GotoState('stateStartCheerInBossPibBattle');
		}
	}
}

function StopBossEncounter()
{
	local Donkey dnk;
	
	HUD = U.GetHUD();
	
	if(aBoss != none)
	{
		HUD.FadeHudItemOut(2);
	}
	
	if(aBoss.IsA('BossPib'))
	{
		foreach AllActors(class'Donkey', dnk)
		{
			dnk.GotoState('stateEndCheerInBossPibBattle');
		}
	}
	
	aBoss = none;
}

function PlayFootSplashes(name FootBone)
{
	local KWGame.EMaterialType mtype;
	local class<Emitter> EffectClass;
	local vector footloc, fakeloc, HitLoc, HitNorm;
	
	if(!bDoFeetSplashes || FootBone == 'None' || U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	footloc = GetBoneCoords(FootBone).Origin;
	fakeloc = footloc;
	fakeloc.Z = Location.Z;
	mtype = TraceMaterial(fakeloc, 1.5 * CollisionHeight, HitLoc, HitNorm);
	
	switch(mtype)
	{
		case MTYPE_Wet:
			EffectClass = class'Water_Splat';
			
			break;
		case MTYPE_Grass:
			EffectClass = class'Grass_Graze';
			
			break;
		case MTYPE_Mud:
			EffectClass = class'Mud_Splat';
			
			break;
		default:
			break;
	}
	
	if(EffectClass == none)
	{
		return;
	}
	
	FancySpawn(EffectClass,,, footloc);
	
	if(FootPrintDecal == none)
	{
		return;
	}
	
	Spawn(FootPrintDecal, self,, HitLoc, rotator(-HitNorm));
}

function PlayFootSplashesFrontLeft()
{
	PlayFootSplashes(FrontLeftBone);
}

function PlayFootSplashesFrontRight()
{
	PlayFootSplashes(FrontRightBone);
}

function PlayFootSplashesBackLeft()
{
	PlayFootSplashes(BackLeftBone);
}

function PlayFootSplashesBackRight()
{
	PlayFootSplashes(BackRightBone);
}

function UnPause()
{
	PC = U.GetPC();
	HUD = U.GetHUD();
	
	if(PC != none && Level.Pauser != none)
	{
		HUD.bHideHUD = false;
		PC.SetPause(false);
	}
}

function TakeFallingDamage()
{
	local CusionVolume cv;
	local BouncePad bp;
	local Actor TraceDownActor;
	local vector HitLocation, HitNormal;
	
	HP = U.GetHP();
	
	if(!(HP == self))
	{
		FallOrginLocation = Location;
		Pawn_TakeFallingDamage();
		
		return;
	}
	
	if(bIsSliding)
	{
		FallOrginLocation = Location;
		
		return;
	}
	
	foreach TouchingActors(class'CusionVolume', cv)
	{
		FallOrginLocation = Location;
		
		return;
	}
	
	foreach TouchingActors(class'BouncePad', bp)
	{
		FallOrginLocation = Location;
		
		return;
	}
	
	if(Abs(FallOrginLocation.Z - Location.Z) > float(DeathIfFallDistance) + CollisionHeight && Location.Z <= FallOrginLocation.Z)
	{
		TraceDownActor = Trace(HitLocation, HitNormal, Location - (U.Vec(0.0, 0.0, 1.5) * CollisionHeight), Location, true, U.Vec(0.0, 0.0, 0.0));
		
		if(TraceDownActor.IsA('KWMover') && KWMover(TraceDownActor).bSaveToLand)
		{
			FallOrginLocation = Location;
		}
		else
		{
			TakeDamage((U.Ceiling(Abs(FallOrginLocation.Z - Location.Z)) - DeathIfFallDistance) / 4, none, Location, U.Vec(0.0, 0.0, 0.0), class'fell');
		}
	}
	
	Pawn_TakeFallingDamage();
}

protected function Pawn_TakeFallingDamage()
{
	local float Shake, EffectiveSpeed;
	
	if(Velocity.Z < (-0.5 * MaxFallSpeed))
	{
		if(Role == ROLE_Authority)
		{
			MakeNoise(1.0);
			
			if(Velocity.Z < -1.0 * MaxFallSpeed)
			{
				EffectiveSpeed = Velocity.Z;
				
				if(TouchingWaterVolume())
				{
					EffectiveSpeed = FMin(0.0, EffectiveSpeed + 100.0);
				}
				
				if(EffectiveSpeed < -1.0 * MaxFallSpeed)
				{
					TakeDamage(int((-100.0 * (EffectiveSpeed + MaxFallSpeed)) / MaxFallSpeed), none, Location, U.Vec(0.0, 0.0, 0.0), class'fell');
				}
			}
		}
		
		if(Controller != none)
		{
			Shake = FMin(1.0, (-1.0 * Velocity.Z) / MaxFallSpeed);
			Controller.ShakeView(0.175 + (0.1 * Shake), 850.0 * Shake, Shake * U.Vec(0.0, 0.0, 1.5), 120000.0, U.Vec(0.0, 0.0, 10.0), 1.0);
		}
	}
	else
	{
		if(Velocity.Z < (-1.4 * MJumpZ))
		{
			MakeNoise(0.5);
		}
	}
}

function bool IsProtected(Actor Enemy)
{
	return false;
}

function UseSHJumpMagnet()
{
	local vector Bottom;
	
	if(NewJumpMagnet == none)
	{
		return;
	}
	
	FallOrginLocation = Location;
	Bottom = Location;
	Bottom.Z -= CollisionHeight;
	Velocity = ComputeTrajectoryByVelocity(Bottom, NewJumpMagnet.Location, SHJumpMagnet(NewJumpMagnet).JumpVelocity);
	
	if(Physics != PHYS_Falling)
	{
		SetPhysics(PHYS_Falling);
	}
	
	NewJumpMagnet = none;
}

function BFGMSwitchControlToPawn(string newname)
{
	local ShHeroPawn NewPawn;
	
	foreach DynamicActors(class'ShHeroPawn', NewPawn)
	{
		if(NewPawn.Label ~= newname)
		{
			break;
		}
	}
	
	if(NewPawn == none)
	{
		return;
	}
	
	bHidden = true;
	SetCollision(false, false, false);
	NewPawn.bHidden = false;
	NewPawn.SetLocation(Location);
	NewPawn.SetRotation(Rotation);
	NewPawn.aBoss = aBoss;
	U.SetHealth(NewPawn, U.GetHealth(self));
	ShrekCreature(NewPawn).fLiveInBFGM = float(GetPropertyText("LiveAsCreature"));
	ShrekCreature(NewPawn).ParentCollisionHeight = CollisionHeight;
	NewPawn.SetCollision(true, true, true);
	
	if(newname ~= "Chicken" || newname ~= "Mouse" || newname ~= "Frog")
	{
		SetPropertyText("PrevCreature", newname);
	}
	
	if(newname ~= "Chicken")
	{
		InterestMgr.CommentMgr.SayComment('FGM_FGMChicken', aBoss.Tag,, true,,,, "BumpDialog");
	}
	else if(newname ~= "Mouse")
	{
		InterestMgr.CommentMgr.SayComment('FGM_FGMMouse', aBoss.Tag,, true,,,, "BumpDialog");
	}
	else if(newname ~= "Frog")
	{
		InterestMgr.CommentMgr.SayComment('FGM_FGMFrog', aBoss.Tag,, true,,,, "BumpDialog");
	}
	else if(newname ~= "Human")
	{
		InterestMgr.CommentMgr.SayComment('SHK_FGMTransform', 'Shrek',, true,,,, "BumpDialog");
	}
	
	SwitchControlToPawn(newname);
}

function bool IsFighting()
{
	local shpawn shp;
	local BossPawn bp;
	
	HP = U.GetHP();
	
	if(!(HP == self) || Controller.IsA('KWCutController') || !HasAnim(IdleFightAnimName))
	{
		return false;
	}
	
	foreach VisibleCollidingActors(class'shpawn', shp, 300.0, Location, true)
	{
		if(shp.bRequireFightIdle)
		{			
			return true;
		}
	}
	
	foreach VisibleCollidingActors(class'BossPawn', bp, 1000.0, Location, true)
	{
		if(bp != none)
		{			
			return true;
		}
	}
	
	return false;
}

function name GetIdleAnimName()
{
	if(IsInState('StatePickupItem'))
	{
		return CarryIdleAnimName;
	}
	else if(IsFighting())
	{
		return IdleFightAnimName;
	}
	else if(IsTired())
	{
		return IdleTiredAnimName;
	}
	else
	{
		return default.IdleAnimName;
	}
}

function ResetSkinUp();

function PlayPickupEnergyBarBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0 || !IsTired())
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(PickupEnergyBarBumpLines, Tag,, true,,, self, "BumpDialog");
}

function PlayPickupShamrockBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(PickupShamrockBumpLines, Tag,, true,,, self, "BumpDialog");
}

function PlayLowCoinsBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(LowCoinsBumpLines, Tag,, true,,, self, "BumpDialog");
}

function PlayManyCoinsBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(ManyCoinsBumpLines, Tag,, true,,, self, "BumpDialog");
}

function SayShimmyBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(SimmyBumpLines, Tag,, true,,, self, "BumpDialog");
}

function SayHurtBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	if(bSayCombatDialog)
	{
		InterestMgr.CommentMgr.SayComment(HurtBumpLines, Tag,, true,,, self, "BumpDialog");
	}
}

function SayHitBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	if(bSayCombatDialog)
	{
		if(Rand(2) == 0)
		{
			InterestMgr.CommentMgr.SayComment(HitBumpLines, Tag,, true,,, self, "BumpDialog");
		}
	}
}

function SayInWaterBumpLine()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(InWaterBumpLines, Tag,, true,,, self, "BumpDialog");
}

function SayWastedPotionBumpLines()
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(WastedPotionBumpLines, Tag,, true,,, self, "BumpDialog");
}

function SayPotionBumpLine(int PotionIndex)
{
	HP = U.GetHP();
	
	if(!(HP == self) || U.GetHealth(self) <= 0.0)
	{
		return;
	}
	
	InterestMgr.CommentMgr.SayComment(PotionBumpLines[PotionIndex], Tag,, true,,, self, "BumpDialog");
}

function SetInvisibleTextures()
{
	local int i;
	local vector StartLocation;
	local EmitterSupport ESupport;
	
	if(SkinsInvisible.Length == 0)
	{
		return;
	}
	
	bInvisible = true;
	
	for(i = 0; i < SkinsInvisible.Length; i++)
	{
		Skins[i] = SkinsInvisible[i];
	}
	
	SetOpacity(InvisibilityPercent);
	Shadow.bShadowActive = false;
	
	if(U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	StartLocation = Location;
	StartLocation.Z += default.CollisionHeight;
	ESupport = Spawn(class'EmitterSupport',,, StartLocation);
	ESupport.SpawnSupportingEmitter(InvisibleEmitterName);
}

function SetVisibleTextures()
{
	local int i;
	local vector StartLocation;
	local EmitterSupport ESupport;
	
	if(SkinsVisible.Length == 0)
	{
		return;
	}
	
	bInvisible = false;
	SetOpacity(1.0);
	
	for(i = 0; i < SkinsVisible.Length; i++)
	{
		Skins[i] = SkinsVisible[i];
	}
	
	Shadow.bShadowActive = true;
	
	if(U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	StartLocation = Location;
	StartLocation.Z += default.CollisionHeight;
	ESupport = Spawn(class'EmitterSupport',,, StartLocation);
	ESupport.SpawnSupportingEmitter(InvisibleEmitterName);
}

function ToggleVisibility()
{
	if(bInvisible)
	{
		SetVisibleTextures();
	}
	else
	{
		SetInvisibleTextures();
	}
}

function ShowStrengthAttributes()
{
	local int i;
	
	bHasStrengthPotion = true;
	
	if(U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	for(i = 0; i < StrengthEmitterBoneName.Length; i++)
	{
		StrengthEmitter[i] = AttachEffectToPawn(StrengthEmitterName, StrengthEmitterBoneName[i]);
	}
}

function HideStrengthAttributes()
{
	local int i;
	
	bHasStrengthPotion = false;
	
	for(i = 0; i < StrengthEmitterBoneName.Length; i++)
	{
		if(StrengthEmitter[i] != none)
		{
			StrengthEmitter[i].Kill();
		}
	}
}

function StartToShrinkDown()
{
	local vector StartLocation;
	local EmitterSupport ESupport;
	local OnOffCollision ooc;
	
	bShrink = true;
	savespeeds[0] = int(GroundRunSpeed);
	savespeeds[1] = int(GroundWalkSpeed);
	savespeeds[2] = int(BaseMovementRate);
	savespeeds[2] = int(GetPropertyText("BaseMovementRate"));
	savespeeds[3] = int(GroundSpeed);
	savespeeds[4] = int(WaterGroundSpeed);
	GroundRunSpeed *= ShrinkLimit;
	GroundWalkSpeed *= ShrinkLimit;
	SetPropertyText("BaseMovementRate", string(_BaseMovementRate * ShrinkLimit));
	GroundSpeed *= ShrinkLimit;
	WaterGroundSpeed *= ShrinkLimit;
	
	foreach AllActors(class'OnOffCollision', ooc)
	{
		if(ooc != none)
		{
			ooc.SetCollision(true, true, false);
		}
	}
	
	if(U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	StartLocation = Location;
	StartLocation.Z += default.CollisionHeight;
	ESupport = Spawn(class'EmitterSupport',,, StartLocation);
	ESupport.SpawnSupportingEmitter(ShrinkEmitterName);
}

function StartToShrinkUp()
{
	local vector StartLocation;
	local EmitterSupport ESupport;
	local OnOffCollision ooc;
	
	bShrink = false;
	GroundRunSpeed = float(savespeeds[0]);
	GroundWalkSpeed = float(savespeeds[1]);
	SetPropertyText("BaseMovementRate", string(savespeeds[2]));
	GroundSpeed = float(savespeeds[3]);
	WaterGroundSpeed = float(savespeeds[4]);
	
	foreach AllActors(class'OnOffCollision', ooc)
	{
		if(ooc != none)
		{
			ooc.SetCollision(true, true, true);
		}
	}
	
	if(U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	StartLocation = Location;
	StartLocation.Z += default.CollisionHeight;
	ESupport = Spawn(class'EmitterSupport',,, StartLocation);
	ESupport.SpawnSupportingEmitter(ShrinkEmitterName);
}

function bool PotionBegin(int Potion)
{
	HP = U.GetHP();
	
	if(!(HP == self))
	{
		return false;
	}
	
	switch(Potion)
	{
		case 0:
			ShowStrengthAttributes();
			
			return true;
		case 2:
			SetInvisibleTextures();
			
			return true;
		case 5:
			StartToShrinkDown();
			
			return true;
		default:
			return false;
	}
}

function PotionFinished(int Potion)
{
	HP = U.GetHP();
	
	if(!(HP == self))
	{
		return;
	}
	
	switch(Potion)
	{
		case 0:
			HideStrengthAttributes();
			
			break;
		case 2:
			SetVisibleTextures();
			
			break;
		case 5:
			StartToShrinkUp();
			
			break;
		default:
			break;
	}
}

function StartSavedRunningGame(int GameSlot)
{
	U.LoadAGame(GameSlot);
}

function KillAllEnemiesAround(float killradius)
{
	local shpawn shp;
	
	foreach CollidingActors(class'shpawn', shp, killradius)
	{
		if(shp.bIsAFriend || !shp.bCouldBeAttacked || shp == self)
		{
			continue;
		}
		
		HitSHPawn(shp, 1000.0, Attack3Sounds, class'RegularAttackDamage');
	}
}

auto state StateIdle
{
	Begin:
	
	if(aHolding == none)
	{
		LoopAnim(GetIdleAnimName(), RandRange(0.8, 1.2), 0.4);
	}
	else
	{
		LoopAnim(GetCarryIdleAnimName(aHolding), RandRange(0.8, 1.2), 0.4);
	}
}

state statePlayerInMovie
{
	event BeginState()
	{
		if(Controller == none)
		{
			GotoState('StateIdle');
			
			return;
		}
		
		if(Controller.IsA('KWCutController'))
		{
			GotoState('StateIdle');
			
			return;
		}
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		Controller.GotoState('StateNoPawnMoveCanTurn');
	}

	event Tick(float dt)
	{
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		
		if(U.IsMoviePlaying())
		{
			return;
		}
		
		Controller.GotoState('PlayerWalking');
		GotoState('StateIdle');
	}
}

state NoMovement
{
	ignores BreathTimer, TakeDamage, PlayLandingAnimation, PlayJump, PlayWaiting, PlayFalling;

	event Tick(float dt)
	{
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
	}

	function bool IsBadStateForSaving()
	{
		return true;
	}
	
	Begin:
	
	Controller.GotoState('None');
}

state TempPauseHero
{
	ignores BreathTimer, TakeDamage, PlayLandingAnimation, PlayJump, PlayWaiting, PlayFalling;

	event Tick(float dt)
	{
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
	}

	function bool IsBadStateForSaving()
	{
		return true;
	}

	event Timer()
	{
		Controller.GotoState('PlayerWalking');
		GotoState('StateIdle');
		LastState = 'None';
		lastcontrollerstate = 'None';
	}
	
	Begin:
	
	LastState = GetStateName();
	lastcontrollerstate = Controller.GetStateName();
	Controller.GotoState('None');
	SetTimer(0.5, false);
}

state stateThrowPotion
{
	event Tick(float DeltaTime)
	{
		global.Tick(DeltaTime);
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
	}

	event BeginState()
	{
		local int PotionIndex;
		
		PotionIndex = ShHeroController(Controller).PotionSelected;
		
		if(!HasAnim(ThrowPotionAnimName))
		{
			SimpleThrowPotion(PotionIndex);
		}
		else
		{
			AnimBlendToAlpha(ATTACKCHANNEL_UPPER, 1.0, 0.0);
			PlayAnim(ThrowPotionAnimName, 1.0, 0.0, ATTACKCHANNEL_UPPER);
			AttachPotion(PotionIndex, ThrowOffset, ThrowRotation);
		}
	}

	event EndState()
	{
		AnimBlendToAlpha(ATTACKCHANNEL_UPPER, 0.0, 0.0);
	}

	function bool DoJump(bool bUpdating)
	{
		return false;
	}

	function DoDoubleJump(bool bUpdating)
	{
		return;
	}

	function bool StateIsInterruptible()
	{
		return false;
	}

	function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
	{
		if(Damage < 1000)
		{
			return;
		}
		
		super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
	}
	
	Begin:
	
	FinishAnim(ATTACKCHANNEL_UPPER);
	GotoState('StateIdle');
}

state stateDrinkPotion
{
	event Tick(float DeltaTime)
	{
		global.Tick(DeltaTime);
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
	}

	event BeginState()
	{
		local int PotionIndex;
		
		PotionIndex = ShHeroController(Controller).PotionSelected;
		
		if(!HasAnim(DrinkPotionAnimName))
		{
			SimpleThrowPotion(PotionIndex);
		}
		else
		{
			AnimBlendToAlpha(ATTACKCHANNEL_UPPER, 1.0, 0.0);
			PlayAnim(DrinkPotionAnimName, 1.0, 0.0, ATTACKCHANNEL_UPPER);
			AttachPotion(PotionIndex, DrinkOffset, DrinkRotation);
		}
	}
	
	event EndState()
	{
		AnimBlendToAlpha(ATTACKCHANNEL_UPPER, 0.0, 0.0);
	}
	
	function bool DoJump(bool bUpdating)
	{
		return false;
	}
	
	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	function bool StateIsInterruptible()
	{
		return false;
	}
	
	function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
	{
		if(Damage < 1000)
		{
			return;
		}
		
		super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
	}
	
	Begin:
	
	FinishAnim(ATTACKCHANNEL_UPPER);
	GotoState('StateIdle');
}

state stateThrowSwitch
{
	event BeginState()
	{
		local vector dirLeft, dirBack, NewLoc;
		local rotator R;
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		YawToSwitchActor = float(SwitchActor.Rotation.Yaw);
		DesiredRotation.Yaw = int(YawToSwitchActor);
		DesiredRotation.Pitch = 0;
		DesiredRotation.Roll = 0;
		
		if(Switch(SwitchActor).PlayerName == 'Shrek')
		{
			R.Pitch = 0;
			R.Roll = 0;
			R.Yaw = SwitchActor.Rotation.Yaw - 16384;
			dirLeft = vector(R) * CollisionRadius;
			R.Pitch = 0;
			R.Roll = 0;
			R.Yaw = SwitchActor.Rotation.Yaw + 32768;
			dirBack = vector(R) * (SwitchActor.CollisionRadius + CollisionRadius);
			NewLoc = (SwitchActor.Location + dirLeft) + dirBack;
			NewLoc.Z = Location.Z;
			SetLocation(NewLoc);
		}
		
		if((((Switch(SwitchActor).PlayerName == 'Steed') || Switch(SwitchActor).PlayerName == 'PIB') || Switch(SwitchActor).PlayerName == 'Donkey') || Switch(SwitchActor).PlayerName == 'ShrekHuman')
		{
			R.Pitch = 0;
			R.Roll = 0;
			R.Yaw = SwitchActor.Rotation.Yaw + 32768;
			dirBack = vector(R) * (SwitchActor.CollisionRadius + CollisionRadius);
			NewLoc = SwitchActor.Location + dirBack;
			NewLoc.Z = Location.Z;
			SetLocation(NewLoc);
		}
	}
	
	function AnimEnd(int Channel)
	{
		return;
	}
	
	event Tick(float dt)
	{
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		DesiredRotation.Yaw = int(YawToSwitchActor);
		DesiredRotation.Pitch = 0;
		DesiredRotation.Roll = 0;
		Controller.DesiredRotation = DesiredRotation;
	}
	
	function bool DoJump(bool bUpdating)
	{
		return false;
	}
	
	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
	{
		return;
	}
	
	Begin:
	
	SwitchActor.GotoState('stateThrowSwitch');
	PlayAnim(Switch(SwitchActor).PlayerThrowSwitchAnimName, 1);
	PlayArraySound(EmoteSoundPull, 0.6);
	FinishAnim();
	Sleep(0.1);
	PlayAnim(GetIdleAnimName(), 1);
	SwitchActor = none;
	GotoState('StateIdle');
}

state stateStartAirAttack
{
	event BeginState()
	{
		local CamSettings cs;
		local BaseCam Camera;
		
		Velocity.Z += AirAttackBoost;
		PlayAnim(StartAirAttackAnim, fDoubleJumpAnimRate, fDoubleJumpTweenTime, 1.0);
		LandAnims[0] = EndAirAttackAnim;
		LandAnims[1] = EndAirAttackAnim;
		Camera = KWHeroController(Controller).Camera;
		cs = Camera.CurrentSet;
		Camera.SetPitch(cs.fMinPitch);
	}
	
	event Bump(Actor Other)
	{
		global.Bump(Other);
		
		CheckForButton(Other);
	}

	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	function JumpOffPawn()
	{
		Velocity += (100.0 + CollisionRadius) * VRand();
		Velocity.Z = 200.0 + CollisionHeight;
		SetPhysics(PHYS_Falling);
		bNoJumpAdjust = true;
		Controller.SetFall();
		
		GotoState('StateIdle');
	}
	
	function bool IsBadStateForSaving()
	{
		return true;
	}
	
	function bool CanGrabLadder()
	{
		return false;
	}
}

state stateContinueAirAttack
{
	event BeginState()
	{
		LandAnims[0] = ContinueAirAttackAnim;
		LandAnims[1] = ContinueAirAttackAnim;
	}
	
	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	event Bump(Actor Other)
	{
		global.Bump(Other);
		
		CheckForButton(Other);
	}
	
	function JumpOffPawn()
	{
		Velocity += (100.0 + CollisionRadius) * VRand();
		Velocity.Z = 200.0 + CollisionHeight;
		SetPhysics(PHYS_Falling);
		bNoJumpAdjust = true;
		Controller.SetFall();
		
		GotoState('StateIdle');
	}
	
	function bool IsBadStateForSaving()
	{
		return true;
	}
	
	function bool CanGrabLadder()
	{
		return false;
	}
}

state stateRunAttack
{
	event BeginState()
	{
		local array<name> MAs;
		local int i;
		
		for(i = 0; i < 4; i++)
		{
			MAs[i] = NewRunAttackAnim;
		}
		
		StartRegularAttack();
		PlayArraySound(RunAttackSounds, 1.0);
		U.HackMovementAnims(self, MAs);
		LoopAnim(MAs[0], 1.0, 0.0, 4);
		LoopAnim(MAs[1], 1.0, 0.0, 5);
		LoopAnim(MAs[2], 1.0, 0.0, 6);
		LoopAnim(MAs[3], 1.0, 0.0, 7);
		
		if(RunAttackEmitter == none)
		{
			if(U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
			{
				return;
			}
			
			RunAttackEmitter = Spawn(RunAttackEmitterName);
			RunAttackEmitter.SetLocation(GetRunAttackEmitterLocation());
		}
	}
	
	function SetWalking(bool bNewIsWalking)
	{
		return;
	}
	
	event EndState()
	{
		local array<name> MAs;
		local int i;
		
		for(i = 0; i < 4; i++)
		{
			if(bInWater || bInQuicksand)
			{
				MAs[i] = WadeAnims[i];
			}
			else
			{
				_MovementAnims[i] = default._MovementAnims[i];
				MAs[i] = _MovementAnims[i];
			}
		}
		
		U.HackMovementAnims(self, MAs);
		LoopAnim(_MovementAnims[0], 1.0, 0.0, 4);
		LoopAnim(_MovementAnims[1], 1.0, 0.0, 5);
		LoopAnim(_MovementAnims[2], 1.0, 0.0, 6);
		LoopAnim(_MovementAnims[3], 1.0, 0.0, 7);
		
		if(RunAttackEmitter != none)
		{
			RunAttackEmitter.Kill();
			RunAttackEmitter = none;
		}
	}

	event Tick(float DeltaTime)
	{
		local float AnimFrame;
		
		global.Tick(DeltaTime);
		
		AnimFrame = GetAnimFrame(4);
		HitSomebody(1, Attack1Sounds, NewRunAttackAnim, AnimFrame);
		
		if(!MovingForward())
		{
			bPressDuringRunAttack = false;
			
			GotoState('stateStartAttack');
		}
		
		if(RunAttackEmitter != none)
		{
			RunAttackEmitter.SetLocation(GetRunAttackEmitterLocation());
		}
	}

	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == 4)
		{
			animseq = GetAnimSequence(4);
			
			if(animseq != NewRunAttackAnim)
			{
				GotoState('StateIdle');
			}
			else
			{
				if(bPressDuringRunAttack && MovingForward())
				{
					StartRegularAttack();
					PlayArraySound(RunAttackSounds, 1.0);
				}
				else
				{
					GotoState('StateIdle');
				}
			}
			
			bPressDuringRunAttack = false;
		}
	}

	function bool DoJump(bool bUpdating)
	{
		return false;
	}

	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
}

state stateStartAttack
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		
		global.Tick(DeltaTime);
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq != StartAttackAnim)
		{
			GotoState('StateIdle');
		}
	}

	event BeginState()
	{
		PutSwordBackIn();
		StartAttackAnimation(StartAttackAnim);
	}

	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == ATTACKCHANNEL_UPPER)
		{
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == StartAttackAnim)
			{
				GotoState('stateAttack1');
			}
		}
	}
}

state stateAttack1
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		local float AnimFrame, AnimRate;
		local vector V, deltav;
		local rotator R;
		
		global.Tick(DeltaTime);
		
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq != StartAttackAnim1)
		{
			GotoState('StateIdle');
		}
		
		AnimRate = GetAnimRate(ATTACKCHANNEL_UPPER);
		R = Rotation;
		R.Pitch = 0;
		R.Roll = 0;
		deltav = vector(R) * AttackMoveAhead;
		V = (deltav * DeltaTime) * AnimRate;
		MoveAheadABit(V);
		AnimFrame = GetAnimFrame(ATTACKCHANNEL_UPPER);
		HitSomebody(1, Attack1Sounds, animseq, AnimFrame);
	}

	event BeginState()
	{
		StartRegularAttack();
		StartAttackAnimation(StartAttackAnim1);
		PlayArraySound(EmoteSoundPunch, 0.2);
		PlayArraySound(SwingSounds, 1.0);
	}

	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == ATTACKCHANNEL_UPPER)
		{
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == StartAttackAnim1)
			{
				GotoState('stateAttack1End');
			}
		}
	}
}

state stateAttack1End
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		
		global.Tick(DeltaTime);
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq != EndAttackAnim1)
		{
			GotoState('StateIdle');
		}
	}

	event BeginState()
	{
		StartAttackAnimation(EndAttackAnim1);
		PlayAnim(GetIdleAnimName());
	}

	event EndState()
	{
		EndAttackAnimation(0.0);
	}
	
	Begin:
	
	FinishAnim(ATTACKCHANNEL_UPPER);
	GotoState('StateIdle');
}

state stateAttack2
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		local float AnimFrame, AnimRate;
		local vector V, deltav;
		local rotator R;
		
		global.Tick(DeltaTime);
		
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		GetAnimParams(ATTACKCHANNEL_UPPER, animseq, AnimFrame, AnimRate);
		
		if((animseq != StartAttackAnim1) && animseq != StartAttackAnim2)
		{
			GotoState('StateIdle');
		}
		
		if(animseq == StartAttackAnim1)
		{
			HitSomebody(1, Attack1Sounds, animseq, AnimFrame);
		}
		else if(animseq == StartAttackAnim2)
		{
			HitSomebody(2, Attack2Sounds, animseq, AnimFrame);
		}
		
		R = Rotation;
		R.Pitch = 0;
		R.Roll = 0;
		deltav = vector(R) * AttackMoveAhead;
		V = (deltav * DeltaTime) * AnimRate;
		MoveAheadABit(V);
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == ATTACKCHANNEL_UPPER)
		{
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == StartAttackAnim1)
			{
				StartAttackAnimation(StartAttackAnim2);
				StartRegularAttack();
				PlayArraySound(EmoteSoundPunch, 0.2);
				PlayArraySound(SwingSounds, 1.0);
			}
			else if(animseq == StartAttackAnim2)
			{
				GotoState('stateAttack2End');
			}
		}
	}
}

state stateAttack2End
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		
		global.Tick(DeltaTime);
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq != EndAttackAnim2)
		{
			GotoState('StateIdle');
		}
	}
	
	event BeginState()
	{
		StartAttackAnimation(EndAttackAnim2);
		PlayAnim(GetIdleAnimName());
	}
	
	event EndState()
	{
		EndAttackAnimation(0.0);
	}
	
	Begin:
	
	FinishAnim(ATTACKCHANNEL_UPPER);
	GotoState('StateIdle');
}

state stateAttack3
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		local float AnimFrame, AnimRate;
		local vector V, deltav;
		local rotator R;
		
		global.Tick(DeltaTime);
		
		GetAnimParams(ATTACKCHANNEL_UPPER, animseq, AnimFrame, AnimRate);
		
		if(animseq != StartAttackAnim2 && animseq != StartAttackAnim3 && animseq != EndAttackAnim3)
		{
			GotoState('StateIdle');
		}
		
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		
		if(animseq == StartAttackAnim2 || animseq == StartAttackAnim3)
		{
			R = Rotation;
			R.Pitch = 0;
			R.Roll = 0;
			deltav = vector(R) * AttackMoveAhead;
			V = (deltav * DeltaTime) * AnimRate;
			MoveAheadABit(V);
		}
		
		if(animseq == StartAttackAnim2)
		{
			HitSomebody(2, Attack2Sounds, animseq, AnimFrame);
		}
		
		if(animseq != StartAttackAnim3)
		{
			return;
		}
		
		HitSomebody(3, Attack3Sounds, animseq, AnimFrame);
	}

	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == ATTACKCHANNEL_UPPER)
		{
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == StartAttackAnim2)
			{
				StartAttackAnimation(StartAttackAnim3);
				StartRegularAttack();
				PlayArraySound(EmoteSoundPunch, 0.2);
				PlayArraySound(SwingSounds, 1.0);
			}
			else if(animseq == StartAttackAnim3)
			{
				StartAttackAnimation(EndAttackAnim3);
				PlayAnim(GetIdleAnimName());
			}
			else if(animseq == EndAttackAnim3)
			{
				EndAttackAnimation(0.0);
				GotoState('StateIdle');
			}
		}
	}
}

state stateAttack3Attack1
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		local float AnimFrame, AnimRate;
		local vector V, deltav;
		local rotator R;
		
		global.Tick(DeltaTime);
		
		GetAnimParams(ATTACKCHANNEL_UPPER, animseq, AnimFrame, AnimRate);
		
		if(animseq != StartAttackAnim2 && animseq != StartAttackAnim3 && animseq != PreStartAttackAnim1)
		{
			GotoState('StateIdle');
		}
		
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		
		if(animseq == StartAttackAnim2 || animseq == StartAttackAnim3)
		{
			R = Rotation;
			R.Pitch = 0;
			R.Roll = 0;
			deltav = vector(R) * AttackMoveAhead;
			V = (deltav * DeltaTime) * AnimRate;
			MoveAheadABit(V);
		}
		
		if(animseq == StartAttackAnim2)
		{
			HitSomebody(2, Attack2Sounds, animseq, AnimFrame);
		}
		else if(animseq == StartAttackAnim3)
		{
			HitSomebody(3, Attack3Sounds, animseq, AnimFrame);
		}
	}
	
	event BeginState()
	{
		StartRegularAttack();
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == ATTACKCHANNEL_UPPER)
		{
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == StartAttackAnim3)
			{
				if(PreStartAttackAnim1 != 'None')
				{
					StartAttackAnimation(PreStartAttackAnim1);
				}
				else
				{
					GotoState('stateAttack1');
				}
			}
			else if(animseq == PreStartAttackAnim1)
			{
				GotoState('stateAttack1');
			}
		}
	}
}

state stateSpecialAttack
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		
		global.Tick(DeltaTime);
		
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq != StartSpecialAttackAnim)
		{
			GotoState('StateIdle');
		}
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
		HitEverybody(false);
	}
	
	event BeginState()
	{
		StartRegularAttack();
		StartAttackAnimation(StartSpecialAttackAnim);
	}
	
	event EndState()
	{
		EndAttackAnimation(0.0);
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == ATTACKCHANNEL_UPPER)
		{
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == StartSpecialAttackAnim)
			{
				GotoState('StateIdle');
			}
		}
	}
}

state stateBossPibAttack
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		
		global.Tick(DeltaTime);
		
		animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
		
		if(animseq != BossPibAttackAnim)
		{
			GotoState('StateIdle');
		}
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		AnimBlendToAlpha(ATTACKCHANNEL_LOWER, 1.0, 0.0);
	}
	
	event BeginState()
	{
		StartAttackAnimation(BossPibAttackAnim);
	}
	
	event EndState()
	{
		EndAttackAnimation(0.0);
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == ATTACKCHANNEL_UPPER)
		{
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == BossPibAttackAnim)
			{
				GotoState('StateIdle');
			}
		}
	}
}

state stateKnockBack
{
	event Tick(float DeltaTime)
	{
		local float AnimRate;
		local name animseq;
		local vector V;
		local rotator R;
		
		global.Tick(DeltaTime);
		
		Velocity *= U.Vec(0.0, 0.0, 1.0);
		Acceleration *= U.Vec(0.0, 0.0, 1.0);
		animseq = GetAnimSequence(22);
		
		if(animseq != KnockBackStartAnimName && animseq != CarryKnockBackStartAnimName)
		{
			return;
		}
		
		AnimRate = GetAnimRate(22);
		R = Rotation;
		R.Pitch = 0;
		R.Roll = 0;
		R.Yaw += 32768;
		V = KnockBackDistance * vector(R) * DeltaTime * AnimRate;
		Move(V);
	}
	
	event BeginState()
	{
		local name animseq;
		
		EndAttackAnimation(0);
		animseq = GetAnimSequence(22);
		
		if(animseq != KnockBackStartAnimName && animseq != CarryKnockBackStartAnimName && animseq != KnockBackEndAnimName && animseq != CarryKnockBackEndAnimName)
		{
			SetAnimFrame(0.0, 22);
			AnimBlendParams(22, 0.0, 0.0, 0.0, TAKEHITBONE);
		}
		
		if(aHolding == none)
		{
			PlayAnim(KnockBackStartAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		else
		{
			PlayAnim(CarryKnockBackStartAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		
		AnimBlendToAlpha(22, 1.0, RandRange(0.2, 0.3));
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel != 22)
		{
			return;
		}
		
		AnimBlendToAlpha(22, 0.0, RandRange(0.2, 0.3));
		animseq = GetAnimSequence(22);
		
		if(animseq == KnockBackStartAnimName)
		{
			PlayAnim(KnockBackEndAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		else if(animseq == CarryKnockBackStartAnimName)
		{
			PlayAnim(CarryKnockBackEndAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		else if((animseq == KnockBackEndAnimName) || animseq == CarryKnockBackEndAnimName)
		{
			LoopAnim(GetIdleAnimName(), 1.0);
		}
		
		GotoState(StateBeforeKnockBack);
	}
	
	function bool StateIsInterruptible()
	{
		return false;
	}
	
	function bool DoJump(bool bUpdating)
	{
		return false;
	}
	
	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	function bool IsBadStateForSaving()
	{
		return true;
	}
}

state stateKnockForward
{
	event Tick(float DeltaTime)
	{
		local float AnimRate;
		local name animseq;
		local vector V;
		local rotator R;
		
		global.Tick(DeltaTime);
		Velocity *= U.Vec(0.0, 0.0, 1.0);
		Acceleration *= U.Vec(0.0, 0.0, 1.0);
		animseq = GetAnimSequence(22);
		
		if((animseq != KnockForwardStartAnimName) && animseq != CarryKnockForwardStartAnimName)
		{
			return;
		}
		
		AnimRate = GetAnimRate(22);
		R = Rotation;
		R.Pitch = 0;
		R.Roll = 0;
		V = KnockBackDistance * vector(R) * DeltaTime * AnimRate;
		Move(V);
	}

	event BeginState()
	{
		local name animseq;
		
		EndAttackAnimation(0);
		animseq = GetAnimSequence(22);
		
		if(animseq != KnockForwardStartAnimName && animseq != CarryKnockForwardStartAnimName && animseq != KnockForwardEndAnimName && animseq != CarryKnockForwardEndAnimName)
		{
			SetAnimFrame(0.0, 22);
			AnimBlendParams(22, 0.0, 0.0, 0.0, TAKEHITBONE);
		}
		
		if(aHolding == none)
		{
			PlayAnim(KnockForwardStartAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		else
		{
			PlayAnim(CarryKnockForwardStartAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		
		AnimBlendToAlpha(22, 1.0, RandRange(0.2, 0.3));
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel != 22)
		{
			return;
		}
		
		AnimBlendToAlpha(22, 0.0, RandRange(0.2, 0.3));
		animseq = GetAnimSequence(22);
		
		if(animseq == KnockForwardStartAnimName)
		{
			PlayAnim(KnockForwardEndAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		else if(animseq == CarryKnockForwardStartAnimName)
		{
			PlayAnim(CarryKnockForwardEndAnimName, RandRange(0.6, 0.7), 0.0, 22);
		}
		else if(animseq == KnockForwardEndAnimName || animseq == CarryKnockForwardEndAnimName)
		{
			LoopAnim(GetIdleAnimName(), 1.0);
		}
		
		GotoState(StateBeforeKnockBack);
	}
	
	function bool StateIsInterruptible()
	{
		return false;
	}
	
	function bool DoJump(bool bUpdating)
	{
		return false;
	}
	
	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	function bool IsBadStateForSaving()
	{
		return true;
	}
}

state stateUpEndFront
{
	event Tick(float DeltaTime)
	{
		global.Tick(DeltaTime);
		
		Velocity *= U.Vec(0.0, 0.0, 1.0);
		Acceleration *= U.Vec(0.0, 0.0, 1.0);
	}
	
	event BeginState()
	{
		EndAttackAnimation(0.0);
	}
	
	function bool CanDoPickupActor()
	{
		return false;
	}
	
	function AnimEnd(int Channel)
	{
		return;
	}
	
	function bool StateIsInterruptible()
	{
		return false;
	}
	
	function bool DoJump(bool bUpdating)
	{
		return false;
	}
	
	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	Begin:
	
	PlayAnim(UpEndFrontAnim, RandRange(0.9, 1.1), RandRange(0.1, 0.2));
	FinishAnim();
	PlayAnim(GetUpFrontAnim, RandRange(0.9, 1.1));
	FinishAnim();
	GotoState('StateIdle');
}

state stateUpEndBack
{
	event Tick(float DeltaTime)
	{
		global.Tick(DeltaTime);
		
		Velocity *= U.Vec(0.0, 0.0, 1.0);
		Acceleration *= U.Vec(0.0, 0.0, 1.0);
	}
	
	event BeginState()
	{
		EndAttackAnimation(0.0);
	}
	
	function AnimEnd(int Channel)
	{
		return;
	}
	
	function bool CanDoPickupActor()
	{
		return false;
	}
	
	function bool StateIsInterruptible()
	{
		return false;
	}
	
	function bool DoJump(bool bUpdating)
	{
		return false;
	}
	
	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	Begin:
	
	PlayAnim(UpEndBackAnim, RandRange(0.9, 1.1), RandRange(0.1, 0.2));
	FinishAnim();
	PlayAnim(GetUpBackAnim, RandRange(0.9, 1.1));
	FinishAnim();
	GotoState('StateIdle');
}

state stateSwingingDeath
{
	ignores BreathTimer;
	
	Begin:
	
	Velocity = U.Vec(0.0, 0.0, 0.0);
	Acceleration = U.Vec(0.0, 0.0, 0.0);
	SetPhysics(PHYS_None);
	PlayerDyingAnim = 'faint';
	SetCollision(false, false, false);
	bHidden = true;
	Spawn(fxSwingingDeathClass);
	Sleep(0.5);
	GotoState('stateHeroDying');
}

state stateHeroDying
{
	ignores BreathTimer, TakeDamage, PlayLandingAnimation, PlayJump, PlayWaiting, PlayFalling;
	
	function AnimEnd(int Channel)
	{
		return;
	}

	function name GetIdleAnimName()
	{
		return PlayerDyingAnim;
	}

	function bool DoJump(bool bUpdating)
	{
		return false;
	}

	function DoDoubleJump(bool bUpdating)
	{
		return;
	}
	
	Begin:
	
	Controller.Focus = none;
	Controller.FocalPoint = Location + (vector(Rotation) * 10000.0);
	Acceleration *= U.Vec(0.0, 0.0, 0.0);
	Velocity *= U.Vec(0.0, 0.0, 1.0);
	TweenOutAnimChannels(0.2);
	PlaySpecialSound(DyingSound);
	PlayArraySound(EmoteSoundFaint, 0.9);
	InterestMgr.CommentMgr.SayComment(DyingBumpLines, Tag,, true,,, self, "BumpDialog");
	PlayAnim(PlayerDyingAnim, 1.0, 0.2);
	FinishAnim();
	Sleep(1.0);
	
	HP = U.GetHP();
	
	if(Level.NetMode == NM_Standalone && Controller.IsA('PlayerController') && HP == self)
	{
		if(U.SaveGameExists(U.GetCurrentSaveSlot()))
		{
			UnPause();
			StartSavedRunningGame(U.GetCurrentSaveSlot());
			UnPause();
		}
		else
		{
			U.RestartLevel();
		}
	}
}


defaultproperties
{
	bCanMount=true
	bLandSlowdown=true
	iAirJumpCount=1
	iDoubleJumpCount=1
	FootPrintDecal=class'SHGame.FootPrintProjector'
	maxTimePoisoned=5.0
	poisonDamageAmount=1.0
	bSayCombatDialog=true
	fxSwingingDeathClass=class'SHGame.Cherry_Trail'
	MaxCombatants=2
	JumpWaterAnim=minijump
	IdleFightAnimName=fightidle
	KnockBackStartAnimName=knockbackstart
	KnockBackEndAnimName=knockbackend
	CarryKnockBackStartAnimName=carryknockbackstart
	CarryKnockBackEndAnimName=carryknockbackend
	KnockForwardStartAnimName=knockforwardstart
	KnockForwardEndAnimName=knockforwardend
	CarryKnockForwardStartAnimName=carryknockforwardstart
	CarryKnockForwardEndAnimName=carryknockforwardend
	RunAttackAnim=punch1
	NewRunAttackAnim=punch1
	StartSpecialAttackAnim=SpecialAttack
	StartAttackAnim=punch1start
	StartAttackAnim1=punch1
	EndAttackAnim1=punch1end
	StartAttackAnim2=punch2
	EndAttackAnim2=punch2end
	StartAttackAnim3=punch3
	EndAttackAnim3=punch3toidle
	PreStartAttackAnim1=punch3topunch1
	bCanUseJumpAttack=True
	StartAirAttackAnim=jumpattack
	LoopAirAttackAnim=jumpattackloop
	EndAirAttackAnim=jumpattacktoidle
	ContinueAirAttackAnim=jumpattacktopunch
	AirAttackBoost=150.0
	AirAttackFall=700.0
	StartSupportAttackAnim=hopstart
	LoopSupportAttackAnim=hoploop
	EndSupportAttackAnim=hopend
	UpEndFrontAnim=upendfront
	UpEndBackAnim=upendback
	GetUpFrontAnim=getupfront
	GetUpBackAnim=getupback
	ThrowPotionAnimName=ThrowPotion
	DrinkPotionAnimName=DrinkPotion
	ThrowPotionBoneName=body_r_wrist_joint
	DrinkPotionBoneName=body_r_wrist_joint
	PlayerDyingAnim=faint
	DeathIfFallDistance=768
	SaveCameraNoSnapRotation=true
	InvisibleEmitterName=class'SHGame.Potion_Invisible'
	InvisibilityPercent=0.5
	StrengthEmitterName=class'SHGame.Potion_Strngth'
	StrengthPotionScale=2
	ShrinkEmitterName=class'SHGame.Potion_Shrink'
	ShrinkSpeed=0.5
	ShrinkLimit=0.25
	PotionDrawScale=1.0
	EndAirAttackEmitterName=class'SHGame.Body_Slam'
	InWaterBeforeSayingBumpLine=30.0
	InWaterSound=Sound'items.water_jump_in'
	OutWaterSound=Sound'items.water_climb_out'
	bCouldBeAttacked=true
	bIsAFriend=true
	fThrowVelocity=800.0
	CameraSetStandard=(vLookAtOffset=(X=-25.0,Z=65.0),fLookAtDistance=170.0,fLookAtHeight=30.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CarryTurnRightAnim=carryidle
	CarryTurnLeftAnim=carryidle
	CarryIdleAnimName=carryidle
	CarryForwardAnimName=carry
	CarryBackwardAnimName=carrybackward
	CarryKnockBackAnimName=CarryKnockBack
	CarryStrafeLeftAnimName=carrystrafeleft
	CarryStrafeRightAnimName=carrystraferight
	LeftUpperLidBone=body_l_upperlid_joint
	LeftLowerLidBone=body_l_lowerlid_joint
	RightUpperLidBone=body_r_upperlid_joint
	RightLowerLidBone=body_r_lowerlid_joint
	LeftBrowBone=body_l_brow1_joint
	RightBrowBone=body_r_brow1_joint
	LeftBlinkAnim=l_blink
	RightBlinkAnim=r_blink
	bCanBlink=true
	IdleAnims(0)=bored1
	IdleAnims(1)=bored1
	IdleAnims(2)=bored1
	IdleAnims(3)=bored1
	IdleAnims(4)=bored2
	IdleAnims(5)=bored2
	IdleAnims(6)=bored2
	IdleAnims(7)=bored2
	IdleDialogAnims(0)=(AnimName=FidgetScratchHead,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 1")
	IdleDialogAnims(1)=(AnimName=FidgetShakeHead,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 2")
	IdleDialogAnims(2)=(AnimName=FidgetShrug,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 3")
	IdleDialogAnims(3)=(AnimName=FidgetStrafe,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 3")
	IdleDialogAnims(4)=(AnimName=FidgetStrafe,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 3")
	IdleDialogAnims(5)=(AnimName=FidgetStretch,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 3")
	IdleDialogAnims(6)=(AnimName=FidgetTalk,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 3")
	IdleDialogAnims(7)=(AnimName=FidgetWandSwish,AnimRate=0.0,AnimTime=0.0,Text="Dialog comment 3")
	bCanDoubleJump=true
	bCanPickupInventory=true
	TurnLeftAnim=turn_left
	TurnRightAnim=turn_right
	bActorShadows=true
	bAcceptsProjectors=false
	bAlignBottom=false
	HandBone=body_rhand
	AirAnims(0)=Jump
	AirAnims(1)=Jump
	AirAnims(2)=Jump
	AirAnims(3)=Jump
	TakeoffAnims(0)=runjump
	TakeoffAnims(1)=runjump
	TakeoffAnims(2)=runjump
	TakeoffAnims(3)=Jump
	LandAnims(0)=JumpLandToStand
	LandAnims(1)=jumplandtorun
	DoubleJumpAnims(0)=doublejump
	DoubleJumpAnims(1)=doublejump
	DoubleJumpAnims(2)=doublejump
	DoubleJumpAnims(3)=doublejump
	AirStillAnim=jumploop
	TakeoffStillAnim=Jump
	GroundRunSpeed=550.0
	GroundWalkSpeed=200.0
	GroundCarrySpeed=450.0
	fLandingTweenInTime=0.01
	fLandingTweenOutTime=0.3
	fLandingAnimRate=1.2
	fJumpTweenTime=0.07
	fJumpAnimRate=0.8
	fDoubleJumpAnimRate=0.8
	fDoubleJumpTweenTime=0.07
	RootBone=body_root_joint
	HeadBone=body_head_joint
	NeckBone=body_neck_joint
	LandedFX=class'Grnd_Impact'
	WetLandedFX=class'splash'
	GroundSpeed=550.0
	AirSpeed=1000.0
	AccelRate=1548
	JumpZ=520.0
	AirControl=0.25
	ControllerClass=class'Sh_NPCController'
	bPhysicsAnimUpdate=true
	BaseMovementRate=450.0
	_BaseMovementRate=450.0
	_MovementAnims(0)=run
	_MovementAnims(1)=runbackward
	_MovementAnims(2)=StrafeLeft
	_MovementAnims(3)=StrafeRight
	MovementBlendStartTime=0.2
	ForwardStrafeBias=0.5
	BackwardStrafeBias=0.5
	CollisionRadius=24.0
	CollisionHeight=42.0
	RotationRate=(Pitch=4096,Yaw=40000,Roll=3072)
	QuicksandGroundSpeed=150.0
	LOWER_BODY_BONE=body_root_joint
	UPPER_BODY_BONE=body_waist_joint
	RIGHT_ARM_BONE=body_r_clavicle_joint
	LEFT_ARM_BONE=body_l_clavicle_joint
	ATTACKCHANNEL_LOWER=12
	ATTACKCHANNEL_UPPER=14
	ARMCHANNEL_RIGHT=40
	ARMCHANNEL_LEFT=41
	WaterGroundSpeed=150.0
	SpecialAttackTime=20.0
	PickUpType=-1
	WadeAnims(0)=wade
	WadeAnims(1)=wadebackward
	WadeAnims(2)=wadeleft
	WadeAnims(3)=waderight
	SpeedOpacityForFadeOut=0.5
	CurrentOpacityForFadeOut=1
	bDropShadowOnActors=true
	bAllFallingMountsUseBigClimb=true
	BigClimbStart=jumptoclimb
	BigClimbEnd=climb
	BigClimbOffset=190.0
	BigShimmyOffset=190.0
	StepUpOffset=50.0
	bAbleToDoShimmy=true
	HangIdleAnim=hangidle
	JumpToHangAnim=jumptohang
	ShimmyRightAnim=shimmyright
	ShimmyLeftAnim=shimmyleft
	ShimmyRightEndAnim=shimmyrightend
	ShimmyLeftEndAnim=shimmyleftend
	HangToLandAnim=hangtoland
	StepUpAnim=climb
	StepUpNoTransAnim=climb2
	TAKEHITBONE=body_root_joint
	bCanClimbLadders=false
	SoundRadius=300.0
	fAccurateThrowingTime=1.0
	CameraSetCutScene=(vLookAtOffset=(X=0.0,Y=0.0,Z=0.0),fLookAtDistance=128.0,fLookAtHeight=0.0,fRotTightness=2.0,fRotSpeed=5.0,fMoveTightness=(X=0.0,Y=0.0,Z=0.0),fMoveSpeed=0.0,fMaxMouseDeltaX=20000.0,fMaxMouseDeltaY=10000.0,fMinPitch=-14000.0,fMaxPitch=14000)
	CameraSetFree=(vLookAtOffset=(X=0.0,Y=0.0,Z=0.0),fLookAtDistance=0.0,fLookAtHeight=0.0,fRotTightness=10.0,fRotSpeed=5.0,fMoveTightness=(X=0.0,Y=0.0,Z=0.0),fMoveSpeed=600.0,fMaxMouseDeltaX=20000.0,fMaxMouseDeltaY=10000.0,fMinPitch=-14000.0,fMaxPitch=14000)
	CameraSetBoss=(vLookAtOffset=(X=0.0,Y=0.0,Z=100.0),fLookAtDistance=170.0,fLookAtHeight=0.0,fRotTightness=0.0,fRotSpeed=0.0,fMoveTightness=(X=0.0,Y=0.0,Z=0.0),fMoveSpeed=0.0,fMaxMouseDeltaX=0.0,fMaxMouseDeltaY=0.0,fMinPitch=0.0,fMaxPitch=0)
	CameraSetFollow=(vLookAtOffset=(X=0.0,Y=0.0,Z=70.0),fLookAtDistance=150.0,fLookAtHeight=0.0,fRotTightness=0.0,fRotSpeed=15.0,fMoveTightness=(X=0.0,Y=0.0,Z=0.0),fMoveSpeed=0.0,fMaxMouseDeltaX=20000.0,fMaxMouseDeltaY=10000.0,fMinPitch=-14000.0,fMaxPitch=14000)
	fDesiredCamDistFromWall=15.0
	fCameraRollModifier=1.0
	bDoWorldCollisionCheck=true
	bPrefersBehind=true
	DefaultPlayerControllerClass=class'MController'
	bTakesDamage=true
	bTakesDamageCheat=true
	AdditionalPrePivotTweenSpeed=100.0
	ConstantRotationRate=(Pitch=0,Yaw=16000,Roll=0)
	ConstantRotationAccel=16000.0
	bRelevantToTriggersWhileInCutscene=true
	BlobShadowLightDistance=380.0
	CompanionWalkAnim=Walk
	BigClimbStartNoTrans=climb96startNoTrans
	BigClimbEndNoTrans=climb96endNoTrans
	Climb32NoTransAnimName=climb32NoTrans
	Climb64NoTransAnimName=climb64NoTrans
	BigClimbAnimRate_Temp=1.0
	Climb32Offset=32.0
	Climb64Offset=64.0
	IdleTiredAnimName=Idle
	IdleAnimName=Idle
	SlideAnimName=SlideIdle
	SlideLeftAnimName=SlideIdle
	SlideRightAnimName=SlideIdle
	SlideAccelRate=100.0
	GroundSlideSpeed=600.0
	GroundSlideSpeedFast=850.0
	GroundSlideSpeedSlow=400.0
	fSlideSkateForce=200.0
	SlideYawChangeRate=14000
	SlidingAmbientMinPitch=48
	SlidingAmbientMaxPitch=115
	SlidingAmbientVolume=100
	SlideLeaveTrackDieTimeout=2.0
	PickupAnimRate=1.0
	TweenGroundSpeedRate=300.0
	fIdleAnimRate=1.0
	fIdleAnimTweenTime=0.5
	fAirStillAnimRate=1.0
	fAirStillAnimTweenTime=0.1
	HeadRotElement=RE_RollPos
	bAcceptAllInventory=true
	FootstepVolume=1.0
	DefaultGroundMovementState=StateGroundMovement
	DefaultAirMovementState=StateAirMovement
	MountCylScaleMag=2.0
	bUseCollisionDuringMount=true
	OnTrig_SoundVolume=1.0
	LeadingActorDistance=300.0
	LastLocationArrayMaxLen=15
	fChanceToPlayIdle=0.2
	DegreeOffsetFromBehind=70.0
	DegreeOffsetFromBehindFight=60.0
	DistanceOffset=70.0
	DistanceOffsetFight=100.0
	IdleMonitorTimeOut=1.5
	AccelMonitorTimeOut=1.0
	IdleWanderRadius=96.0
	WanderPauseOdds=0.4
	WanderPauseDurationMin=1.0
	WanderPauseDurationMax=3.0
	WanderDistance=72.0
	WanderTowardsLeadCharDistance=40.0
	IdleRotationRateScale=0.5
	fIdleToleranceOffset=40.0
	fDoubleJumpHeight=96.0
	fJumpHeight=64.0
	fJumpDist=192.0
	ShimmySpeed=70.0
	RunningGameSlot=9998
	Physics=PHYS_Walking
	bStasis=false
	bUseCylinderCollision=true
	vStepDiff=(X=100.0,Y=0.0,Z=16.0)
	bJumpCapable=true
	bCanJump=true
	bCanWalk=true
	bCanWalkOffLedges=true
	bLOSHearing=true
	bUseCompressedPosition=true
	bWeaponBob=true
	Visibility=128
	DesiredSpeed=1.0
	MaxDesiredSpeed=1.0
	HearingThreshold=2800.0
	SightRadius=5000.0
	AvgPhysicsTime=0.1
	WaterSpeed=300.0
	LadderSpeed=200.0
	WalkingPct=0.5
	CrouchedPct=0.5
	MaxFallSpeed=1200.0
	fMinFloorZ=0.7
	BaseEyeHeight=64.0
	EyeHeight=54.0
	CrouchHeight=40.0
	CrouchRadius=34.0
	Health=100.0
	HeadScale=1.0
	noise1time=-10.0
	noise2time=-10.0
	Bob=0.008
	SoundDampening=1.0
	DamageScaling=1.0
	LandMovementState=PlayerWalking
	WaterMovementState=PlayerSwimming
	BlendChangeTime=0.25
	MouthBone="Body__Mouth"
	fLumosRadius=512.0
	StepHeight=16.0
	StepWidth=32.0
	DrawType=DT_Mesh
	bUpdateSimulatedPosition=true
	RemoteRole=ROLE_SimulatedProxy
	NetPriority=2.0
	Texture=Texture'S_Pawn'
	bTravel=true
	bCanBeDamaged=true
	bShouldBaseAtStartup=true
	bOwnerNoSee=true
	bCanTeleport=true
	bDisturbFluidSurface=true
	SoundVolume=255
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
	bBlockPlayers=true
	bProjTarget=true
	bRotateToDesired=true
	bNoRepMesh=true
	bDirectional=true
	bLightingVisibility=true
	bUseDynamicLights=true
	bReplicateMovement=true
	Role=ROLE_Authority
	NetUpdateFrequency=100.0
	LODBias=1.0
	LODBiasSW=1.0
	DrawScale=1.0
	DrawScale3D=(X=1.0,Y=1.0,Z=1.0)
	MaxLights=4
	ScaleGlow=1.0
	Style=STY_Normal
	bMovable=true
	SoundPitch=64
	TransientSoundVolume=0.3
	TransientSoundRadius=300.0
	TransientSoundPitch=1.0
	bBlockZeroExtentTraces=true
	bBlockNonZeroExtentTraces=true
	bJustTeleported=true
	RotationalAcceleration=(Pitch=200000,Yaw=200000,Roll=200000)
	fRotationalTightness=5.0
	Mass=100.0
	MessageClass=class'LocalMessage'
	bPauseWithSpecial=true
	SkinColorModifier=(B=127,G=127,R=127,A=255)
	fDefaultAnimRate=1.0
	SizeModifier=1.0
	CentreOffset=(X=0.0,Y=0.0,Z=10.0)
	GestureDistance=1.0
	DesiredOpacityForCamera=0.5
	SpeedOpacityForCamera=1.0
	CurrentOpacityForCamera=1.0
}