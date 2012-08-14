package invaders.objects
{
	import invaders.utils.*;
	
	import away3d.cameras.*;
	
	import flash.events.*;
	import flash.utils.*;
	
	public class Player extends GameObject
	{
		private var _camera:Camera3D;
		private var _shakeTimer:Timer;
		private var _shakeT:Number = 0;
		private var _shakeTimerCount:uint = 10;
		private var _targets:Vector.<GameObject>;
		
		public function Player( camera:Camera3D )
		{
			super();
			
			addChild( camera );

			_camera = camera;

			_shakeTimer = new Timer( 25, _shakeTimerCount );
			_shakeTimer.addEventListener( TimerEvent.TIMER, onShakeTimerTick );
			_shakeTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onShakeTimerComplete );
		}
		
		override public function update():void
		{
			super.update();
			
			var dx:Number, dy:Number, dz:Number;
			
			// Check for collisions with invaders.
			var target:GameObject;
			for each ( target in _targets ) {
				if( target.enabled ) {

					dz = target.z - z;

					if( Math.abs( dz ) < Math.abs( target.velocity.z ) ) {
						dx = target.x - x;
						dy = target.y - y;
						if( Math.sqrt( dx * dx + dy * dy ) < GameSettings.impactHitSize ) {
							impact( target );
							target.impact(this);
						}
					}
				}

			}
		}
		
		override public function impact( hitter:GameObject ):void
		{
			super.impact( hitter );
			shake();
		}
		
		private function onShakeTimerTick( event:TimerEvent ):void
		{
			var shakeRange:Number = GameSettings.playerHitShake * _shakeT;
			_camera.x = MathUtils.rand( -shakeRange, shakeRange );
			_camera.y = MathUtils.rand( -shakeRange, shakeRange );
			_shakeT = 1 - _shakeTimer.currentCount / _shakeTimerCount;
		}
		
		private function onShakeTimerComplete( event:TimerEvent ):void
		{
			_camera.x = 0;
			_camera.y = 0;
		}
		
		private function shake():void
		{
			_shakeT = 1;
			_shakeTimer.reset();
			_shakeTimer.start();
		}
		
		public function set targets( value:Vector.<GameObject> ):void
		{
			_targets = value;
		}
	}
}
