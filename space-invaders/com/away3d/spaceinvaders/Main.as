package com.away3d.spaceinvaders
{

	import away3d.textures.BitmapCubeTexture;

	import com.away3d.spaceinvaders.events.GameEvent;
	import com.away3d.spaceinvaders.input.AccelerometerInput;
	import com.away3d.spaceinvaders.input.InputBase;
	import com.away3d.spaceinvaders.input.MouseInput;
	import com.away3d.spaceinvaders.input.TouchInput;
	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.sound.Sounds;
	import com.away3d.spaceinvaders.utils.PlatformUtil;
	import com.away3d.spaceinvaders.utils.ScoreManager;
	import com.away3d.spaceinvaders.scene.InvaderScene;
	import com.away3d.spaceinvaders.ui.UIView;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.sensors.Accelerometer;

	public class Main extends Sprite
	{
		private var _ui:UIView;
		private var _input:InputBase;
		private var _invaderScene:InvaderScene;

		public function Main() {
			initStage();
			initScene();
			initScoreManager();
			initSound();
			initInput();
			initUi();
		}

		private function initScoreManager():void {
			ScoreManager.instance.addEventListener( GameEvent.GAME_OVER, onGameOver );
		}

		private function onGameOver( event:GameEvent ):void {
			_ui.showGameOverPopUp();
			_invaderScene.reset();
			stopGame();
		}

		private function initInput():void {
			_input = PlatformUtil.isRunningOnMobile() ?
					GameSettings.useAccelerometer && Accelerometer.isSupported ? new AccelerometerInput( _invaderScene ) : new TouchInput( _invaderScene )
					: new MouseInput( _invaderScene );
			addChild( _input );
		}

		private function initSound():void {
			SoundManager.registerSound( Sounds.PLAYER_FIRE, new SoundPlayerFire() );
			SoundManager.registerSound( Sounds.INVADER_DEATH, new SoundInvaderDeath() );
			SoundManager.registerSound( Sounds.EXPLOSION_SOFT, new SoundExplosionSoft() );
			SoundManager.registerSound( Sounds.EXPLOSION_STRONG, new SoundExplosionStrong() );
			SoundManager.registerSound( Sounds.MOTHERSHIP, new SoundMothership() );
			SoundManager.registerSound( Sounds.BOING, new SoundFast() );
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

		private function initUi():void {

			_ui = new UIView();
			addChild( _ui );

			ScoreManager.instance.ui = _ui;

			_ui.addEventListener( GameEvent.PLAY, onUiPlay );
			_ui.addEventListener( GameEvent.RESTART, onUiRestart );
			_ui.addEventListener( GameEvent.PAUSE, onUiPause );
			_ui.addEventListener( GameEvent.RESUME, onUiResume );

			_ui.showSplashPopUp();
		}

		private function onUiResume( event:GameEvent ):void {
			_invaderScene.resume();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function onUiPause( event:GameEvent ):void {
			stopGame();
		}

		private function onUiRestart( event:GameEvent ):void {
			_invaderScene.reset();
			ScoreManager.instance.reset();
		}

		private function onUiPlay( event:GameEvent ):void {
			_ui.hideSplashPopUp();
			_ui.hideGameOverPopUp();
			startGame();
		}

		private function stopGame():void {
			_invaderScene.stop();
			removeEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function startGame():void {
			_invaderScene.resume();
			ScoreManager.instance.reset();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function enterframeHandler( event:Event ):void {
			_input.update();
			_invaderScene.update();
		}
	}
}
