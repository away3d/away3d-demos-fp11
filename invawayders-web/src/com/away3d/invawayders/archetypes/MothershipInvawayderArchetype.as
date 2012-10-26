package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.sounds.*;
	
	import flash.geom.*;
	
	/**
	 * Data class for Mothership Invawayder
	 */
	public class MothershipInvawayderArchetype extends InvawayderArchetype
	{
		public function MothershipInvawayderArchetype()
		{
			id = ArchetypeLibrary.INVAWAYDERS[3];
			
			cellDefinitions = Vector.<Vector.<uint>>([
				Vector.<uint>([
					0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
					0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
					0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0,
					0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
				]),
				Vector.<uint>([
					0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
					0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
					0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
					0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
				])
			]);
			
			dimensions = new Point( 16, 7 );
			
			life = 20;
			
			spawnRate = 120000;
			
			fireRate = 200;
			
			panAmplitude = 0;
			
			speed = 10;
			
			scale = 3;
			
			score = 200;
			
			soundOnAdd = SoundLibrary.MOTHERSHIP;
			
			soundOnRemove = SoundLibrary.EXPLOSION_STRONG;
			
			projectileArchetype = ArchetypeLibrary.MOTHERSHIP_PROJECTILE;
			
			Component = Invawayder;
		}
	}
}
