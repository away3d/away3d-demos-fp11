package com.away3d.spaceinvaders.gameobjects.blast
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;

	public class BlastPool extends GameObjectPool
	{
		private var _mesh:Mesh;

		public function BlastPool( mesh:Mesh ) {
			super();
			_mesh = mesh;
		}

		override protected function createItem():GameObject {
			return new Blast( _mesh.clone() as Mesh );
		}
	}
}
