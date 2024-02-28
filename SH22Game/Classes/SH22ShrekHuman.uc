// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22ShrekHuman extends SH22HeroPawn
	Config(SH22);


var ShrekSword Sword;
var string PrevCreature;
var() name QuickThrowStartAnimName, QuickThrowLoopAnimName, QuickThrowEndAnimName, QuickThrowBoneName;
var bool bQuickThrowWasSpawn;
var int iFoodThrowInARow;
var(BossFGM) float ThrowTime, ThrowFoodTime, ThrowAccuracy, ThrowFoodAccuracy, ThrowProtection, LiveAsCreature;
var(BossFGM) KWGame.Range FoodThrowInARow;
var() Material SwordSkin;
var StaticMesh OriginalSwordStaticMesh, PowerfulSwordStaticMesh;


function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Sword = Spawn(class'ShrekSword');
	Sword.AttachWeaponToKWPawn(self);
	Sword.bIsOut = true;
	SHWeap = Sword;
}

function AddAnimNotifys()
{
	local MeshAnimation MeshAnim;

	super.AddAnimNotifys();
	
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddNotify(MeshAnim, LandAnims[0], 20.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, LandAnims[1], 8.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, EndAirAttackAnim, 20.0, 'AnimNotifyBlendOutEndAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 15.0, 'AnimNotifyBlendOutContinueAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, EndAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, PickupAnimName, 14.0, 'AnimNotifyObjectPickup');
	AddNotify(MeshAnim, PickupAnimName, 6.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, ThrowAnimName, 16.0, 'PlayerThrowCarryingActor');
	AddNotify(MeshAnim, ThrowAnimName, 25.0, 'AnimNotifySwordIsOut');
	AddNotify(MeshAnim, StartAttackAnim1, 5.0, 'CreateRibbonEmittersForAttack1');
	AddNotify(MeshAnim, StartAttackAnim2, 2.0, 'CreateRibbonEmittersForAttack2');
	AddNotify(MeshAnim, StartAttackAnim3, 7.0, 'CreateRibbonEmittersForAttack3');
	AddNotify(MeshAnim, StartAttackAnim1, 13.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, StartAttackAnim2, 10.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, StartAttackAnim3, 15.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, JumpToHangNoTransAnim, 17.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, BigClimbStartNoTrans, 4.0, 'AnimNotifySwordIsIn');
	AddNotify(MeshAnim, BigClimbEndNoTrans, 64.0, 'AnimNotifySwordIsOut');
	AddNotify(MeshAnim, NewRunAttackAnim, 1.0, 'CreateRibbonEmittersForRunAttack');
	AddNotify(MeshAnim, NewRunAttackAnim, 8.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, NewRunAttackAnim, 11.0, 'CreateRibbonEmittersForRunAttack');
	AddNotify(MeshAnim, NewRunAttackAnim, 23.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, ThrowPotionAnimName, 17.0, 'ThrowPotion');
	AddNotify(MeshAnim, DrinkPotionAnimName, 56.0, 'DrinkPotion');
	AddNotify(MeshAnim, ThrowPotionAnimName, 15.0, 'PlayThrowPotionSound');
	AddNotify(MeshAnim, DrinkPotionAnimName, 16.0, 'PlayDrinkPotionSound');
	AddFootStepsNotify(MeshAnim);
}

event AnimNotifySwordIsOut()
{
	Sword.WeaponAttachBone = Sword.default.WeaponAttachBone;
	Sword.WeaponAttachOffset = Sword.default.WeaponAttachOffset;
	Sword.WeaponAttachRotation = Sword.default.WeaponAttachRotation;
	Sword.AttachWeaponToKWPawn(self);
	Sword.bIsOut = true;
}

event AnimNotifySwordIsIn()
{
	Sword.WeaponAttachBone = Sword.SecondaryWeaponAttachBone;
	Sword.WeaponAttachOffset = Sword.SecondaryWeaponAttachOffset;
	Sword.WeaponAttachRotation = Sword.SecondaryWeaponAttachRotation;
	Sword.AttachWeaponToKWPawn(self);
	Sword.bIsOut = false;
}

