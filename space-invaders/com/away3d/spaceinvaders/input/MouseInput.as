package com.away3d.spaceinvaders.input
{

	import com.away3d.spaceinvaders.GameSettings;
	import com.away3d.spaceinvaders.views.InvaderScene;

	import flash.events.Event;

	import flash.events.MouseEvent;

	public class MouseInput extends InputBase
	{
		private var _mouseIsOnStage:Boolean = true;

		public function MouseInput( scene:InvaderScene ) {
			super( scene );
			_scene.cameraMotionEase = GameSettings.mouseCameraMotionEase;
		}

		override public function init():void {
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.addEventListener( Event.MOUSE_LEAVE, onStageMouseLeave );
		}

		private function onStageMouseMove( event:MouseEvent ):void {
			_mouseIsOnStage = true;
		}

		private function onStageMouseLeave( event:Event ):void {
			_mouseIsOnStage = false;
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_scene.firePlayer();
		}

		override public function update():void {

			if( _mouseIsOnStage ) {
				if( stage.mouseX > 0 && stage.mouseX < 100000 ) {
					_currentPosition.x = stage.mouseX;
				}
				if( stage.mouseY > 0 && stage.mouseY < 100000 ) {
					_currentPosition.y = stage.mouseY;
				}
			}

			var targetX:Number =  GameSettings.cameraPanRange * ( _currentPosition.x - stage.stageWidth  / 2 ) / ( stage.stageWidth  / 2 );
			var targetY:Number = -GameSettings.cameraPanRange * ( _currentPosition.y - stage.stageHeight / 2 ) / ( stage.stageHeight / 2 );

			_scene.movePlayerTowards( targetX, targetY );
		}
	}
}
