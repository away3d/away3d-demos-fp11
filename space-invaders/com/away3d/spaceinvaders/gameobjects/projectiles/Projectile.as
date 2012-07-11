package com.away3d.spaceinvaders.gameobjects.projectiles
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.utils.MathUtils;

	public class Projectile extends GameObject
	{
		private var _targets:Vector.<GameObject>;

		public function Projectile( mesh:Mesh ) {
			super();
			addChild( mesh );
		}

		override public function reset():void {
			super.reset();
			rotationalVelocity.z = MathUtils.rand( -5, 5 );
		}

		override public function update():void {

			super.update();

			var i:uint, len:uint;
			var target:GameObject;
			var dx:Number, dy:Number, dz:Number, distance:Number;

			// Check for collisions.
			len = _targets.length;
			for( i = 0; i < len; ++i ) {

				target = _targets[ i ];
				if( target.enabled ) {

					dz = target.z - z;

					if( Math.abs( dz ) < Math.abs( velocity.z ) ) {
						dx = target.x - x;
						dy = target.y - y;
						distance = Math.sqrt( dx * dx + dy * dy );
						if( distance < 150 ) {
							target.impact( this );
							enabled = false;
						}
					}
				}

			}

		}

		override public function destroy():void {
			super.destroy();
			_targets = null;
		}

		public function set targets( value:Vector.<GameObject> ):void {
			_targets = value;
		}
	}
}
