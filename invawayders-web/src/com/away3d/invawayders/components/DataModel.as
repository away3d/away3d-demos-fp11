package com.away3d.invawayders.components
{
	import com.away3d.invawayders.archetypes.*;
	
	/**
	 * @author robbateman
	 */
	public class DataModel
	{
		public var archetype : ArchetypeBase;
		public var subType : ArchetypeBase;
		
		public function DataModel( archetype : ArchetypeBase, subType : ArchetypeBase )
		{
			this.archetype = archetype;
			this.subType = subType;
		}
	}
}
