package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.materials.MaterialBase;

	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;

	import flash.events.Event;

	public class InvaderPool extends GameObjectPool
	{
		private var _invaderFactory:InvaderFactory;
		private var _currentTypeIndex:uint;

		public var targetNumInvaders:uint = 0;
		public var creationProbability:Number = 0;

		public function InvaderPool( invaderMaterial:MaterialBase ) {
			super();
			_invaderFactory = new InvaderFactory( invaderMaterial );
		}

		override public function update():void {

			// Need to create invader?
			if( numChildren < targetNumInvaders ) {
				if( Math.random() < creationProbability ) {
					var rand:Number = Math.random();
					var randIndex:uint;
					if( rand > 0.95 ) {
						randIndex = InvaderFactory.MOTHERSHIP;
					}
					else if( rand > 0.75 ) {
						randIndex = InvaderFactory.HEAVY_INVADER;
					}
					else if( rand > 0.5 ) {
						randIndex = InvaderFactory.MEDIUM_INVADER;
					}
					else {
						randIndex = InvaderFactory.LIGHT_INVADER;
					}
					var invader:Invader = addItemOfType( randIndex ) as Invader;
					dispatchEvent( new GameObjectEvent( GameObjectEvent.CREATED, invader ) );
				}
			}

			super.update();
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
