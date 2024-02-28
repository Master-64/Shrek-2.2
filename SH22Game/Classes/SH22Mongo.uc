// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Mongo extends SH22HeroPawn
	Config(SH22);


var() array<name> CrumpBones;
var() class<Emitter> CrumpEmitter;
var() array<Material> SkinsArray;
var() Material ShrekSkinInv, ShrekSkin;
var() array<Sound> Throw2Sounds, KickSounds, FakeKickSounds;
var GenericColObj LeftFistColObj, RightFistColObj;
var name LeftFistBone, RightFistBone, KickAnimName;
var() bool bShowShrek;
var bool L, R, bOldbShowShrek;

function AttachGenericColObjs()
{
	if(!bIsMainPlayer)
	{
		return;
	}
	
	LeftFistColObj = Spawn(class'GenericColObj');
	
	if(LeftFistColObj != none)
	{
		L = AttachToBone(LeftFistColObj, LeftFistBone);
		LeftFistColObj.SetOwner(self);
		LeftFistColObj.SetCollision(true, true, true);
	}
	
	RightFistColObj = Spawn(class'GenericColObj');
	
	if(RightFistColObj != none)
	{
		R = AttachToBone(RightFistColObj, RightFistBone);
		RightFistColObj.SetOwner(self);
		RightFistColObj.SetCollision(true, true, true);
	}
}

function AttachCitizenCollision()
{
	local MongoCitizenRadius citizenRadius;
	local bool bAttachedToBone;
	
	citizenRadius = Spawn(class'MongoCitizenRadius');
	
	if(citizenRadius == none)
	{
		Log("Mongo Citizen Radius not spawned");
	}
	
	bAttachedToBone = AttachToBone(citizenRadius, 'body_root_joint');
	
	if(!bAttachedToBone)
	{
		Log("Mongo Citizen Radius not attached to bone");
	}
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Skins[0] = SkinsArray[0];
	AttachCitizenCollision();
	
	if(bShowShrek)
	{
		Skins[1] = ShrekSkin;
	}
	else
	{
		Skins[1] = none;
	}
}

function AddAnimNotifys()
{
	local MeshAnimation MeshAnim;

	super.AddAnimNotifys();
	
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddNotify(MeshAnim, LandAnims[0], 20.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, LandAnims[1], 10.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, PickupAnimName, 8.0, 'AnimNotifyObjectPickup');
	AddNotify(MeshAnim, ThrowAnimName, 29.0, 'PlayerThrowCarryingActor');
	AddNotify(MeshAnim, PickupAnimNames[0], 28.0, 'AnimNotifyObjectPickup');
	AddNotify(MeshAnim, ThrowAnimNames[0], 27.0, 'PlayerThrowCarryingActor');
	AddFootStepsNotify(MeshAnim);
}

function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(Rand(300) == 0)
	{
		DropACrump();
	}
	
	if(bShowShrek != bOldbShowShrek)
	{
		if(bShowShrek)
		{
			Skins[1] = ShrekSkin;
		}
		else
		{
			Skins[1] = none;
		}
	}
	
	bOldbShowShrek = bShowShrek;
}

function bool CanUsePotion()
{
	return false;
}

function PlayFootStepsSound()
{
	super.PlayFootStepsSound();
	
	ShakeTheGround();
}

function PlayerThrowCarryingActor()
{
	if(aHolding != none && aHolding.IsA('Tram'))
	{
		InterestMgr.CommentMgr.SayComment('TRA_TramThrow', aHolding.Tag,, true,,,, "BumpDialog");
	}
	
	PlayArraySound(Throw2Sounds, 1.0);
	super.PlayerThrowCarryingActor();
}

function AnimNotifyObjectPickup()
{
	super.AnimNotifyObjectPickup();
	
	if(aHolding != none && aHolding.IsA('Tram'))
	{
		InterestMgr.CommentMgr.SayComment('TRA_TramPickup', aHolding.Tag,, true,,,, "BumpDialog");
	}
}

function PlayGroundShakeSound()
{
	local Sound snd;

	snd = GetRandSound(FootstepsNone);
	
	if(snd == none)
	{
		return;
	}
	
	PlayOwnedSound(snd, SLOT_None, 1.0, false, 800.0, RandRange(0.95, 1.05));
}

function ShakeTheGround()
{
	PC = U.GetPC();
	
	PC.SimpleShakeView(0.5, 100.0, 0.5);
	PlayGroundShakeSound();
}

