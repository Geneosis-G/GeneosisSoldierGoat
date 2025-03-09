class GGUnlimitedGumshot extends GGGumshotComponentsContent;

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
	SoldierGoat(mOwningMutator).AttachWeaponToSurvivor(survivor, survivorWeaponBoneName, class'GGGumshotComponents');
}
// Fix decals
function SpawnDecal(ImpactInfo Impact)
{
	local LinearColor lc;

	super.SpawnDecal(Impact);

	lc = GetRandomColor();

	mRandomColorMat = new() Class'MaterialInstanceConstant';
	mRandomColorMat.SetParent( mHitDecalMat );
	mRandomColorMat.SetVectorParameterValue( 'Color', lc);

	if( GGNpc(Impact.HitActor) != none && GGNpcZombieGameModeAbstract(Impact.HitActor) == None )
	{
		SoldierGoat(mOwningMutator).SetScalarParameterValue(GGNpc(Impact.HitActor), 'GumshotActive', 1);
	}
}

DefaultProperties
{
	mConsumeAmmo=false
	mMaxAmmo=5999994
}