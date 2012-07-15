package com.away3d.spaceinvaders
{

	import com.away3d.spaceinvaders.events.GameEvent;
	import com.away3d.spaceinvaders.input.InputBase;
	import com.away3d.spaceinvaders.input.DesktopInput;
	import com.away3d.spaceinvaders.save.StateSaveManager;
	import com.away3d.spaceinvaders.scene.InvaderScene;
	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.ui.UIView;
	import com.away3d.spaceinvaders.utils.ScoreManager;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	public class Main extends Sprite
	{
		protected var _input:InputBase;
		protected var _scene:InvaderScene;

		private var _ui:UIView;

		public function Main() {
			initScoreManager();
			initConsistency();
			initStage();
			initScene();
			SoundManager.registerSounds();
			initInput();
			initUi();
		}

		protected function initConsistency():void {
			ScoreManager.instance.saveManager = new StateSaveManager();
		}

		private function initScoreManager():void {
			ScoreManager.instance.addEventListener( GameEvent.GAME_OVER, onGameOver );
		}

		private function onGameOver( event:GameEvent ):void {
			_ui.showGameOverPopUp( ScoreManager.instance.score, ScoreManager.instance.highScore );
			_scene.reset();
			stopGame();
		}

		protected function initInput():void {
			_input = new DesktopInput( _scene );
			addChild( _input );
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
		}

		private function initScene():void {
			_scene = new InvaderScene();
			addChild( _scene );
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

		// -----------------------
		// App flow.
		// -----------------------

		private function stopGame():void {
			_scene.stop();
			removeEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function startGame():void {
			_scene.reset();
			_scene.resume();
			ScoreManager.instance.reset();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function enterframeHandler( event:Event ):void {
			_input.update();
			_scene.update();
		}

		// -----------------------------
		// User interface interaction.
		// -----------------------------

		private function onUiResume( event:GameEvent ):void {
			_scene.resume();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function onUiPause( event:GameEvent ):void {
			stopGame();
		}

		private function onUiRestart( event:GameEvent ):void {
			_scene.reset();
			ScoreManager.instance.reset();
		}

		private function onUiPlay( event:GameEvent ):void {
			_ui.hideSplashPopUp();
			_ui.hideGameOverPopUp();
			startGame();
		}
	}
}
