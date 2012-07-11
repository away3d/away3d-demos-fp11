package com.away3d.spaceinvaders
{

	import away3d.audio.Sound3D;

	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.sound.Sounds;
	import com.away3d.spaceinvaders.views.InvaderScene;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.media.Sound;

	public class Main extends Sprite
	{
		private var _invaderScene:InvaderScene;

		public function Main() {
			initStage();
			initScene();
			initSound();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function initSound():void {
			SoundManager.registerSound( Sounds.PLAYER_FIRE, new SoundPlayerFire() );
			SoundManager.registerSound( Sounds.INVADER_DEATH, new SoundInvaderDeath() );
			SoundManager.registerSound( Sounds.EXPLOSION_SOFT, new SoundExplosionSoft() );
			SoundManager.registerSound( Sounds.EXPLOSION_STRONG, new SoundExplosionStrong() );
			SoundManager.registerSound( Sounds.MOTHERSHIP, new SoundMothership() );
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
