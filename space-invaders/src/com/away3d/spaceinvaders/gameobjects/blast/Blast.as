package com.away3d.spaceinvaders.gameobjects.blast
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.gameobjects.GameObject;

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
