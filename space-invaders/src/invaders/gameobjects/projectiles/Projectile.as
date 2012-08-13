package invaders.gameobjects.projectiles
{

	import away3d.entities.Mesh;
	import invaders.gameobjects.GameObject;


	public class Projectile extends GameObject
	{
		private var _targets:Vector.<GameObject>;

		public function Projectile( mesh:Mesh ) {
			super();
			addChild( mesh );
		}

		override public function update():void {

			super.update();

			if( z > 30000 ) {
				enabled = false;
				return;
			}

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
						if( distance < GameSettings.impactHitSize * target.scaleX ) {
							target.impact( this );
							if( GameSettings.projectilesDieOnImpact ) enabled = false;
						}
					}
				}

			}

		}

		public function set targets( value:Vector.<GameObject> ):void {
			_targets = value;
		}
	}
}
