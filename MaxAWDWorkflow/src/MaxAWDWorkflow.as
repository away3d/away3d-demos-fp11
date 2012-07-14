package
{
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.SphereGeometry;
	import flash.display.Sprite;
	import flash.events.Event;
	[SWF(backgroundColor="#000000", frameRate="60", width="1024", height="768")]
	public class MaxAWDWorkflow extends Sprite
	{
		private var view:View3D;
		public function MaxAWDWorkflow()
		{
			view = new View3D();
			addChild(view);
			var sphereGeometry:SphereGeometry = new SphereGeometry(350);
			var sphereMaterial:ColorMaterial = new ColorMaterial( 0xff0000 );
			var mesh:Mesh = new Mesh(sphereGeometry, sphereMaterial);
			view.scene.addChild(mesh);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		private function onEnterFrame(event:Event):void
		{
			view.render();
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}