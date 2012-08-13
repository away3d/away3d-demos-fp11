package invaders.input
{

	import flash.events.AccelerometerEvent;
	import flash.events.MouseEvent;
	import flash.sensors.Accelerometer;
	import invaders.scene.InvaderScene;


	public class AccelerometerInput extends InputBase
	{
		private var _mouseIsDown:Boolean;
		private var _firstAccY:Number;

		public function AccelerometerInput( scene:InvaderScene ) {
			super( scene );
			_firstAccY = 0;
			_scene.cameraMotionEase = GameSettings.accelerometerCameraMotionEase;
		}

		override public function init():void {
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			var accelerometer:Accelerometer = new Accelerometer();
			accelerometer.addEventListener( AccelerometerEvent.UPDATE, onAccelerometerUpdate );
		}

		override public function update():void {
			if( _mouseIsDown ) _scene.firePlayer();
			_scene.movePlayerTowards( _currentPosition.x, _currentPosition.y );
		}

		override public function reset():void {
			_firstAccY = 0;
		}

		private function onAccelerometerUpdate( event:AccelerometerEvent ):void {
//			trace( "accelerometer: " + event.accelerationX + ", " + event.accelerationY + ", " + event.accelerationZ );
			// Use first encountered acc Y as Y center.
			if( _firstAccY == 0 ) {
				_firstAccY = event.accelerationY;
			}
			// Update position.
			_currentPosition.x = -GameSettings.accelerometerMotionFactorX * event.accelerationX * GameSettings.cameraPanRange;
			_currentPosition.y =  GameSettings.accelerometerMotionFactorY * ( _firstAccY - event.accelerationY ) * GameSettings.cameraPanRange;
			// Containment.
//			if( _currentPosition.x < -GameSettings.cameraPanRange ) _currentPosition.x = -GameSettings.cameraPanRange;
//			if( _currentPosition.x >  GameSettings.cameraPanRange ) _currentPosition.x =  GameSettings.cameraPanRange;
//			if( _currentPosition.y < -GameSettings.cameraPanRange ) _currentPosition.y = -GameSettings.cameraPanRange;
//			if( _currentPosition.y >  GameSettings.cameraPanRange ) _currentPosition.y =  GameSettings.cameraPanRange;
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_mouseIsDown = true;
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_mouseIsDown = false;
		}
	}
}