function Tick(float DeltaTime)
{
	local name animseq;
	
	super.Tick(DeltaTime);
	
	if(Sword != none)
	{
		if(!Sword.bIsOut)
		{
			if(Controller.IsA('KWCutController') || IsInState('MountHanging'))
			{
				return;
			}
			
			animseq = GetAnimSequence(0);
			
			if(animseq == BigClimbStartNoTrans || animseq == BigClimbEndNoTrans || animseq == JumpToHangNoTransAnim)
			{
				return;
			}
			
			animseq = GetAnimSequence(12);
			
			if(animseq == PickupAnimName || animseq == ThrowAnimName)
			{
				return;
			}
			
			AnimNotifySwordIsOut();
		}
	}
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

function bool IsProtected(Actor Enemy)
{
	local name animseq;
	local rotator R, er;
	local vector V, ev;
	local float cosA;
	
	if(FRand() > ThrowProtection)
	{
		return false;
	}
	
	ev = Enemy.Velocity;
	R = Rotation;
	R.Pitch = 0;
	R.Roll = 0;
	er = rotator(ev);
	er.Pitch = 0;
	er.Roll = 0;
	V = vector(R);
	ev = vector(er);
	cosA = V Dot ev;
	
	if(cosA > -0.85)
	{
		return false;
	}
	
	animseq = GetAnimSequence(ATTACKCHANNEL_UPPER);
	
	if(animseq == StartAttackAnim1 || animseq == StartAttackAnim2 || animseq == StartAttackAnim3)
	{
		return true;
	}
	
	return false;
}

function bool InFrontOfFGM(Actor fgm)
{
	local float cosA;
	local vector v1, v2;
	local rotator r1, r2;
	
	r1 = Rotation;
	r1.Pitch = 0;
	r1.Roll = 0;
	v1 = vector(r1);
	v2 = fgm.Location - Location;
	r2 = rotator(v2);
	r2.Pitch = 0;
	r2.Roll = 0;
	v2 = vector(r2);
	cosA = v2 Dot v1;
	
	if(cosA < 0.85)
	{
		return false;
	}
	
	return true;
}

function bool FGMTableClosest(Actor fgm)
{
	local FGM_Table table;
	local FGM_TableRound tableround;
	local Actor tableClosest;
	local float dist, DistMin, cosA, cosB;
	local vector v1, v2, v3;
	local rotator r1, r2, r3;

	DistMin = 1000000.0;
	
	foreach AllActors(class'FGM_Table', table)
	{
		r1 = Rotation;
		r1.Pitch = 0;
		r1.Roll = 0;
		r2 = table.Rotation;
		r2.Pitch = 0;
		r2.Roll = 0;
		v1 = vector(r1);
		v2 = vector(r2);
		v3 = fgm.Location - Location;
		r3 = rotator(v3);
		r3.Pitch = 0;
		r3.Roll = 0;
		v3 = vector(r3);
		cosB = v3 Dot v1;
		
		if(cosB < 0.85)
		{
			continue;
		}
		
		r1 = Rotation;
		r1.Pitch = 0;
		r1.Roll = 0;
		r2 = table.Rotation;
		r2.Pitch = 0;
		r2.Roll = 0;
		v1 = vector(r1);
		v2 = vector(r2);
		cosA = v1 Dot v2;
		
		if(cosA > 0.5 || cosA < -0.5)
		{
			continue;
		}
		
		dist = VSize2d(table.Location - Location);
		
		if(dist > 20.0 + table.CollisionRadius + CollisionRadius || table.Location.Z - table.CollisionHeight > Location.Z || table.Location.Z + table.CollisionHeight < Location.Z - CollisionHeight)
		{
			continue;
		}
		
		if(dist < DistMin)
		{
			DistMin = dist;
			tableClosest = table;
		}
	}
	
	if(tableClosest != none)
	{
		return true;
	}
	
	DistMin = 1000000.0;
	
	foreach AllActors(class'FGM_TableRound', tableround)
	{
		r1 = Rotation;
		r1.Pitch = 0;
		r1.Roll = 0;
		v1 = vector(r1);
		v3 = fgm.Location - Location;
		r3 = rotator(v3);
		r3.Pitch = 0;
		r3.Roll = 0;
		v3 = vector(r3);
		cosB = v3 Dot v1;
		
		if(cosB < 0.85)
		{
			continue;
		}
		
		v2 = tableround.Location - Location;
		r2 = rotator(v2);
		r2.Pitch = 0;
		r2.Roll = 0;
		v2 = vector(r2);
		cosA = v1 Dot v2;
		
		if(cosA < -0.5)
		{
			continue;
		}
		
		dist = VSize2d(tableround.Location - Location);
		
		if(dist > 20.0 + tableround.CollisionRadius + CollisionRadius || tableround.Location.Z - tableround.CollisionHeight > Location.Z || tableround.Location.Z + tableround.CollisionHeight < Location.Z - CollisionHeight)
		{
			continue;
		}
		
		if(dist < DistMin)
		{
			DistMin = dist;
			tableClosest = tableround;
		}
	}
	
	if(tableClosest != none)
	{
		return true;
	}
	
	return false;
}

function bool StartQuickThrow()
{
	if(aBoss == none || !aBoss.IsA('BossFGM') || !aBoss.IsInState('stateDizzy') || !BossFGM(aBoss).bDizzyFromSpell || !Controller.IsInState('PlayerWalking') || IsInState('statePickupItem') || IsInState('StateCarryItem') || IsInState('stateThrowItem') || IsAttacking() || Physics == PHYS_Falling || IsInState('stateQuickThrowStart') || !FGMTableClosest(aBoss))
	{
		return false;
	}
	
	return true;
}

function SpawnQuickThrowActor()
{
	local Actor QuickThrowActor;
	
	switch(Rand(3))
	{
		case 0:
			QuickThrowActor = Spawn(class'FoodThrowA');
			
			break;
		case 1:
			QuickThrowActor = Spawn(class'FoodThrowB');
			
			break;
		case 2:
			QuickThrowActor = Spawn(class'FoodThrowC');
			
			break;
		default:
			break;
	}
	
	if(QuickThrowActor != none)
	{
		AttachToBone(QuickThrowActor, QuickThrowBoneName);
		QuickThrowActor.SetOwner(self);
		QuickThrowActor.SetCollision(true, true, true);
		QuickThrowActor.bUnlit = true;
		bQuickThrowWasSpawn = true;
		iFoodThrowInARow--;
	}
}

function JumpFromShimmy()
{
	if(Sword.bIsOut)
	{
		return;
	}
	
	AnimNotifySwordIsOut();
}

function SetVisibleTextures()
{
	super.SetVisibleTextures();
	
	Sword.SetOpacity(1.0);
	Sword.Skins[0] = SwordSkin;
}

function SetInvisibleTextures()
{
	super.SetInvisibleTextures();
	
	Sword.SetOpacity(InvisibilityPercent);
}

function ShowStrengthAttributes()
{
	super.ShowStrengthAttributes();
	
	PC = U.GetPC();
	
	if(SHHeroController(PC).HumanFirstStrengthPotion == 0)
	{
		SHHeroController(PC).HumanFirstStrengthPotion = 1;
		SHHeroController(PC).SaveConfig();
		TriggerEvent('HumanStrengthPotion', none, none);
	}
	
	Sword.SetStaticMesh(PowerfulSwordStaticMesh);
}

function HideStrengthAttributes()
{
	super.HideStrengthAttributes();
	
	Sword.SetStaticMesh(OriginalSwordStaticMesh);
}

function vector GetRunAttackEmitterLocation()
{
	local vector rloc, lloc, Loc;
	
	rloc = GetBoneCoords('body_r_ball_joint').Origin;
	lloc = GetBoneCoords('body_l_ball_joint').Origin;
	Loc = (rloc + lloc) / 2.0;
	
	return Loc;
}

state stateQuickThrowStart
{
	event Tick(float DeltaTime)
	{
		local name animseq;
		local float AnimFrame;
		
		global.Tick(DeltaTime);
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		animseq = GetAnimSequence(0);
		
		if(animseq != QuickThrowStartAnimName && animseq != QuickThrowLoopAnimName)
		{
			GotoState('StateIdle');
		}
		
		AnimFrame = GetAnimFrame(0);
		
		if(AnimFrame > 5.0 && !bQuickThrowWasSpawn)
		{
			SpawnQuickThrowActor();
		}
		
		if(!InFrontOfFGM(aBoss))
		{
			GotoState('stateQuickThrowEnd');
		}
	}

	event BeginState()
	{
		PlayAnim(QuickThrowStartAnimName);
		bQuickThrowWasSpawn = false;
		iFoodThrowInARow = U.RandRangeInt(FoodThrowInARow.Min, FoodThrowInARow.Max);
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == 0)
		{
			animseq = GetAnimSequence(0);
			
			if(animseq == QuickThrowStartAnimName || animseq == QuickThrowLoopAnimName)
			{
				if(bPressDuringQuickThrow && iFoodThrowInARow > 0)
				{
					PlayAnim(QuickThrowLoopAnimName);
					bQuickThrowWasSpawn = false;
					bPressDuringQuickThrow = false;
				}
				else
				{
					GotoState('stateQuickThrowEnd');
				}
			}
		}
	}
}

