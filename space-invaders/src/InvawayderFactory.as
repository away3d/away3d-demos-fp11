package 
{
	import invawayders.data.*;
	import invawayders.objects.*;
	import invawayders.primitives.*;
	
	import away3d.core.base.*;
	import away3d.entities.*;
	import away3d.materials.*;
	
	import flash.geom.*;
	

	public class InvawayderFactory
	{
		private static var _instance:InvawayderFactory;
		
		public static const BUG_INVAWAYDER:uint = 0;
		public static const OCTOPUS_INVAWAYDER:uint = 1;
		public static const ROUNDED_OCTOPUS_INVAWAYDER:uint = 2;
		public static const MOTHERSHIP_INVAWAYDER:uint = 3;
		
		private var _invawayders:Vector.<InvawayderData> = Vector.<InvawayderData>([
			new BugInvawayderData(BUG_INVAWAYDER),
			new OctopusInvawayderData(OCTOPUS_INVAWAYDER),
			new RoundedOctopusInvawayderData(ROUNDED_OCTOPUS_INVAWAYDER),
			new MothershipInvawayderData(MOTHERSHIP_INVAWAYDER)
		]);
		
		public static function getInstance():InvawayderFactory
		{
			if (_instance)
				return _instance;
			
			_instance = new InvawayderFactory();
			
			return _instance;
		}
		
		public function get invawayders():Vector.<InvawayderData>
		{
			return _invawayders;
		}
		
		public function getInvawayder( id:uint, material:MaterialBase ):Invawayder
		{
			var invawayderData:InvawayderData = _invawayders[id];
			
			if (invawayderData.invawayder)
				return invawayderData.invawayder.cloneGameObject() as Invawayder;
			
			var definition:Vector.<Vector.<uint>> = invawayderData.cellDefinition;
			var dimensions:Point = invawayderData.dimensions;
			
			var definitionFrame0:Vector.<uint> = definition[ 0 ];
			var definitionFrame1:Vector.<uint> = definition[ 1 ];
			
			var invawayderGeometry0:Geometry = new InvawayderGeometry( GameSettings.invawayderSizeXY, GameSettings.invawayderSizeZ, definitionFrame0, dimensions );
			var invawayderGeometry1:Geometry = new InvawayderGeometry( GameSettings.invawayderSizeXY, GameSettings.invawayderSizeZ, definitionFrame1, dimensions );
			
			var meshFrame0:Mesh = new Mesh( invawayderGeometry0, material );
			var meshFrame1:Mesh = new Mesh( invawayderGeometry1, material );
			
			invawayderData.cellsFrame0 = createInvawayderCells( definition[ 0 ], dimensions );
			invawayderData.cellsFrame1 = createInvawayderCells( definition[ 1 ], dimensions );
			
			return invawayderData.invawayder = new Invawayder( invawayderData, meshFrame0, meshFrame1 );
		}
		
		public function resetLastSpawnTimes(time:uint):void
		{
			var invawayderData:InvawayderData;
			for each (invawayderData in _invawayders)
				invawayderData.lastSpawnTime = time;
		}
		
		private function createInvawayderCells( definition:Vector.<uint>, gridDimensions:Point ):Vector.<Point>
		{
			var positions:Vector.<Point> = new Vector.<Point>();
			
			var i:uint, j:uint;
			var cellIndex:uint;
			var cellSize:Number;
			var lenX:uint, lenY:uint;
			var posX:Number, posY:Number;
			var offX:Number, offY:Number;
			
			cellSize = GameSettings.invawayderSizeXY;
			lenX = gridDimensions.x;
			lenY = gridDimensions.y;
			offX = -( lenX - 1 ) * cellSize / 2;
			offY = (lenY - 1 ) * cellSize / 2;
			
			for( j = 0; j < lenY; j++ ) {
				for( i = 0; i < lenX; i++ ) {
					cellIndex = j * lenX + i;
					if( definition[ cellIndex ] ) {
						posX = offX + i * cellSize;
						posY = offY - j * cellSize;
						positions.push( new Point( posX, posY ) );
					}
				}
			}
			
			return positions;
		}
	}
}
