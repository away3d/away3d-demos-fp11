package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.materials.MaterialBase;

	import com.away3d.spaceinvaders.GameSettings;

	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;
	import com.away3d.spaceinvaders.utils.MathUtils;

	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class InvaderPool extends GameObjectPool
	{
		private var _invaderFactory:InvaderFactory;
		private var _currentTypeIndex:uint;
		private var _spawnTimer:Timer;

		public var targetNumInvaders:uint = 0;
		public var spawnTime:Number;

		public function InvaderPool( invaderMaterial:MaterialBase ) {
			super();
			_invaderFactory = new InvaderFactory( invaderMaterial );
			spawnTime = GameSettings.initialSpawnTime;
			_spawnTimer = new Timer( 0, 1 );
			_spawnTimer.addEventListener( TimerEvent.TIMER, onSpawnTimerTick );
		}

		public function startSpawning():void {
			_spawnTimer.reset();
			_spawnTimer.start();
		}

		public function stopSpawning():void {
			_spawnTimer.stop();
		}

		private function onSpawnTimerTick( event:TimerEvent ):void {
			if( numChildren < targetNumInvaders ) {
				if( Math.random() < spawnTime ) {
					var rand:Number = Math.random();
					var randIndex:uint;
					if( rand > 0.9 ) {
						randIndex = InvaderFactory.MOTHERSHIP;
					}
					else if( rand > 0.75 ) {
						randIndex = InvaderFactory.OCTOPUS_INVADER;
					}
					else if( rand > 0.5 ) {
						randIndex = InvaderFactory.BUG_INVADER;
					}
					else {
						randIndex = InvaderFactory.ROUNDED_OCTOPUS_INVADER;
					}
					var invader:Invader = addItemOfType( randIndex ) as Invader;
					dispatchEvent( new GameObjectEvent( GameObjectEvent.CREATED, invader ) );
				}
			}
			_spawnTimer.delay = Math.floor( MathUtils.rand( spawnTime, spawnTime * 1.5 ) * 1000 );
			startSpawning();
		}

		private function addItemOfType( typeIndex:uint ):GameObject {
			// Adds an unused item or creates a new item if none is found.
			var invader:Invader;
			var len:uint = _gameObjects.length;
			for( var i:uint; i < len; i++ ) {
				invader = _gameObjects[ i ] as Invader;
				if( !invader.enabled && invader.typeIndex == _currentTypeIndex ) {
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
