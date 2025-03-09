class SoldierGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var StaticMeshComponent soldierhat;

var array<GGWeapon> weapons;
var int weaponIndex;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;

		soldierhat.SetLightEnvironment( gMe.mesh.LightEnvironment );
  		gMe.mesh.AttachComponentToSocket( soldierhat, 'hairSocket' );

		weapons.AddItem(none);
		weapons.AddItem(gMe.Spawn(class'GGUnlimitedGumshot',,, vect(0, 0, -1000)));
  		weapons.AddItem(gMe.Spawn(class'GGUnlimitedGoogun',,, vect(0, 0, -1000)));
  		weapons.AddItem(gMe.Spawn(class'GGUnlimitedLovegun',,, vect(0, 0, -1000)));
  		weapons.AddItem(gMe.Spawn(class'GGUnlimitedAAGun',,, vect(0, 0, -1000)));
  		weapons.AddItem(gMe.Spawn(class'GGUnlimitedMindcontrol',,, vect(0, 0, -1000)));
  		weapons.AddItem(gMe.Spawn(class'GGUnlimitedMinigun',,, vect(0, 0, -1000)));
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	if(PCOwner != gMe.Controller)
		return;

	if( keyState == KS_Down )
	{
		if(newKey == 'LEFTCONTROL' || newKey == 'XboxTypeS_DPad_Down')
		{
			SwitchWeapon();
		}
	}
}

function SwitchWeapon()
{
	local string weaponName;

	if(gMe.mIsRagdoll)
		return;

	if(weapons[weaponIndex] != none)
	{
		weapons[weaponIndex].DetachFromPlayer();
	}

	weaponIndex++;
	if(weaponIndex == weapons.Length)
	{
		weaponIndex = 0;
	}
	weaponName = "NO WEAPON";
	if(weapons[weaponIndex] != none)
	{
		weapons[weaponIndex].AttachToPlayer(gMe, myMut);
		weaponName = weapons[weaponIndex].mWeaponJuices[weapons[weaponIndex].mJuiceIdentifier].Title;
	}
	myMut.WorldInfo.Game.Broadcast(myMut, weaponName);
}

function Tick( float deltaTime )
{
	local GGPlayerInputGame localInput;
	//Fix weapon fire in non-zombie game modes
	localInput = GGPlayerInputGame( PlayerController( gMe.Controller ).PlayerInput );
	if(localInput != none && GGPlayerInputGameZombie(localInput) == none && weapons[weaponIndex] != none)
	{
		if(localInput.mPendingAttackAuto)
		{
			localInput.mPendingAttackAuto = !weapons[weaponIndex].TryWeaponFire();
		}
	}
}
// Fix minifun keypress
function NotifyOnPossess( Controller C, Pawn P )
{
	super.NotifyOnPossess(C, P);
	if( gMe == P && GGUnlimitedMinigun(weapons[weaponIndex]) != none )
	{
		GGPlayerInput( PlayerController(C).PlayerInput ).RegisterKeyStateListner( GGUnlimitedMinigun(weapons[weaponIndex]).KeyState );
	}
}

function NotifyOnUnpossess( Controller C, Pawn P )
{
	super.NotifyOnUnpossess(C, P);
	if( gMe == P && GGUnlimitedMinigun(weapons[weaponIndex]) != none )
	{
		GGPlayerInput( PlayerController(C).PlayerInput ).UnregisterKeyStateListner( GGUnlimitedMinigun(weapons[weaponIndex]).KeyState );
	}
}

defaultproperties
{
	Begin Object class=StaticMeshComponent Name=StaticMeshComp1
		StaticMesh=StaticMesh'Hats.Mesh.GeneralHat'
	End Object
	soldierhat=StaticMeshComp1
}