class GGUnlimitedMinigun extends GGMinigunComponentsContent;

function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	SoldierGoat(owningMutator).AttachWeapon(goat, self, true);
	if( mGoat != none )
    {
		if(!mManualStart)
	    {
	        StartWeaponTimers();
	    }
	    if(PlayerController( mGoat.Controller ) != none)
	    {
	    	GGPlayerInput( PlayerController( mGoat.Controller ).PlayerInput ).RegisterKeyStateListner( KeyState );
	    }
	}
}

function DetachFromPlayer( optional bool removeWeaponInstantly, optional bool keepWeaponAlive )
{
	//Survivor try to steal the weapon, ignore him
	if(removeWeaponInstantly && keepWeaponAlive)
		return;
	if( mRevvingUp || mGunFiring )
    {
        StopFiring( false );
    }

    if( mGoat != none && PlayerController( mGoat.Controller ) != none)
    {
        GGPlayerInput( PlayerController( mGoat.Controller ).PlayerInput ).UnregisterKeyStateListner( KeyState );
    }

    SoldierGoat(mOwningMutator).DetachWeapon(self, removeWeaponInstantly, keepWeaponAlive, true);
}

function AttachToSurvivor( GGNpcSurvivorAbstract survivor, name survivorWeaponBoneName )
{
	SoldierGoat(mOwningMutator).AttachWeaponToSurvivor(survivor, survivorWeaponBoneName, class'GGMinigunComponents');
}

DefaultProperties
{
	mConsumeAmmo=false
	mMaxAmmo=5999994
}