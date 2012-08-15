package invaders.events
{
	import invaders.objects.*;
	
	import flash.events.*;
	
	public class GameObjectEvent extends Event
	{
		public static const GAME_OBJECT_DEAD:String = "gameObjectDead";
		public static const GAME_OBJECT_HIT:String = "gameObjectHit";
		public static const GAME_OBJECT_FIRE:String = "gameObjectFire";
		public static const GAME_OBJECT_ADDED:String = "gameObjectAdded";
		
		public var gameTarget:GameObject;
		public var gameTrigger:GameObject;
		
		public function GameObjectEvent( type:String, gameTarget:GameObject = null, gameTrigger:GameObject = null, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
			this.gameTarget = gameTarget;
			this.gameTrigger = gameTrigger;
		}
		
		override public function clone():Event
		{
			return new GameObjectEvent( type, gameTarget, gameTrigger, bubbles, cancelable );
		}
	}
}
