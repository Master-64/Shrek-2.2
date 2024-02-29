// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22Donkey extends SH22HeroPawn
	Config(SH22);


var() int TotalGameStateTokens, GameStateTokenLen;
var(GameState) const editconst string GameStateMasterList;
var(GameState) travel string CurrentGameState;
var(sounds) array<Sound> SoundKickThrow, SoundSpin;
var() name LowLipBoneName, DonkeyREStartBoneNames[4], DonkeyREEndBoneNames[4];
var() class<Emitter> GrassGrazeEmitter;
var() vector BottleAttachOffset;
var() rotator BottleAttachRotation;
var() array<Material> BracesSkins;
var() bool bShowBottle, bShowBraces;
var bool bOldbShowBottle, bOldbShowBraces;
var DonkeyHelmet DHelmet;
var Emitter DonkeyREEffect[4];
var PotionBottleHEA BottleHEA;


function DestroySpecialRibbonEmitters()
{
	local int i;
	
	for(i = 0; i < 4; i++)
	{
		if(DonkeyREEffect[i] != none)
		{
			DonkeyREEffect[i].Destroy();
			DonkeyREEffect[i] = none;
		}
	}
}

function CreateSpecialRibbonEmitters()
{
	local int i;
	
	DestroySpecialRibbonEmitters();
	
	if(U.IsSoftwareRendering() || Level.DetailMode == DM_Low)
	{
		return;
	}
	
	for(i = 0; i < 4; i++)
	{
		if(DonkeyREStartBoneNames[i] == 'None')
		{
			continue;
		}
		
		DonkeyREEffect[i] = Spawn(RibbonEmitterName, self);
		
		if(DonkeyREEffect[i] == none)
		{
			continue;
		}
		
		RibbonEmitter(DonkeyREEffect[i].Emitters[0]).BoneNameStart = DonkeyREStartBoneNames[i];
		RibbonEmitter(DonkeyREEffect[i].Emitters[0]).BoneNameEnd = DonkeyREEndBoneNames[i];
		
		if(TexName != none)
		{
			RibbonEmitter(DonkeyREEffect[i].Emitters[0]).Texture = TexName;
		}
	}
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	DHelmet = Spawn(class'DonkeyHelmet');
	DHelmet.AttachWeaponToKWPawn(self);
	DHelmet.bHidden = true;
	
	BottleHEA = Spawn(class'PotionBottleHEA',,, Location);
	BottleHEA.SetDrawScale(0.5);
	AttachToBone(BottleHEA, DrinkPotionBoneName);
	BottleHEA.SetRelativeLocation(BottleAttachOffset);
	BottleHEA.SetRelativeRotation(BottleAttachRotation);
	BottleHEA.SetOwner(self);
	BottleHEA.bHidden = !bShowBottle;
	BottleHEA.bCanBePickedUp = false;
	
	if(bShowBraces)
	{
		Skins = BracesSkins;
	}
}

