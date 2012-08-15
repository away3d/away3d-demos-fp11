package invawayders.pools
{
	import invawayders.objects.*;
	
	import away3d.containers.*;
	
	public class GameObjectPool extends ObjectContainer3D
	{
		protected var _gameObject : GameObject;
		protected var _gameObjects:Vector.<GameObject>  = new Vector.<GameObject>();
		
		public function get gameObjects():Vector.<GameObject>
		{
			return _gameObjects;
		}
		
		public function GameObjectPool( gameObject:GameObject)
		{
			super();
			
			_gameObject = gameObject;
		}
		
		public function reset():void
		{
			var gameObject:GameObject;
			for each ( gameObject in _gameObjects)
				if( gameObject.enabled )
					gameObject.removeItem();
		}
		
		public function update():void
		{
			var gameObject:GameObject;
			for each ( gameObject in _gameObjects) {
				if( gameObject.enabled ) {
					gameObject.update();
					
					// Disable objects that have gone outside of the scene range.
					if( gameObject.z < GameSettings.minZ || gameObject.z > GameSettings.maxZ )
						gameObject.removeItem();
				}
			}
		}
		
		public function getGameObject():GameObject
		{
			// Adds an unused game object or creates a new game object if none is found.
			var gameObject:GameObject;
			for each ( gameObject in _gameObjects ) {
				if( !gameObject.enabled ) {
					gameObject.addItem(this);
					return gameObject;
				}
			}
			
			gameObject = _gameObject.cloneGameObject();
			
			gameObject.addItem(this);
			_gameObjects.push( gameObject );
			
			return gameObject;
		}
	}
}
