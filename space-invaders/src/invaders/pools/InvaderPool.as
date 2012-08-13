package invaders.pools
{

	import away3d.materials.MaterialBase;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import invaders.events.GameObjectEvent;
	import invaders.objects.GameObject;
	import invaders.objects.Invader;
	import invaders.objects.invaders.InvaderFactory;
	import invaders.utils.MathUtils;



	public class InvaderPool extends GameObjectPool
	{
		private var _invaderFactory:InvaderFactory;
		private var _currentTypeIndex:uint;

		public var spawnTimeFactor:Number = 1;

		private var _time:uint;
		private var _lastSpawnTimes:Dictionary;

		public function InvaderPool( invaderMaterial:MaterialBase ) {
			super();

			_invaderFactory = new InvaderFactory( invaderMaterial );
			_lastSpawnTimes = new Dictionary();
		}

		private function resetSpawnTimes():void {
			_time = getTimer();
			_lastSpawnTimes[ InvaderDefinitions.MOTHERSHIP 				] = _time;
			_lastSpawnTimes[ InvaderDefinitions.BUG_INVADER 			] = _time;
			_lastSpawnTimes[ InvaderDefinitions.OCTOPUS_INVADER			] = _time;
			_lastSpawnTimes[ InvaderDefinitions.ROUNDED_OCTOPUS_INVADER ] = _time;
		}

		override public function update():void {
			super.update();
			_time = getTimer();
			evaluateSpawnInvader( InvaderDefinitions.MOTHERSHIP );
			evaluateSpawnInvader( InvaderDefinitions.BUG_INVADER );
			evaluateSpawnInvader( InvaderDefinitions.OCTOPUS_INVADER );
			evaluateSpawnInvader( InvaderDefinitions.ROUNDED_OCTOPUS_INVADER );
		}

		override protected function createItem():GameObject {

			// Get an invader clone from the factory.
			var invader:Invader = _invaderFactory.createInvaderOfType( _currentTypeIndex );

			// Listen for when the invader is dead.
			invader.addEventListener( GameObjectEvent.DEAD, forwardEvent );
			invader.addEventListener( GameObjectEvent.FIRE, forwardEvent );
			invader.addEventListener( GameObjectEvent.HIT, forwardEvent );

			return invader;
		}

		public function stop():void {
			var invader:Invader;
			var len:uint = _gameObjects.length;
			for( var i:uint; i < len; i++ ) {
				invader = _gameObjects[ i ] as Invader;
				invader.stopTimers();
			}
		}

		public function resume():void {
			var invader:Invader;
			var len:uint = _gameObjects.length;
			for( var i:uint; i < len; i++ ) {
				invader = _gameObjects[ i ] as Invader;
				invader.resumeTimers();
			}
			resetSpawnTimes();
		}

		private function forwardEvent( event:Event ):void {
			dispatchEvent( event );
		}

		private function evaluateSpawnInvader( typeIndex:uint ):void {
				var elapsedSinceSpawn:int = _time - _lastSpawnTimes[ typeIndex ];
				if( elapsedSinceSpawn > InvaderDefinitions.getSpawnRateMSForInvaderType( typeIndex ) * spawnTimeFactor * MathUtils.rand( 0.9, 1.1 ) ) {
					var invader:Invader = addItemOfType( typeIndex ) as Invader;
					dispatchEvent( new GameObjectEvent( GameObjectEvent.CREATED, invader ) );
					_lastSpawnTimes[ typeIndex ] = _time;
				}
		}

		private function addItemOfType( typeIndex:uint ):GameObject {
			// Adds an unused item or creates a new item if none is found.
			var invader:Invader;
			var len:uint = _gameObjects.length;
			for( var i:uint; i < len; i++ ) {
				invader = _gameObjects[ i ] as Invader;
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
	}
}
