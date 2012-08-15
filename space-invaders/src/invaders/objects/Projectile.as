package invaders.objects
{
	import away3d.entities.*;
	
	public class Projectile extends GameObject
	{
		private var _mesh:Mesh;
		
		public var targets:Vector.<GameObject>;
		
		public function Projectile( mesh:Mesh )
		{
			super();
			
			_mesh = mesh;
			
			addChild( mesh );
		}
		
		override public function cloneGameObject():GameObject
		{
			return new Projectile( _mesh.clone() as Mesh );
		}
		
		override public function update():void
		{
			super.update();
			
			if( z > 30000 ) {
				removeItem();
				return;
			}
			
			var target:GameObject;
			var dx:Number, dy:Number, dz:Number, distance:Number;

			// Check for collisions.
			for each ( target in targets) {
				if( target.enabled ) {

					dz = target.z - z;

					if( Math.abs( dz ) < Math.abs( velocity.z ) ) {
						dx = target.x - x;
						dy = target.y - y;
						distance = Math.sqrt( dx * dx + dy * dy );
						if( distance < GameSettings.impactHitSize * target.scaleX ) {
							target.impact( this );
							removeItem();
						}
					}
				}

			}

		}
	}
}
