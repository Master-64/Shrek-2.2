// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Steed extends SH22HeroPawn
	Config(SH22);


var SteedHelmet SHelmet;
var() Sound SteedFaintSound, SteedFaintDropSound;


function PostBeginPlay()
{
	super.PostBeginPlay();
	
	SHelmet = Spawn(class'SteedHelmet');
	SHelmet.AttachWeaponToKWPawn(self);
	SHelmet.bHidden = true;
}

function CreateRibbonEmittersForAttack3()
{
	CreateRibbonEmitters(2);
}

function AddAnimNotifys()
{
	local MeshAnimation MeshAnim;

	super.AddAnimNotifys();
	
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddNotify(MeshAnim, LandAnims[0], 25.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, LandAnims[1], 10.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, EndAirAttackAnim, 35.0, 'AnimNotifyBlendOutEndAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 25.0, 'AnimNotifyBlendOutContinueAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, EndAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, PickupAnimName, 13.0, 'AnimNotifyObjectPickup');
	AddNotify(MeshAnim, ThrowAnimName, 20.0, 'PlayerThrowCarryingActor');
	AddNotify(MeshAnim, ThrowPotionAnimName, 18.0, 'ThrowPotion');
	AddNotify(MeshAnim, DrinkPotionAnimName, 65.0, 'DrinkPotion');
	AddNotify(MeshAnim, ThrowPotionAnimName, 13.0, 'PlayThrowPotionSound');
	AddNotify(MeshAnim, DrinkPotionAnimName, 18.0, 'PlayDrinkPotionSound');
	AddNotify(MeshAnim, StartAttackAnim3, 2.0, 'CreateRibbonEmittersForAttack3');
	AddNotify(MeshAnim, StartAttackAnim3, 26.0, 'DestroyRibbonEmitters');
	AddNotify(MeshAnim, PlayerDyingAnim, 25.0, 'PlaySteedFaintSound');
	AddNotify(MeshAnim, PlayerDyingAnim, 53.0, 'PlaySteedFaintDropSound');
	AddFootStepsNotify(MeshAnim);
}

function PlaySteedFaintSound()
{
	PlayOwnedSound(SteedFaintSound, SLOT_None, 1.0, true, 1000.0, 1.0);
}

function PlaySteedFaintDropSound()
{
	PlayOwnedSound(SteedFaintDropSound, SLOT_None, 1.0, true, 1000.0, 1.0);
}

function ShowStrengthAttributes()
{
	super.ShowStrengthAttributes();
	
	PC = U.GetPC();
	
	if(SHHeroController(PC).SteedFirstStrengthPotion == 0)
	{
		SHHeroController(PC).SteedFirstStrengthPotion = 1;
		SHHeroController(PC).SaveConfig();
		TriggerEvent('SteedStrengthPotion', none, none);
	}
	
	SHelmet.bHidden = false;
}

function HideStrengthAttributes()
{
	super.HideStrengthAttributes();
	
	SHelmet.bHidden = true;
}


