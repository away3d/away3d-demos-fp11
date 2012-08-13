package invaders.events
{

	import flash.events.Event;
	import invaders.gameobjects.GameObject;


	public class GameObjectEvent extends Event
	{
		public static const DEAD:String = "gameObjectEvent/dead";
		public static const HIT:String = "gameObjectEvent/hit";
		public static const FIRE:String = "gameObjectEvent/fire";
		public static const CREATED:String = "gameObjectEvent/created";

		public var objectA:GameObject;
		public var objectB:GameObject;

		public function GameObjectEvent( type:String, objectA:GameObject = null, objectB:GameObject = null, bubbles:Boolean = false, cancelable:Boolean = false ) {
			super( type, bubbles, cancelable );
			this.objectA = objectA;
			this.objectB = objectB;
		}

		override public function clone():Event {
			return new GameObjectEvent( type, objectA, objectB, bubbles, cancelable );
		}
	}
}
