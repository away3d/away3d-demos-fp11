package invaders.pools
{

	import away3d.entities.Mesh;
	import invaders.objects.GameObject;
	import invaders.objects.Projectile;


	public class ProjectilePool extends GameObjectPool
	{
		private var _projectileMesh:Mesh;

		public function ProjectilePool( projectileMesh:Mesh ) {
			super();
			_projectileMesh = projectileMesh;
		}

		override protected function createItem():GameObject {
			return new Projectile( _projectileMesh.clone() as Mesh );
		}
	}
}
