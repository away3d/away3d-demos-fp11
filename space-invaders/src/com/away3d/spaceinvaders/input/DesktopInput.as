package com.away3d.spaceinvaders.input
{

	import com.away3d.spaceinvaders.GameVariables;
	import com.away3d.spaceinvaders.scene.InvaderScene;

	import flash.events.Event;
	import flash.events.KeyboardEvent;

	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	public class DesktopInput extends InputBase
	{
		private var _mouseIsOnStage:Boolean = true;

		public function DesktopInput( scene:InvaderScene ) {
			super( scene );
			_scene.cameraMotionEase = GameVariables.mouseCameraMotionEase;
		}

		override public function init():void {
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.addEventListener( Event.MOUSE_LEAVE, onStageMouseLeave );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
		}

		private function onStageKeyDown( event:KeyboardEvent ):void {
			switch( event.keyCode ) {
				case Keyboard.SPACE:
					_scene.firePlayer();
					break;
			}
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

			var hw:Number = GameVariables.windowWidth / 2;
			var hh:Number = GameVariables.windowHeight / 2;
			var targetX:Number =  GameVariables.mouseMotionFactor * ( _currentPosition.x - hw ) / hw;
			var targetY:Number = -GameVariables.mouseMotionFactor * ( _currentPosition.y - hh ) / hh;

			_scene.movePlayerTowards( targetX, targetY );
		}
	}
}
