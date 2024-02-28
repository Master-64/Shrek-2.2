// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22PIB extends SH22HeroPawn
	Config(SH22);


var int TotalGameStateTokens, GameStateTokenLen;
var(GameState) const editconst string GameStateMasterList;
var(GameState) travel string CurrentGameState;
var Sword PibSword;
var() class<Emitter> HairFlyEmitter;
var() array<Sound> BodyFallSounds, LandingSounds, GetUpSounds, SwordUnsheathSounds, SwordPutAwaySounds, SwordHitSounds;
var() Texture SwordRibbonTexName;
var() Material SwordSkin;
var() float fDelay;
var() bool bInCutScene, bShowNecklace;
var() name NecklaceAttachBone;
var() vector NecklaceAttachOffset;
var() rotator NecklaceAttachRotation;
var bool bOldbShowNecklace;
var PibLeftGlove LeftGlove;
var PibRightGlove RightGlove;
var PibNecklace Necklace;


function PostBeginPlay()
{
	super.PostBeginPlay();
	
	PibSword = Spawn(class'Sword');
	PibSword.AttachWeaponToKWPawn(self);
	PibSword.bIsOut = false;
	
	LeftGlove = Spawn(class'PibLeftGlove');
	LeftGlove.AttachWeaponToKWPawn(self);
	LeftGlove.bHidden = true;
	
	RightGlove = Spawn(class'PibRightGlove');
	RightGlove.AttachWeaponToKWPawn(self);
	RightGlove.bHidden = true;
	SHWeap = PibSword;
	
	Necklace = Spawn(class'PibNecklace');
	AttachToBone(Necklace, NecklaceAttachBone);
	Necklace.SetRelativeLocation(NecklaceAttachOffset);
	Necklace.SetRelativeRotation(NecklaceAttachRotation);
	Necklace.SetOwner(self);
	Necklace.bHidden = !bShowNecklace;
}

function AddAnimNotifys()
{
	local MeshAnimation MeshAnim;
	
	super.AddAnimNotifys();
	
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddNotify(MeshAnim, LandAnims[0], 20.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, LandAnims[1], 10.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, EndAirAttackAnim, 50.0, 'AnimNotifyBlendOutEndAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 35.0, 'AnimNotifyBlendOutContinueAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, EndAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, StartSupportAttackAnim, 30.0, 'AnimNotifySwordIsOut');
	AddNotify(MeshAnim, EndSupportAttackAnim, 17.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, StartAttackAnim1, 5.0, 'PlayHairFlyEmitter');
	AddNotify(MeshAnim, StartAttackAnim2, 8.0, 'PlayHairFlyEmitter');
	AddNotify(MeshAnim, StartAttackAnim3, 12.0, 'PlayHairFlyEmitter');
	AddNotify(MeshAnim, StartAttackAnim3, 8.0, 'KillEverybody');
	AddNotify(MeshAnim, PickupAnimName, 6.0, 'AnimNotifyObjectPickup');
	AddNotify(MeshAnim, ThrowAnimName, 11.0, 'PlayerThrowCarryingActor');
	AddNotify(MeshAnim, StartAttackAnim1, 2.0, 'CreateRibbonEmittersForAttack1');
	AddNotify(MeshAnim, StartAttackAnim2, 1.0, 'CreateRibbonEmittersForAttack2');
	AddNotify(MeshAnim, StartAttackAnim3, 1.0, 'CreateRibbonEmittersForAttack3');
	AddNotify(MeshAnim, StartAttackAnim1, 10.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, StartAttackAnim2, 19.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, StartAttackAnim3, 21.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, NewRunAttackAnim, 1.0, 'AnimNotifySwordIsOut');
	AddNotify(MeshAnim, NewRunAttackAnim, 27.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, NewRunAttackAnim, 3.0, 'CreateRibbonEmittersForRunAttack');
	AddNotify(MeshAnim, NewRunAttackAnim, 22.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, ThrowPotionAnimName, 18.0, 'ThrowPotion');
	AddNotify(MeshAnim, DrinkPotionAnimName, 52.0, 'DrinkPotion');
	AddNotify(MeshAnim, ThrowPotionAnimName, 4.0, 'PlayThrowPotionSound');
	AddNotify(MeshAnim, DrinkPotionAnimName, 16.0, 'PlayDrinkPotionSound');
	AddNotify(MeshAnim, StartAttackAnim, 1.0, 'AnimNotifySwordIsOut');
	AddNotify(MeshAnim, StartAttackAnim1, 1.0, 'AnimNotifySwordIsOutForPunch1');
	AddNotify(MeshAnim, EndAttackAnim1, 18.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, EndAttackAnim2, 16.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, EndAttackAnim3, 19.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, 'DrawinghisSword', 5.0, 'AnimNotifySwordIsOut');
	AddNotify(MeshAnim, 'CS_PutSwordBack', 13.0, 'AnimNotifySwordIsIn');
	AddFootStepsNotify(MeshAnim);
}

function KillEverybody()
{
	local Emitter em;
	
	em = Spawn(class'range_attack', self);
	AttachToBone(em, 'body_spine3_joint');
	KillAllEnemiesAround(150.0);
}

