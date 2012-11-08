package com.away3d.invawayders.archetypes
{
	import com.away3d.invawayders.archetypes.subtypes.*;
	
	/**
	 * @author robbateman
	 */
	public class ArchetypeLibrary
	{
		private static var _instance:ArchetypeLibrary;
		
		//available archetypes
		public static const PLAYER:uint = 0;
		public static const INVAWAYDER:uint = 1;
		public static const PROJECTILE:uint = 2;
		public static const BLAST:uint = 3;
		public static const FRAGMENTS:uint = 4;
		public static const EXPLOSION:uint = 5;
		
		public static function getArchetype(id:uint) : ArchetypeBase
		{
			if (!_instance)
				_instance = new ArchetypeLibrary();
			
			return _instance.archetypes[id];
		}
		
		protected var archetypes : Vector.<ArchetypeBase>;
		
		public function ArchetypeLibrary()
		{
			archetypes = new Vector.<ArchetypeBase>();
			archetypes.push(new PlayerArchetype());
			archetypes.push(new InvawayderArchetype(Vector.<ArchetypeBase>([new BugInvawayderArchetype(), new MothershipInvawayderArchetype(), new OctopusInvawayderArchetype(), new RoundedOctopusInvawayderArchetype()])));
			archetypes.push(new ProjectileArchetype(Vector.<ArchetypeBase>([new InvawayderProjectileArchetype(), new PlayerProjectileArchetype()])));
			archetypes.push(new BlastArchetype(Vector.<ArchetypeBase>([new PlayerBlastArchetype(), new InvawayderBlastArchetype()])));
			archetypes.push(new FragmentsArchetype(Vector.<ArchetypeBase>([null, new MothershipFragmentsArchetype()])));
			archetypes.push(new ExplosionArchetype());
		}
	}
}
