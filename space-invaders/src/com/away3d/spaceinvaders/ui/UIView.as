package com.away3d.spaceinvaders.ui
{

	import com.away3d.spaceinvaders.GameVariables;
	import com.away3d.spaceinvaders.events.GameEvent;
	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.sound.Sounds;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class UIView extends Sprite
	{
		private var _scoreText:TextField;
		private var _livesText:TextField;
		private var _popUp:MovieClip;
		private var _restartButton:SimpleButton;
		private var _pauseButton:SimpleButton;
		private var _liveIconsContainer:Sprite;
		private var _crossHair:Sprite;

		public function UIView() {
			addEventListener( Event.ADDED_TO_STAGE, stageInitHandler );
		}

		private function stageInitHandler( event:Event ):void {

			removeEventListener( Event.ADDED_TO_STAGE, stageInitHandler );

			// Cross hair.
			_crossHair = new Crosshair();
			_crossHair.x = GameVariables.windowWidth / 2;
			_crossHair.y = GameVariables.windowHeight / 2;
			addChild( _crossHair );

			// Score text.
			_scoreText = getTextField();
			addChild( _scoreText );

			// Lives text.
			_livesText = getTextField();
			_livesText.y = GameVariables.windowHeight - 35;
			fitClip( _livesText );
			addChild( _livesText );

			// Lives icons.
			_liveIconsContainer = new Sprite();
			addChild( _liveIconsContainer );
			for( var i:uint; i < GameVariables.playerLives; i++ ) {
				var live:Sprite = new InvaderLive();
				live.x = i * ( live.width + 5 );
				_liveIconsContainer.addChild( live );
			}
			_liveIconsContainer.y = _livesText.y + 12;
			fitClip( _liveIconsContainer );

			// Buttons.
			_restartButton = new RestartButton();
			_restartButton.addEventListener( MouseEvent.MOUSE_UP, onRestart );
			initializeButton( _restartButton );
			addChild( _restartButton );
			_pauseButton = new PauseButton();
			_pauseButton.x = GameVariables.windowWidth - _pauseButton.width;
			fitClip( _pauseButton );
			_pauseButton.addEventListener( MouseEvent.MOUSE_UP, onPause );
			initializeButton( _pauseButton );
			addChild( _pauseButton );
		}

		// -----------------------
		// Pop ups.
		// -----------------------

		public function showPausePopUp():void {
			var popUp:MovieClip = new PausePopUp();
			var resumeButton:SimpleButton = popUp.resumeButton;
			resumeButton.addEventListener( MouseEvent.MOUSE_UP, onResume, false, 0, true );
			initializeButton( resumeButton );
			initializePopUp( popUp );
		}

		public function hidePausePopUp():void {
			if( !_popUp || !( _popUp is PausePopUp ) ) return;
			var resumeButton:SimpleButton = _popUp.resumeButton;
			resumeButton.removeEventListener( MouseEvent.MOUSE_UP, onResume );
			destroyButton( resumeButton );
			destroyPopUp();
		}

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
			fitClip( scoreText );
			highScoreText.width = highScoreText.textWidth * 1.05;
			highScoreText.x = -highScoreText.width / 2;
			fitClip( highScoreText );
			initializePopUp( popUp );
		}

		public function hideGameOverPopUp():void {
			if( !_popUp || !( _popUp is GameOverPopUp ) ) return;
			var playAgainButton:SimpleButton = _popUp.playAgainButton;
			playAgainButton.removeEventListener( MouseEvent.MOUSE_UP, onPlay );
			destroyButton( playAgainButton );
			destroyPopUp();
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
			destroyPopUp();
		}

		private function destroyPopUp():void {
			removeChild( _popUp );
			_popUp = null;
			_scoreText.visible = true;
			_livesText.visible = true;
			_restartButton.visible = true;
			_pauseButton.visible = true;
			_liveIconsContainer.visible = true;
			_crossHair.visible = true;
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
			_scoreText.visible = false;
			_livesText.visible = false;
			_restartButton.visible = false;
			_pauseButton.visible = false;
			_liveIconsContainer.visible = false;
			_crossHair.visible = false;
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
			dispatchEvent( new GameEvent( GameEvent.RESUME ) );
		}

		private function onPause( event:MouseEvent ):void {
			dispatchEvent( new GameEvent( GameEvent.PAUSE ) );
		}

		private function onRestart( event:MouseEvent ):void {
			dispatchEvent( new GameEvent( GameEvent.RESTART ) );
		}

		// -----------------------
		// Text fields.
		// -----------------------

		public function updateLives( lives:uint ):void {
			// Update icons.
			for( var i:uint; i < GameVariables.playerLives; i++ ) {
				var child:Sprite = _liveIconsContainer.getChildAt( i ) as Sprite;
				child.visible = lives >= i + 1;
			}
			// Update text.
			_livesText.text = "LIVES " + lives + "";
			_livesText.width = _livesText.textWidth * 1.05;
			_livesText.x = GameVariables.windowWidth / 2 - _livesText.width / 2 - _liveIconsContainer.width / 2 - 5;
			_liveIconsContainer.x = _livesText.x + _livesText.width + 10;
			fitClip( _livesText );
			fitClip( _liveIconsContainer );
		}

		public function updateScore( score:uint, highScore:uint ):void {
			_scoreText.text = "SCORE " + uintToString( score ) + "   ";
			_scoreText.text += "HIGH-SCORE " + uintToString( highScore );
			_scoreText.width = _scoreText.textWidth * 1.05;
			_scoreText.x = GameVariables.windowWidth / 2 - _scoreText.width / 2;
			fitClip( _scoreText );
		}

		private function getTextField():TextField {
			var clip:CustomTextField = new CustomTextField();
			return clip.tf;
		}

		private function fitClip( clip:DisplayObject ):void {
			clip.x = Math.floor( clip.x );
			clip.y = Math.floor( clip.y );
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
