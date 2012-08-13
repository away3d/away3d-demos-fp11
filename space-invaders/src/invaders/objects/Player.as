package invaders.objects
{

	import away3d.cameras.Camera3D;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import invaders.utils.MathUtils;



	public class Player extends GameObject
	{
		private var _camera:Camera3D;
		private var _shakeTimer:Timer;
		private var _shakeT:Number = 0;
		private var _shakeTimerCount:uint = 10;
		private var _targets:Vector.<GameObject>;

		public function Player( camera:Camera3D ) {

			super();
			addChild( camera );

			_camera = camera;

			_shakeTimer = new Timer( 25, _shakeTimerCount );
			_shakeTimer.addEventListener( TimerEvent.TIMER, onShakeTimerTick );
			_shakeTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onShakeTimerComplete );
		}


		override public function update():void {

			var i:uint, len:uint;
			var target:GameObject;
			var dx:Number, dy:Number, dz:Number, distance:Number;

			// Check for collisions with invaders.
			len = _targets.length;
			for( i = 0; i < len; ++i ) {

				target = _targets[ i ];
				if( target.enabled ) {

					dz = target.z - z;

					if( Math.abs( dz ) < Math.abs( target.velocity.z ) ) {
						dx = target.x - x;
						dy = target.y - y;
						distance = Math.sqrt( dx * dx + dy * dy );
						if( distance < GameSettings.impactHitSize ) {
							impact( target );
						}
					}
				}

			}

			super.update();
		}

		private function onShakeTimerTick( event:TimerEvent ):void {
			var shakeRange:Number = GameSettings.playerHitShake * _shakeT;
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

		public function set targets( value:Vector.<GameObject> ):void {
			_targets = value;
		}
	}
}
