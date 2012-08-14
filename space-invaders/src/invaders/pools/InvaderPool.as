package invaders.pools
{
	import invaders.events.*;
	import invaders.objects.*;
	import invaders.primitives.*;
	import invaders.utils.*;
	
	import away3d.core.base.*;
	import away3d.entities.*;
	import away3d.materials.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class InvaderPool extends GameObjectPool
	{
		private var _time:uint;
		private var _invaders:Vector.<Invader> = new Vector.<Invader>(4);
		private var _lastSpawnTimes:Vector.<uint> = new Vector.<uint>(4);
		private var _invaderMaterial:MaterialBase;
		private var _currentTypeIndex:uint;
		
		public var spawnTimeFactor:Number = 1;
		
		public function InvaderPool( invaderMaterial:MaterialBase )
		{
			super();
			
			_invaderMaterial = invaderMaterial;
		}
		
		override public function update():void
		{
			super.update();
			_time = getTimer();
			evaluateSpawnInvader( InvaderDefinitions.MOTHERSHIP );
			evaluateSpawnInvader( InvaderDefinitions.BUG_INVADER );
			evaluateSpawnInvader( InvaderDefinitions.OCTOPUS_INVADER );
			evaluateSpawnInvader( InvaderDefinitions.ROUNDED_OCTOPUS_INVADER );
		}
		
		public function stop():void
		{
			var invader:Invader;
			for each ( invader in _gameObjects)
				invader.stopTimers();
		}
		
		public function resume():void
		{
			var invader:Invader;
			for each ( invader in _gameObjects)
				invader.resumeTimers();
			
			resetSpawnTimes();
		}
		
		override protected function createItem():GameObject
		{

			// Get an invader clone from the factory.
			var invader:Invader = _invaders[ _currentTypeIndex ];
			if( !invader ) {
				var definition:Array = InvaderDefinitions.getDefinitionForInvaderType( _currentTypeIndex );
				var dimensions:Point = InvaderDefinitions.getDefinitionDimensionsForInvaderType( _currentTypeIndex );
				var definitionFrame0:Array = definition[ 0 ];
				var definitionFrame1:Array = definition[ 1 ];
				var invaderGeometry0:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definitionFrame0, dimensions );
				var invaderGeometry1:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definitionFrame1, dimensions );
				var meshFrame0:Mesh = new Mesh( invaderGeometry0, _invaderMaterial );
				var meshFrame1:Mesh = new Mesh( invaderGeometry1, _invaderMaterial );
				var cellsFrame0:Vector.<Point> = createInvaderCells( definition[ 0 ], dimensions );
				var cellsFrame1:Vector.<Point> = createInvaderCells( definition[ 1 ], dimensions );
				invader = new Invader( _currentTypeIndex, meshFrame0, meshFrame1, cellsFrame0, cellsFrame1 );
			}
			else {
				invader = invader.getInvaderClone();
			}
			
			// Listen for when the invader is dead.
			invader.addEventListener( GameObjectEvent.DEAD, forwardEvent );
			invader.addEventListener( GameObjectEvent.FIRE, forwardEvent );
			invader.addEventListener( GameObjectEvent.HIT, forwardEvent );

			return invader;
		}
		
		private function forwardEvent( event:Event ):void
		{
			dispatchEvent( event );
		}
		
		private function evaluateSpawnInvader( typeIndex:uint ):void
		{
			var elapsedSinceSpawn:int = _time - _lastSpawnTimes[ typeIndex ];
			if( elapsedSinceSpawn > InvaderDefinitions.getSpawnRateMSForInvaderType( typeIndex ) * spawnTimeFactor * MathUtils.rand( 0.9, 1.1 ) ) {
				var invader:Invader = addItemOfType( typeIndex ) as Invader;
				dispatchEvent( new GameObjectEvent( GameObjectEvent.CREATED, invader ) );
				_lastSpawnTimes[ typeIndex ] = _time;
			}
		}
		
		private function addItemOfType( typeIndex:uint ):GameObject
		{
			// Adds an unused item or creates a new item if none isfound.
			var invader:Invader;
			for each ( invader in _gameObjects) {
				if( !invader.enabled && invader.invaderType == typeIndex ) {
					invader.reset();
					return invader;
				}
			}
			_currentTypeIndex = typeIndex;
			invader = createItem() as Invader;
			invader.reset();
			_gameObjects.push( invader );
			return invader;
		}
		
		private function resetSpawnTimes():void
		{
			_time = getTimer();
			_lastSpawnTimes[ InvaderDefinitions.MOTHERSHIP 				] = _time;
			_lastSpawnTimes[ InvaderDefinitions.BUG_INVADER 			] = _time;
			_lastSpawnTimes[ InvaderDefinitions.OCTOPUS_INVADER			] = _time;
			_lastSpawnTimes[ InvaderDefinitions.ROUNDED_OCTOPUS_INVADER ] = _time;
		}
		
		private function createInvaderCells( definition:Array, gridDimensions:Point ):Vector.<Point>
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
			offX = cellSize / 2 - ( lenX / 2 ) * cellSize;
			offY = -cellSize / 2 + ( lenY / 2 ) * cellSize;
			
			for( j = 0; j < lenY; j++ ) {
				for( i = 0; i < lenX; i++ ) {
					cellIndex = j * lenX + i;
					if( definition[ cellIndex ] == 1 ) {
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
