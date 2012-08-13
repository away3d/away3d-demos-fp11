package invaders.objects
{

	import away3d.entities.Mesh;


	public class Blast extends GameObject
	{
		public function Blast( mesh:Mesh ) {
			super();
			addChild( mesh );
		}

		override public function update():void {
			scaleX = scaleY = scaleZ += 0.15;
			if( scaleX >= 5 ) {
				enabled = false;
			}
			super.update();
		}

		override public function reset():void {
			scaleX = scaleY = scaleZ = 0;
			super.reset();
		}
	}
}
