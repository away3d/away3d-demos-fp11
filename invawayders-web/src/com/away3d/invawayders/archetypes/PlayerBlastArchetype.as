package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	
	import away3d.materials.*;
	import away3d.primitives.*;
	
	/**
	 * Data class for Player projectile data
	 */
	public class PlayerBlastArchetype extends ArchetypeBase
	{
		public function PlayerBlastArchetype()
		{
			id = ArchetypeLibrary.PLAYER_BLAST;
			
			geometry = new SphereGeometry();
			
			material = new ColorMaterial( 0xFF0000, 0.5 );
			
			Component = Blast;
		}
	}
}
