package 
{

	import invaders.input.DesktopInput;
	import invaders.events.GameEvent;
	import invaders.input.InputBase;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.Mouse;
	import invaders.save.StateSaveManager;
	import invaders.scene.InvaderScene;
	import invaders.sound.SoundManager;
	import invaders.ui.UIView;
	import invaders.utils.ScoreManager;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class Main extends Sprite
	{
		protected var _input:InputBase;
		protected var _scene:InvaderScene;

		private var _showingMouse:Boolean = true;
		private var _ui:UIView;
		
				
		/**
		 * Constructor
		 */
		public function Main()
		{
			//initialise the score manager
			ScoreManager.instance.addEventListener( GameEvent.GAME_OVER, onGameOver );
			
			//initialise the save manager
			ScoreManager.instance.saveManager = new StateSaveManager();
			
			//set stage properties
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//update game settings
			GameSettings.windowWidth = stage.stageWidth;
			GameSettings.windowHeight = stage.stageHeight;
			
			_scene = new InvaderScene();
			addChild( _scene );
			
			//initialise sound manager
			SoundManager.registerSounds();
			
			//initilaise input
			_input = new DesktopInput( _scene );
			addChild( _input );
			
			//initialise UI
			_ui = new UIView();
			addChild( _ui );

			ScoreManager.instance.ui = _ui;

			_ui.addEventListener( GameEvent.PLAY, onUiPlay );
			_ui.addEventListener( GameEvent.RESTART, onUiRestart );
			_ui.addEventListener( GameEvent.PAUSE, onUiPause );
			_ui.addEventListener( GameEvent.RESUME, onUiResume );

			_ui.showSplashPopUp();
			
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		protected function initStageDims():void {
			GameSettings.windowWidth = stage.stageWidth;
			GameSettings.windowHeight = stage.stageHeight;
		}

		private function onGameOver( event:GameEvent ):void {
			_ui.showGameOverPopUp( ScoreManager.instance.score, ScoreManager.instance.highScore );
			stopGame();
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
			_input.reset();
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
			_input.reset();
		}
	}
}
