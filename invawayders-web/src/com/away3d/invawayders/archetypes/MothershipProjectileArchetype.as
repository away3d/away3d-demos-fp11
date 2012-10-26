package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	
	import away3d.materials.*;
	import away3d.primitives.*;
	
	/**
	 * Data class for Mothership projectile archetype
	 */
	public class MothershipProjectileArchetype extends ArchetypeBase
	{
		public function MothershipProjectileArchetype()
		{
			id = ArchetypeLibrary.MOTHERSHIP_PROJECTILE;
			
			geometry = new CubeGeometry( 25, 25, 200, 1, 1, 4 );
			
			material = new ColorMaterial( 0xFF0000 );
			
			Component = Bullet;
		}
	}
}
