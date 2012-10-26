package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	
	import away3d.materials.*;
	import away3d.primitives.*;
	
	/**
	 * Data class for Player projectile data
	 */
	public class PlayerArchetype extends ArchetypeBase
	{
		public function PlayerArchetype()
		{
			id = ArchetypeLibrary.PLAYER;
			
			geometry = new CubeGeometry( 25, 25, 500 );
			
			material = new ColorMaterial( 0xFFFFFF );
			
			Component = Player;
		}
	}
}
