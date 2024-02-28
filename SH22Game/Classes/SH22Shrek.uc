// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Shrek extends SH22HeroPawn
	Config(SH22);


var() int TotalGameStateTokens, GameStateTokenLen;
var(GameState) const editconst string GameStateMasterList;
var(GameState) travel string CurrentGameState;
var() array<Sound> FartSounds;
var() Sound EarthQuakeSound, SoundBellyFlop1, SoundBellyFlop2;
var travel string FuturePlayerLabel;
var() name SavedTag, LeftWristBoneName, RightWristBoneName;
var() class<Emitter> SpecialAttackEmitterName, BellyFlopEmitterName;
var ShrekLeftGlove LeftGlove;
var ShrekRightGlove RightGlove;
var PotionBottleHEA BottleHEA;
var() vector PibAttachOffset, BottleAttachOffset;
var() rotator PibAttachRotation, BottleAttachRotation;
var() bool bShowBottle;
var bool bOldbShowBottle;
var Controller PibSaveController;
var travel int WhichBonusGame, TotalHealthIcons;


function PlayFartSound()
{
	local Sound snd;
	
	snd = GetRandSound(FartSounds);
	
	if(snd == none)
	{
		return;
	}
	
	PlayOwnedSound(snd, SLOT_None, 1.0, true, 800.0, RandRange(0.9, 1.1));
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	LeftGlove = Spawn(class'ShrekLeftGlove');
	LeftGlove.AttachWeaponToKWPawn(self);
	LeftGlove.bHidden = true;
	
	RightGlove = Spawn(class'ShrekRightGlove');
	RightGlove.AttachWeaponToKWPawn(self);
	RightGlove.bHidden = true;
	
	BottleHEA = Spawn(class'PotionBottleHEA',,, Location);
	BottleHEA.SetDrawScale(0.5);
	AttachToBone(BottleHEA, DrinkPotionBoneName);
	BottleHEA.SetRelativeLocation(BottleAttachOffset);
	BottleHEA.SetRelativeRotation(BottleAttachRotation);
	BottleHEA.SetOwner(self);
	BottleHEA.bHidden = !bShowBottle;
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(bShowBottle != bOldbShowBottle)
	{
		BottleHEA.bHidden = !bShowBottle;
	}
	
	bOldbShowBottle = bShowBottle;
}

function bool IsInBonusLevel()
{
	if(InStr(Caps(Level.GetPropertyText("ID")), "BEANSTALK") > -1)
	{
		return true;
	}
	
	return false;
}

event PostLoadGame(bool bLoadFromSaveGame)
{
	local ShHeroPawn shhp;
	
	HP = U.GetHP();
	
	super.PostLoadGame(bLoadFromSaveGame);
	
	foreach DynamicActors(class'ShHeroPawn', shhp)
	{
		if(shhp != none && shhp.Tag == 'MainPlayer')
		{
			shhp.Tag = SavedTag;
		}
	}
	
	if(!IsInBonusLevel())
	{
		FuturePlayerLabel = "";
		
		return;
	}
	
	if(FuturePlayerLabel == "")
	{
		return;
	}
	
	SwitchControlToPawn(FuturePlayerLabel);
	FuturePlayerLabel = "";
	SavedTag = HP.Tag;
	HP.Tag = 'MainPlayer';
}

