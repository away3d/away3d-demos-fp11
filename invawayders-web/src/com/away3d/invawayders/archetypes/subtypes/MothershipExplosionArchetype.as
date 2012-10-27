package com.away3d.invawayders.archetypes.subtypes
{
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.sounds.*;
	
	
	/**
	 * Data class for explosion data
	 */
	public class MothershipExplosionArchetype extends ExplosionArchetype
	{
		public function MothershipExplosionArchetype()
		{
			id = ExplosionArchetype.MOTHERSHIP;
			
			soundOnAdd = SoundLibrary.EXPLOSION_STRONG;
		}
	}
}
