class GGUnlimitedMindcontrol extends GGMindcontrolComponentsContent;

function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	SoldierGoat(owningMutator).AttachWeapon(goat, self, true);
}

function DetachFromPlayer( optional bool removeWeaponInstantly, optional bool keepWeaponAlive )
{
	SoldierGoat(mOwningMutator).DetachWeapon(self, removeWeaponInstantly, keepWeaponAlive, true);
}

function AttachToSurvivor( GGNpcSurvivorAbstract survivor, name survivorWeaponBoneName )
{
	SoldierGoat(mOwningMutator).AttachWeaponToSurvivor(survivor, survivorWeaponBoneName, class'GGMindcontrolComponents');
}

DefaultProperties
{
	mConsumeAmmo=false
	mMaxAmmo=5999994
}