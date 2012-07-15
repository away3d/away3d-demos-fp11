package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.materials.MaterialBase;

	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;
	import com.away3d.spaceinvaders.utils.MathUtils;

	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class InvaderPool extends GameObjectPool
	{
		private var _invaderFactory:InvaderFactory;
		private var _currentTypeIndex:uint;

		public var spawnTimeFactor:Number = 1;

		private var _time:uint;
		private var _lastSpawnTimes:Dictionary;
		private var _spawnTimes:Dictionary;

		public function InvaderPool( invaderMaterial:MaterialBase ) {
			super();

			_invaderFactory = new InvaderFactory( invaderMaterial );

			_lastSpawnTimes = new Dictionary();

			_spawnTimes = new Dictionary();
			_spawnTimes[ InvaderFactory.MOTHERSHIP				] = 60000;
			_spawnTimes[ InvaderFactory.BUG_INVADER 			] = 5000;
			_spawnTimes[ InvaderFactory.OCTOPUS_INVADER 		] = 10000;
			_spawnTimes[ InvaderFactory.ROUNDED_OCTOPUS_INVADER ] = 3000;
		}

		public function resetSpawnTimes():void {
			_time = getTimer();
			_lastSpawnTimes[ InvaderFactory.MOTHERSHIP 				] = _time;
			_lastSpawnTimes[ InvaderFactory.BUG_INVADER 			] = _time;
			_lastSpawnTimes[ InvaderFactory.OCTOPUS_INVADER			] = _time;
			_lastSpawnTimes[ InvaderFactory.ROUNDED_OCTOPUS_INVADER ] = _time;
		}

		override public function update():void {
			super.update();

			_time = getTimer();

			evaluateSpawnInvader( InvaderFactory.MOTHERSHIP );
			evaluateSpawnInvader( InvaderFactory.BUG_INVADER );
			evaluateSpawnInvader( InvaderFactory.OCTOPUS_INVADER );
			evaluateSpawnInvader( InvaderFactory.ROUNDED_OCTOPUS_INVADER );
		}

		private function evaluateSpawnInvader( typeIndex:uint ):void {
				var elapsedSinceSpawn:int = _time - _lastSpawnTimes[ typeIndex ];
				if( elapsedSinceSpawn > _spawnTimes[ typeIndex ] * spawnTimeFactor * MathUtils.rand( 0.9, 1.1 ) ) {
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
				if( !invader.enabled && invader.typeIndex == typeIndex ) {
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

		override protected function createItem():GameObject {

			// Get an invader clone from the factory.
			var invader:Invader = _invaderFactory.createInvaderOfType( _currentTypeIndex );

			// Enable mouse listeners for shooting at the invader.
			invader.meshFrame0.mouseEnabled = true;
			invader.meshFrame1.mouseEnabled = true;

			// Listen for when the invader is dead.
			invader.addEventListener( GameObjectEvent.DEAD, forwardEvent );
			invader.addEventListener( GameObjectEvent.FIRE, forwardEvent );

			return invader;
		}

		private function forwardEvent( event:Event ):void {
			dispatchEvent( event );
		}


	}
}
