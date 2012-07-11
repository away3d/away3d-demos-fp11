package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.materials.MaterialBase;

	import aze.motion.easing.Quart;
	import aze.motion.eaze;

	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;
	import com.away3d.spaceinvaders.utils.MathUtils;

	import flash.events.Event;

	public class InvaderPool extends GameObjectPool
	{
		private var _invaderFactory:InvaderFactory;

		public var targetNumInvaders:uint = 0;
		public var creationProbability:Number = 0;
		public var invaderFireRate:Number;

		public function InvaderPool( invaderMaterial:MaterialBase ) {
			super();
			_invaderFactory = new InvaderFactory( invaderMaterial );
		}

		override public function update():void {

			// Need to create invader?
			if( numChildren < targetNumInvaders ) {
				if( Math.random() < creationProbability ) {
					addItem();
				}
			}

			super.update();
		}

		override public function addItem():GameObject {
			var gameObject:GameObject = super.addItem();
			// Set velocity.
			gameObject.velocity.z = -50;
			// Set fire rate.
			Invader( gameObject ).fireTimerRate = invaderFireRate;
			// Randomize XY.
			gameObject.x = MathUtils.rand( -1000, 1000 );
			gameObject.y = MathUtils.rand( -1000, 1000 );
			// Ease Z towards scene range.
			gameObject.z = 100000;
			eaze( gameObject ).to( 0.5, { z:MathUtils.rand( 4000, 5000 ) } ).easing( Quart.easeOut );
			return gameObject;
		}

		override protected function createItem():GameObject {

			// Get an invader clone from the factory.
			var invader:Invader = _invaderFactory.createInvader();

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
