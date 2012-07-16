package com.away3d.spaceinvaders.gameobjects.player
{

	import away3d.cameras.Camera3D;

	import com.away3d.spaceinvaders.GameVariables;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.utils.MathUtils;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Player extends GameObject
	{
		private var _camera:Camera3D;
		private var _shakeTimer:Timer;
		private var _shakeT:Number = 0;
		private var _shakeTimerCount:uint = 10;

		public function Player( camera:Camera3D ) {

			super();
			addChild( camera );

			_camera = camera;

			_shakeTimer = new Timer( 25, _shakeTimerCount );
			_shakeTimer.addEventListener( TimerEvent.TIMER, onShakeTimerTick );
			_shakeTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onShakeTimerComplete );
		}

		private function onShakeTimerTick( event:TimerEvent ):void {
			var shakeRange:Number = GameVariables.playerHitShake * _shakeT;
			_camera.x = MathUtils.rand( -shakeRange, shakeRange );
			_camera.y = MathUtils.rand( -shakeRange, shakeRange );
			_shakeT = 1 - _shakeTimer.currentCount / _shakeTimerCount;
		}

		private function onShakeTimerComplete( event:TimerEvent ):void {
			_camera.x = 0;
			_camera.y = 0;
		}

		override public function impact( hitter:GameObject ):void {
			shake();
			super.impact( hitter );
		}

		private function shake():void {
			_shakeT = 1;
			_shakeTimer.reset();
			_shakeTimer.start();
		}
	}
}
