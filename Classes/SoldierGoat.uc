class SoldierGoat extends GGMutator;

var array<SoldierGoatComponent> mComponents;
struct TexturedNpc
{
	var GGNpc npc;
	var MaterialInstanceConstant MIC;
};
var array<TexturedNpc> texturedNpcs;

var Material mLegacyInstanceMaterial;

var ParticleSystem mDisintegrationPSTemplate, mDisintegrationBurstPSTemplate;
var SoundCue mDisintegrationSound;

struct SurvivorWeapon
{
	var GGNpcSurvivorAbstract npc;
	var GGWeapon wp;
};
var array<SurvivorWeapon> delayedSurvivorWeapons;

/**
 * See super.
 */
function ModifyPlayer(Pawn Other)
{
	local GGGoat goat;
	local SoldierGoatComponent soldierComp;

	super.ModifyPlayer( other );

	goat = GGGoat( other );
	if( goat != none )
	{
		soldierComp=SoldierGoatComponent(GGGameInfo( class'WorldInfo'.static.GetWorldInfo().Game ).FindMutatorComponent(class'SoldierGoatComponent', goat.mCachedSlotNr));
		if(soldierComp != none && mComponents.Find(soldierComp) == INDEX_NONE)
		{
			mComponents.AddItem(soldierComp);
		}
	}
}

event Tick(float deltaTime)
{
	local SoldierGoatComponent comp;
	local SurvivorWeapon sw;
	local int i;

	super.Tick(deltaTime);
	// Clean textured NPC list
	for(i = 0; i<texturedNpcs.Length ; i = i)
	{
		if(texturedNpcs[i].npc == none || texturedNpcs[i].npc.bPendingDelete)
		{
			texturedNpcs.Remove(i, 1);
		}
		else
		{
			i++;
		}
	}
	// Fix survivor stealing the wrong weapon
	foreach delayedSurvivorWeapons(sw)
	{
		sw.npc.mEquippedWeapon = sw.wp;
	}
	delayedSurvivorWeapons.Length=0;

	foreach mComponents(comp)
	{
		comp.Tick(deltaTime);
	}
}

function DelayedAttachWeaponToSurvivor(GGNpcSurvivorAbstract npc, GGWeapon wp)
{
	local SurvivorWeapon sw;

	sw.npc = npc;
	sw.wp = wp;
	delayedSurvivorWeapons.AddItem(sw);
}

function OnTakeDamage( Actor damagedActor, Actor damageCauser, int damage, class< DamageType > dmgType, vector momentum )
{
	local GGNpc damagedNpc;
	//Fix various NPC effects on non-zombie NPCs
	damagedNpc = GGNpc(damagedActor);
	if(damagedNpc == none || GGNpcZombieGameModeAbstract(damagedNpc) != none)
		return;

	if(class< GGDamageTypeLoveGun >(dmgType) != none)
 	{
 		Disintegrate(damagedNpc, GGPawn(damageCauser).Controller);
 	}

	if(class< GGDamageTypeAntiquer >(dmgType) != none)
	{
		SetScalarParameterValue(damagedNpc, 'AntiqueActive', 1 );
	}
}

function SetScalarParameterValue(GGNpc npc, name param, float value)
{
	local int index;

	index = texturedNpcs.Find('npc', npc);
	if(index == INDEX_NONE)
	{
		index = InitMIC(npc);
	}

	texturedNpcs[index].MIC.SetScalarParameterValue( param, value );
}

// Creates a controllable MaterialInstanceConstant for the zombies!
function int InitMIC(GGNpc npc)
{
	local int i, matIndex;
	local bool matChanged;
	local TexturedNpc newTN;

	newTN.npc = npc;
	matChanged = false;
	for ( i = 0; i < class'GGZombieManager'.default.mZombieTypeData.Length; i++ )
	{
		if( class'GGZombieManager'.default.mZombieTypeData[ i ].OriginalTexture != None &&
			npc.mesh.GetMaterial( 0 ) == class'GGZombieManager'.default.mZombieTypeData[ i ].NormalMaterial )
		{
			npc.mesh.SetMaterial( 0, mLegacyInstanceMaterial );
			matIndex = i;
			matChanged = true;
		}
	}

	newTN.MIC = npc.mesh.CreateAndSetMaterialInstanceConstant( 0 );
	if(matChanged)
	{
		newTN.MIC.SetTextureParameterValue( 'Diffuse', class'GGZombieManager'.default.mZombieTypeData[matIndex].OriginalTexture);
	}
	texturedNpcs.AddItem(newTN);

	return texturedNpcs.Length-1;
}

/**
 * When NPCs are hit by the Lovegun they should get blown to dust
 */
