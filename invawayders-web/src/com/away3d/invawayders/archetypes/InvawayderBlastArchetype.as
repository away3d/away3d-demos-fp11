package com.away3d.invawayders.archetypes
{
	import away3d.materials.*;
	
	/**
	 * Data class for Player projectile data
	 */
	public class InvawayderBlastArchetype extends BlastArchetype
	{
		public function InvawayderBlastArchetype()
		{
			id = BlastArchetype.INVAWAYDER;
			
			material = new ColorMaterial( 0x00FFFF, 0.5 );
		}
	}
}
