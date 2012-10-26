package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	
	import away3d.materials.*;
	import away3d.primitives.*;
	
	/**
	 * Data class for Player projectile data
	 */
	public class InvawayderBlastArchetype extends ArchetypeBase
	{
		public function InvawayderBlastArchetype()
		{
			id = ArchetypeLibrary.INVAWAYDER_BLAST;
			
			geometry = new SphereGeometry();
			
			material = new ColorMaterial( 0x00FFFF, 0.5 );
			
			Component = Blast;
		}
	}
}