function Disintegrate(GGNpc npc, optional controller inst)
{
	local ParticleSystemComponent disPSC;
	local ParticleSysParam instanceParam;
	local int i, attachmentCount;

	PlaySound( mDisintegrationSound, false, , , npc.Location );

	disPSC = WorldInfo.MyEmitterPool.SpawnEmitter( mDisintegrationPSTemplate, npc.Location );
	WorldInfo.MyEmitterPool.SpawnEmitter( mDisintegrationBurstPSTemplate, npc.Location );

	instanceParam.Name = 'VertSurfaceActor';
	instanceParam.ParamType = PSPT_Actor;
	instanceParam.Actor = npc;

	disPSC.InstanceParameters.Length = 0;
	disPSC.InstanceParameters[0] = instanceParam;

	attachmentCount = npc.Attached.Length;

	// Destroy any attachments (Signs, masks etc)
	if(attachmentCount > 0)
	{
		for( i = 0; i < attachmentCount; i++ )
		{
			npc.Attached[0].ShutDown();
			npc.Attached[0].Destroy();
		}
	}
	texturedNpcs.Remove(texturedNpcs.Find('npc', npc), 1);
	npc.SetPhysics(PHYS_None);
	npc.SetLocation(vect(0, 0, -1000));
	npc.SetHidden(true);
	npc.ShutDown();
	npc.Destroy();
}

function AttachWeapon( GGGoat goat, GGWeapon weapon, optional bool registerInterface)
{
	local GGGameInfoZombie game;

	weapon.mGoat = goat;
	game = GGGameInfoZombie( class'WorldInfo'.static.GetWorldInfo().Game);

	if(weapon.mGoat != None)
	{
		`log(weapon@"was attached to"@goat);
		weapon.mOwningMutator = self;
		weapon.mSlotNr = weapon.mGoat.mCachedSlotNr;

		if(game != None)
		{
			game.RegisterWeapon( weapon, weapon.mSlotNr );
			game.OnWeaponPickup( weapon.mGoat, weapon.class );
			if(registerInterface) game.mZombieGMNotificationInterfaceListeners.AddItem( weapon );
		}

		goat.mesh.AttachComponentToSocket( weapon.mWeaponMesh, weapon.mWeaponSocketName );

		weapon.mWeaponMesh.SetLightEnvironment( goat.mesh.lightenvironment );

		//@todo this should probably change if we decide to make the weapon droppable
		weapon.mCurrentAmmo = weapon.mMaxAmmo;

		if( weapon.mPickUpSound != none )
		{
			weapon.PlaySound( weapon.mPickUpSound, false,,, goat.Location );
		}

		if(weapon.mCrosshairActor == None && weapon.mCrosshairActive)
		{
			weapon.SpawnCrosshair(goat);
		}

		if(GGGoatZombieGamemode(goat) != None)
		{
			weapon.mZombieHUDMovie = GGHUDGfxIngameZombie( GGHUDZombie( GGPlayerControllerGame(goat.controller).myHUD ).mHUDMovie );

			if(weapon.mZombieHUDMovie != None)
			{
				weapon.mZombieHUDMovie.ToggleweaponStats(true);
			}
		}

		weapon.mReadyToFire = true;
	}
	else
	{
		weapon.DetachFromPlayer();
	}
}

function DetachWeapon(GGWeapon weapon, optional bool removeWeaponInstantly, optional bool keepWeaponAlive, optional bool unregisterInterface)
{
	local GGGameInfoZombie game;
	//Survivor try to steal the weapon, ignore him
	if(removeWeaponInstantly && keepWeaponAlive)
		return;

	game = GGGameInfoZombie( class'WorldInfo'.static.GetWorldInfo().Game);

	if( weapon.mGoat != none )
	{
		weapon.mGoat.mesh.DetachComponent( weapon.mWeaponMesh );
	}
	if(weapon.mCrosshairActor != None)
	{
		weapon.mCrosshairActor.DestroyCrosshair();
	}

	if(game != none)
	{
		if(unregisterInterface) game.mZombieGMNotificationInterfaceListeners.RemoveItem( weapon );
		game.RemoveWeapon( weapon, weapon.mSlotNr );
	}

	weapon.mGoat = none; // Just to make sure

	if(weapon.mZombieHUDMovie != None)
	{
		weapon.mZombieHUDMovie.ToggleweaponStats(false);
		weapon.mZombieHUDMovie = none;
	}
}

function AttachWeaponToSurvivor(GGNpcSurvivorAbstract survivor, name survivorWeaponBoneName, class<GGWeapon> weaponClass)
{
	local GGWeapon newWeapon;
	//Survivor try to steal the weapon, give him a standard copy
	if( survivor != none )
	{
		newWeapon = Spawn(weaponClass);
		newWeapon.AttachToSurvivor(survivor, survivorWeaponBoneName);
		DelayedAttachWeaponToSurvivor(survivor, newWeapon);
	}
}

DefaultProperties
{
	mMutatorComponentClass=class'SoldierGoatComponent'

	mLegacyInstanceMaterial=Material'Human_Characters.Materials.M_Survival_Character_Mat'

	mDisintegrationPSTemplate=ParticleSystem'Zombie_Particles.Particles.Disintegration_ParticleSystem'
	mDisintegrationBurstPSTemplate=ParticleSystem'Zombie_Particles.Particles.Disintegration_Burst_PS'
	mDisintegrationSound=SoundCue'Zombie_Weapon_Sounds.Lovegun.Lovegun_ProjectileImpact_Cue'
}