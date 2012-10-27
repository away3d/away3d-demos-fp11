package com.away3d.invawayders.components
{
	import away3d.containers.*;
	
	import flash.geom.*;
	
	public class Explosion
	{
		public var currentFrame : uint;
		
		public var cellContainers : Vector.<ObjectContainer3D>;
		
		public var cellVelocities : Vector.<Vector.<Vector3D>>;
		
		public var cellRotationalVelocities : Vector.<Vector.<Vector3D>>;
		
		public var cellDeathTimers : Vector.<Vector.<uint>>;
		
		public function Explosion(cellContainers : Vector.<ObjectContainer3D>, cellVelocities : Vector.<Vector.<Vector3D>>, cellRotationalVelocities : Vector.<Vector.<Vector3D>>, cellDeathTimers : Vector.<Vector.<uint>>)
		{
			this.cellContainers = cellContainers;
			this.cellVelocities = cellVelocities;
			this.cellRotationalVelocities = cellRotationalVelocities;
			this.cellDeathTimers = cellDeathTimers;
		}
	}
}
