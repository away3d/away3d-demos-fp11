package com.away3d.spaceinvaders.input
{

	import com.away3d.spaceinvaders.GameSettings;
	import com.away3d.spaceinvaders.views.InvaderScene;

	import flash.events.MouseEvent;

	public class MouseInput extends InputBase
	{
		public function MouseInput( scene:InvaderScene ) {
			super( scene );
		}

		override public function init():void {
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
		}

		private function onStageMouseDown( event:MouseEvent ):void {
			_scene.firePlayer();
		}

		override public function update():void {
			if( !stage ) return;
			// TODO: handle out of screen mouse input
			var targetX:Number =  GameSettings.cameraPanRange * ( stage.mouseX - stage.stageWidth  / 2 ) / ( stage.stageWidth  / 2 );
			var targetY:Number = -GameSettings.cameraPanRange * ( stage.mouseY - stage.stageHeight / 2 ) / ( stage.stageHeight / 2 );
			_scene.movePlayerTowards( targetX, targetY );
		}
	}
}
