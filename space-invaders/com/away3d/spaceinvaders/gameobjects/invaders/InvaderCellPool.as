package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;

	public class InvaderCellPool extends GameObjectPool
	{
		private var _cellMesh:Mesh;

		public function InvaderCellPool( cellMesh:Mesh ) {
			super();
			_cellMesh = cellMesh;
		}

		override protected function createItem():GameObject {
			return new InvaderCell( _cellMesh.clone() as Mesh );
		}
	}
}
