package com.away3d.spaceinvaders.input
{

	import com.away3d.spaceinvaders.GameSettings;
	import com.away3d.spaceinvaders.scene.InvaderScene;

	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	public class TouchInput extends InputBase
	{
		private var _firstTouchId:int = 0;
		private var _currentTouchNum:int;
		private var _firstTouchPosition:Point;
		private var _playerTouchPosition:Point;

		public function TouchInput( scene:InvaderScene ) {
			super( scene );
			_firstTouchPosition = new Point();
			_scene.cameraMotionEase = GameSettings.touchCameraMotionEase;
		}

		override public function init():void {
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			stage.addEventListener( TouchEvent.TOUCH_BEGIN, onTouchBegin );
			stage.addEventListener( TouchEvent.TOUCH_END, onTouchEnd );
			stage.addEventListener( TouchEvent.TOUCH_MOVE, onTouchMove );
		}

		override public function update():void {
			_scene.movePlayerTowards( _currentPosition.x, _currentPosition.y );
		}

		private function onTouchMove( event:TouchEvent ):void {
			if( event.touchPointID == _firstTouchId ) {
				var dx:Number = event.stageX - _firstTouchPosition.x;
				var dy:Number = event.stageY - _firstTouchPosition.y;
				_currentPosition.x = _playerTouchPosition.x + GameSettings.touchMotionFactor * dx;
				_currentPosition.y = _playerTouchPosition.y - GameSettings.touchMotionFactor * dy;
			}
		}

		private function onTouchEnd( event:TouchEvent ):void {
			_currentTouchNum--;
		}

		private function onTouchBegin( event:TouchEvent ):void {
			_currentTouchNum++;
			_scene.firePlayer();
			if( _currentTouchNum == 1 ) {
				_firstTouchId = event.touchPointID;
				_playerTouchPosition = _scene.playerPosition;
				_firstTouchPosition.x = event.stageX;
				_firstTouchPosition.y = event.stageY;
				_currentPosition.x = 0;
				_currentPosition.y = 0;
			}
		}
	}
}
