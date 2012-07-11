package com.away3d.spaceinvaders.gameobjects
{

	import away3d.containers.ObjectContainer3D;

	import flash.geom.Vector3D;

	public class GameObject extends ObjectContainer3D
	{
		public var velocity:Vector3D;
		public var rotationalVelocity:Vector3D;

		private var _enabled:Boolean;

		public function GameObject() {
			super();

			velocity = new Vector3D();
			rotationalVelocity = new Vector3D();
		}

		public function update():void {

			if( !_enabled ) {
				return;
			}

			// Move.
			x += velocity.x;
			y += velocity.y;
			z += velocity.z;

			// Rotate.
			rotationX += rotationalVelocity.x;
			rotationY += rotationalVelocity.y;
			rotationZ += rotationalVelocity.z;
		}

		public function impact( hitter:GameObject ):void {
			// override
		}

		public function destroy():void {
//			_velocity = null;
//			_zSceneRange = null;
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled( value:Boolean ):void {
			_enabled = value;
		}
	}
}
