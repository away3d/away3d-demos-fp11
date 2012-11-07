package com.away3d.invawayders.archetypes.subtypes
{
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.sounds.*;
	
	
	/**
	 * Data class for fragments data
	 */
	public class MothershipFragmentsArchetype extends FragmentsArchetype
	{
		public function MothershipFragmentsArchetype()
		{
			id = FragmentsArchetype.MOTHERSHIP;
			
			soundOnAdd = SoundLibrary.EXPLOSION_STRONG;
		}
	}
}