function SayHitKarmaBumpLine()
{
	if(bIsMainPlayer)
	{
		InterestMgr.CommentMgr.SayComment('GBM_MongoCheer', Tag,, true,,, self, "BumpDialog");
	}
}

function HitSomebody(int hitdamage, array<Sound> SoundArray, name animseq, float AnimFrame)
{
	if(AnimFrame <= 13.0)
	{
		return;
	}
	
	super.HitSomebody(hitdamage, SoundArray, animseq, AnimFrame);
}

function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local float fHealthPercent;
	
	super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
	
	if(bIsMainPlayer && U.GetHealth(self) > 0.0 && Damage > 0)
	{
		InterestMgr.CommentMgr.SayComment('GGM_MongoHurt', Tag,, true,,, self, "BumpDialog");
	}
	
	fHealthPercent = U.GetHealth(self) / U.GetMaxHealth(self);
	
	if(fHealthPercent > 0.8)
	{
		Skins[0] = SkinsArray[0];
	}
	else if(fHealthPercent > 0.6)
	{
		Skins[0] = SkinsArray[1];
	}
	else if(fHealthPercent > 0.4)
	{
		Skins[0] = SkinsArray[2];
	}
	else if(fHealthPercent > 0.2)
	{
		Skins[0] = SkinsArray[3];
	}
	else
	{
		Skins[0] = SkinsArray[4];
	}
}

function ResetSkinUp()
{
	local float fHealthPercent;
	
	fHealthPercent = U.GetHealth(self) / U.GetMaxHealth(self);
	
	if(fHealthPercent > 0.8)
	{
		Skins[0] = SkinsArray[0];
	}
	else if(fHealthPercent > 0.6)
	{
		Skins[0] = SkinsArray[1];
	}
	else if(fHealthPercent > 0.4)
	{
		Skins[0] = SkinsArray[2];
	}
	else if(fHealthPercent > 0.2)
	{
		Skins[0] = SkinsArray[3];
	}
	else
	{
		Skins[0] = SkinsArray[4];
	}
}

function GoToStateKnock(bool forward)
{
	return;
}

function bool IsAttacking()
{
	if(IsInState('stateKickAttack'))
	{
		return true;
	}
	
	return super.IsAttacking();
}

function DoSomeAction()
{
	if(IsInState('stateKickAttack'))
	{
		return;
	}
	
	super.DoSomeAction();
}

function DropACrump()
{
	local vector Loc;
	local name bname;
	
	if(Velocity == U.Vec(0.0, 0.0, 0.0))
	{
		return;
	}
	
	bname = CrumpBones[Rand(CrumpBones.Length)];
	Loc = GetBoneCoords(bname).Origin;
	Spawn(CrumpEmitter,,, Loc);
}

function ColObjTouch(Actor Other, GenericColObj ColObj)
{
	Other.TakeDamage(1, self, ColObj.Location, U.Vec(0.0, 0.0, 0.0), none);
}

function bool DoJump(bool bUpdating)
{
	if(!StateIsInterruptible() || IsAttacking() || aHolding != none)
	{
		return false;
	}
	
	GotoState('stateKickAttack');
	
	return false;
}

function bool MovingForward()
{
	return false;
}

event Bump(Actor Other)
{
	super.Bump(Other);
	
	if(!MovingForward() || (!Other.IsA('MongoKnight') && !Other.IsA('MilkKnight')))
	{
		return;
	}
	
	Pawn(Other).TakeDamage(1, self, U.Vec(0.0, 0.0, 0.0), U.Vec(0.0, 0.0, 0.0), class'WalkingKickDamage');
}

state stateKickAttack
{
	event Tick(float DeltaTime)
	{
		local float AnimFrame;

		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		AnimFrame = GetAnimFrame(ATTACKCHANNEL_UPPER);
		
		if(AnimFrame < 20.0)
		{
			return;
		}
		
		HitSomebody(1, FakeKickSounds, 'None', AnimFrame);
	}

	event BeginState()
	{
		HitType = HT_LOWBODY;
		StartRegularAttack();
		
		if(Rand(2) == 0)
		{
			KickAnimName = 'kickright';
		}
		else
		{
			KickAnimName = 'kickleft';
		}
		
		StartAttackAnimation(KickAnimName);
		PlayArraySound(EmoteSoundPunch, 0.6);
		PlayArraySound(KickSounds, 1.0);
	}

	event EndState()
	{
		HitType = HT_UPPERBODY;
		EndAttackAnimation(0.0);
	}

	function bool StateIsInterruptible()
	{
		return false;
	}
	
	Begin:
	
	FinishAnim(ATTACKCHANNEL_UPPER);
	GotoState('StateIdle');
}

