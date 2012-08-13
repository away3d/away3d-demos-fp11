package invaders.gameobjects.invaders
{

	import away3d.entities.Mesh;
	import invaders.gameobjects.GameObject;
	import invaders.gameobjects.GameObjectPool;


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
