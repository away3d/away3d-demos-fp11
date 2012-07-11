package com.away3d.spaceinvaders.views
{

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	public class UIView extends Sprite
	{
		private var _currentLevelKills:uint;
		private var _totalKills:uint;
		private var _levelTargetKills:uint;
		private var _level:uint;

		private var _mainText:TextField;

		public function UIView() {
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );

			_mainText = new TextField();
			_mainText.width = 250;
			_mainText.height = 400;
			_mainText.mouseEnabled = false;
			_mainText.selectable = false;
			_mainText.x = stage.stageWidth - _mainText.width;
			_mainText.textColor = 0xFFFFFF;
			addChild( _mainText );

			updateUi();
		}

		public function updateTotalKills( value:uint ):void {
			_totalKills = value;
			updateUi();
		}

		public function updateCurrentLevelKills( value:uint, target:uint ):void {
			_currentLevelKills = value;
			_levelTargetKills = target;
			updateUi();
		}

		public function updateLevel( value:uint ):void {
			_level = value;
			updateUi();
		}

		private function updateUi():void {
			_mainText.text = "Temporary UI \n";
			_mainText.text += "kills: " + _currentLevelKills + "/" + _levelTargetKills + "\n"
			_mainText.text += "total kills: " + _totalKills + "\n"
			_mainText.text += "level: " + _level + "\n"
		}
	}
}
