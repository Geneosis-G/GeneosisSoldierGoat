class GGUnlimitedAAGun extends GGAAGunComponentsContent;

function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	mWeaponMesh.AttachComponentToSocket( mAttachedBag, 'BagSocketStatic' );
	SoldierGoat(owningMutator).AttachWeapon(goat, self);
}

function DetachFromPlayer( optional bool removeWeaponInstantly, optional bool keepWeaponAlive )
{
	SoldierGoat(mOwningMutator).DetachWeapon(self, removeWeaponInstantly, keepWeaponAlive);
}

function AttachToSurvivor( GGNpcSurvivorAbstract survivor, name survivorWeaponBoneName )
{
	SoldierGoat(mOwningMutator).AttachWeaponToSurvivor(survivor, survivorWeaponBoneName, class'GGAAGunComponents');
}

DefaultProperties
{
	mConsumeAmmo=false
	mMaxAmmo=5999994
}