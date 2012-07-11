package com.away3d.spaceinvaders
{

	import com.away3d.spaceinvaders.views.InvaderScene;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	public class Main extends Sprite
	{
		private var _invaderScene:InvaderScene;

		public function Main() {
			initStage();
			initScene();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 30;
		}

		private function initScene():void {
			_invaderScene = new InvaderScene();
			addChild( _invaderScene );
		}

		private function enterframeHandler( event:Event ):void {
			var targetX:Number = 1500 * ( stage.mouseX - stage.stageWidth / 2 ) / ( stage.stageWidth / 2 );
			var targetY:Number = -1500 * ( stage.mouseY - stage.stageHeight / 2 ) / ( stage.stageHeight / 2 );
			_invaderScene.movePlayerTowards( targetX, targetY );
			_invaderScene.update();
		}
	}
}
