package com.away3d.spaceinvaders.utils
{

	import com.away3d.spaceinvaders.events.GameEvent;
	import com.away3d.spaceinvaders.gameobjects.invaders.InvaderFactory;
	import com.away3d.spaceinvaders.ui.UIView;

	import flash.events.EventDispatcher;

	import flash.utils.Dictionary;

	public class ScoreManager extends EventDispatcher
	{
		private static var _instance:ScoreManager;

		private var _ui:UIView;

		private var _score:uint;
		private var _lives:uint;

		private var _invaderScores:Dictionary;

		public function ScoreManager() {
			_invaderScores = new Dictionary();
			_invaderScores[ InvaderFactory.ROUNDED_OCTOPUS_INVADER ] = 10;
			_invaderScores[ InvaderFactory.BUG_INVADER ] = 20;
			_invaderScores[ InvaderFactory.OCTOPUS_INVADER ] = 30;
			_invaderScores[ InvaderFactory.MOTHERSHIP ] = 100;
		}

		public static function get instance():ScoreManager {
			if( !_instance ) _instance = new ScoreManager();
			return _instance;
		}

		public function reset():void {
			_score = 0;
			_lives = 3;
			_ui.updateScoreText( _score );
			_ui.updateLivesText( _lives );
		}

		public function set ui( value:UIView ):void {
			_ui = value;
		}

		public function registerKill( invaderType:uint ):void {
			_score += _invaderScores[ invaderType ];
			_ui.updateScoreText( _score );
		}

		public function registerPlayerHit():void {
			_lives--;
			_ui.updateLivesText( _lives );
			if( _lives == 0 ) {
				dispatchEvent( new GameEvent( GameEvent.GAME_OVER ) );
			}
		}
	}
}
