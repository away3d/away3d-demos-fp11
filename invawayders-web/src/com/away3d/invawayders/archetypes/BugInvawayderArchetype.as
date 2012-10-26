package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.sounds.*;
	
	import flash.geom.*;
	
	/**
	 * Data class for Bug Invawayder
	 */
	public class BugInvawayderArchetype extends InvawayderArchetype
	{
		public function BugInvawayderArchetype()
		{
			id = ArchetypeLibrary.INVAWAYDERS[0];
			
			cellDefinitions = Vector.<Vector.<uint>>([
				Vector.<uint>([
					0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,
					0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
					0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0,
					0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1,
					1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1,
					0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0
				]),
				Vector.<uint>([
					0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,
					1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1,
					1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1,
					1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1,
					1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
					0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
					0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,
					0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0
				])
			]);
			
			dimensions = new Point( 11, 8 );
			
			life = 2;
			
			spawnRate = 10000;
			
			fireRate = 1500;
			
			panAmplitude = 250;
			
			speed = 50;
			
			scale = 1;
			
			score = 30;
			
			soundOnRemove = SoundLibrary.INVAWAYDER_DEATH;
			
			projectileArchetype = ArchetypeLibrary.INVAWAYDER_PROJECTILE;
			
			Component = Invawayder;
		}
	}
}
