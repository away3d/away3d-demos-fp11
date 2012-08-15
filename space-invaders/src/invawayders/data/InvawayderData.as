package invawayders.data
{
	import invawayders.objects.*;
	
	import flash.geom.*;
	
	/**
	 * 
	 */
	public class InvawayderData
	{
		public var id:uint;
		
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
		
		public var invawayder:Invawayder;
		
		public var cellsFrame0:Vector.<Point>;
		
		public var cellsFrame1:Vector.<Point>;
	}
}
