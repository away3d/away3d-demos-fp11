package com.away3d.spaceinvaders.ui
{

	import com.away3d.spaceinvaders.GameVariables;
	import com.away3d.spaceinvaders.events.GameEvent;
	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.sound.Sounds;

	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	public class UIView extends Sprite
	{
		private var _scoreText:TextField;
		private var _livesText:TextField;
		private var _popUp:MovieClip;
		private var _pauseButton:SimpleButton;
		private var _resumeButton:SimpleButton;

		public function UIView() {
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {

			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );

			// Cross hair.
			var crossHair:Sprite = new Crosshair();
			crossHair.x = GameVariables.windowWidth / 2;
			crossHair.y = GameVariables.windowHeight / 2;
			addChild( crossHair );

			// Score text.
			_scoreText = getTextField();
			addChild( _scoreText );

			// Lives text.
			_livesText = getTextField();
			_livesText.y = GameVariables.windowHeight - 20;
			addChild( _livesText );

			// Buttons.
			var restartButton:SimpleButton = new RestartButton();
			restartButton.x = GameVariables.windowWidth - restartButton.width;
			restartButton.y = GameVariables.windowHeight - restartButton.height;
			restartButton.addEventListener( MouseEvent.MOUSE_UP, onRestart );
			initializeButton( restartButton );
			addChild( restartButton );
			_pauseButton = new PauseButton();
			_pauseButton.x = GameVariables.windowWidth - _pauseButton.width;
			_pauseButton.addEventListener( MouseEvent.MOUSE_UP, onPause );
			initializeButton( _pauseButton );
			addChild( _pauseButton );
			_resumeButton = new PlayButton();
			_resumeButton.visible = false;
			_resumeButton.x = GameVariables.windowWidth - _resumeButton.width;
			_resumeButton.addEventListener( MouseEvent.MOUSE_UP, onResume );
			initializeButton( _resumeButton );
			addChild( _resumeButton );
		}

		// -----------------------
		// Pop ups.
		// -----------------------

		public function showGameOverPopUp( score:uint, highScore:uint ):void {
			var popUp:MovieClip = new GameOverPopUp();
			var playAgainButton:SimpleButton = popUp.playAgainButton;
			playAgainButton.addEventListener( MouseEvent.MOUSE_UP, onPlay, false, 0, true );
			initializeButton( playAgainButton );
			var scoreText:TextField = popUp.scoreText;
			scoreText.text =     "SCORE................................... " + uintToString( score );
			var highScoreText:TextField = popUp.highScoreText;
			highScoreText.text = "HIGH-SCORE.............................. " + uintToString( highScore );
			scoreText.width = scoreText.textWidth * 1.05;
			scoreText.x = -scoreText.width / 2;
			highScoreText.width = highScoreText.textWidth * 1.05;
			highScoreText.x = -highScoreText.width / 2;
			initializePopUp( popUp );
		}

		public function hideGameOverPopUp():void {
			if( !_popUp || !( _popUp is GameOverPopUp ) ) return;
			var playAgainButton:SimpleButton = _popUp.playAgainButton;
			playAgainButton.removeEventListener( MouseEvent.MOUSE_UP, onPlay );
			destroyButton( playAgainButton );
			removeChild( _popUp );
			_popUp = null;
		}

		public function showSplashPopUp():void {
			var popUp:SplashPopUp = new SplashPopUp();
			var playButton:SimpleButton = popUp.playButton;
			playButton.addEventListener( MouseEvent.MOUSE_UP, onPlay, false, 0, true );
			initializeButton( playButton );
			initializePopUp( popUp );
		}

		public function hideSplashPopUp():void {
			if( !_popUp || !( _popUp is SplashPopUp ) ) return;
			var playButton:SimpleButton = _popUp.playButton;
			playButton.removeEventListener( MouseEvent.MOUSE_UP, onPlay );
			destroyButton( playButton );
			removeChild( _popUp );
			_popUp = null;
		}

		private function initializePopUp( popUp:MovieClip ):void {
			popUp.x = GameVariables.windowWidth / 2;
			popUp.y = GameVariables.windowHeight / 2;
			var bg:Sprite = popUp.bg;
			bg.width = GameVariables.windowWidth;
			bg.height = GameVariables.windowHeight;
			bg.x = -GameVariables.windowWidth / 2;
			bg.y = -GameVariables.windowHeight / 2;
			_popUp = popUp;
			addChild( popUp );
		}

		private function initializeButton( button:SimpleButton ):void {
			button.addEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown, false, 0, true );
		}

		private function destroyButton( button:SimpleButton ):void {
			button.removeEventListener( MouseEvent.MOUSE_DOWN, onBtnMouseDown );
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onBtnMouseDown( event:MouseEvent ):void {
			SoundManager.playSound( Sounds.UFO );
		}

		private function onPlay( event:MouseEvent ):void {
			dispatchEvent( new GameEvent( GameEvent.PLAY ) );
		}

		private function onResume( event:MouseEvent ):void {
			_pauseButton.visible = true;
			_resumeButton.visible = false;
			dispatchEvent( new GameEvent( GameEvent.RESUME ) );
		}

		private function onPause( event:MouseEvent ):void {
			_pauseButton.visible = false;
			_resumeButton.visible = true;
			dispatchEvent( new GameEvent( GameEvent.PAUSE ) );
		}

		private function onRestart( event:MouseEvent ):void {
			dispatchEvent( new GameEvent( GameEvent.RESTART ) );
		}

		// -----------------------
		// Text fields.
		// -----------------------

		public function updateLivesText( lives:uint ):void {
			_livesText.text = "< LIVES " + lives + " >";
			_livesText.width = _livesText.textWidth * 1.05;
			_livesText.x = GameVariables.windowWidth / 2 - _livesText.width / 2;
		}

		public function updateScoreText( score:uint, highScore:uint ):void {
			_scoreText.text = "< SCORE " + uintToString( score ) + " >   < ";
			_scoreText.text += "HIGH-SCORE " + uintToString( highScore ) + " >"; // TODO
			_scoreText.width = _scoreText.textWidth * 1.05;
			_scoreText.x = GameVariables.windowWidth / 2 - _scoreText.width / 2;
		}

		private function getTextField():TextField {
			var clip:CustomTextField = new CustomTextField();
			return clip.tf;
		}

		private function uintToString( value:uint ):String {
			if( value == 0 ) return "00000";
			var str:String = "";
			var compare:Number = 10000;
			while( compare > value ) {
				str += "0";
				compare /= 10;
			}
			str += value;
			return str;
		}
	}
}