function PreCutPossess()
{
	super.PreCutPossess();
	
	WalkAnims[0] = CompanionWalkAnim;
	WalkAnims[1] = CompanionWalkAnim;
	WalkAnims[2] = CompanionWalkAnim;
	WalkAnims[3] = CompanionWalkAnim;
	bInCutScene = true;
}

function PreCutUnPossess()
{
	super.PreCutUnPossess();
	
	WalkAnims[0] = default.WalkAnims[0];
	WalkAnims[1] = default.WalkAnims[1];
	WalkAnims[2] = default.WalkAnims[2];
	WalkAnims[3] = default.WalkAnims[3];
	bInCutScene = false;
}

function CreateRibbonEmittersForAttack1()
{
	CreateRibbonEmitters(0);
}

function CreateRibbonEmittersForAttack2()
{
	CreateRibbonEmitters(1);
}

function CreateRibbonEmittersForAttack3()
{
	CreateRibbonEmitters(2);
}

function CreateRibbonEmittersForRunAttack()
{
	super.CreateRibbonEmittersForRunAttack();
	
	if(RibbonEffect != none)
	{
		RibbonEmitter(RibbonEffect.Emitters[0]).Texture = SwordRibbonTexName;
	}
}

function PlayPibSound(array<Sound> sounds)
{
	local Sound snd;

	snd = GetRandSound(sounds);
	
	if(snd == none)
	{
		return;
	}
	
	PlayOwnedSound(snd, SLOT_None, 1.0, false, 800.0, 1.0);
}

function PlayHairFlyEmitter()
{
	if(Rand(2) != 0)
	{
		return;
	}
	
	Spawn(HairFlyEmitter);
}

event AnimNotifySwordIsOut()
{
	PibSword.WeaponAttachBone = PibSword.SecondaryWeaponAttachBone;
	PibSword.WeaponAttachOffset = PibSword.SecondaryWeaponAttachOffset;
	PibSword.WeaponAttachRotation = PibSword.SecondaryWeaponAttachRotation;
	PibSword.AttachWeaponToKWPawn(self);
	PibSword.bIsOut = true;
}

event AnimNotifySwordIsOutForPunch1()
{
	if(PibSword.bIsOut)
	{
		return;
	}
	
	AnimNotifySwordIsOut();
}

event AnimNotifySwordIsIn()
{
	PibSword.WeaponAttachBone = PibSword.default.WeaponAttachBone;
	PibSword.WeaponAttachOffset = PibSword.default.WeaponAttachOffset;
	PibSword.WeaponAttachRotation = PibSword.default.WeaponAttachRotation;
	PibSword.AttachWeaponToKWPawn(self);
	PibSword.bIsOut = false;
	DestroyRibbonEmitters();
}

function SetEverythingForClimbingLadder()
{
	local array<name> MAs;
	
	bDoingDoubleJump = false;
	PlayAnim(LandAnims[0], 0.0, 0.0, 1);
	AnimBlendToAlpha(1, 0.0, 0.0);
	PlayAnim(GetIdleAnimName());
	
	MAs[0] = 'pipeclimbup';
	MAs[1] = 'pipeclimbdown';
	MAs[2] = _MovementAnims[2];
	MAs[3] = _MovementAnims[3];
	
	U.HackMovementAnims(self, MAs);
}

function name GetIdleAnimName()
{
	if(Controller.IsInState('PlayerClimbing'))
	{
		return 'pipeidle';
	}
	
	if(bIsWalking)
	{
		if(bInCutScene)
		{
			return 'Idle';
		}
		else
		{
			return 'stealthidle';
		}
	}
	
	return super.GetIdleAnimName();
}

event SetWalking(bool bNewIsWalking)
{
	if(!Controller.IsA('KWCutController'))
	{
		return;
	}
	
	super.SetWalking(bNewIsWalking);
}

event ChangeAnimation()
{
	super.ChangeAnimation();
	
	if(bIsWalking)
	{
		if(bInCutScene)
		{
			TurnLeftAnim = default.TurnLeftAnim;
			TurnRightAnim = default.TurnRightAnim;
		}
		else
		{
			TurnLeftAnim = 'stealthturn_left';
			TurnRightAnim = 'stealthturn_right';
			
			SetCollisionSize(default.CollisionRadius, 10.0);
		}
	}
	else
	{
		TurnLeftAnim = default.TurnLeftAnim;
		TurnRightAnim = default.TurnRightAnim;
		SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
	}
	
	if(!IsInState('MountHanging'))
	{
		PlayAnim(GetIdleAnimName(), 1.0, 0.3);
	}
	
	if(Controller == none)
	{
		return;
	}
	
	if(!Controller.IsInState('PlayerClimbing'))
	{
		return;
	}
	
	SetEverythingForClimbingLadder();
}

function ClimbLadder(LadderVolume L)
{
	if(IsInState('LadderClimbFinish'))
	{
		return;
	}
	
	super.ClimbLadder(L);
	
	SetEverythingForClimbingLadder();
}

function EndClimbLadder(LadderVolume OldLadder)
{
	local array<name> MAs;
	
	super.EndClimbLadder(OldLadder);
	
	IdleAnimName = 'Idle';
	PlayAnim(GetIdleAnimName());
	AnimBlendToAlpha(1, 0.0, 0.01);
	
	MAs[0] = default._MovementAnims[1];
	MAs[1] = default._MovementAnims[1];
	MAs[2] = default._MovementAnims[2];
	MAs[3] = default._MovementAnims[3];
	
	U.HackMovementAnims(self, MAs);
}

