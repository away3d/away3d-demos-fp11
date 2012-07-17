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
	import flash.ui.Mouse;

	public class Main extends Sprite
	{
		protected var _input:InputBase;
		protected var _scene:InvaderScene;

		private var _showingMouse:Boolean = true;
		private var _ui:UIView;

		public function Main() {
			initScoreManager();
			initConsistency();
			initStage();
			initStageDims();
			initScene();
			SoundManager.registerSounds();
			initInput();
			initUi();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		protected function initStageDims():void {
			GameVariables.windowWidth = stage.stageWidth;
			GameVariables.windowHeight = stage.stageHeight;
		}

		protected function initConsistency():void {
			ScoreManager.instance.saveManager = new StateSaveManager();
		}

		private function initScoreManager():void {
			ScoreManager.instance.addEventListener( GameEvent.GAME_OVER, onGameOver );
		}

		private function onGameOver( event:GameEvent ):void {
			_ui.showGameOverPopUp( ScoreManager.instance.score, ScoreManager.instance.highScore );
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
			showMouse();
			_scene.stop();
		}

		private function startGame():void {
			hideMouse();
			_scene.reset();
			_scene.resume();
			ScoreManager.instance.reset();
		}

		private function enterframeHandler( event:Event ):void {
			_input.update();
			_scene.update();

			if( _scene.active ) {
				if( mouseY < 50 ) showMouse();
				else hideMouse();
			}
		}

		// -----------------------------
		// User interface interaction.
		// -----------------------------

		private function showMouse():void {
			if( _showingMouse ) return;
			Mouse.show();
			_showingMouse = true;
		}

		private function hideMouse():void {
			if( !_showingMouse ) return;
			Mouse.hide();
			_showingMouse = false;
		}

		private function onUiResume( event:GameEvent ):void {
			hideMouse();
			_ui.hidePausePopUp();
			_scene.resume();
		}

		private function onUiPause( event:GameEvent ):void {
			showMouse();
			stopGame();
			_ui.showPausePopUp();
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