state stateQuickThrowEnd
{
	event Tick(float DeltaTime)
	{
		local name animseq;

		global.Tick(DeltaTime);
		
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		animseq = GetAnimSequence(0);
		
		if(animseq != QuickThrowEndAnimName)
		{
			GotoState('StateIdle');
		}
	}

	event BeginState()
	{
		PlayAnim(QuickThrowEndAnimName);
	}
	
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel == 0)
		{
			animseq = GetAnimSequence(0);
			
			if(animseq == QuickThrowEndAnimName)
			{
				GotoState('StateIdle');
			}
		}
	}
}


defaultproperties
{
	QuickThrowStartAnimName=quickthrowstart
	QuickThrowLoopAnimName=quickthrowloop
	QuickThrowEndAnimName=QuickThrowIdle
	QuickThrowBoneName=body_l_wrist_joint
	ThrowTime=0.7
	ThrowFoodTime=0.7
	ThrowAccuracy=1.0
	ThrowFoodAccuracy=1.0
	ThrowProtection=1.0
	LiveAsCreature=30.0
	FoodThrowInARow=(Min=5,Max=9)
	SwordSkin=Texture'Character_Props_tx.handsome_tx'
	OriginalSwordStaticMesh=StaticMesh'Character_Props.handsome_sword'
	PowerfulSwordStaticMesh=StaticMesh'Character_Props.hs_slapper'
	NewTag=ShrekHuman
	AttackMoveAhead=70.0
	fxSwingingDeathClass=class'Handsome_plow'
	SHHeroName=ShrekHuman
	NewRunAttackAnim=runattack
	EndAttackAnim3=punch3end
	ThrowPotionBoneName=body_l_wrist_joint
	DrinkPotionBoneName=body_l_wrist_joint
	ThrowOffset=(X=-3,Y=6,Z=2)
	ThrowRotation=(Pitch=0,Yaw=8192,Roll=-16384)
	DrinkOffset=(X=-3,Y=6,Z=2)
	DrinkRotation=(Pitch=0,Yaw=8192,Roll=-16384)
	SwingSounds(0)=Sound'Peasants.action_swoosh01'
	SwingSounds(1)=Sound'Peasants.action_swoosh02'
	SwingSounds(2)=Sound'Peasants.action_swoosh03'
	SwingSounds(3)=Sound'Peasants.action_swoosh04'
	SwingSounds(4)=Sound'Peasants.action_swoosh05'
	SwingSounds(5)=Sound'Peasants.action_swoosh06'
	SwingSounds(6)=Sound'Peasants.action_swoosh07'
	SwingSounds(7)=Sound'Peasants.action_swoosh08'
	SwingSounds(8)=Sound'Peasants.action_swoosh09'
	SwingSounds(9)=Sound'Peasants.action_swoosh10'
	SwingSounds(10)=Sound'Peasants.action_swoosh11'
	SwingSounds(11)=Sound'Peasants.action_swoosh12'
	Attack1Sounds(0)=Sound'Knights.sword_hit01'
	Attack1Sounds(1)=Sound'Knights.sword_hit02'
	Attack1Sounds(2)=Sound'Knights.sword_hit03'
	Attack1Sounds(3)=Sound'Knights.sword_hit04'
	Attack1Sounds(4)=Sound'Knights.sword_hit05'
	Attack1Sounds(5)=Sound'Knights.sword_hit06'
	Attack1Sounds(6)=Sound'Knights.sword_hit07'
	Attack1Sounds(7)=Sound'Knights.sword_hit08'
	Attack1Sounds(8)=Sound'Knights.sword_hit09'
	Attack1Sounds(9)=Sound'Knights.sword_hit10'
	Attack1Sounds(10)=Sound'Knights.sword_hit11'
	Attack2Sounds(0)=Sound'Knights.sword_hit01'
	Attack2Sounds(1)=Sound'Knights.sword_hit02'
	Attack2Sounds(2)=Sound'Knights.sword_hit03'
	Attack2Sounds(3)=Sound'Knights.sword_hit04'
	Attack2Sounds(4)=Sound'Knights.sword_hit05'
	Attack2Sounds(5)=Sound'Knights.sword_hit06'
	Attack2Sounds(6)=Sound'Knights.sword_hit07'
	Attack2Sounds(7)=Sound'Knights.sword_hit08'
	Attack2Sounds(8)=Sound'Knights.sword_hit09'
	Attack2Sounds(9)=Sound'Knights.sword_hit10'
	Attack2Sounds(10)=Sound'Knights.sword_hit11'
	Attack3Sounds(0)=Sound'Knights.sword_hit01'
	Attack3Sounds(1)=Sound'Knights.sword_hit02'
	Attack3Sounds(2)=Sound'Knights.sword_hit03'
	Attack3Sounds(3)=Sound'Knights.sword_hit04'
	Attack3Sounds(4)=Sound'Knights.sword_hit05'
	Attack3Sounds(5)=Sound'Knights.sword_hit06'
	Attack3Sounds(6)=Sound'Knights.sword_hit07'
	Attack3Sounds(7)=Sound'Knights.sword_hit08'
	Attack3Sounds(8)=Sound'Knights.sword_hit09'
	Attack3Sounds(9)=Sound'Knights.sword_hit10'
	Attack3Sounds(10)=Sound'Knights.sword_hit11'
	DyingSound=Sound'Shrek.faint'
	ThrowPotionSound=Sound'Shrek.HS_throw_potion'
	DrinkPotionSound=Sound'Shrek.HS_drink_potion'
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
	AttackStartBoneNames[0]=body_swordribbon_joint
	AttackStartBoneNames[1]=body_swordribbon_joint
	AttackStartBoneNames[2]=body_swordribbon_joint
	AttackStartBoneNames[3]=body_swordribbon_joint
	AttackEndBoneNames[0]=body_swordhand_joint
	AttackEndBoneNames[1]=body_swordhand_joint
	AttackEndBoneNames[2]=body_swordhand_joint
	AttackEndBoneNames[3]=body_swordhand_joint
	RibbonEmitterName=class'Hero_Ribbon'
	TexName=Texture'ShCharacters.Handsome_blur'
	PowerfulTexName=Texture'ShCharacters.Handsome_strength_blur'
	KnockBackDistance=30.0
	SkinsVisible(0)=Texture'ShCharacters.handsome_tx'
	SkinsInvisible(0)=Texture'ShCharacters.handsome_inv'
	StrengthEmitterBoneName(0)=body_swordribbon_joint
	RunAttackEmitterName=class'Shrek_Slide'
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
	HurtBumpLines=SHK_HandsomeHurt
	HitBumpLines=SHK_HandsomeHit
	SimmyBumpLines=SHK_Shimmy
	PickupEnergyBarBumpLines=SHK_ShrekHero
	PickupShamrockBumpLines=SHK_ShrekClover
	LowCoinsBumpLines=SHK_ShrekCoinLow
	ManyCoinsBumpLines=SHK_ShrekCoin
	TiredBumpLines=SHK_ShrekLowHealth
	FootstepsWade(0)=Sound'Footsteps.F_shrek_wading01'
	FootstepsWade(1)=Sound'Footsteps.F_shrek_wading02'
	FootstepsWade(2)=Sound'Footsteps.F_shrek_wading03'
	FootstepsWade(3)=Sound'Footsteps.F_shrek_wading04'
	FootstepsWade(4)=Sound'Footsteps.F_shrek_wading05'
	FootstepsWade(5)=Sound'Footsteps.F_shrek_wading06'
	AttackDist=60.0
	AttackHeight=60.0
	AttackAngle=60.0
	WadeAnims[0]=Walk
	WadeAnims[1]=walkbackwards
	WadeAnims[2]=walkleft
	WadeAnims[3]=walkright
	AttackInfo(0)=(AnimName=punch1,StartBoneName=body_swordhand_joint,EndBoneName=body_swordribbon_joint,StartFrame=6.0,EndFrame=12.0)
	AttackInfo(1)=(AnimName=punch2,StartBoneName=body_swordhand_joint,EndBoneName=body_swordribbon_joint,StartFrame=3.0,EndFrame=7.0)
	AttackInfo(2)=(AnimName=punch3,StartBoneName=body_swordhand_joint,EndBoneName=body_swordribbon_joint,StartFrame=8.0,EndFrame=12.0)
	AttackInfo(3)=(AnimName=punch3,StartBoneName=body_swordhand_joint,EndBoneName=body_swordribbon_joint,StartFrame=1.0,EndFrame=24.0)
	AttackInfo(4)=(AnimName=runattack,StartBoneName=body_swordhand_joint,EndBoneName=body_swordribbon_joint,StartFrame=1.0,EndFrame=24.0)
	PunchEmitterClass=class'Punch_Shrek'
	AttackDistFromEnemy=40
	CameraSetStandard=(vLookAtOffset=(X=-15.0,Y=0.0,Z=65.0),fLookAtDistance=170.0,fLookAtHeight=30.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CameraSnapRotationPitch=-3500.0
	WalkAnims[1]=walkbackwards
	LandAnims[0]=jumptostand
	LandAnims[1]=jumptorun
	BigClimbStartNoTrans=jumptoclimb2
	BigClimbEndNoTrans=climb2
	BigClimbStartOffset=155.0
	BigClimbOffset=110.0
	BigShimmyOffset=105.0
	HangIdleNoTransAnim=hangidle2
	JumpToHangNoTransAnim=jumptohang2
	ShimmyRightNoTransAnim=shimmyright2
	ShimmyLeftNoTransAnim=shimmyleft2
	ShimmyRightEndNoTransAnim=shimmyrightend2
	ShimmyLeftEndNoTransAnim=shimmyleftend2
	IdleTiredAnimName=tired_idle
	PickupAnimName=Pickup
	ThrowAnimName=throw
	KnockBackAnimName=knockback
	PickupBoneName=body_object_joint
	NeckRotElement=RE_RollNeg
	HeadRotElement=RE_YawNeg
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
	FootFramesWalk(0)=4
	FootFramesWalk(1)=19
	FootFramesWalk(2)=33
	FootFramesWalk(3)=49
	FootFramesRun(0)=5
	FootFramesRun(1)=20
	FootFramesRun(2)=35
	FootFramesRun(3)=50
	bUseNewMountCode=true
	IdleAnims(0)=bored1
	IdleAnims(1)=bored1
	IdleAnims(2)=bored1
	IdleAnims(3)=bored1
	IdleAnims(4)=bored2
	IdleAnims(5)=bored2
	IdleAnims(6)=bored2
	IdleAnims(7)=bored2
	bIsMainPlayer=true
	ControllerClass=class'SHCompanionController'
	TurnLeftAnim=TurnLeft
	TurnRightAnim=TurnRight
	Mesh=SkeletalMesh'ShrekCharacters.humanshrek'
	CollisionRadius=15.0
	CollisionHeight=38.0
	Label="ShrekHuman"
}