function AddAnimNotifys()
{
	local MeshAnimation MeshAnim;

	super.AddAnimNotifys();
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddNotify(MeshAnim, LandAnims[0], 30.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, LandAnims[1], 8.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, EndAirAttackAnim, 20.0, 'AnimNotifyBlendOutEndAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 15.0, 'AnimNotifyBlendOutContinueAirAttack');
	AddNotify(MeshAnim, PickupAnimName, 8.0, 'AnimNotifyObjectPickup');
	AddNotify(MeshAnim, ThrowAnimName, 15.0, 'PlayerThrowCarryingActor');
	AddFootStepsNotify(MeshAnim);
	AddNotify(MeshAnim, 'run', 6.0, 'PlayFootSplashesFrontRight');
	AddNotify(MeshAnim, 'run', 35.0, 'PlayFootSplashesFrontRight');
	AddNotify(MeshAnim, 'run', 21.0, 'PlayFootSplashesFrontLeft');
	AddNotify(MeshAnim, 'run', 51.0, 'PlayFootSplashesFrontLeft');
	AddNotify(MeshAnim, 'bored3', 50.0, 'PlayFartSound');
	AddNotify(MeshAnim, StartSpecialAttackAnim, 53.0, 'SpecialAttackCameraShake');
	AddNotify(MeshAnim, BossPibAttackAnim, 22.0, 'BossPibAttackCameraShake');
	AddNotify(MeshAnim, StartAttackAnim3, 19.0, 'HitGround');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 2.0, 'PlaySoundBellyFlop2');
	AddNotify(MeshAnim, EndAirAttackAnim, 3.0, 'PlaySoundBellyFlop2');
	AddNotify(MeshAnim, StartAttackAnim3, 28.0, 'PlaySoundBellyFlop1');
	AddNotify(MeshAnim, NewRunAttackAnim, 1.0, 'CreateRibbonEmittersForRunAttack');
	AddNotify(MeshAnim, NewRunAttackAnim, 11.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, ThrowPotionAnimName, 18.0, 'ThrowPotion');
	AddNotify(MeshAnim, DrinkPotionAnimName, 41.0, 'DrinkPotion');
	AddNotify(MeshAnim, ThrowPotionAnimName, 4.0, 'PlayThrowPotionSound');
	AddNotify(MeshAnim, DrinkPotionAnimName, 10.0, 'PlayDrinkPotionSound');
}

function bool HitBossPib()
{
	local int DamageAmount;
	
	if(aBoss == none || !aBoss.IsA('BossPib') || aBoss.Controller == none || BossPibController(aBoss.Controller) == none || aBoss.IsInState('stateKnockBack') || aBoss.Physics == PHYS_Falling || !BossPibController(aBoss.Controller).IsInState('RunToNewLocation'))
	{
		return false;
	}
	
	DamageAmount = BossPib(aBoss).DamageFromPlayer;
	aBoss.TakeDamage(DamageAmount, self, U.Vec(0.0, 0.0, 0.0), U.Vec(0.0, 0.0, 0.0), class'SpecialAttackDamage');
	
	return true;
}

function PlaySoundBellyFlop1()
{
	PlayOwnedSound(SoundBellyFlop1, SLOT_None, 1.0, true, 1000.0, RandRange(0.9, 1.1));
}

function PlaySoundBellyFlop2()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal;

	HitActor = Trace(HitLocation, HitNormal, Location - U.Vec(0.0, 0.0, 500.0), Location, true, U.Vec(1.0, 1.0, 1.0));
	Spawn(BellyFlopEmitterName,,, HitLocation);
	PlayOwnedSound(SoundBellyFlop2, SLOT_None, 1.0, true, 1000.0, RandRange(0.9, 1.1));
}

function SpecialAttackCameraShake()
{
	local vector locLeft, locRight, locMiddle, HitLoc, HitNorm;

	KWHeroController(Controller).SimpleShakeView(0.2, 150.0, 0.5);
	PlayOwnedSound(EarthQuakeSound, SLOT_None, 1.0, true, 1000.0, RandRange(0.9, 1.1));
	HitEverybody(true);
	locLeft = GetBoneCoords(LeftWristBoneName).Origin;
	locRight = GetBoneCoords(RightWristBoneName).Origin;
	locMiddle = (locLeft + locRight) / 2.0;
	TraceMaterial(locMiddle, 1.5 * CollisionHeight, HitLoc, HitNorm);
	Spawn(SpecialAttackEmitterName,,, locMiddle);
}

function HitGround()
{
	local vector locRight, HitLoc, HitNorm;
	local KWGame.EMaterialType mtype;
	
	locRight = GetBoneCoords(RightWristBoneName).Origin;
	mtype = TraceMaterial(locRight, 1.5 * CollisionHeight, HitLoc, HitNorm);
	
	if(mtype != MTYPE_Wet)
	{
		PlayOwnedSound(EarthQuakeSound, SLOT_None, 1.0, true, 1000.0, RandRange(0.9, 1.1));
		Spawn(SpecialAttackEmitterName,,, HitLoc);
	}
	else
	{
		PlayOwnedSound(InWaterSound, SLOT_None, 1.0, true, 1000.0, RandRange(0.9, 1.1));
		Spawn(WetLandedFX,,, HitLoc);
	}
	
	KillAllEnemiesAround(150.0);
}

