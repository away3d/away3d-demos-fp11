package com.away3d.invawayders.archetypes
{
	/**
	 * @author robbateman
	 */
	public class ArchetypeLibrary
	{
		//different player archetypes
		public static const PLAYER:uint = 0;
		
		//internal array of invawayder archetypes
		public static const INVAWAYDERS:Vector.<uint> = Vector.<uint>([1,2,3,4]);
		
		//different projectile archetypes
		public static var PLAYER_PROJECTILE:uint = 5;
		public static var INVAWAYDER_PROJECTILE:uint = 6;
		public static var MOTHERSHIP_PROJECTILE:uint = 7;
		
		//different blast archetypes
		public static const PLAYER_BLAST:uint = 8;
		public static const INVAWAYDER_BLAST:uint = 9;
		
		public static function getArchetype(id:uint) : ArchetypeBase
		{
			if (!_instance)
				_instance = new ArchetypeLibrary();
			
			return _instance.archetypes[id];
		}
		
		private static var _instance:ArchetypeLibrary;
		
		protected var archetypes : Vector.<ArchetypeBase>;
		
		public function ArchetypeLibrary()
		{
			archetypes = new Vector.<ArchetypeBase>();
			archetypes.push(new PlayerArchetype());
			archetypes.push(new BugInvawayderArchetype());
			archetypes.push(new OctopusInvawayderArchetype());
			archetypes.push(new RoundedOctopusInvawayderArchetype());
			archetypes.push(new MothershipInvawayderArchetype());
			archetypes.push(new PlayerProjectileArchetype());
			archetypes.push(new InvawayderProjectileArchetype());
			archetypes.push(new MothershipProjectileArchetype());
			archetypes.push(new PlayerBlastArchetype());
			archetypes.push(new InvawayderBlastArchetype());
		}
	}
}
