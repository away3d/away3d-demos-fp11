package com.away3d.spaceinvaders.gameobjects.projectiles
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.gameobjects.GameObjectPool;

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