function bool DoJump(bool bUpdating)
{
	local bool retvalue;
	local rotator R;
	local vector V;
	
	if(bIsWalking)
	{
		return false;
	}
	
	retvalue = super.DoJump(bUpdating);
	
	if(Controller.IsInState('PlayerClimbing'))
	{
		R = Rotation;
		R.Pitch = 0;
		R.Roll = 0;
		R.Yaw += 32768;
		V = vector(R);
		Velocity = 100.0 * V;
	}
	
	return retvalue;
}

function DoDoubleJump(bool bUpdating)
{
	if(bIsWalking)
	{
		return;
	}
	
	super.DoDoubleJump(bUpdating);
}

function DoSomeAction()
{
	if(bIsWalking)
	{
		return;
	}
	
	super.DoSomeAction();
}

function StartToShrinkDown()
{
	super.StartToShrinkDown();
	
	AmbientGlow = 64;
}

function StartToShrinkUp()
{
	super.StartToShrinkUp();
	
	AmbientGlow = 0;
}

function Tick(float DeltaTime)
{
	local name animseq;
	local PibCrouchVolume pcv;
	
	super.Tick(DeltaTime);
	
	if(bShowNecklace != bOldbShowNecklace)
	{
		Necklace.bHidden = !bShowNecklace;
	}
	
	bOldbShowNecklace = bShowNecklace;
	
	foreach TouchingActors(class'PibCrouchVolume', pcv)
	{
		SetWalking(true);
		
		break;
	}
	
	if(PibSword != none)
	{
		if(PibSword.bIsOut)
		{
			if(IsInState('stateKnockBack') || IsInState('stateKnockForward'))
			{
				AnimNotifySwordIsIn();
				
				return;
			}
			
			animseq = GetAnimSequence(4);
			
			if(animseq == NewRunAttackAnim)
			{
				return;
			}
			
			animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
			
			if(animseq == StartAttackAnim || animseq == StartAttackAnim1 || animseq == StartAttackAnim2 || animseq == EndAttackAnim1 || animseq == EndAttackAnim2 || animseq == StartAttackAnim3 || animseq == EndAttackAnim3 || animseq == PreStartAttackAnim1)
			{
				return;
			}
			
			if(!Controller.IsA('KWCutController'))
			{
				AnimNotifySwordIsIn();
			}
		}
	}
}

function PutSwordBackIn()
{
	if(PibSword == none || !PibSword.bIsOut)
	{
		return;
	}
	
	AnimNotifySwordIsIn();
}

function SetVisibleTextures()
{
	super.SetVisibleTextures();
	
	PibSword.SetOpacity(1.0);
	PibSword.Skins[0] = SwordSkin;
}

function SetInvisibleTextures()
{
	super.SetInvisibleTextures();
	
	PibSword.SetOpacity(InvisibilityPercent);
}

