package invaders.events
{

	import flash.events.Event;

	public class GameEvent extends Event
	{
		public static const GAME_OVER:String = "gameEvent/game/over";
		public static const PLAY:String = "gameEvent/play";
		public static const RESTART:String = "gameEvent/restart";
		public static const PAUSE:String = "gameEvent/pause";
		public static const RESUME:String = "gameEvent/resume";

		public function GameEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false ) {
			super( type, bubbles, cancelable );
		}

		override public function clone():Event {
			return new GameEvent( type, bubbles, cancelable );
		}
	}
}
