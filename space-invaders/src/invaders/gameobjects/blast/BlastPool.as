package invaders.gameobjects.blast
{

	import away3d.entities.Mesh;
	import invaders.gameobjects.GameObject;
	import invaders.gameobjects.GameObjectPool;


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
