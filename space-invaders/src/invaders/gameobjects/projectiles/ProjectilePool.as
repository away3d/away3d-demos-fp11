package invaders.gameobjects.projectiles
{

	import away3d.entities.Mesh;
	import invaders.gameobjects.GameObject;
	import invaders.gameobjects.GameObjectPool;


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
