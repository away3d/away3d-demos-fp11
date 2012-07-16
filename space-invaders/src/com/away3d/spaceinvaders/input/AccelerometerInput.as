package com.away3d.spaceinvaders.input
{

	import com.away3d.spaceinvaders.GameVariables;
	import com.away3d.spaceinvaders.scene.InvaderScene;

	import flash.events.AccelerometerEvent;
	import flash.events.MouseEvent;
	import flash.sensors.Accelerometer;

	public class AccelerometerInput extends InputBase
	{
		public function AccelerometerInput( scene:InvaderScene ) {
			super( scene );
			_scene.cameraMotionEase = GameVariables.accelerometerCameraMotionEase;
		}

		override public function init():void {
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			var accelerometer:Accelerometer = new Accelerometer();
			accelerometer.addEventListener( AccelerometerEvent.UPDATE, onAccelerometerUpdate );
		}

		override public function update():void {
			_scene.movePlayerTowards( _currentPosition.x, _currentPosition.y );
		}

		private function onAccelerometerUpdate( event:AccelerometerEvent ):void {
			_currentPosition.x = -GameVariables.accelerometerMotionFactorX * event.accelerationX * GameVariables.cameraPanRange;
			_currentPosition.y =  GameVariables.accelerometerMotionFactorY * ( GameVariables.accelerometerCenterY - event.accelerationY ) * GameVariables.cameraPanRange;
			if( _currentPosition.x < -GameVariables.cameraPanRange ) _currentPosition.x = -GameVariables.cameraPanRange;
			if( _currentPosition.x >  GameVariables.cameraPanRange ) _currentPosition.x =  GameVariables.cameraPanRange;
			if( _currentPosition.y < -GameVariables.cameraPanRange ) _currentPosition.y = -GameVariables.cameraPanRange;
			if( _currentPosition.y >  GameVariables.cameraPanRange ) _currentPosition.y =  GameVariables.cameraPanRange;
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_scene.firePlayer();
		}
	}
}
