package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.sounds.*;
	
	import away3d.materials.*;
	
	/**
	 * Data class for Player projectile data
	 */
	public class PlayerProjectileArchetype extends ProjectileArchetype
	{
		public function PlayerProjectileArchetype()
		{
			id = ProjectileArchetype.PLAYER;
			
			material = new ColorMaterial( 0x00FFFF, 0.75 );
			
			soundOnAdd = SoundLibrary.PLAYER_FIRE;
		}
	}
}