function ShowStrengthAttributes()
{
	super.ShowStrengthAttributes();
	
	PC = U.GetPC();
	
	if(SHHeroController(PC).PibFirstStrengthPotion == 0)
	{
		SHHeroController(PC).PibFirstStrengthPotion = 1;
		SHHeroController(PC).SaveConfig();
		TriggerEvent('PibStrengthPotion', none, none);
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

state stateHeldByTheScruffIdle
{
	function name GetIdleAnimName()
	{
		return 'HeldBytheScruffidle';
	}

	function BeginState()
	{
		TurnLeftAnim = 'None';
		TurnRightAnim = 'None';
		LoopAnim('HeldBytheScruffidle');
	}

	function EndState()
	{
		TurnLeftAnim = default.TurnLeftAnim;
		TurnRightAnim = default.TurnRightAnim;
	}
}

state LadderClimbFinish
{
	function FaceRotation(rotator NewRotation, float DeltaTime)
	{
		return;
	}

	event Falling()
	{
		super.Falling();
	}

	function PlayFalling()
	{
		super.PlayFalling();
	}

	function name GetIdleAnimName()
	{
		return 'pipeend2';
	}

	event Tick(float DeltaTime)
	{
		local name SeqName;
		local float AnimFrame, AnimFrames, AnimRate;
		local vector V;
		local rotator R;

		global.Tick(DeltaTime);
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		
		if(fDelay > 0.0)
		{
			SetPhysics(PHYS_Projectile);
		}
		
		fDelay -= DeltaTime;
		GetAnimParams(0, SeqName, AnimFrame, AnimRate);
		AnimFrames = GetAnimNumFrames();
		
		if(AnimFrame > 0.0 && AnimFrame < AnimFrames / 2.0)
		{
			V = 25.0 * DeltaTime * AnimRate * U.Vec(0.0, 0.0, 2.0);
			
			Move(V);
		}
		
		if(AnimFrame > AnimFrames / 2.0)
		{
			R = Rotation;
			R.Roll = 0;
			R.Pitch = 0;
			V = 15.0 * DeltaTime * AnimRate * vector(R) * 2.0;
			
			Move(V);
		}
	}

	event BeginState()
	{
		fDelay = 0.1;
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		SetPhysics(PHYS_Projectile);
		bPhysicsAnimUpdate = false;
		SetCollisionSize(CollisionRadius * 0.5, CollisionHeight * 0.5);
		TweenOutAnimChannels(0.1);
		PlayAnim('pipeend2');
	}

	event EndState()
	{
		SetCollisionSize(CollisionRadius * 2.0, CollisionHeight * 2.0);
		SetPhysics(PHYS_Walking);
	}

	function AnimEnd(int Channel)
	{
		return;
	}

	function PlayWaiting()
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

	FinishAnim();
	Sleep(0.0001);
	bPhysicsAnimUpdate = true;
	GotoState('StateIdle');
}


defaultproperties
{
	NecklaceAttachBone=body_spine4_joint
	NecklaceAttachRotation=(Pitch=-16235)
	HairFlyEmitter=class'SHGame.Hair_Fly'
	BodyFallSounds(0)=Sound'PussInBoots.body_fall1'
	BodyFallSounds(1)=Sound'PussInBoots.body_fall2'
	BodyFallSounds(2)=Sound'PussInBoots.body_fall3'
	BodyFallSounds(3)=Sound'PussInBoots.body_fall4'
	LandingSounds(0)=Sound'PussInBoots.landing2'
	LandingSounds(1)=Sound'PussInBoots.landing3'
	GetUpSounds(0)=Sound'PussInBoots.get_up'
	SwordUnsheathSounds(0)=Sound'PussInBoots.sword_unsheath'
	SwordPutAwaySounds(0)=Sound'PussInBoots.sword_put_away'
	SwordHitSounds(0)=Sound'PussInBoots.sword_hit1'
	SwordHitSounds(1)=Sound'PussInBoots.sword_hit2'
	SwordHitSounds(2)=Sound'PussInBoots.sword_hit3'
	SwordHitSounds(3)=Sound'PussInBoots.sword_hit4'
	SwordHitSounds(4)=Sound'PussInBoots.sword_hit5'
	SwordHitSounds(5)=Sound'PussInBoots.sword_hit6'
	SwordHitSounds(6)=Sound'PussInBoots.sword_hit7'
	SwordHitSounds(7)=Sound'PussInBoots.sword_hit8'
	SwordHitSounds(8)=Sound'PussInBoots.sword_hit9'
	SwordRibbonTexName=Texture'ShCharacters.Handsome_blur'
	SwordSkin=Texture'ShCharacters.PIB'
	AttackMoveAhead=50.0
	SHHeroName=PIB
	KnockBackStartAnimName=knockback_start
	KnockBackEndAnimName=knockback_end
	CarryKnockBackStartAnimName=carryknockback_start
	CarryKnockBackEndAnimName=carryknockback_end
	NewRunAttackAnim=runattack
	StartSpecialAttackAnim=punch1
	EndAttackAnim3=punch3end
	StartAirAttackAnim=jump_attack
	LoopAirAttackAnim=jump_attack_loop
	EndAirAttackAnim=jump_attacktoidle
	ContinueAirAttackAnim=jump_attacktopunch1
	StartSupportAttackAnim=cheer_start
	LoopSupportAttackAnim=cheer_loop
	EndSupportAttackAnim=cheer_end
	UpEndFrontAnim=upend_front
	UpEndBackAnim=upend_back
	GetUpFrontAnim=getup_front
	GetUpBackAnim=getup_back
	LookAroundAnims(0)=lookaround1
	LookAroundAnims(1)=lookaround2
	LookAroundAnims(2)=lookaround3
	ThrowOffset=(X=-3.0,Y=-4.0,Z=2.0)
	ThrowRotation=(Roll=24576)
	DrinkOffset=(X=-3.0,Y=-4.0,Z=2.0)
	DrinkRotation=(Roll=24576)
	SwingSounds(0)=Sound'PussInBoots.action_swish1'
	SwingSounds(1)=Sound'PussInBoots.action_swish2'
	SwingSounds(2)=Sound'PussInBoots.action_swish3'
	SwingSounds(3)=Sound'PussInBoots.action_swish4'
	SwingSounds(4)=Sound'PussInBoots.action_swish5'
	SwingSounds(5)=Sound'PussInBoots.action_swish6'
	SwingSounds(6)=Sound'PussInBoots.action_swish7'
	SwingSounds(7)=Sound'PussInBoots.action_swish8'
	SwingSounds(8)=Sound'PussInBoots.action_swish9'
	SwingSounds(9)=Sound'PussInBoots.action_swish10'
	RunAttackSounds(0)=Sound'PussInBoots.action_triple_swish1'
	RunAttackSounds(1)=Sound'PussInBoots.action_triple_swish2'
	RunAttackSounds(2)=Sound'PussInBoots.action_triple_swish3'
	Attack1Sounds(0)=Sound'PussInBoots.action_swish1'
	Attack1Sounds(1)=Sound'PussInBoots.action_swish2'
	Attack1Sounds(2)=Sound'PussInBoots.action_swish3'
	Attack1Sounds(3)=Sound'PussInBoots.action_swish4'
	Attack1Sounds(4)=Sound'PussInBoots.action_swish5'
	Attack1Sounds(5)=Sound'PussInBoots.action_swish6'
	Attack1Sounds(6)=Sound'PussInBoots.action_swish7'
	Attack1Sounds(7)=Sound'PussInBoots.action_swish8'
	Attack1Sounds(8)=Sound'PussInBoots.action_swish9'
	Attack1Sounds(9)=Sound'PussInBoots.action_swish10'
	Attack2Sounds(0)=Sound'PussInBoots.action_swish1'
	Attack2Sounds(1)=Sound'PussInBoots.action_swish2'
	Attack2Sounds(2)=Sound'PussInBoots.action_swish3'
	Attack2Sounds(3)=Sound'PussInBoots.action_swish4'
	Attack2Sounds(4)=Sound'PussInBoots.action_swish5'
	Attack2Sounds(5)=Sound'PussInBoots.action_swish6'
	Attack2Sounds(6)=Sound'PussInBoots.action_swish7'
	Attack2Sounds(7)=Sound'PussInBoots.action_swish8'
	Attack2Sounds(8)=Sound'PussInBoots.action_swish9'
	Attack2Sounds(9)=Sound'PussInBoots.action_swish10'
	Attack3Sounds(0)=Sound'PussInBoots.action_swish1'
	Attack3Sounds(1)=Sound'PussInBoots.action_swish2'
	Attack3Sounds(2)=Sound'PussInBoots.action_swish3'
	Attack3Sounds(3)=Sound'PussInBoots.action_swish4'
	Attack3Sounds(4)=Sound'PussInBoots.action_swish5'
	Attack3Sounds(5)=Sound'PussInBoots.action_swish6'
	Attack3Sounds(6)=Sound'PussInBoots.action_swish7'
	Attack3Sounds(7)=Sound'PussInBoots.action_swish8'
	Attack3Sounds(8)=Sound'PussInBoots.action_swish9'
	Attack3Sounds(9)=Sound'PussInBoots.action_swish10'
	ThrowPotionSound=Sound'PussInBoots.pib_throw_potion'
	DrinkPotionSound=Sound'PussInBoots.pib_drink_potion'
	EmoteSoundJump(0)=Sound'AllDialog.pc_pib_pibemote_50'
	EmoteSoundJump(1)=Sound'AllDialog.pc_pib_pibemote_46'
	EmoteSoundJump(2)=Sound'AllDialog.pc_pib_pibemote_24'
	EmoteSoundJump(3)=Sound'AllDialog.pc_pib_pibemote_22'
	EmoteSoundJump(4)=Sound'AllDialog.pc_pib_pibemote_20'
	EmoteSoundLand(0)=Sound'AllDialog.pc_pib_pibemote_32'
	EmoteSoundLand(1)=Sound'AllDialog.pc_pib_pibemote_28'
	EmoteSoundLand(2)=Sound'AllDialog.pc_pib_pibemote_14'
	EmoteSoundLand(3)=Sound'AllDialog.pc_pib_pibemote_8'
	EmoteSoundLand(4)=Sound'AllDialog.pc_pib_pibemote_84'
	EmoteSoundLand(5)=Sound'AllDialog.pc_pib_pibemote_64'
	EmoteSoundLand(6)=Sound'AllDialog.pc_pib_pibemote_110'
	EmoteSoundLand(7)=Sound'AllDialog.pc_pib_pibemote_86'
	EmoteSoundClimb(0)=Sound'AllDialog.pc_pib_pibemote_6'
	EmoteSoundClimb(1)=Sound'AllDialog.pc_pib_pibemote_4'
	EmoteSoundClimb(2)=Sound'AllDialog.pc_pib_pibemote_82'
	EmoteSoundClimb(3)=Sound'AllDialog.pc_pib_pibemote_68'
	EmoteSoundPain(0)=Sound'AllDialog.pc_pib_pibemote_52'
	EmoteSoundPain(1)=Sound'AllDialog.pc_pib_pibemote_2'
	EmoteSoundPain(2)=Sound'AllDialog.pc_pib_pibemote_58'
	EmoteSoundPain(3)=Sound'AllDialog.pc_pib_pibemote_10'
	EmoteSoundPain(4)=Sound'AllDialog.pc_pib_pibemote_106'
	EmoteSoundPain(5)=Sound'AllDialog.pc_pib_pibemote_100'
	EmoteSoundPain(6)=Sound'AllDialog.pc_pib_pibemote_98'
	EmoteSoundPain(7)=Sound'AllDialog.pc_pib_pibemote_92'
	EmoteSoundPain(8)=Sound'AllDialog.pc_pib_pibemote_88'
	EmoteSoundPain(9)=Sound'AllDialog.pc_pib_pibemote_56'
	EmoteSoundPain(10)=Sound'AllDialog.pc_pib_pibemote_80'
	EmoteSoundPain(11)=Sound'AllDialog.pc_pib_pibemote_70'
	EmoteSoundPain(12)=Sound'AllDialog.pc_pib_pibemote_60'
	EmoteSoundPunch(0)=Sound'AllDialog.pc_pib_pibemote_26'
	EmoteSoundPunch(1)=Sound'AllDialog.pc_pib_pibemote_48'
	EmoteSoundPunch(2)=Sound'AllDialog.pc_pib_pibemote_44'
	EmoteSoundPunch(3)=Sound'AllDialog.pc_pib_pibemote_36'
	EmoteSoundPunch(4)=Sound'AllDialog.pc_pib_pibemote_34'
	EmoteSoundPunch(5)=Sound'AllDialog.pc_pib_pibemote_30'
	EmoteSoundPunch(6)=Sound'AllDialog.pc_pib_pibemote_94'
	EmoteSoundPunch(7)=Sound'AllDialog.pc_pib_pibemote_96'
	EmoteSoundPunch(8)=Sound'AllDialog.pc_pib_pibemote_90'
	EmoteSoundPunch(9)=Sound'AllDialog.pc_pib_pibemote_76'
	EmoteSoundPunch(10)=Sound'AllDialog.pc_pib_pibemote_78'
	EmoteSoundPunch(11)=Sound'AllDialog.pc_pib_pibemote_66'
	EmoteSoundPull(0)=Sound'AllDialog.pc_pib_pibemote_6'
	EmoteSoundPull(1)=Sound'AllDialog.pc_pib_pibemote_4'
	EmoteSoundPull(2)=Sound'AllDialog.pc_pib_pibemote_82'
	EmoteSoundPull(3)=Sound'AllDialog.pc_pib_pibemote_68'
	EmoteSoundShimmy(0)=Sound'AllDialog.pc_pib_pibemote_4'
	EmoteSoundShimmy(1)=Sound'AllDialog.pc_pib_pibemote_6'
	EmoteSoundShimmy(2)=Sound'AllDialog.pc_pib_pibemote_10'
	EmoteSoundShimmy(3)=Sound'AllDialog.pc_pib_pibemote_42'
	EmoteSoundShimmy(4)=Sound'AllDialog.pc_pib_pibemote_68'
	EmoteSoundShimmy(5)=Sound'AllDialog.pc_pib_pibemote_82'
	EmoteSoundShimmy(6)=Sound'AllDialog.pc_pib_pibemote_84'
	EmoteSoundThrow(0)=Sound'AllDialog.pc_pib_pibemote_26'
	EmoteSoundThrow(1)=Sound'AllDialog.pc_pib_pibemote_48'
	EmoteSoundThrow(2)=Sound'AllDialog.pc_pib_pibemote_44'
	EmoteSoundThrow(3)=Sound'AllDialog.pc_pib_pibemote_36'
	EmoteSoundThrow(4)=Sound'AllDialog.pc_pib_pibemote_34'
	EmoteSoundThrow(5)=Sound'AllDialog.pc_pib_pibemote_30'
	EmoteSoundThrow(6)=Sound'AllDialog.pc_pib_pibemote_94'
	EmoteSoundThrow(7)=Sound'AllDialog.pc_pib_pibemote_96'
	EmoteSoundThrow(8)=Sound'AllDialog.pc_pib_pibemote_90'
	EmoteSoundThrow(9)=Sound'AllDialog.pc_pib_pibemote_76'
	EmoteSoundThrow(10)=Sound'AllDialog.pc_pib_pibemote_78'
	EmoteSoundThrow(11)=Sound'AllDialog.pc_pib_pibemote_66'
	EmoteSoundFaint(0)=Sound'AllDialog.pc_pib_pibemote_38'
	EmoteSoundFaint(1)=Sound'AllDialog.pc_pib_pibemote_108'
	EmoteSoundFaint(2)=Sound'AllDialog.pc_pib_pibemote_102'
	EmoteSoundFaint(3)=Sound'AllDialog.pc_pib_pibemote_104'
	EmoteSoundFaint(4)=Sound'AllDialog.pc_pib_pibemote_54'
	EmoteSoundFaint(5)=Sound'AllDialog.pc_pib_pibemote_72'
	EmoteSoundFaint(6)=Sound'AllDialog.pc_pib_pibemote_74'
	EmoteSoundFaint(7)=Sound'AllDialog.pc_pib_pibemote_62'
	EmoteSoundVictory(0)=Sound'AllDialog.pc_pib_pibemote_18'
	EmoteSoundVictory(1)=Sound'AllDialog.pc_pib_pibemote_16'
	SoundShimmy(0)=Sound'PussInBoots.shimmy1'
	SoundShimmy(1)=Sound'PussInBoots.shimmy2'
	SoundShimmy(2)=Sound'PussInBoots.shimmy3'
	SoundShimmy(3)=Sound'PussInBoots.shimmy4'
	SoundPickup(0)=Sound'PussInBoots.pick_up'
	SoundThrow(0)=Sound'PussInBoots.action_swish1'
	SoundThrow(1)=Sound'PussInBoots.action_swish2'
	SoundThrow(2)=Sound'PussInBoots.action_swish3'
	SoundThrow(3)=Sound'PussInBoots.action_swish4'
	SoundThrow(4)=Sound'PussInBoots.action_swish5'
	SoundThrow(5)=Sound'PussInBoots.action_swish6'
	SoundThrow(6)=Sound'PussInBoots.action_swish7'
	SoundThrow(7)=Sound'PussInBoots.action_swish8'
	SoundThrow(8)=Sound'PussInBoots.action_swish9'
	SoundThrow(9)=Sound'PussInBoots.action_swish10'
	DoubleJumpSound(0)=Sound'PussInBoots.action_swish1'
	DoubleJumpSound(1)=Sound'PussInBoots.action_swish2'
	DoubleJumpSound(2)=Sound'PussInBoots.action_swish3'
	DoubleJumpSound(3)=Sound'PussInBoots.action_swish4'
	DoubleJumpSound(4)=Sound'PussInBoots.action_swish5'
	DoubleJumpSound(5)=Sound'PussInBoots.action_swish6'
	DoubleJumpSound(6)=Sound'PussInBoots.action_swish7'
	DoubleJumpSound(7)=Sound'PussInBoots.action_swish8'
	DoubleJumpSound(8)=Sound'PussInBoots.action_swish9'
	DoubleJumpSound(9)=Sound'PussInBoots.action_swish10'
	AttackStartBoneNames(0)=body_swordtip_joint
	AttackStartBoneNames(1)=body_swordtip_joint
	AttackStartBoneNames(2)=body_swordtip_joint
	AttackStartBoneNames(3)=body_swordtip_joint
	AttackEndBoneNames(0)=body_object_joint
	AttackEndBoneNames(1)=body_object_joint
	AttackEndBoneNames(2)=body_object_joint
	AttackEndBoneNames(3)=body_object_joint
	RibbonEmitterName=class'SHGame.Hero_Ribbon'
	TexName=Texture'ShCharacters.Handsome_blur'
	KnockBackDistance=20.0
	SkinsVisible(0)=Shader'ShCharacters.PiB_S'
	SkinsVisible(1)=Shader'ShCharacters.PiBHat_S'
	SkinsInvisible(0)=Texture'ShCharacters.PiB_inv'
	SkinsInvisible(1)=Texture'ShCharacters.PIBHat_inv'
	StrengthEmitterBoneName(0)=body_l_fingersmid_joint
	StrengthEmitterBoneName(1)=body_r_fingersmid_joint
	PotionDrawScale=0.5
	PotionBumpLines(0)=PIB_PibStrength
	PotionBumpLines(1)=PIB_PibFrog
	PotionBumpLines(2)=PIB_PibGhost
	PotionBumpLines(3)=PIB_PibSleep
	PotionBumpLines(4)=PIB_PibStink
	PotionBumpLines(5)=PIB_PibShrinkMe
	PotionBumpLines(6)=PIB_PibShrinkYou
	PotionBumpLines(7)=PIB_PibFreeze
	PotionBumpLines(8)=PIB_PibLove
	WastedPotionBumpLines=PIB_PibWaste
	HurtBumpLines=PIB_PibHurt
	HitBumpLines=PIB_PibHit
	SimmyBumpLines=PIB_ShimmyPib
	PickupEnergyBarBumpLines=PIB_PibHero
	PickupShamrockBumpLines=PIB_PibClover
	LowCoinsBumpLines=PIB_PibCoinLow
	ManyCoinsBumpLines=PIB_PibCoin
	TiredBumpLines=PIB_PibLowHealth
	AttackDist=45.0
	AttackHeight=30.0
	AttackAngle=45.0
	WadeAnims(0)=run
	WadeAnims(1)=runbackward
	WadeAnims(2)=StrafeLeft
	WadeAnims(3)=StrafeRight
	AttackInfo(0)=(AnimName=punch1,StartBoneName=body_object_joint,EndBoneName=body_swordtip_joint,StartFrame=1.0,EndFrame=10.0)
	AttackInfo(1)=(AnimName=punch2,StartBoneName=body_object_joint,EndBoneName=body_swordtip_joint,StartFrame=1.0,EndFrame=19.0)
	AttackInfo(2)=(AnimName=punch3,StartBoneName=body_object_joint,EndBoneName=body_swordtip_joint,StartFrame=1.0,EndFrame=21.0)
	AttackInfo(3)=(AnimName=runattack,StartBoneName=body_object_joint,EndBoneName=body_swordtip_joint,StartFrame=3.0,EndFrame=22.0)
	AttackInfo(4)=(AnimName=runattack,StartBoneName=body_r_wrist_joint,EndBoneName=body_object_joint,StartFrame=3.0,EndFrame=22.0)
	AttackInfo(5)=(AnimName=runattack,StartBoneName=body_r_elbow_joint,EndBoneName=body_r_wrist_joint,StartFrame=3.0,EndFrame=22.0)
	PunchEmitterClass=class'SHGame.Punch_PIB'
	AttackDistFromEnemy=30.0
	CameraSetStandard=(vLookAtOffset=(X=-25.0,Y=0.0,Z=45.0),fLookAtDistance=100.0,fLookAtHeight=35.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CameraSnapRotationPitch=-2500.0
	DoubleJumpAnims(1)=doublejumpback
	CarryTurnRightAnim=carryturnright
	CarryTurnLeftAnim=carryturnleft
	CompanionWalkAnim=BiPedWalk
	bCouldNotWalkAsCompanion=True
	BigClimbStartNoTrans=jumptoclimb2
	BigClimbEndNoTrans=climb2
	BigClimbStartOffset=92.0
	BigClimbOffset=48.0
	BigShimmyOffset=50.0
	StepUpOffset=30.0
	HangIdleNoTransAnim=hangidle2
	JumpToHangNoTransAnim=jumptohang2
	ShimmyRightNoTransAnim=shimmyright2
	ShimmyLeftNoTransAnim=shimmyleft2
	ShimmyRightEndNoTransAnim=shimmyrightend2
	ShimmyLeftEndNoTransAnim=shimmyleftend2
	IdleTiredAnimName=tiredidle
	RunAnimName=run
	WalkAnimName=Walk
	PickupAnimName=Pickup
	ThrowAnimName=throw
	KnockBackAnimName=knockback
	PickupBoneName=body_object_joint
	GroundRunSpeed=375.0
	GroundCarrySpeed=300.0
	fDoubleJumpAnimRate=1.2
	NeckRotElement=RE_RollNeg
	JumpSounds(0)=Sound'PussInBoots.action_swish1'
	JumpSounds(1)=Sound'PussInBoots.action_swish2'
	JumpSounds(2)=Sound'PussInBoots.action_swish3'
	JumpSounds(3)=Sound'PussInBoots.action_swish4'
	JumpSounds(4)=Sound'PussInBoots.action_swish5'
	JumpSounds(5)=Sound'PussInBoots.action_swish6'
	JumpSounds(6)=Sound'PussInBoots.action_swish7'
	JumpSounds(7)=Sound'PussInBoots.action_swish8'
	JumpSounds(8)=Sound'PussInBoots.action_swish9'
	JumpSounds(9)=Sound'PussInBoots.action_swish10'
	LandingStone(0)=Sound'Footsteps.F_PIB_stone1'
	LandingWood(0)=Sound'Footsteps.F_PIB_wood1'
	LandingWet(0)=Sound'Footsteps.F_PIB_wet1'
	LandingDirt(0)=Sound'Footsteps.F_PIB_dirt1'
	LandingNone(0)=Sound'Footsteps.F_PIB_default1'
	FootstepsStone(0)=Sound'Footsteps.F_PIB_stone1'
	FootstepsStone(1)=Sound'Footsteps.F_PIB_stone2'
	FootstepsStone(2)=Sound'Footsteps.F_PIB_stone3'
	FootstepsStone(3)=Sound'Footsteps.F_PIB_stone4'
	FootstepsStone(4)=Sound'Footsteps.F_PIB_stone5'
	FootstepsStone(5)=Sound'Footsteps.F_PIB_stone6'
	FootstepsWood(0)=Sound'Footsteps.F_PIB_wood1'
	FootstepsWood(1)=Sound'Footsteps.F_PIB_wood2'
	FootstepsWood(2)=Sound'Footsteps.F_PIB_wood3'
	FootstepsWood(3)=Sound'Footsteps.F_PIB_wood4'
	FootstepsWood(4)=Sound'Footsteps.F_PIB_wood5'
	FootstepsWood(5)=Sound'Footsteps.F_PIB_wood6'
	FootstepsWet(0)=Sound'Footsteps.F_PIB_wet1'
	FootstepsWet(1)=Sound'Footsteps.F_PIB_wet2'
	FootstepsWet(2)=Sound'Footsteps.F_PIB_wet3'
	FootstepsWet(3)=Sound'Footsteps.F_PIB_wet4'
	FootstepsWet(4)=Sound'Footsteps.F_PIB_wet5'
	FootstepsWet(5)=Sound'Footsteps.F_PIB_wet6'
	FootstepsDirt(0)=Sound'Footsteps.F_PIB_dirt1'
	FootstepsDirt(1)=Sound'Footsteps.F_PIB_dirt2'
	FootstepsDirt(2)=Sound'Footsteps.F_PIB_dirt3'
	FootstepsDirt(3)=Sound'Footsteps.F_PIB_dirt4'
	FootstepsDirt(4)=Sound'Footsteps.F_PIB_dirt5'
	FootstepsDirt(5)=Sound'Footsteps.F_PIB_dirt6'
	FootstepsNone(0)=Sound'Footsteps.F_PIB_default1'
	FootstepsNone(1)=Sound'Footsteps.F_PIB_default2'
	FootstepsNone(2)=Sound'Footsteps.F_PIB_default3'
	FootstepsNone(3)=Sound'Footsteps.F_PIB_default4'
	FootstepsNone(4)=Sound'Footsteps.F_PIB_default5'
	FootstepsNone(5)=Sound'Footsteps.F_PIB_default6'
	FootFramesWalk(0)=7
	FootFramesWalk(1)=23
	FootFramesWalk(2)=40
	FootFramesWalk(3)=57
	FootFramesRun(0)=4
	FootFramesRun(1)=18
	FootFramesRun(2)=30
	FootFramesRun(3)=44
	bUseNewMountCode=True
	IdleAnims(0)=bored1
	IdleAnims(1)=bored1
	IdleAnims(2)=bored1
	IdleAnims(3)=bored1
	IdleAnims(4)=bored2
	IdleAnims(5)=bored2
	IdleAnims(6)=bored2
	IdleAnims(7)=bored2
	fDoubleJumpHeight=72.0
	fJumpHeight=48.0
	ShimmySpeed=50.0
	bIsMainPlayer=True
	bCanClimbLadders=True
	ControllerClass=class'SHGame.SHCompanionController'
	BaseMovementRate=300.0
	_BaseMovementRate=300.0
	MouthBone=body_jaw_joint
	Mesh=SkeletalMesh'ShrekCharacters.PIB'
	CollisionRadius=10.0
	CollisionHeight=19.0
	Label="PIB"
}