package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.utils.MathUtils;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class InvaderCell extends GameObject
	{
		private var _deathTimer:Timer;

		public function InvaderCell( cellMesh:Mesh ) {

			super();
			addChild( cellMesh );

			_deathTimer = new Timer( MathUtils.rand( 500, 5000 ), 1 );
			_deathTimer.addEventListener( TimerEvent.TIMER, onDeathTimerTick );
		}

		private function onDeathTimerTick( event:TimerEvent ):void {
			enabled = false;
			_deathTimer.stop();
		}

		override public function set enabled( value:Boolean ):void {
			super.enabled = value;
			if( !enabled ) {
				_deathTimer.stop();
			}
			else {
				_deathTimer.start();
			}
		}
	}
}