function BossPibAttackCameraShake()
{
	local vector locRight, HitLoc, HitNorm;
	
	PC = U.GetPC();
	
	if(IsInState('stateKnockBack') || IsInState('stateKnockForward'))
	{
		return;
	}
	
	PC.SimpleShakeView(0.2, 150.0, 0.5);
	PlayOwnedSound(EarthQuakeSound, SLOT_None, 1.0, true, 1000.0, RandRange(0.9, 1.1));
	HitBossPib();
	locRight = GetBoneCoords(RightWristBoneName).Origin;
	TraceMaterial(locRight, 1.5 * CollisionHeight, HitLoc, HitNorm);
	Spawn(SpecialAttackEmitterName,,, locRight);
}

function OnEvent(name EventName)
{
	super.OnEvent(EventName);
	
	switch(EventName)
	{
		case 'HamletBellows1':
			DeliverLocalizedDialog("PC_SHK_BUMPLINE_2783", true,,,, true,, true);
			
			break;
		case 'HamletBellows2':
			DeliverLocalizedDialog("PC_SHK_BUMPLINE_2784", true,,,, true,, true);
			
			break;
	}
}

function ShowStrengthAttributes()
{
	super.ShowStrengthAttributes();
	
	PC = U.GetPC();
	
	if(SHHeroController(PC).ShrekFirstStrengthPotion == 0)
	{
		SHHeroController(PC).ShrekFirstStrengthPotion = 1;
		SHHeroController(PC).SaveConfig();
		TriggerEvent('ShrekStrengthPotion', none, none);
	}
	
	LeftGlove.bHidden = false;
	RightGlove.bHidden = false;
}

function HideStrengthAttributes()
{
	super.HideStrengthAttributes();
	
	LeftGlove.bHidden = true;
	RightGlove.bHidden = true;
}

function vector GetRunAttackEmitterLocation()
{
	local vector rloc, lloc, Loc;

	rloc = GetBoneCoords('body_r_ball_joint').Origin;
	lloc = GetBoneCoords('body_l_ball_joint').Origin;
	Loc = (rloc + lloc) / 2.0;
	
	return Loc;
}

auto state StateIdle
{
	function OnEvent(name EventName)
	{
		super.OnEvent(EventName);
		
		if(EventName == 'AttachPib')
		{
			GotoState('stateAttachPib');
		}
	}
}

state stateAttachPib
{
	function name GetIdleAnimName()
	{
		return 'ShrekholdingPiB';
	}
	
	function OnEvent(name EventName)
	{
		super.OnEvent(EventName);
		
		if(EventName == 'DetachPib')
		{
			GotoState('StateIdle');
		}
	}
	
	event BeginState()
	{
		local PIB pb;
		
		foreach DynamicActors(class'PIB', pb)
		{
			if(pb != none)
			{
				break;
			}
		}
		
		if(pb == none)
		{
			GotoState('StateIdle');
			
			return;
		}
		
		PibSaveController = pb.Controller;
		pb.Controller = none;
		pb.SetCollision(false, false, false);
		pb.bCanBePickedUp = true;
		AttachToBone(pb, 'body_l_wrist_joint');
		pb.SetRelativeLocation(PibAttachOffset);
		pb.SetRelativeRotation(PibAttachRotation);
		pb.GotoState('stateHeldByTheScruffIdle');
		LoopAnim('ShrekholdingPiB');
	}

	event EndState()
	{
		local PIB pb;
		
		foreach DynamicActors(class'PIB', pb)
		{
			if(pb != none)
			{
				break;
			}
		}
		
		if(pb == none)
		{
			GotoState('StateIdle');
			
			return;
		}
		
		pb.bCanBePickedUp = false;
		pb.SetOwner(none);
		pb.Controller = PibSaveController;
		pb.SetCollision(true, true, true);
		pb.GotoState('StateIdle');
	}
}

state StateCarryItem
{
	event BeginState()
	{
		if(aHolding.IsA('PickupWheel'))
		{
			TriggerEvent('PickedWheel', none, none);
		}
	}
}