defaultproperties
{
	bCanMount=false
	ShrekSkin=Texture'ShCharacters.minus_handsome_tx'
	CrumpBones(0)=body_l_thigh_joint
	CrumpBones(1)=body_r_thigh_joint
	CrumpBones(2)=body_l_wrist_joint
	CrumpBones(3)=body_r_wrist_joint
	CrumpBones(4)=body_spine2_joint
	CrumpEmitter=class'Cookie_Bits'
	SkinsArray(0)=Texture'ShCharacters.mongo_tx'
	SkinsArray(1)=Texture'ShCharacters.mongo2_tx'
	SkinsArray(2)=Texture'ShCharacters.mongo3_tx'
	SkinsArray(3)=Texture'ShCharacters.mongo4_tx'
	SkinsArray(4)=Texture'ShCharacters.mongo5_tx'
	ShrekSkinInv=Texture'ShCharacters.minus_handsome_tx'
	Throw2Sounds(0)=Sound'Mongo.throw_01'
	Throw2Sounds(1)=Sound'Mongo.throw_02'
	KickSounds(0)=Sound'Mongo.kick_01'
	KickSounds(1)=Sound'Mongo.kick_02'
	LeftFistBone=body_l_wrist_joint
	RightFistBone=body_r_wrist_joint
	KickAnimName=kickright
	HitType=HT_UPPERBODY
	SHHeroName=Mongo
	EndAttackAnim3=punch3end
	PreStartAttackAnim1=None
	SwingSounds(0)=Sound'Mongo.attack_01'
	SwingSounds(1)=Sound'Mongo.attack_02'
	Attack1Sounds(0)=Sound'The_Seige.building_smash01'
	Attack1Sounds(1)=Sound'The_Seige.building_smash02'
	Attack1Sounds(2)=Sound'The_Seige.building_smash03'
	Attack1Sounds(3)=Sound'The_Seige.building_smash04'
	Attack1Sounds(4)=Sound'The_Seige.building_smash05'
	Attack1Sounds(5)=Sound'The_Seige.building_smash06'
	Attack1Sounds(6)=Sound'The_Seige.building_smash07'
	Attack1Sounds(7)=Sound'The_Seige.building_smash08'
	Attack1Sounds(8)=Sound'The_Seige.building_smash09'
	Attack2Sounds(0)=Sound'The_Seige.building_smash01'
	Attack2Sounds(1)=Sound'The_Seige.building_smash02'
	Attack2Sounds(2)=Sound'The_Seige.building_smash03'
	Attack2Sounds(3)=Sound'The_Seige.building_smash04'
	Attack2Sounds(4)=Sound'The_Seige.building_smash05'
	Attack2Sounds(5)=Sound'The_Seige.building_smash06'
	Attack2Sounds(6)=Sound'The_Seige.building_smash07'
	Attack2Sounds(7)=Sound'The_Seige.building_smash08'
	Attack2Sounds(8)=Sound'The_Seige.building_smash09'
	Attack3Sounds(0)=Sound'The_Seige.building_smash01'
	Attack3Sounds(1)=Sound'The_Seige.building_smash02'
	Attack3Sounds(2)=Sound'The_Seige.building_smash03'
	Attack3Sounds(3)=Sound'The_Seige.building_smash04'
	Attack3Sounds(4)=Sound'The_Seige.building_smash05'
	Attack3Sounds(5)=Sound'The_Seige.building_smash06'
	Attack3Sounds(6)=Sound'The_Seige.building_smash07'
	Attack3Sounds(7)=Sound'The_Seige.building_smash08'
	Attack3Sounds(8)=Sound'The_Seige.building_smash09'
	FrontLeftBone=body_l_hoof_joint
	FrontRightBone=body_r_hoof_joint
	BackLeftBone=body_l_foot_joint
	BackRightBone=body_r_foot_joint
	KnockBackDistance=30.0
	DyingBumpLines=GGM_MongoDie
	AttackDist=100.0
	AttackHeight=100.0
	AttackAngle=40.0
	PickupAnimNames(0)=pickup2
	ThrowAnimNames(0)=throw2
	CarryIdleAnimNames(0)=carry_idle2
	CarryTurnRightAnims(0)=carry_turnright2
	CarryTurnLeftAnims(0)=carry_turnleft2
	CarryForwardAnimNames(0)=carry2
	CarryBackwardAnimNames(0)=carrybackwards2
	CarryStrafeLeftAnimNames(0)=carrystafeleft2
	CarryStrafeRightAnimNames(0)=carrystaferight2
	CameraSetStandard=(vLookAtOffset=(X=-200.0,Y=20.0,Z=250.0),fLookAtDistance=600.0,fLookAtHeight=400.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CameraSnapRotationPitch=-2500.0
	WalkAnims[1]=walkbackwards
	CarryTurnRightAnim=carry_turnright
	CarryTurnLeftAnim=carry_turnleft
	BigClimbOffset=50.0
	JumpToHangAnim=jumptoclimb
	RunAnimName=Walk
	WalkAnimName=Walk
	CarryIdleAnimName=carry_idle
	CarryBackwardAnimName=carrybackwards
	PickupAnimName=Pickup
	ThrowAnimName=throw
	PickupBoneName=body_object_joint
	LeftUpperLidBone=body_l_topeyelid_joint
	LeftLowerLidBone=body_l_bottomeyelid_joint
	RightUpperLidBone=body_r_topeyelid_joint
	RightLowerLidBone=body_r_bottomeyelid_joint
	bCanBlink=false
	FootstepsStone(0)=Sound'Footsteps.F_GGM_default01'
	FootstepsStone(1)=Sound'Footsteps.F_GGM_default01'
	FootstepsStone(2)=Sound'Footsteps.F_GGM_default01'
	FootstepsStone(3)=Sound'Footsteps.F_GGM_default01'
	FootstepsStone(4)=Sound'Footsteps.F_GGM_default01'
	FootstepsStone(5)=Sound'Footsteps.F_GGM_default01'
	FootstepsWood(0)=Sound'Footsteps.F_GGM_default01'
	FootstepsWood(1)=Sound'Footsteps.F_GGM_default01'
	FootstepsWood(2)=Sound'Footsteps.F_GGM_default01'
	FootstepsWood(3)=Sound'Footsteps.F_GGM_default01'
	FootstepsWood(4)=Sound'Footsteps.F_GGM_default01'
	FootstepsWood(5)=Sound'Footsteps.F_GGM_default01'
	FootstepsGrass(0)=Sound'Footsteps.F_GGM_default01'
	FootstepsGrass(1)=Sound'Footsteps.F_GGM_default01'
	FootstepsGrass(2)=Sound'Footsteps.F_GGM_default01'
	FootstepsGrass(3)=Sound'Footsteps.F_GGM_default01'
	FootstepsGrass(4)=Sound'Footsteps.F_GGM_default01'
	FootstepsGrass(5)=Sound'Footsteps.F_GGM_default01'
	FootstepsDirt(0)=Sound'Footsteps.F_GGM_default01'
	FootstepsDirt(1)=Sound'Footsteps.F_GGM_default01'
	FootstepsDirt(2)=Sound'Footsteps.F_GGM_default01'
	FootstepsDirt(3)=Sound'Footsteps.F_GGM_default01'
	FootstepsDirt(4)=Sound'Footsteps.F_GGM_default01'
	FootstepsDirt(5)=Sound'Footsteps.F_GGM_default01'
	FootstepsNone(0)=Sound'Footsteps.F_GGM_default01'
	FootstepsNone(1)=Sound'Footsteps.F_GGM_default01'
	FootstepsNone(2)=Sound'Footsteps.F_GGM_default01'
	FootstepsNone(3)=Sound'Footsteps.F_GGM_default01'
	FootstepsNone(4)=Sound'Footsteps.F_GGM_default01'
	FootstepsNone(5)=Sound'Footsteps.F_GGM_default01'
	FootFramesWalk(0)=12
	FootFramesWalk(1)=32
	FootFramesWalk(2)=52
	FootFramesWalk(3)=72
	FootFramesRun(0)=12
	FootFramesRun(1)=32
	FootFramesRun(2)=52
	FootFramesRun(3)=72
	IdleAnims(0)=Idle
	IdleAnims(1)=Idle
	IdleAnims(2)=Idle
	IdleAnims(3)=Idle
	IdleAnims(4)=Idle
	IdleAnims(5)=Idle
	IdleAnims(6)=Idle
	IdleAnims(7)=Idle
	bIsMainPlayer=true
	ControllerClass=class'SHCompanionController'
	MovementAnims[0]=Walk
	MovementAnims[1]=walkbackwards
	MovementAnims[2]=walkleft
	MovementAnims[3]=walkright
	TurnLeftAnim=TurnLeft
	TurnRightAnim=TurnRight
	Mesh=SkeletalMesh'ShrekCharacters.Mongo'
	CollisionRadius=150.0
	CollisionHeight=300.0
	Label="Mongo"
}