function AddAnimNotifys()
{
	local MeshAnimation MeshAnim;

	super.AddAnimNotifys();
	
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddNotify(MeshAnim, LandAnims[0], 29.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, LandAnims[1], 8.0, 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, EndAirAttackAnim, 20.0, 'AnimNotifyBlendOutEndAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 15.0, 'AnimNotifyBlendOutContinueAirAttack');
	AddNotify(MeshAnim, ContinueAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, EndAirAttackAnim, 2.0, 'PlayEndAirAttackFX');
	AddNotify(MeshAnim, PickupAnimName, 13.0, 'AnimNotifyObjectPickup');
	AddNotify(MeshAnim, ThrowAnimName, 33.0, 'PlayerThrowCarryingActor');
	AddNotify(MeshAnim, ThrowAnimName, 31.0, 'PlayKickThrowingSound');
	AddNotify(MeshAnim, 'bored2', 35.0, 'PlayGrassGrazeEmitter');
	AddNotify(MeshAnim, 'bored2', 58.0, 'PlayGrassGrazeEmitter');
	AddNotify(MeshAnim, 'bored2', 84.0, 'PlayGrassGrazeEmitter');
	AddNotify(MeshAnim, 'bored2', 130.0, 'PlayGrassGrazeEmitter');
	AddFootStepsNotify(MeshAnim);
	AddNotify(MeshAnim, 'run', 1.0, 'PlayFootSplashesFrontRight');
	AddNotify(MeshAnim, 'run', 14.0, 'PlayFootSplashesFrontRight');
	AddNotify(MeshAnim, 'run', 12.0, 'PlayFootSplashesFrontLeft');
	AddNotify(MeshAnim, 'run', 27.0, 'PlayFootSplashesFrontLeft');
	AddNotify(MeshAnim, 'run', 9.0, 'PlayFootSplashesBackRight');
	AddNotify(MeshAnim, 'run', 26.0, 'PlayFootSplashesBackRight');
	AddNotify(MeshAnim, 'run', 6.0, 'PlayFootSplashesBackLeft');
	AddNotify(MeshAnim, 'run', 24.0, 'PlayFootSplashesBackLeft');
	AddNotify(MeshAnim, ThrowPotionAnimName, 18.0, 'ThrowPotion');
	AddNotify(MeshAnim, DrinkPotionAnimName, 65.0, 'DrinkPotion');
	AddNotify(MeshAnim, ThrowPotionAnimName, 14.0, 'PlayThrowPotionSound');
	AddNotify(MeshAnim, DrinkPotionAnimName, 12.0, 'PlayDrinkPotionSound');
	AddNotify(MeshAnim, StartAttackAnim3, 9.0, 'CreateSpecialRibbonEmitters');
	AddNotify(MeshAnim, StartAttackAnim3, 28.0, 'DestroySpecialRibbonEmitters');
	AddNotify(MeshAnim, StartAttackAnim3, 15.0, 'KillEverybody');
	AddNotify(MeshAnim, StartAttackAnim3, 11.0, 'PlaySpinSound');
}

function KillEverybody()
{
	local Emitter em;

	em = Spawn(class'range_attack', self);
	
	KillAllEnemiesAround(150.0);
}

function PlayGrassGrazeEmitter()
{
	local vector Loc;
	local KWGame.EMaterialType mtype;
	
	if(Rand(2) != 0)
	{
		return;
	}
	
	mtype = TraceMaterial(Location, 1.5 * CollisionHeight);
	
	switch(mtype)
	{
		case MTYPE_Grass:
		case MTYPE_Dirt:
		case MTYPE_Leaf:
			Loc = GetBoneCoords(LowLipBoneName).Origin;
			Spawn(GrassGrazeEmitter, self,, Loc);
			
			break;
		default:
			return;
	}
}

function PlayKickThrowingSound()
{
	PlayArraySound(SoundKickThrow, 1.0);
}

function PlaySpinSound()
{
	PlayArraySound(SoundSpin, 1.0);
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
	if(bShowBottle != bOldbShowBottle)
	{
		BottleHEA.bHidden = !bShowBottle;
	}
	
	if(bShowBraces != bOldbShowBraces)
	{
		if(bShowBraces)
		{
			Skins = BracesSkins;
		}
		else
		{
			Skins = default.Skins;
		}
	}
	
	bOldbShowBottle = bShowBottle;
	bOldbShowBraces = bShowBraces;
}

function OnEvent(name EventName)
{
	super.OnEvent(EventName);
	
	switch(EventName)
	{
		case 'SecretArea':
			InterestMgr.CommentMgr.SayComment('DNK_DonkeySecret', Tag,, true,,,, "BumpDialog");
			
			break;
		case 'Snapdragon':
			DeliverLocalizedDialog("PC_DNK_SNAPDRAGINTRO_2", true,,,, true,, true);
			
			break;
	}
}

event AnimEnd(int Channel)
{
	local name animseq;
	local int randval;
	
	if(Channel == 0)
	{
		animseq = GetAnimSequence();
		
		if(aHolding != none)
		{
			if(animseq == GetIdleAnimName() || animseq == CarryIdleAnimName)
			{
				PlayAnim(CarryIdleAnimName, 1.0);
			}
			
			return;
		}
		
		if(animseq == GetIdleAnimName())
		{
			if(CanPlayFidgets())
			{
				randval = Rand(12);
				
				switch(randval)
				{
					case 0:
						PlayAnim('bored1', RandRange(1.0, 1.2));
						
						break;
					case 1:
						PlayAnim('bored2', RandRange(1.0, 1.2));
						
						break;
					case 2:
					case 3:
						PlayAnim('bored3a', RandRange(1.0, 1.2));
						
						break;
					case 4:
					case 5:
					case 6:
					case 7:
					case 8:
					case 9:
						PlayLookAroundAnim();
						
						break;
					default:
						PlayAnim(IdleAnimName, RandRange(0.8, 1.2));
						
						break;
				}
			}
			else
			{
				PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2));
			}
		}
		else
		{
			if(animseq == 'bored3a')
			{
				if(CanPlayFidgets())
				{
					PlayAnim('bored3b', RandRange(0.8, 1.2));
				}
				else
				{
					PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2));
				}
			}
			else
			{
				if(animseq == 'bored3b')
				{
					if(CanPlayFidgets())
					{
						randval = Rand(20);
						
						switch(randval)
						{
							case 0:
								PlayAnim('bored3c', RandRange(1.0, 1.2));
								
								break;
							default:
								PlayAnim('bored3b', RandRange(0.8, 1.2));
								
								break;
						}
					}
					else
					{
						PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2));
					}
				}
				else
				{
					if(animseq == 'bored3c')
					{
						PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2));
					}
					else
					{
						if(IsInState('MountFinish'))
						{
							return;
						}
						
						PlayAnim(GetIdleAnimName(), RandRange(0.8, 1.2));
					}
				}
			}
		}
	}
	else
	{
		super.AnimEnd(Channel);
	}
}

