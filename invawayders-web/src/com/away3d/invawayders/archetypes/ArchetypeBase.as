package com.away3d.invawayders.archetypes
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.materials.*;
	
	import net.richardlord.ash.core.*;
	
	/**
	 * Base class for invawayder archetypes.
	 */
	public class ArchetypeBase
	{
		protected var subTypes:Vector.<ArchetypeBase>;
		
		public var id : uint;
		
		public var geometry : Geometry;
		
		public var material : ColorMaterial;
		
		/**
		 * An instance of the 3d object representing the entity view, from which new views are cloned.
		 * Created the first time the entity view of an archetype is requested, and used to clone a view for all subsequent entity requests.
		 */
		public var entityView:ObjectContainer3D;
		
		public var entityPool:Vector.<Entity> = new Vector.<Entity>();
		
		public var soundOnAdd:String;
		
		public var soundOnRemove:String;
		
		public var Component : Class;
		
		public function ArchetypeBase(subTypes:Vector.<ArchetypeBase> = null)
		{
			this.subTypes = subTypes || new Vector.<ArchetypeBase>();
		}
		
		public function getSubType(subId : uint):ArchetypeBase
		{
			if (subTypes.length < subId + 1)
				subTypes.length = subId + 1;
			
			if (subTypes[subId])
				return subTypes[subId];
			
			return clone(subTypes[subId], subId);
		}
		
		protected function clone(archetype:ArchetypeBase, subId : uint):ArchetypeBase
		{
			archetype ||= new ArchetypeBase();
			archetype.id = subId;
			archetype.geometry ||= geometry;
			archetype.material ||= material;
			archetype.soundOnAdd ||= soundOnAdd;
			archetype.soundOnRemove ||= soundOnRemove;
			archetype.Component ||= Component;
			
			return archetype;
		}
	}
}
