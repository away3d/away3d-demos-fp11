package com.away3d.spaceinvaders.input
{

	import com.away3d.spaceinvaders.views.InvaderScene;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class InputBase extends Sprite
	{
		protected var _currentPosition:Point;
		protected var _scene:InvaderScene;

		public function InputBase( scene:InvaderScene ) {
			_scene = scene;
			_currentPosition = new Point();
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {
			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
			init();
		}

		public function init():void {
			// override
		}

		public function update():void {
			// override
		}
	}
}
