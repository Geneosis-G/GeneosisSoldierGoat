class GGUnlimitedLovegun extends GGLovegunComponentsContent;

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
	SoldierGoat(mOwningMutator).AttachWeaponToSurvivor(survivor, survivorWeaponBoneName, class'GGLovegunComponents');
}

DefaultProperties
{
	mConsumeAmmo=false
	mMaxAmmo=5999994
}