package invawayders.objects
{
	import invawayders.pools.*;
	
	import away3d.entities.*;
	
	public class Blast extends GameObject
	{
		private var _mesh:Mesh;
		
		public function Blast( mesh:Mesh )
		{
			super();
			
			_mesh = mesh;
			
			addChild( mesh );
		}
		
		override public function update():void
		{
			super.update();
			
			scaleX = scaleY = scaleZ += 0.15;
			
			if( scaleX >= 5 )
				clear();
			
		}
		
		override public function cloneGameObject():GameObject
		{
			return new Blast( _mesh.clone() as Mesh );
		}
		
		override public function add(parent:GameObjectPool):void 
		{
			super.add(parent);
			
			scaleX = scaleY = scaleZ = 0;
		}
	}
}
