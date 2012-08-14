package invaders.pools
{
	import away3d.entities.*;
	
	import invaders.objects.*;
	
	public class InvaderCellPool extends GameObjectPool
	{
		private var _cellMesh:Mesh;

		public function InvaderCellPool( cellMesh:Mesh )
		{
			
			super();
			_cellMesh = cellMesh;
		}

		override protected function createItem():GameObject
		{
			return new InvaderCell( _cellMesh.clone() as Mesh );
		}
	}
}
