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
		private var _startFlashingOnCount:uint;

		public function InvaderCell( cellMesh:Mesh ) {

			super();
			addChild( cellMesh );

			var flashCount:uint = 5 + Math.floor( 20 * Math.random() );
			_startFlashingOnCount = Math.floor( flashCount * 0.75 );
			var flashSpeed:uint = 25 + Math.floor( 50 * Math.random() );
			_deathTimer = new Timer( flashSpeed, flashCount );
			_deathTimer.addEventListener( TimerEvent.TIMER, onDeathTimerTick );
			_deathTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onDeathTimerComplete );
		}

		private function onDeathTimerComplete( event:TimerEvent ):void {
			visible = true;
			enabled = false;
			_deathTimer.reset();
		}

		private function onDeathTimerTick( event:TimerEvent ):void {
			if( _deathTimer.currentCount > _startFlashingOnCount ) {
				visible = !visible;
			}
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
