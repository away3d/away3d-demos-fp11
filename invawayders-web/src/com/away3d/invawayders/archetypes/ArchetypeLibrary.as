package com.away3d.invawayders.archetypes
{
	/**
	 * @author robbateman
	 */
	public class ArchetypeLibrary
	{
		private static var _instance:ArchetypeLibrary;
		
		//player archetype
		public static const PLAYER:uint = 0;
		
		//invawayder archetype
		public static const INVAWAYDER:uint = 1;
		
		//projectile archetype
		public static var PROJECTILE:uint = 2;
		
		//blast archetype
		public static const BLAST:uint = 3;
		
		//explosion archetype
		public static const EXPLOSION:uint = 4;
		
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
			archetypes.push(new ExplosionArchetype());
		}
	}
}