defaultproperties
{
	SteedFaintSound=Sound'Steed.faint'
	SteedFaintDropSound=Sound'Steed.faint_drop'
	NewTag=Donkey
	AttackMoveAhead=100.0
	fxSwingingDeathClass=class'SHGame.Steed_plow'
	SHHeroName=Steed
	NewRunAttackAnim=runattack
	StartSpecialAttackAnim=punch1
	EndAttackAnim1=punchtoidle
	EndAttackAnim2=punchtoidle
	PreStartAttackAnim1=None
	LookAroundAnims(0)=lookaround1
	LookAroundAnims(1)=lookaround2
	LookAroundAnims(2)=lookaround3
	ThrowPotionBoneName=body_object_joint
	DrinkPotionBoneName=body_object_joint
	ThrowRotation=(Roll=-16384)
	DrinkRotation=(Roll=-16384)
	SwingSounds(0)=Sound'Steed.ambience.swoosh_01'
	SwingSounds(1)=Sound'Steed.ambience.swoosh_02'
	RunAttackSounds(0)=Sound'Steed.ambience.whinny_01'
	RunAttackSounds(1)=Sound'Steed.ambience.whinny_02'
	RunAttackSounds(2)=Sound'Steed.ambience.whinny_03'
	RunAttackSounds(3)=Sound'Steed.ambience.whinny_04'
	RunAttackSounds(4)=Sound'Steed.ambience.whinny_05'
	RunAttackSounds(5)=Sound'Steed.ambience.whinny_06'
	Attack1Sounds(0)=Sound'Donkey.punch01'
	Attack2Sounds(0)=Sound'Donkey.punch02'
	Attack3Sounds(0)=Sound'Donkey.punch03'
	ThrowPotionSound=Sound'Donkey.steed_throw_potion'
	DrinkPotionSound=Sound'Donkey.steed_drink_potion'
	EmoteSoundJump(0)=Sound'AllDialog.pc_dnk_donkeymote_30'
	EmoteSoundJump(1)=Sound'AllDialog.pc_dnk_donkeymote_38'
	EmoteSoundJump(2)=Sound'AllDialog.pc_dnk_donkeymote_20'
	EmoteSoundJump(3)=Sound'AllDialog.pc_dnk_donkeymote_22'
	EmoteSoundJump(4)=Sound'AllDialog.pc_dnk_donkeymote_10'
	EmoteSoundJump(5)=Sound'AllDialog.pc_dnk_donkeymote_102'
	EmoteSoundJump(6)=Sound'AllDialog.pc_dnk_donkeymote_104'
	EmoteSoundJump(7)=Sound'AllDialog.pc_dnk_donkeymote_92'
	EmoteSoundJump(8)=Sound'AllDialog.pc_dnk_donkeymote_80'
	EmoteSoundLand(0)=Sound'AllDialog.pc_dnk_donkeymote_50'
	EmoteSoundLand(1)=Sound'AllDialog.pc_dnk_donkeymote_28'
	EmoteSoundLand(2)=Sound'AllDialog.pc_dnk_donkeymote_24'
	EmoteSoundLand(3)=Sound'AllDialog.pc_dnk_donkeymote_8'
	EmoteSoundLand(4)=Sound'AllDialog.pc_dnk_donkeymote_86'
	EmoteSoundLand(5)=Sound'AllDialog.pc_dnk_donkeymote_106'
	EmoteSoundLand(6)=Sound'AllDialog.pc_dnk_donkeymote_88'
	EmoteSoundLand(7)=Sound'AllDialog.pc_dnk_donkeymote_84'
	EmoteSoundLand(8)=Sound'AllDialog.pc_dnk_donkeymote_66'
	EmoteSoundLand(9)=Sound'AllDialog.pc_dnk_donkeymote_91'
	EmoteSoundClimb(0)=Sound'AllDialog.pc_dnk_donkeymote_44'
	EmoteSoundClimb(1)=Sound'AllDialog.pc_dnk_donkeymote_46'
	EmoteSoundClimb(2)=Sound'AllDialog.pc_dnk_donkeymote_48'
	EmoteSoundClimb(3)=Sound'AllDialog.pc_dnk_donkeymote_114'
	EmoteSoundClimb(4)=Sound'AllDialog.pc_dnk_donkeymote_100'
	EmoteSoundClimb(5)=Sound'AllDialog.pc_dnk_donkeymote_94'
	EmoteSoundClimb(6)=Sound'AllDialog.pc_dnk_donkeymote_78'
	EmoteSoundClimb(7)=Sound'AllDialog.pc_dnk_donkeymote_72'
	EmoteSoundPain(0)=Sound'AllDialog.pc_dnk_donkeymote_36'
	EmoteSoundPain(1)=Sound'AllDialog.pc_dnk_donkeymote_2'
	EmoteSoundPain(2)=Sound'AllDialog.pc_dnk_donkeymote_32'
	EmoteSoundPain(3)=Sound'AllDialog.pc_dnk_donkeymote_16'
	EmoteSoundPain(4)=Sound'AllDialog.pc_dnk_donkeymote_14'
	EmoteSoundPain(5)=Sound'AllDialog.pc_dnk_donkeymote_34'
	EmoteSoundPain(6)=Sound'AllDialog.pc_dnk_donkeymote_98'
	EmoteSoundPain(7)=Sound'AllDialog.pc_dnk_donkeymote_58'
	EmoteSoundPain(8)=Sound'AllDialog.pc_dnk_donkeymote_82'
	EmoteSoundPain(9)=Sound'AllDialog.pc_dnk_donkeymote_76'
	EmoteSoundPain(10)=Sound'AllDialog.pc_dnk_donkeymote_116'
	EmoteSoundPunch(0)=Sound'AllDialog.pc_dnk_donkeymote_42'
	EmoteSoundPunch(1)=Sound'AllDialog.pc_dnk_donkeymote_12'
	EmoteSoundPunch(2)=Sound'AllDialog.pc_dnk_donkeymote_6'
	EmoteSoundPunch(3)=Sound'AllDialog.pc_dnk_donkeymote_4'
	EmoteSoundPunch(4)=Sound'AllDialog.pc_dnk_donkeymote_74'
	EmoteSoundPunch(5)=Sound'AllDialog.pc_dnk_donkeymote_70'
	EmoteSoundPunch(6)=Sound'AllDialog.pc_dnk_donkeymote_68'
	EmoteSoundPunch(7)=Sound'AllDialog.pc_dnk_donkeymote_64'
	EmoteSoundThrow(0)=Sound'AllDialog.pc_dnk_donkeymote_42'
	EmoteSoundThrow(1)=Sound'AllDialog.pc_dnk_donkeymote_12'
	EmoteSoundThrow(2)=Sound'AllDialog.pc_dnk_donkeymote_6'
	EmoteSoundThrow(3)=Sound'AllDialog.pc_dnk_donkeymote_4'
	EmoteSoundThrow(4)=Sound'AllDialog.pc_dnk_donkeymote_74'
	EmoteSoundThrow(5)=Sound'AllDialog.pc_dnk_donkeymote_70'
	EmoteSoundThrow(6)=Sound'AllDialog.pc_dnk_donkeymote_68'
	EmoteSoundThrow(7)=Sound'AllDialog.pc_dnk_donkeymote_64'
	EmoteSoundFaint(0)=Sound'AllDialog.pc_dnk_donkeymote_52'
	EmoteSoundFaint(1)=Sound'AllDialog.pc_dnk_donkeymote_40'
	EmoteSoundFaint(2)=Sound'AllDialog.pc_dnk_donkeymote_62'
	EmoteSoundFaint(3)=Sound'AllDialog.pc_dnk_donkeymote_26'
	EmoteSoundFaint(4)=Sound'AllDialog.pc_dnk_donkeymote_112'
	EmoteSoundFaint(5)=Sound'AllDialog.pc_dnk_donkeymote_110'
	EmoteSoundFaint(6)=Sound'AllDialog.pc_dnk_donkeymote_108'
	EmoteSoundFaint(7)=Sound'AllDialog.pc_dnk_donkeymote_96'
	EmoteSoundFaint(8)=Sound'AllDialog.pc_dnk_donkeymote_60'
	SoundThrow(0)=Sound'Donkey.throw'
	DoubleJumpSound(0)=Sound'Donkey.jump_double'
	FrontLeftBone=body_l_hoof_joint
	FrontRightBone=body_r_hoof_joint
	BackLeftBone=body_l_foot_joint
	BackRightBone=body_r_foot_joint
	AttackStartBoneNames(2)=body_l_heel_joint
	AttackEndBoneNames(2)=body_l_thigh_joint
	RibbonEmitterName=class'SHGame.Hero_Ribbon'
	TexName=Texture'ShCharacters.Donkey_blur'
	KnockBackDistance=30.0
	DeathIfFallDistance=700.0
	SkinsVisible(0)=Shader'ShCharacters.steed_S'
	SkinsInvisible(0)=Texture'ShCharacters.noblesteed_inv'
	StrengthEmitterBoneName(0)=body_head_joint
	PotionBumpLines(0)=DNK_DonkeyStrength
	PotionBumpLines(1)=DNK_DonkeyFrog
	PotionBumpLines(2)=DNK_DonkeyGhost
	PotionBumpLines(3)=DNK_DonkeySleep
	PotionBumpLines(4)=DNK_DonkeyStink
	PotionBumpLines(5)=DNK_DonkeyShrinkMe
	PotionBumpLines(6)=DNK_DonkeyShrinkYou
	PotionBumpLines(7)=DNK_DonkeyFreeze
	PotionBumpLines(8)=DNK_DonkeyLove
	WastedPotionBumpLines=DNK_DonkeyWaste
	HurtBumpLines=DNK_SteedHurt
	HitBumpLines=DNK_SteedHit
	PickupEnergyBarBumpLines=DNK_DonkeyHero
	PickupShamrockBumpLines=DNK_DonkeyClover
	LowCoinsBumpLines=DNK_DonkeyCoinLow
	ManyCoinsBumpLines=DNK_DonkeyCoin
	TiredBumpLines=DNK_DonkeyLowHealth
	UPPER_BODY_BONE=body_spine1_joint
	AttackDist=60.0
	AttackHeight=50.0
	AttackAngle=60.0
	WadeAnims(0)=Walk
	WadeAnims(1)=walkbackward
	WadeAnims(2)=walkleft
	WadeAnims(3)=walkright
	AttackInfo(0)=(AnimName=punch1,StartBoneName=body_l_brow1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(1)=(AnimName=punch1,StartBoneName=body_l_brow2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(2)=(AnimName=punch1,StartBoneName=body_r_brow1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(3)=(AnimName=punch1,StartBoneName=body_r_brow2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(4)=(AnimName=punch1,StartBoneName=body_nose_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(5)=(AnimName=punch1,StartBoneName=body_head_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(6)=(AnimName=punch1,StartBoneName=body_mane1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(7)=(AnimName=punch1,StartBoneName=body_mane2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(8)=(AnimName=punch1,StartBoneName=body_mane3_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(9)=(AnimName=punch1,StartBoneName=body_mane4_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(10)=(AnimName=punch1,StartBoneName=body_neck_joint,EndBoneName=None,StartFrame=1.0,EndFrame=13.0)
	AttackInfo(11)=(AnimName=punch3,StartBoneName=body_l_hip_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(12)=(AnimName=punch3,StartBoneName=body_l_thigh_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(13)=(AnimName=punch3,StartBoneName=body_l_knee_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(14)=(AnimName=punch3,StartBoneName=body_l_heel_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(15)=(AnimName=punch3,StartBoneName=body_l_foot_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(16)=(AnimName=punch3,StartBoneName=body_r_hip_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(17)=(AnimName=punch3,StartBoneName=body_r_thigh_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(18)=(AnimName=punch3,StartBoneName=body_r_knee_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(19)=(AnimName=punch3,StartBoneName=body_r_heel_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(20)=(AnimName=punch3,StartBoneName=body_r_foot_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(21)=(AnimName=punch3,StartBoneName=body_tailbase_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(22)=(AnimName=punch3,StartBoneName=body_tail1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(23)=(AnimName=punch3,StartBoneName=body_tail2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(24)=(AnimName=punch3,StartBoneName=body_tail3_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(25)=(AnimName=punch3,StartBoneName=body_tail4_joint,EndBoneName=None,StartFrame=1.0,EndFrame=20.0)
	AttackInfo(26)=(AnimName=punch2,StartBoneName=body_l_thigh_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(27)=(AnimName=punch2,StartBoneName=body_l_knee_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(28)=(AnimName=punch2,StartBoneName=body_l_heel_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(29)=(AnimName=punch2,StartBoneName=body_l_foot_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(30)=(AnimName=punch2,StartBoneName=body_r_thigh_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(31)=(AnimName=punch2,StartBoneName=body_r_knee_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(32)=(AnimName=punch2,StartBoneName=body_r_heel_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(33)=(AnimName=punch2,StartBoneName=body_r_foot_joint,EndBoneName=None,StartFrame=4.0,EndFrame=12.0)
	AttackInfo(34)=(AnimName=punch2,StartBoneName=body_head_joint,EndBoneName=None,StartFrame=17.0,EndFrame=26.0)
	AttackInfo(35)=(AnimName=runattack,StartBoneName=body_neck_joint,EndBoneName=body_head_joint,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(36)=(AnimName=runattack,StartBoneName=body_head_joint,EndBoneName=body_nose_joint,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(37)=(AnimName=runattack,StartBoneName=body_head_joint,EndBoneName=body_l_earbase_joint,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(38)=(AnimName=runattack,StartBoneName=body_head_joint,EndBoneName=body_r_earbase_joint,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(39)=(AnimName=runattack,StartBoneName=body_mane1_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(40)=(AnimName=runattack,StartBoneName=body_mane2_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(41)=(AnimName=runattack,StartBoneName=body_mane3_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(42)=(AnimName=runattack,StartBoneName=body_mane4_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(43)=(AnimName=runattack,StartBoneName=body_l_brow1_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(44)=(AnimName=runattack,StartBoneName=body_l_brow2_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(45)=(AnimName=runattack,StartBoneName=body_r_brow1_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	AttackInfo(46)=(AnimName=runattack,StartBoneName=body_r_brow2_joint,EndBoneName=None,StartFrame=6.0,EndFrame=23.0)
	PunchEmitterClass=class'SHGame.Punch_Donkey'
	CameraSetStandard=(vLookAtOffset=(X=-35.0,Y=0.0,Z=60.0),fLookAtDistance=130.0,fLookAtHeight=40.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CameraSnapRotationPitch=-2500.0
	BigClimbStartNoTrans=jumptoclimb2
	BigClimbEndNoTrans=climb2
	BigClimbStartOffset=85.0
	BigClimbOffset=67.0
	JumpToHangNoTransAnim=jumptohang2
	IdleTiredAnimName=tiredidle
	RunAnimName=run
	WalkAnimName=Walk
	PickupAnimName=Pickup
	ThrowAnimName=throw
	PickupBoneName=body_object_joint
	LeftUpperLidBone=body_l_topeyelid_joint
	LeftLowerLidBone=body_l_bottomeyelid_joint
	RightUpperLidBone=body_r_topeyelid_joint
	RightLowerLidBone=body_r_bottomeyelid_joint
	NeckRotElement=RE_RollNeg
	HeadRotElement=RE_YawPos
	bCanBlink=false
	JumpSounds(0)=Sound'Donkey.Jump'
	LandingStone(0)=Sound'Donkey.land'
	LandingWood(0)=Sound'Donkey.land'
	LandingWet(0)=Sound'Donkey.land'
	LandingGrass(0)=Sound'Donkey.land'
	LandingDirt(0)=Sound'Donkey.land'
	LandingHay(0)=Sound'Donkey.land'
	LandingLeaf(0)=Sound'Donkey.land'
	LandingSand(0)=Sound'Donkey.land'
	LandingMud(0)=Sound'Donkey.land'
	LandingNone(0)=Sound'Donkey.land'
	FootstepsStone(0)=Sound'Footsteps.F_donkey_stone01'
	FootstepsStone(1)=Sound'Footsteps.F_donkey_stone02'
	FootstepsStone(2)=Sound'Footsteps.F_donkey_stone03'
	FootstepsStone(3)=Sound'Footsteps.F_donkey_stone04'
	FootstepsStone(4)=Sound'Footsteps.F_donkey_stone05'
	FootstepsStone(5)=Sound'Footsteps.F_donkey_stone06'
	FootstepsWood(0)=Sound'Footsteps.F_donkey_wood01'
	FootstepsWood(1)=Sound'Footsteps.F_donkey_wood02'
	FootstepsWood(2)=Sound'Footsteps.F_donkey_wood03'
	FootstepsWood(3)=Sound'Footsteps.F_donkey_wood04'
	FootstepsWood(4)=Sound'Footsteps.F_donkey_wood05'
	FootstepsWood(5)=Sound'Footsteps.F_donkey_wood06'
	FootstepsWet(0)=Sound'Footsteps.F_donkey_water01'
	FootstepsWet(1)=Sound'Footsteps.F_donkey_water02'
	FootstepsWet(2)=Sound'Footsteps.F_donkey_water03'
	FootstepsWet(3)=Sound'Footsteps.F_donkey_water04'
	FootstepsWet(4)=Sound'Footsteps.F_donkey_water05'
	FootstepsWet(5)=Sound'Footsteps.F_donkey_water06'
	FootstepsGrass(0)=Sound'Footsteps.F_donkey_grass01'
	FootstepsGrass(1)=Sound'Footsteps.F_donkey_grass02'
	FootstepsGrass(2)=Sound'Footsteps.F_donkey_grass03'
	FootstepsGrass(3)=Sound'Footsteps.F_donkey_grass04'
	FootstepsGrass(4)=Sound'Footsteps.F_donkey_grass05'
	FootstepsGrass(5)=Sound'Footsteps.F_donkey_grass06'
	FootstepsMetal(0)=Sound'Footsteps.F_donkey_metal01'
	FootstepsMetal(1)=Sound'Footsteps.F_donkey_metal02'
	FootstepsMetal(2)=Sound'Footsteps.F_donkey_metal03'
	FootstepsMetal(3)=Sound'Footsteps.F_donkey_metal04'
	FootstepsMetal(4)=Sound'Footsteps.F_donkey_metal05'
	FootstepsMetal(5)=Sound'Footsteps.F_donkey_metal06'
	FootstepsDirt(0)=Sound'Footsteps.F_donkey_dirt01'
	FootstepsDirt(1)=Sound'Footsteps.F_donkey_dirt02'
	FootstepsDirt(2)=Sound'Footsteps.F_donkey_dirt03'
	FootstepsDirt(3)=Sound'Footsteps.F_donkey_dirt04'
	FootstepsDirt(4)=Sound'Footsteps.F_donkey_dirt05'
	FootstepsDirt(5)=Sound'Footsteps.F_donkey_dirt06'
	FootstepsDirt(6)=Sound'Footsteps.F_donkey_dirt07'
	FootstepsMud(0)=Sound'Footsteps.F_donkey_mud01'
	FootstepsMud(1)=Sound'Footsteps.F_donkey_mud02'
	FootstepsMud(2)=Sound'Footsteps.F_donkey_mud03'
	FootstepsMud(3)=Sound'Footsteps.F_donkey_mud04'
	FootstepsMud(4)=Sound'Footsteps.F_donkey_mud05'
	FootstepsMud(5)=Sound'Footsteps.F_donkey_mud06'
	FootstepsNone(0)=Sound'Footsteps.F_donkey_stone01'
	FootstepsNone(1)=Sound'Footsteps.F_donkey_stone02'
	FootstepsNone(2)=Sound'Footsteps.F_donkey_stone03'
	FootstepsNone(3)=Sound'Footsteps.F_donkey_stone04'
	FootstepsNone(4)=Sound'Footsteps.F_donkey_stone05'
	FootstepsNone(5)=Sound'Footsteps.F_donkey_stone06'
	FootFramesWalk(0)=12
	FootFramesWalk(1)=17
	FootFramesWalk(2)=33
	FootFramesWalk(3)=38
	FootFramesWalk(4)=53
	FootFramesWalk(5)=58
	FootFramesWalk(6)=72
	FootFramesWalk(7)=78
	FootFramesRun(0)=1
	FootFramesRun(1)=2
	FootFramesRun(2)=4
	FootFramesRun(3)=7
	FootFramesRun(4)=20
	FootFramesRun(5)=21
	FootFramesRun(6)=23
	FootFramesRun(7)=28
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
	ControllerClass=class'SHGame.SHCompanionController'
	MouthBone=body___mouth
	Mesh=SkeletalMesh'ShrekCharacters.Steed'
	CollisionRadius=35.0
	CollisionHeight=35.0
	Label="Steed"
}