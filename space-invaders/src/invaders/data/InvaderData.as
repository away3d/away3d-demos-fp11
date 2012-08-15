package invaders.data
{
	import invaders.objects.*;
	
	import flash.geom.*;
	
	/**
	 * 
	 */
	public class InvaderData
	{
		public var cellDefinition:Vector.<Vector.<uint>>;
		
		public var dimensions:Point;
		
		public var life:uint;
		
		public var spawnRate:uint;
		
		public var fireRate:uint;
		
		public var panAmplitude:uint;
		
		public var speed:uint;
		
		public var scale:Number;
		
		public var score:uint;
		
		public var lastSpawnTime:uint;
		
		public var invader:Invader;
		
		public var cellsFrame0:Vector.<Point>;
		
		public var cellsFrame1:Vector.<Point>;
	}
}
