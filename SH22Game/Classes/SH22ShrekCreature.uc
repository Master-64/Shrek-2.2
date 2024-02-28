// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22ShrekCreature extends SH22HeroPawn
	Config(SH22);


var() int BlendOutLandingFrame;
var() float ParentCollisionHeight, fLiveInBFGM;


function PostBeginPlay()
{
	super.PostBeginPlay();
}

function AddAnimNotifys()
{
	local MeshAnimation MeshAnim;

	super.AddAnimNotifys();
	
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddNotify(MeshAnim, LandAnims[0], float(BlendOutLandingFrame), 'AnimNotifyBlendOutLanding');
	AddNotify(MeshAnim, LandAnims[1], float(BlendOutLandingFrame), 'AnimNotifyBlendOutLanding');
}

event Tick(float deltaT)
{
	super.Tick(deltaT);
	
	if(fLiveInBFGM > 0.0)
	{
		fLiveInBFGM -= deltaT;
	}
	
	if(bIsMainPlayer && fLiveInBFGM <= 0.0 && !IsInState('stateKnockBack') && TraceUpForTable())
	{
		BFGMSwitchControlToPawn("ShrekHuman");
	}
}

function bool TraceUpForTable()
{
	local Actor HitActor;
	local vector HitLocation, HitNormal, TraceStart, TraceEnd;
	
	TraceStart = Location;
	TraceEnd = TraceStart;
	TraceEnd.Z -= CollisionHeight;
	TraceEnd.Z += 3.0 * ParentCollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, U.Vec(0.0, 0.0, 0.0));
	
	if(HitActor.IsA('FGM_Table') || HitActor.IsA('FGM_TableRound') || HitActor.IsA('FGM_TableFake'))
	{
		return false;
	}
	
	return true;
}

function bool IsTrailingChar()
{
	return false;
}

function bool MovingForward()
{
	return false;
}

state stateKnockBack
{
	function Tick(float DeltaTime)
	{
		global.Tick(DeltaTime);
		Velocity = U.Vec(0.0, 0.0, 0.0);
		Acceleration = U.Vec(0.0, 0.0, 0.0);
		return;
	}

	function BeginState()
	{
		local name animseq;

		animseq = GetAnimSequence(22);
		
		if(animseq != KnockBackAnimName)
		{
			SetAnimFrame(0.0, 22);
			AnimBlendParams(22, 0.0, 0.0, 0.0, TAKEHITBONE);
		}
		
		PlayAnim(KnockBackAnimName, RandRange(0.6, 0.7), 0.0, 22);
		AnimBlendToAlpha(22, 1.0, RandRange(0.2, 0.3));
	}

	function AnimEnd(int Channel)
	{
		if(Channel == 22)
		{
			AnimBlendToAlpha(22, 0.0, RandRange(0.2, 0.3));
			GotoState('StateIdle');
		}
	}
}


defaultproperties
{
	bCanMount=false
	bCanJump=false
	WalkAnims[0]=run
	WalkAnims[1]=runbackward
	WalkAnims[2]=StrafeLeft
	WalkAnims[3]=StrafeRight
	LandAnims[0]=land
	LandAnims[1]=land
	AirStillAnim=Fall
	RunAnimName=run
	WalkAnimName=run
	KnockBackAnimName=knockback
	bCanBlink=false
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
	TurnLeftAnim=Idle
	TurnRightAnim=Idle
}