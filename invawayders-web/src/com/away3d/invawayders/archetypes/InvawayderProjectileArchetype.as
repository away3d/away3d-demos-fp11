package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.sounds.*;
	
	import away3d.materials.*;
	import away3d.primitives.*;
	
	/**
	 * Data class for Invawayder projectile data
	 */
	public class InvawayderProjectileArchetype extends ArchetypeBase
	{
		public function InvawayderProjectileArchetype()
		{
			id = ArchetypeLibrary.INVAWAYDER_PROJECTILE;
			
			geometry = new CubeGeometry( 25, 25, 200, 1, 1, 4 );
			
			material = new ColorMaterial( 0xFF0000 );
			
			soundOnAdd = SoundLibrary.INVAWAYDER_FIRE;
			
			Component = Bullet;
		}
	}
}
