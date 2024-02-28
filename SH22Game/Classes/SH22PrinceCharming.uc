// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22PrinceCharming extends SH22HeroPawn
	Config(SH22);


function PostBeginPlay()
{
	local MeshAnimation MeshAnim;

	super.PostBeginPlay();
	MeshAnim = MeshAnimation(DynamicLoadObject("ShrekCharacters.PrinceCharming", class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddFootStepsNotify(MeshAnim);
}


defaultproperties
{
	RunAnimName=run
	WalkAnimName=Walk
	GroundRunSpeed=300.0
	GroundWalkSpeed=150.0
	LeftUpperLidBone=body_l_toplid_joint
	LeftLowerLidBone=body_l_bottomlid_joint
	RightUpperLidBone=body_r_toplid_joint
	RightLowerLidBone=body_r_bottomlid_joint
	NeckRotElement=RE_RollNeg
	HeadRotElement=RE_YawNeg
	IdleAnims(0)=Idle
	IdleAnims(1)=Idle
	IdleAnims(2)=Idle
	IdleAnims(3)=Idle
	IdleAnims(4)=Idle
	IdleAnims(5)=Idle
	IdleAnims(6)=Idle
	IdleAnims(7)=Idle
	BaseMovementRate=300.0
	_BaseMovementRate=300.0
	Mesh=SkeletalMesh'ShrekCharacters.PrinceCharming'
	CollisionRadius=15.0
	CollisionHeight=38.0
}