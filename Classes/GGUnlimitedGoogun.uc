class GGUnlimitedGoogun extends GGGoogunComponentsContent;

var GGNpc mNPCToRelaxNZ;

function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	SoldierGoat(owningMutator).AttachWeapon(goat, self);
}

function DetachFromPlayer( optional bool removeWeaponInstantly, optional bool keepWeaponAlive )
{
	SoldierGoat(mOwningMutator).DetachWeapon(self, removeWeaponInstantly, keepWeaponAlive);
}

function AttachToSurvivor( GGNpcSurvivorAbstract survivor, name survivorWeaponBoneName )
{
	SoldierGoat(mOwningMutator).AttachWeaponToSurvivor(survivor, survivorWeaponBoneName, class'GGGoogunComponents');
}

function TurnIntoGoo(Actor a, GGGoat goat)
{
	local GGNpc npc;

	super.TurnIntoGoo(a, goat);

	npc = GGNpc(a);

	if(npc != None && GGNpcZombieGameModeAbstract(npc) == none)
	{
		SoldierGoat(mOwningMutator).SetScalarParameterValue(npc, 'FlubberActive', 1);

		mGoat.SetTimer( 0.5f, false, NameOf(MakeNPCRelaxed), self );

		mNPCToRelaxNZ = npc;

		npc.mesh.SetPhysicsAsset( mGooPhysAsset );
	}
}

function MakeNPCRelaxed()
{
	super.MakeNPCRelaxed();

	if(mNPCToRelaxNZ != None)
	{
		mNPCToRelaxNZ.mesh.SetPhysicsAsset( mGooPhysAsset );
	}
}

DefaultProperties
{
	mConsumeAmmo=false
	mMaxAmmo=5999994
}