function ShowStrengthAttributes()
{
	super.ShowStrengthAttributes();
	
	PC = U.GetPC();
	
	if(SHHeroController(PC).DonkeyFirstStrengthPotion == 0)
	{
		SHHeroController(PC).DonkeyFirstStrengthPotion = 1;
		SHHeroController(PC).SaveConfig();
		TriggerEvent('DonkeyStrengthPotion', none, none);
	}
	
	DHelmet.bHidden = false;
}

function HideStrengthAttributes()
{
	super.HideStrengthAttributes();
	
	DHelmet.bHidden = true;
}

state stateStartCheerInBossPibBattle
{
	function AnimEnd(int Channel)
	{
		local name animseq;
		
		if(Channel != 0)
		{
			return;
		}
		
		animseq = GetAnimSequence();
		
		if(animseq != LoopSupportAttackAnim)
		{
			LoopAnim(LoopSupportAttackAnim);
		}
	}
	
	Begin:
	
	PlayAnim(StartSupportAttackAnim);
	FinishAnim();
	LoopAnim(LoopSupportAttackAnim);
}

state stateEndCheerInBossPibBattle
{
	function AnimEnd(int Channel)
	{
		return;
	}
	
	Begin:
	
	FinishAnim();
	PlayAnim(EndSupportAttackAnim);
	FinishAnim();
	GotoState('StateIdle');
}


