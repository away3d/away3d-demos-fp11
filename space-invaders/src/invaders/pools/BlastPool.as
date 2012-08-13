package invaders.pools
{

	import away3d.entities.Mesh;
	import invaders.objects.Blast;
	import invaders.objects.GameObject;


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
