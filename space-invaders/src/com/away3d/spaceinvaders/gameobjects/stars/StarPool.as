package com.away3d.spaceinvaders.gameobjects.stars
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.GameVariables;

	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;

	public class StarPool extends GameObjectPool
	{
		private var _starMesh:Mesh;

		public function StarPool( mesh:Mesh ) {
			super();
			_starMesh = mesh;
		}

		override public function update():void {
			if( numChildren < GameVariables.maxStarNum ) {
				var len:uint = Math.floor( 1 + 4 * Math.random() );
				for( var i:uint; i < len; ++i ) {
					addItem();
				}
			}
			super.update();
		}

		override protected function createItem():GameObject {
			return new Star( _starMesh.clone() as Mesh );
		}
	}
}
