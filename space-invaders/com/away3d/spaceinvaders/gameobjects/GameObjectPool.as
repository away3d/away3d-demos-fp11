package com.away3d.spaceinvaders.gameobjects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.errors.AbstractMethodError;

	public class GameObjectPool extends ObjectContainer3D
	{
		protected var _gameObjects:Vector.<GameObject>;

		public function GameObjectPool() {
			super();
			_gameObjects = new Vector.<GameObject>();
		}

		public function update():void {
			var len:uint = _gameObjects.length;
			for( var i:uint; i < len; i++ ) {
				var gameObject:GameObject = _gameObjects[ i ];
				if( gameObject.enabled ) {
					gameObject.update();
					// Disable objects that have gone outside of the scene range.
					if( gameObject.z < -1000 || gameObject.z > 100000 ) {
						gameObject.enabled = false;
					}
					// Make sure item is added to view.
					if( !gameObject.parent && gameObject.enabled ) {
						addChild( gameObject );
					}
				}
				// Remove all disabled objects from view.
				else if( gameObject.parent ) {
					removeChild( gameObject );
				}
			}
		}

		public function addItem():GameObject {
			// Adds an unused item or creates a new item if none is found.
			var gameObject:GameObject;
			var len:uint = _gameObjects.length;
			for( var i:uint; i < len; i++ ) {
				gameObject = _gameObjects[ i ];
				if( !gameObject.enabled ) {
					gameObject.reset();
					return gameObject;
				}
			}
			gameObject = createItem();
			gameObject.reset();
			_gameObjects.push( gameObject );
			return gameObject;
		}

		protected function createItem():GameObject {
			throw new AbstractMethodError();
		}

		public function get gameObjects():Vector.<GameObject> {
			return _gameObjects;
		}
	}
}
