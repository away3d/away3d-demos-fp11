package com.away3d.invawayders.archetypes.subtypes
{
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.sounds.*;
	
	/**
	 * Data class for Invawayder projectile data
	 */
	public class InvawayderProjectileArchetype extends ProjectileArchetype
	{
		public function InvawayderProjectileArchetype()
		{
			id = ProjectileArchetype.INVAWAYDER;
			
			soundOnAdd = SoundLibrary.INVAWAYDER_FIRE;
		}
	}
}
