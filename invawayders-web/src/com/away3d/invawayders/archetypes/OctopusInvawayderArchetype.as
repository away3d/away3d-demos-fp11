package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.sounds.*;
	
	import flash.geom.*;
	
	/**
	 * Data class for Octopus Invawayder
	 */
	public class OctopusInvawayderArchetype extends InvawayderArchetype
	{
		public function OctopusInvawayderArchetype()
		{
			id = ArchetypeLibrary.INVAWAYDERS[1];
			
			cellDefinitions = Vector.<Vector.<uint>>([
				Vector.<uint>([
					0, 0, 0, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 1, 1, 0, 0,
					0, 1, 1, 1, 1, 1, 1, 0,
					1, 1, 0, 1, 1, 0, 1, 1,
					1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 1, 0, 0, 1, 0, 0,
					0, 1, 0, 1, 1, 0, 1, 0,
					1, 0, 1, 0, 0, 1, 0, 1
				]),
				Vector.<uint>([
					0, 0, 0, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 1, 1, 0, 0,
					0, 1, 1, 1, 1, 1, 1, 0,
					1, 1, 0, 1, 1, 0, 1, 1,
					1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 1, 0, 0, 1, 0, 0,
					0, 1, 0, 0, 0, 0, 1, 0,
					0, 0, 1, 0, 0, 1, 0, 0
				])
			]);
			
			dimensions = new Point( 8, 8 );
			
			life = 1;
			
			spawnRate = 20000;
			
			fireRate = 1000;
			
			panAmplitude = 500;
			
			speed = 25;
			
			scale = 1;
			
			score = 100;
			
			soundOnRemove = SoundLibrary.INVAWAYDER_DEATH;
			
			projectileArchetype = ArchetypeLibrary.INVAWAYDER_PROJECTILE;
			
			Component = Invawayder;
		}
	}
}
