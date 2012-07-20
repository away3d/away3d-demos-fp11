package com.away3d.spaceinvaders.input
{

	import com.away3d.spaceinvaders.GameSettings;
	import com.away3d.spaceinvaders.scene.InvaderScene;

	import flash.events.AccelerometerEvent;
	import flash.events.MouseEvent;
	import flash.sensors.Accelerometer;

	public class AccelerometerInput extends InputBase
	{
		private var _mouseIsDown:Boolean;

		public function AccelerometerInput( scene:InvaderScene ) {
			super( scene );
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

		private function onAccelerometerUpdate( event:AccelerometerEvent ):void {
//			trace( "accelerometer: " + event.accelerationX + ", " + event.accelerationY + ", " + event.accelerationZ );
			_currentPosition.x = -GameSettings.accelerometerMotionFactorX * event.accelerationX * GameSettings.cameraPanRange;
			_currentPosition.y =  GameSettings.accelerometerMotionFactorY * ( GameSettings.accelerometerCenterY - event.accelerationY ) * GameSettings.cameraPanRange;
			if( _currentPosition.x < -GameSettings.cameraPanRange ) _currentPosition.x = -GameSettings.cameraPanRange;
			if( _currentPosition.x >  GameSettings.cameraPanRange ) _currentPosition.x =  GameSettings.cameraPanRange;
			if( _currentPosition.y < -GameSettings.cameraPanRange ) _currentPosition.y = -GameSettings.cameraPanRange;
			if( _currentPosition.y >  GameSettings.cameraPanRange ) _currentPosition.y =  GameSettings.cameraPanRange;
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_mouseIsDown = true;
		}

		private function onStageMouseUp( event:MouseEvent ):void {
			_mouseIsDown = false;
		}
	}
}
