package invaders.pools
{
	import invaders.objects.*;
	
	import away3d.containers.*;
	import away3d.errors.*;


	public class GameObjectPool extends ObjectContainer3D
	{
		protected var _gameObjects:Vector.<GameObject>  = new Vector.<GameObject>();

		public function GameObjectPool()
		{
			super();
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
			
			gameObject = createItem();
			gameObject.addItem(this);
			_gameObjects.push( gameObject );
			
			return gameObject;
		}
		
		protected function createItem():GameObject
		{
			throw new AbstractMethodError();
		}

		public function get gameObjects():Vector.<GameObject>
		{
			return _gameObjects;
		}
	}
}