defaultproperties
{
	BottleAttachOffset=(X=-9,Y=5,Z=-6)
	BottleAttachRotation=(Roll=14999)
	FartSounds(0)=Sound'Shrek.fart01'
	FartSounds(1)=Sound'Shrek.fart02'
	FartSounds(2)=Sound'Shrek.fart03'
	EarthQuakeSound=Sound'Shrek.punch_GROUND_SHAKE'
	LeftWristBoneName="body_l_wrist_joint"
	RightWristBoneName="body_r_wrist_joint"
	SpecialAttackEmitterName=class'SHGame.Dust_Cloud'
	BellyFlopEmitterName=class'SHGame.Body_Slam'
	SoundBellyFlop1=Sound'Shrek.bellyflop_01'
	SoundBellyFlop2=Sound'Shrek.bellyflop_02'
	PibAttachOffset=(X=1.0,Y=1.0,Z=17.0)
	PibAttachRotation=(Pitch=26026,Yaw=22950,Roll=60766)
	WhichBonusGame=1
	TotalHealthIcons=1
	AttackMoveAhead=90.0
	JumpAttackMoveAhead=80.0
	SHHeroName=Shrek
	NewRunAttackAnim=runattack
	BossPibAttackAnim=Attack_bosspib
	LookAroundAnims(0)=lookaround1
	LookAroundAnims(1)=lookaround2
	LookAroundAnims(2)=lookaround3
	ThrowOffset=(X=-9.0,Y=5.0,Z=-6.0)
	ThrowRotation=(Roll=16384)
	DrinkOffset=(X=-9.0,Y=5.0,Z=-6.0)
	DrinkRotation=(Roll=16384)
	Attack1Sounds(0)=Sound'Shrek.punch01'
	Attack2Sounds(0)=Sound'Shrek.punch02'
	Attack3Sounds(0)=Sound'Shrek.punch03'
	SpecialAttackSounds(0)=Sound'Shrek.punch03'
	BossPibAttackSounds(0)=Sound'Shrek.punch03'
	DyingSound=Sound'Shrek.faint'
	ThrowPotionSound=Sound'Shrek.throw_potion'
	DrinkPotionSound=Sound'Shrek.drink_potion'
	EmoteSoundJump(0)=Sound'AllDialog.pc_shk_ShrekEmote_21'
	EmoteSoundJump(1)=Sound'AllDialog.pc_shk_ShrekEmote_23'
	EmoteSoundJump(2)=Sound'AllDialog.pc_shk_ShrekEmote_27'
	EmoteSoundJump(3)=Sound'AllDialog.pc_shk_ShrekEmote_31'
	EmoteSoundJump(4)=Sound'AllDialog.pc_shk_ShrekEmote_17'
	EmoteSoundJump(5)=Sound'AllDialog.pc_shk_ShrekEmote_33'
	EmoteSoundJump(6)=Sound'AllDialog.pc_shk_ShrekEmote_89'
	EmoteSoundJump(7)=Sound'AllDialog.pc_shk_ShrekEmote_117'
	EmoteSoundLand(0)=Sound'AllDialog.pc_shk_ShrekEmote_65'
	EmoteSoundLand(1)=Sound'AllDialog.pc_shk_ShrekEmote_42'
	EmoteSoundLand(2)=Sound'AllDialog.pc_shk_ShrekEmote_44'
	EmoteSoundLand(3)=Sound'AllDialog.pc_shk_ShrekEmote_99'
	EmoteSoundLand(4)=Sound'AllDialog.pc_shk_ShrekEmote_74'
	EmoteSoundClimb(0)=Sound'AllDialog.pc_shk_ShrekEmote_57'
	EmoteSoundClimb(1)=Sound'AllDialog.pc_shk_ShrekEmote_115'
	EmoteSoundClimb(2)=Sound'AllDialog.pc_shk_ShrekEmote_105'
	EmoteSoundClimb(3)=Sound'AllDialog.pc_shk_ShrekEmote_95'
	EmoteSoundClimb(4)=Sound'AllDialog.pc_shk_ShrekEmote_97'
	EmoteSoundClimb(5)=Sound'AllDialog.pc_shk_ShrekEmote_92'
	EmoteSoundClimb(6)=Sound'AllDialog.pc_shk_ShrekEmote_77'
	EmoteSoundClimb(7)=Sound'AllDialog.pc_shk_ShrekEmote_93'
	EmoteSoundPain(0)=Sound'AllDialog.pc_shk_ShrekEmote_5'
	EmoteSoundPain(1)=Sound'AllDialog.pc_shk_ShrekEmote_7'
	EmoteSoundPain(2)=Sound'AllDialog.pc_shk_ShrekEmote_9'
	EmoteSoundPain(3)=Sound'AllDialog.pc_shk_ShrekEmote_19'
	EmoteSoundPain(4)=Sound'AllDialog.pc_shk_ShrekEmote_13'
	EmoteSoundPain(5)=Sound'AllDialog.pc_shk_ShrekEmote_11'
	EmoteSoundPain(6)=Sound'AllDialog.pc_shk_ShrekEmote_63'
	EmoteSoundPain(7)=Sound'AllDialog.pc_shk_ShrekEmote_50'
	EmoteSoundPain(8)=Sound'AllDialog.pc_shk_ShrekEmote_46'
	EmoteSoundPain(9)=Sound'AllDialog.pc_shk_ShrekEmote_51'
	EmoteSoundPain(10)=Sound'AllDialog.pc_shk_ShrekEmote_101'
	EmoteSoundPain(11)=Sound'AllDialog.pc_shk_ShrekEmote_103'
	EmoteSoundPain(12)=Sound'AllDialog.pc_shk_ShrekEmote_73'
	EmoteSoundPain(13)=Sound'AllDialog.pc_shk_ShrekEmote_75'
	EmoteSoundPunch(0)=Sound'AllDialog.pc_shk_ShrekEmote_29'
	EmoteSoundPunch(1)=Sound'AllDialog.pc_shk_ShrekEmote_59'
	EmoteSoundPunch(2)=Sound'AllDialog.pc_shk_ShrekEmote_55'
	EmoteSoundPunch(3)=Sound'AllDialog.pc_shk_ShrekEmote_53'
	EmoteSoundPunch(4)=Sound'AllDialog.pc_shk_ShrekEmote_49'
	EmoteSoundPunch(5)=Sound'AllDialog.pc_shk_ShrekEmote_47'
	EmoteSoundPunch(6)=Sound'AllDialog.pc_shk_ShrekEmote_25'
	EmoteSoundPunch(7)=Sound'AllDialog.pc_shk_ShrekEmote_15'
	EmoteSoundPunch(8)=Sound'AllDialog.pc_shk_ShrekEmote_113'
	EmoteSoundPunch(9)=Sound'AllDialog.pc_shk_ShrekEmote_111'
	EmoteSoundPunch(10)=Sound'AllDialog.pc_shk_ShrekEmote_109'
	EmoteSoundPunch(11)=Sound'AllDialog.pc_shk_ShrekEmote_107'
	EmoteSoundPull(0)=Sound'AllDialog.pc_shk_ShrekEmote_89'
	EmoteSoundPull(1)=Sound'AllDialog.pc_shk_ShrekEmote_92'
	EmoteSoundPull(2)=Sound'AllDialog.pc_shk_ShrekEmote_93'
	EmoteSoundShimmy(0)=Sound'AllDialog.pc_shk_ShrekEmote_95'
	EmoteSoundShimmy(1)=Sound'AllDialog.pc_shk_ShrekEmote_97'
	EmoteSoundShimmy(2)=Sound'AllDialog.pc_shk_ShrekEmote_99'
	EmoteSoundShimmy(3)=Sound'AllDialog.pc_shk_ShrekEmote_101'
	EmoteSoundShimmy(4)=Sound'AllDialog.pc_shk_ShrekEmote_103'
	EmoteSoundShimmy(5)=Sound'AllDialog.pc_shk_ShrekEmote_105'
	EmoteSoundThrow(0)=Sound'AllDialog.pc_shk_ShrekEmote_107'
	EmoteSoundThrow(1)=Sound'AllDialog.pc_shk_ShrekEmote_109'
	EmoteSoundThrow(2)=Sound'AllDialog.pc_shk_ShrekEmote_111'
	EmoteSoundThrow(3)=Sound'AllDialog.pc_shk_ShrekEmote_113'
	EmoteSoundThrow(4)=Sound'AllDialog.pc_shk_ShrekEmote_115'
	EmoteSoundThrow(5)=Sound'AllDialog.pc_shk_ShrekEmote_117'
	EmoteSoundFaint(0)=Sound'AllDialog.pc_shk_ShrekEmote_61'
	EmoteSoundFaint(1)=Sound'AllDialog.pc_shk_ShrekEmote_79'
	EmoteSoundFaint(2)=Sound'AllDialog.pc_shk_ShrekEmote_81'
	EmoteSoundFaint(3)=Sound'AllDialog.pc_shk_ShrekEmote_85'
	EmoteSoundFaint(4)=Sound'AllDialog.pc_shk_ShrekEmote_86'
	EmoteSoundFaint(5)=Sound'AllDialog.pc_shk_ShrekEmote_87'
	EmoteSoundFaint(6)=Sound'AllDialog.pc_shk_ShrekEmote_72'
	EmoteSoundFaint(7)=Sound'AllDialog.pc_shk_ShrekEmote_67'
	SoundShimmy(0)=Sound'Shrek.shrek_shimmy'
	SoundShimmy(1)=Sound'Shrek.shrek_shimmy2'
	SoundThrow(0)=Sound'Shrek.throw'
	DoubleJumpSound(0)=Sound'Shrek.jump_double'
	FrontLeftBone=body_l_ball_joint
	FrontRightBone=body_r_ball_joint
	AttackStartBoneNames(3)=body_l_wrist_joint
	AttackEndBoneNames(3)=body_l_shoulder_joint
	RibbonEmitterName=class'SHGame.Hero_Ribbon'
	TexName=Texture'ShCharacters.Shrek_blur'
	KnockBackDistance=50.0
	SkinsVisible(0)=Texture'ShCharacters.Shrek'
	SkinsVisible(1)=Shader'ShCharacters.shrekshirt_S'
	SkinsInvisible(0)=Texture'ShCharacters.shrek_inv'
	SkinsInvisible(1)=Texture'ShCharacters.shrekshirt_inv'
	StrengthEmitterBoneName(0)="body_l_indexmid_joint"
	StrengthEmitterBoneName(1)="body_r_indexmid_joint"
	RunAttackEmitterName=class'SHGame.Shrek_Slide'
	PotionBumpLines(0)=SHK_ShrekStrength
	PotionBumpLines(1)=SHK_ShrekFrog
	PotionBumpLines(2)=SHK_ShrekGhost
	PotionBumpLines(3)=SHK_ShrekSleep
	PotionBumpLines(4)=SHK_ShrekStink
	PotionBumpLines(5)=SHK_ShrekShrinkMe
	PotionBumpLines(6)=SHK_ShrekShrinkYou
	PotionBumpLines(7)=SHK_ShrekFreeze
	PotionBumpLines(8)=SHK_ShrekLove
	WastedPotionBumpLines=SHK_ShrekWaste
	HurtBumpLines=SHK_ShrekHurt
	HitBumpLines=SHK_ShrekHit
	SimmyBumpLines=SHK_Shimmy
	PickupEnergyBarBumpLines=SHK_ShrekHero
	PickupShamrockBumpLines=SHK_ShrekClover
	LowCoinsBumpLines=SHK_ShrekCoinLow
	ManyCoinsBumpLines=SHK_ShrekCoin
	TiredBumpLines=SHK_ShrekLowHealth
	InWaterBumpLines=SHK_ShrekWater
	FootstepsWade(0)=Sound'Footsteps.F_shrek_wading01'
	FootstepsWade(1)=Sound'Footsteps.F_shrek_wading02'
	FootstepsWade(2)=Sound'Footsteps.F_shrek_wading03'
	FootstepsWade(3)=Sound'Footsteps.F_shrek_wading04'
	FootstepsWade(4)=Sound'Footsteps.F_shrek_wading05'
	FootstepsWade(5)=Sound'Footsteps.F_shrek_wading06'
	AttackDist=60.0
	AttackHeight=60.0
	AttackAngle=60.0
	AttackInfo(0)=(AnimName=punch1,StartBoneName=body_r_fingersbase_joint,EndBoneName=None,StartFrame=1.0,EndFrame=9.0)
	AttackInfo(1)=(AnimName=punch2,StartBoneName=body_l_elbow_joint,EndBoneName=body_l_wrist_joint,StartFrame=9.0,EndFrame=20.0)
	AttackInfo(2)=(AnimName=punch3,StartBoneName=body_r_fingersbase_joint,EndBoneName=body_r_wrist_joint,StartFrame=10.0,EndFrame=18.0)
	AttackInfo(3)=(AnimName=punch3,StartBoneName=body_r_wrist_joint,EndBoneName=body_r_elbow_joint,StartFrame=10.0,EndFrame=18.0)
	AttackInfo(4)=(AnimName=punch3,StartBoneName=body_r_elbow_joint,EndBoneName=body_r_shoulder_joint,StartFrame=10.0,EndFrame=18.0)
	AttackInfo(5)=(AnimName=runattack,StartBoneName=body_l_fingersbase_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(6)=(AnimName=runattack,StartBoneName=body_l_wrist_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(7)=(AnimName=runattack,StartBoneName=body_l_elbow_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(8)=(AnimName=runattack,StartBoneName=body_l_shoulder_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(9)=(AnimName=runattack,StartBoneName=body_l_toe_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(10)=(AnimName=runattack,StartBoneName=body_l_ball_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(11)=(AnimName=runattack,StartBoneName=body_l_ankle_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(12)=(AnimName=runattack,StartBoneName=body_l_knee_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(13)=(AnimName=runattack,StartBoneName=body_l_thigh_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	PunchEmitterclass=class'SHGame.Punch_Shrek'
	AttackDistFromEnemy=35.0
	CameraSetStandard=(vLookAtOffset=(X=-15.0,Y=15.0,Z=75.0),fLookAtDistance=170.0,fLookAtHeight=50.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CameraSnapRotationPitch=-3500.0
	CarryTurnRightAnim=carryturnright
	CarryTurnLeftAnim=carryturnleft
	BigClimbStartNoTrans=jumptoclimb2
	BigClimbEndNoTrans=climb2
	BigClimbStartOffset=190.0
	BigClimbOffset=130.0
	BigShimmyOffset=140.0
	HangIdleNoTransAnim=hangidle2
	JumpToHangNoTransAnim=jumptohang2
	ShimmyRightNoTransAnim=shimmyright2
	ShimmyLeftNoTransAnim=shimmyleft2
	ShimmyRightEndNoTransAnim=shimmyrightend2
	ShimmyLeftEndNoTransAnim=shimmyleftend2
	StepUpAnim=stepup
	StepUpNoTransAnim=stepup2
	IdleTiredAnimName=tiredidle
	RunAnimName=run
	WalkAnimName=Walk
	PickupAnimName=Pickup
	ThrowAnimName=throw
	KnockBackAnimName=knockback
	PickupBoneName=body_object_joint
	GroundWalkSpeed=150.0
	NeckRotElement=RE_RollNeg
	HeadRotElement=RE_YawPos
	JumpSounds(0)=Sound'Shrek.Jump'
	LandingStone(0)=Sound'Shrek.land'
	LandingWood(0)=Sound'Shrek.land'
	LandingWet(0)=Sound'Shrek.land'
	LandingGrass(0)=Sound'Shrek.land'
	LandingDirt(0)=Sound'Shrek.land'
	LandingHay(0)=Sound'Shrek.land'
	LandingLeaf(0)=Sound'Shrek.land'
	LandingSand(0)=Sound'Shrek.land'
	LandingMud(0)=Sound'Shrek.land'
	LandingNone(0)=Sound'Shrek.land'
	FootstepsStone(0)=Sound'Footsteps.F_shrek_stone01'
	FootstepsStone(1)=Sound'Footsteps.F_shrek_stone02'
	FootstepsStone(2)=Sound'Footsteps.F_shrek_stone03'
	FootstepsStone(3)=Sound'Footsteps.F_shrek_stone04'
	FootstepsStone(4)=Sound'Footsteps.F_shrek_stone05'
	FootstepsStone(5)=Sound'Footsteps.F_shrek_stone06'
	FootstepsWood(0)=Sound'Footsteps.F_shrek_wood01'
	FootstepsWood(1)=Sound'Footsteps.F_shrek_wood02'
	FootstepsWood(2)=Sound'Footsteps.F_shrek_wood03'
	FootstepsWood(3)=Sound'Footsteps.F_shrek_wood04'
	FootstepsWood(4)=Sound'Footsteps.F_shrek_wood05'
	FootstepsWood(5)=Sound'Footsteps.F_shrek_wood06'
	FootstepsWet(0)=Sound'Footsteps.F_shrek_water01'
	FootstepsWet(1)=Sound'Footsteps.F_shrek_water02'
	FootstepsWet(2)=Sound'Footsteps.F_shrek_water03'
	FootstepsWet(3)=Sound'Footsteps.F_shrek_water04'
	FootstepsWet(4)=Sound'Footsteps.F_shrek_water05'
	FootstepsWet(5)=Sound'Footsteps.F_shrek_water06'
	FootstepsGrass(0)=Sound'Footsteps.F_shrek_grass01'
	FootstepsGrass(1)=Sound'Footsteps.F_shrek_grass02'
	FootstepsGrass(2)=Sound'Footsteps.F_shrek_grass03'
	FootstepsGrass(3)=Sound'Footsteps.F_shrek_grass04'
	FootstepsGrass(4)=Sound'Footsteps.F_shrek_grass05'
	FootstepsGrass(5)=Sound'Footsteps.F_shrek_grass06'
	FootstepsMetal(0)=Sound'Footsteps.F_shrek_metal01'
	FootstepsMetal(1)=Sound'Footsteps.F_shrek_metal02'
	FootstepsMetal(2)=Sound'Footsteps.F_shrek_metal03'
	FootstepsMetal(3)=Sound'Footsteps.F_shrek_metal04'
	FootstepsMetal(4)=Sound'Footsteps.F_shrek_metal05'
	FootstepsMetal(5)=Sound'Footsteps.F_shrek_metal06'
	FootstepsDirt(0)=Sound'Footsteps.F_shrek_dirt01'
	FootstepsDirt(1)=Sound'Footsteps.F_shrek_dirt02'
	FootstepsDirt(2)=Sound'Footsteps.F_shrek_dirt03'
	FootstepsDirt(3)=Sound'Footsteps.F_shrek_dirt04'
	FootstepsDirt(4)=Sound'Footsteps.F_shrek_dirt05'
	FootstepsDirt(5)=Sound'Footsteps.F_shrek_dirt06'
	FootstepsHay(0)=Sound'Footsteps.F_shrek_grass01'
	FootstepsHay(1)=Sound'Footsteps.F_shrek_grass02'
	FootstepsHay(2)=Sound'Footsteps.F_shrek_grass03'
	FootstepsHay(3)=Sound'Footsteps.F_shrek_grass04'
	FootstepsLeaf(0)=Sound'Footsteps.F_shrek_leaf01'
	FootstepsLeaf(1)=Sound'Footsteps.F_shrek_leaf02'
	FootstepsLeaf(2)=Sound'Footsteps.F_shrek_leaf03'
	FootstepsLeaf(3)=Sound'Footsteps.F_shrek_leaf04'
	FootstepsLeaf(4)=Sound'Footsteps.F_shrek_leaf05'
	FootstepsLeaf(5)=Sound'Footsteps.F_shrek_leaf06'
	FootstepsNone(0)=Sound'Footsteps.F_shrek_stone01'
	FootstepsNone(1)=Sound'Footsteps.F_shrek_stone02'
	FootstepsNone(2)=Sound'Footsteps.F_shrek_stone03'
	FootstepsNone(3)=Sound'Footsteps.F_shrek_stone04'
	FootstepsNone(4)=Sound'Footsteps.F_shrek_stone05'
	FootstepsNone(5)=Sound'Footsteps.F_shrek_stone06'
	FootFramesWalk(0)=8
	FootFramesWalk(1)=25
	FootFramesWalk(2)=44
	FootFramesWalk(3)=61
	FootFramesRun(0)=5
	FootFramesRun(1)=20
	FootFramesRun(2)=34
	FootFramesRun(3)=50
	WaterRipples=class'SHGame.WaterRipples'
	fMoveWaterRipplesTime=0.250000
	fRestWaterRipplesTime=1.500000
	bUseNewMountCode=true
	IdleAnims(0)=bored1
	IdleAnims(1)=bored1
	IdleAnims(2)=bored1
	IdleAnims(3)=bored1
	IdleAnims(4)=bored2
	IdleAnims(5)=bored2
	IdleAnims(6)=bored2
	IdleAnims(7)=bored2
	ShimmySpeed=120.0
	bIsMainPlayer=true
	Controllerclass=class'SHGame.SHCompanionController'
	Mesh=SkeletalMesh'ShrekCharacters.Shrek'
	CollisionHeight=44.0
	Label="Shrek"
}