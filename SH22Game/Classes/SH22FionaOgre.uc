// *****************************************************
// *			  Shrek 2.2 by Master_64			   *
// *		  Copyrighted (c) Master_64, 2019		   *
// *   May be modified but not without proper credit!  *
// *****************************************************


class SH22FionaOgre extends SH22HeroPawn
	Config(SH22);


var int TotalGameStateTokens, GameStateTokenLen;
var(GameState) const editconst string GameStateMasterList;
var(GameState) travel string CurrentGameState;


function PostBeginPlay()
{
	local MeshAnimation MeshAnim;
	
	super.PostBeginPlay();
	
	MeshAnim = MeshAnimation(DynamicLoadObject(string(Mesh), class'MeshAnimation'));
	LinkSkelAnim(MeshAnim);
	AddFootStepsNotify(MeshAnim);
}


defaultproperties
{
	NewTag=Fiona
	RunAnimName=run
	WalkAnimName=Walk
	GroundRunSpeed=300.0
	GroundWalkSpeed=150.0
	NeckRotElement=RE_RollNeg
	HeadRotElement=RE_YawNeg
	BaseMovementRate=300.0
	_BaseMovementRate=300.0
	Mesh=SkeletalMesh'ShrekCharacters.fiona_o'
	CollisionRadius=20.0
	CollisionHeight=38.0
}