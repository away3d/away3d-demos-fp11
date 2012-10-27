package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.sounds.*;
	
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	
	/**
	 * Data class for explosion data
	 */
	public class ExplosionArchetype extends ArchetypeBase
	{
		public var cellContainers:Vector.<ObjectContainer3D>;
		
		public static const explosionGeometry:Geometry = new CubeGeometry( GameSettings.invawayderSizeXY, GameSettings.invawayderSizeXY, GameSettings.invawayderSizeZ );
		
		public static const explosionMaterial:ColorMaterial = new ColorMaterial( 0x777780);
		
		public function ExplosionArchetype(subTypes:Vector.<ArchetypeBase> = null)
		{
			super(subTypes);
			
			id = ArchetypeLibrary.EXPLOSION;
			
			geometry = explosionGeometry;
			
			material = explosionMaterial;
			
			soundOnAdd = SoundLibrary.INVAWAYDER_DEATH;
			
			Component = Explosion;
		}
		
		override protected function clone(archetype:ArchetypeBase, subId:uint):ArchetypeBase
		{
			return super.clone(archetype ||= new ExplosionArchetype(), subId);
		}
	}
}