defaultproperties
{
	BracesSkins(0)=Texture'ShCharacters.donkey2_tx'
	BracesSkins(1)=Texture'ShCharacters.donkey_braces_tx'
	BottleAttachRotation=(Roll=-19000)
	SoundKickThrow(0)=Sound'Donkey.land'
	SoundSpin(0)=Sound'Donkey.spin_punch'
	LowLipBoneName="body_midbottomlip_joint"
	GrassGrazeEmitter=class'SHGame.Grass_Graze'
	DonkeyREStartBoneNames(0)="body_l_foot_joint"
	DonkeyREStartBoneNames(1)="body_r_foot_joint"
	DonkeyREStartBoneNames(2)="body_l_hoof_joint"
	DonkeyREStartBoneNames(3)="body_r_hoof_joint"
	AttackMoveAhead=75.0
	fxSwingingDeathClass=class'SHGame.Donkey_plow'
	SHHeroName=Donkey
	NewRunAttackAnim=runattack
	ContinueAirAttackAnim=jumpattacktopunch1
	UpEndBackAnim=UpEndBackward
	LookAroundAnims(0)=lookaround1
	LookAroundAnims(1)=lookaround2
	LookAroundAnims(2)=lookaround3
	ThrowPotionBoneName=body_object_joint
	DrinkPotionBoneName=body_object_joint
	ThrowOffset=(Y=3.0)
	ThrowRotation=(Roll=-16384)
	DrinkOffset=(Y=3.0)
	DrinkRotation=(Roll=-16384)
	SwingSounds(0)=Sound'Steed.ambience.swoosh_01'
	SwingSounds(1)=Sound'Steed.ambience.swoosh_02'
	SwingSounds(2)=Sound'Steed.ambience.swoosh_01'
	SwingSounds(3)=Sound'Steed.ambience.swoosh_02'
	SwingSounds(4)=Sound'Steed.ambience.swoosh_01'
	SwingSounds(5)=Sound'Steed.ambience.swoosh_02'
	SwingSounds(6)=Sound'Donkey.donkey_emote01'
	SwingSounds(7)=Sound'Donkey.donkey_emote02'
	RunAttackSounds(0)=Sound'Donkey.donkey_emote01'
	RunAttackSounds(1)=Sound'Donkey.donkey_emote02'
	Attack1Sounds(0)=Sound'Donkey.punch01'
	Attack2Sounds(0)=Sound'Donkey.punch02'
	Attack3Sounds(0)=Sound'Donkey.punch03'
	SpecialAttackSounds(0)=Sound'Donkey.punch03'
	DyingSound=Sound'Donkey.faint'
	ThrowPotionSound=Sound'Donkey.donkey_throw_potion'
	DrinkPotionSound=Sound'Donkey.donkey_drink_potion'
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
	RibbonEmitterName=class'SHGame.Donkey_Spinblur'
	TexName=Texture'ShCharacters.Donkey_blur'
	KnockBackDistance=30.0
	SkinsVisible(0)=Texture'ShCharacters.donkey2_tx'
	SkinsVisible(1)=Texture'ShCharacters.donkey_tx'
	SkinsInvisible(0)=Texture'ShCharacters.donkey2_inv'
	SkinsInvisible(1)=Texture'ShCharacters.donkey_inv'
	StrengthEmitterBoneName(0)="body_head_joint"
	PotionBumpLines(0)="DNK_DonkeyStrength"
	PotionBumpLines(1)="DNK_DonkeyFrog"
	PotionBumpLines(2)="DNK_DonkeyGhost"
	PotionBumpLines(3)="DNK_DonkeySleep"
	PotionBumpLines(4)="DNK_DonkeyStink"
	PotionBumpLines(5)="DNK_DonkeyShrinkMe"
	PotionBumpLines(6)="DNK_DonkeyShrinkYou"
	PotionBumpLines(7)="DNK_DonkeyFreeze"
	PotionBumpLines(8)="DNK_DonkeyLove"
	WastedPotionBumpLines="DNK_DonkeyWaste"
	HurtBumpLines="DNK_DonkeyHurt"
	HitBumpLines="DNK_DonkeyHit"
	PickupEnergyBarBumpLines="DNK_DonkeyHero"
	PickupShamrockBumpLines="DNK_DonkeyClover"
	LowCoinsBumpLines="DNK_DonkeyCoinLow"
	ManyCoinsBumpLines="DNK_DonkeyCoin"
	TiredBumpLines="DNK_DonkeyLowHealth"
	InWaterBumpLines="DNK_DonkeyWater"
	UPPER_BODY_BONE="body_spine1_joint"
	AttackDist=40.0
	AttackHeight=40.0
	AttackAngle=40.0
	AttackInfo(0)=(AnimName=punch1,StartBoneName=body_l_earbase_joint,EndBoneName=None,StartFrame=1.0,EndFrame=7.0)
	AttackInfo(1)=(AnimName=punch1,StartBoneName=body_r_earbase_joint,EndBoneName=None,StartFrame=1.0,EndFrame=7.0)
	AttackInfo(2)=(AnimName=punch1,StartBoneName=body_l_brow1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=7.0)
	AttackInfo(3)=(AnimName=punch1,StartBoneName=body_r_brow1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=7.0)
	AttackInfo(4)=(AnimName=punch1,StartBoneName=body_l_brow2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=7.0)
	AttackInfo(5)=(AnimName=punch1,StartBoneName=body_r_brow2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=7.0)
	AttackInfo(6)=(AnimName=punch1,StartBoneName=body_teeth_joint,EndBoneName=None,StartFrame=1.0,EndFrame=7.0)
	AttackInfo(7)=(AnimName=punch3,StartBoneName=body_r_hoof_joint,EndBoneName=None,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(8)=(AnimName=punch3,StartBoneName=body_l_hoof_joint,EndBoneName=None,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(9)=(AnimName=punch3,StartBoneName=body_r_foot_joint,EndBoneName=None,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(10)=(AnimName=punch3,StartBoneName=body_l_foot_joint,EndBoneName=None,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(11)=(AnimName=punch3,StartBoneName=body_r_wrist_joint,EndBoneName=body_r_elbow_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(12)=(AnimName=punch3,StartBoneName=body_r_elbow_joint,EndBoneName=body_r_shoulder2_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(13)=(AnimName=punch3,StartBoneName=body_l_wrist_joint,EndBoneName=body_l_elbow_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(14)=(AnimName=punch3,StartBoneName=body_l_elbow_joint,EndBoneName=body_l_shoulder2_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(15)=(AnimName=punch3,StartBoneName=body_r_ankle_joint,EndBoneName=body_r_knee_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(16)=(AnimName=punch3,StartBoneName=body_r_knee_joint,EndBoneName=body_r_leg_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(17)=(AnimName=punch3,StartBoneName=body_l_ankle_joint,EndBoneName=body_l_knee_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(18)=(AnimName=punch3,StartBoneName=body_l_knee_joint,EndBoneName=body_l_leg_joint,StartFrame=4.0,EndFrame=23.0)
	AttackInfo(19)=(AnimName=punch2,StartBoneName=body_r_foot_joint,EndBoneName=None,StartFrame=4.0,EndFrame=21.0)
	AttackInfo(20)=(AnimName=punch2,StartBoneName=body_l_foot_joint,EndBoneName=None,StartFrame=4.0,EndFrame=21.0)
	AttackInfo(21)=(AnimName=punch2,StartBoneName=body_r_ankle_joint,EndBoneName=body_r_knee_joint,StartFrame=4.0,EndFrame=21.0)
	AttackInfo(22)=(AnimName=punch2,StartBoneName=body_r_knee_joint,EndBoneName=body_r_leg_joint,StartFrame=4.0,EndFrame=21.0)
	AttackInfo(23)=(AnimName=punch2,StartBoneName=body_l_ankle_joint,EndBoneName=body_l_knee_joint,StartFrame=4.0,EndFrame=21.0)
	AttackInfo(24)=(AnimName=punch2,StartBoneName=body_l_knee_joint,EndBoneName=body_l_leg_joint,StartFrame=4.0,EndFrame=21.0)
	AttackInfo(25)=(AnimName=runattack,StartBoneName=body_head_joint,EndBoneName=body_neck_joint,StartFrame=1.0,EndFrame=24.0)
	AttackInfo(26)=(AnimName=runattack,StartBoneName=body_l_brow1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=24.0)
	AttackInfo(27)=(AnimName=runattack,StartBoneName=body_l_brow2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=24.0)
	AttackInfo(28)=(AnimName=runattack,StartBoneName=body_r_brow1_joint,EndBoneName=None,StartFrame=1.0,EndFrame=24.0)
	AttackInfo(29)=(AnimName=runattack,StartBoneName=body_r_brow2_joint,EndBoneName=None,StartFrame=1.0,EndFrame=24.0)
	AttackInfo(30)=(AnimName=runattack,StartBoneName=body_l_earbase_joint,EndBoneName=None,StartFrame=1.0,EndFrame=24.0)
	AttackInfo(31)=(AnimName=runattack,StartBoneName=body_r_earbase_joint,EndBoneName=None,StartFrame=1.0,EndFrame=24.0)
	PunchEmitterClass=class'SHGame.Punch_Donkey'
	AttackDistFromEnemy=20.0
	CameraSetStandard=(vLookAtOffset=(X=-35.0,Y=20.0,Z=60.0),fLookAtDistance=130.0,fLookAtHeight=40.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CameraSnapRotationPitch=-2500.0
	CarryTurnRightAnim=carryturnright
	CarryTurnLeftAnim=carryturnleft
	BigClimbStartNoTrans=jumptoclimb2
	BigClimbEndNoTrans=climb2
	BigClimbStartOffset=66.0
	BigClimbOffset=32.0
	BigShimmyOffset=50.0
	StepUpOffset=30.0
	JumpToHangAnim=jumptoclimb
	JumpToHangNoTransAnim=jumptoclimb2
	StepUpAnim=stepup
	StepUpNoTransAnim=stepup2
	IdleTiredAnimName=tiredidle
	RunAnimName=run
	WalkAnimName=Walk
	PickupAnimName=Pickup
	ThrowAnimName=throw
	KnockBackAnimName=knockback
	PickupBoneName=body_object_joint
	LeftUpperLidBone=body_l_topeyelid_joint
	LeftLowerLidBone=body_l_bottomeyelid_joint
	RightUpperLidBone=body_r_topeyelid_joint
	RightLowerLidBone=body_r_bottomeyelid_joint
	HeadRotElement=RE_YawPos
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
	FootFramesWalk(0)=4
	FootFramesWalk(1)=6
	FootFramesWalk(2)=16
	FootFramesWalk(3)=18
	FootFramesWalk(4)=30
	FootFramesWalk(5)=32
	FootFramesWalk(6)=41
	FootFramesWalk(7)=43
	FootFramesRun(0)=7
	FootFramesRun(1)=8
	FootFramesRun(2)=11
	FootFramesRun(3)=14
	FootFramesRun(4)=23
	FootFramesRun(5)=25
	FootFramesRun(6)=28
	FootFramesRun(7)=31
	WaterRipples=class'SHGame.WaterRipples'
	fMoveWaterRipplesTime=0.250000
	fRestWaterRipplesTime=1.500000
	bUseNewMountCode=true
	IdleAnims(0)=bored1
	IdleAnims(1)=bored1
	IdleAnims(2)=bored1
	IdleAnims(3)=bored1
	IdleAnims(4)=bored1
	IdleAnims(5)=bored2
	IdleAnims(6)=bored2
	IdleAnims(7)=bored2
	fDoubleJumpHeight=80.0
	fJumpHeight=40.0
	bIsMainPlayer=true
	ControllerClass=class'SHGame.SHCompanionController'
	Mesh=SkeletalMesh'ShrekCharacters.Donkey'
	CollisionHeight=22.0
	Label="Donkey"
}