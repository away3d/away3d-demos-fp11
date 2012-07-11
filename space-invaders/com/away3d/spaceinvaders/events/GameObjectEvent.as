package com.away3d.spaceinvaders.events
{

	import com.away3d.spaceinvaders.gameobjects.GameObject;

	import flash.events.Event;

	public class GameObjectEvent extends Event
	{
		public static const DEAD:String = "gameObjectEvent/dead";
		public static const FIRE:String = "gameObjectEvent/fire";

		public var objectA:GameObject;
		public var objectB:GameObject;

		public function GameObjectEvent( type:String, objectA:GameObject = null, objectB:GameObject = null, bubblesBoolean = false, cancelable:Boolean = false ) {
			super( type, bubbles, cancelable );
			this.objectA = objectA;
			this.objectB = objectB;
		}

		override public function clone():Event {
			return new GameObjectEvent( type, objectA, objectB, bubbles, cancelable );
		}
	}
}
