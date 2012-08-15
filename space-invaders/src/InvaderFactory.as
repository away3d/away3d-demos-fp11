package 
{
	import invawayders.data.*;
	import invawayders.objects.*;
	import invawayders.primitives.*;
	
	import away3d.core.base.*;
	import away3d.entities.*;
	import away3d.materials.*;
	
	import flash.geom.*;
	

	public class InvaderFactory
	{
		private static var _instance:InvaderFactory;
		
		public static const BUG_INVADER:uint = 0;
		public static const OCTOPUS_INVADER:uint = 1;
		public static const ROUNDED_OCTOPUS_INVADER:uint = 2;
		public static const MOTHERSHIP:uint = 3;
		
		private var _invaders:Vector.<InvaderData> = Vector.<InvaderData>([
			new BugInvaderData(BUG_INVADER),
			new OctopusInvaderData(OCTOPUS_INVADER),
			new RoundedOctopusInvaderData(ROUNDED_OCTOPUS_INVADER),
			new MothershipInvaderData(MOTHERSHIP)
		]);
		
		public static function getInstance():InvaderFactory
		{
			if (_instance)
				return _instance;
			
			_instance = new InvaderFactory();
			
			return _instance;
		}
		
		public function get invaders():Vector.<InvaderData>
		{
			return _invaders;
		}
		
		public function getInvader( id:uint, material:MaterialBase ):Invader
		{
			var invaderData:InvaderData = _invaders[id];
			
			if (invaderData.invader)
				return invaderData.invader.cloneGameObject() as Invader;
			
			var definition:Vector.<Vector.<uint>> = invaderData.cellDefinition;
			var dimensions:Point = invaderData.dimensions;
			
			var definitionFrame0:Vector.<uint> = definition[ 0 ];
			var definitionFrame1:Vector.<uint> = definition[ 1 ];
			
			var invaderGeometry0:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definitionFrame0, dimensions );
			var invaderGeometry1:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definitionFrame1, dimensions );
			
			var meshFrame0:Mesh = new Mesh( invaderGeometry0, material );
			var meshFrame1:Mesh = new Mesh( invaderGeometry1, material );
			
			invaderData.cellsFrame0 = createInvaderCells( definition[ 0 ], dimensions );
			invaderData.cellsFrame1 = createInvaderCells( definition[ 1 ], dimensions );
			
			return invaderData.invader = new Invader( invaderData, meshFrame0, meshFrame1 );
		}
		
		public function resetLastSpawnTimes(time:uint):void
		{
			var invaderData:InvaderData;
			for each (invaderData in _invaders)
				invaderData.lastSpawnTime = time;
		}
		
		private function createInvaderCells( definition:Vector.<uint>, gridDimensions:Point ):Vector.<Point>
		{
			var positions:Vector.<Point> = new Vector.<Point>();
			
			var i:uint, j:uint;
			var cellIndex:uint;
			var cellSize:Number;
			var lenX:uint, lenY:uint;
			var posX:Number, posY:Number;
			var offX:Number, offY:Number;
			
			cellSize = GameSettings.invaderSizeXY;
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
