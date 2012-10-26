package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.sounds.*;
	
	import flash.geom.*;
	
	/**
	 * Data class for Rounded Octopus Invawayder
	 */
	public class RoundedOctopusInvawayderArchetype extends InvawayderArchetype
	{
		public function RoundedOctopusInvawayderArchetype()
		{
			id = ArchetypeLibrary.INVAWAYDERS[2];
			
			cellDefinitions = Vector.<Vector.<uint>>([
				Vector.<uint>([
					0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
					0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0,
					1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
				]),
				Vector.<uint>([
					0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
					0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0,
					0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0
				])
			]);
			
			dimensions = new Point( 12, 8 );
			
			life = 4;
			
			spawnRate = 6000;
			
			fireRate = 2000;
			
			panAmplitude = 0;
			
			speed = 100;
			
			scale = 1;
			
			score = 10;
			
			soundOnRemove = SoundLibrary.INVAWAYDER_DEATH;
			
			projectileArchetype = ArchetypeLibrary.INVAWAYDER_PROJECTILE;
			
			Component = Invawayder;
		}
	}
}
