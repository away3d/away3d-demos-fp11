package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.sounds.*;
	
	import away3d.materials.*;
	import away3d.primitives.*;
	
	/**
	 * Data class for Player projectile data
	 */
	public class PlayerProjectileArchetype extends ArchetypeBase
	{
		public function PlayerProjectileArchetype()
		{
			id = ArchetypeLibrary.PLAYER_PROJECTILE;
			
			geometry = new CubeGeometry( 25, 25, 200 );
			
			material = new ColorMaterial( 0x00FFFF, 0.75 );
			
			soundOnAdd = SoundLibrary.PLAYER_FIRE;
			
			Component = Bullet;
		}
	}
}
