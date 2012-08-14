package invaders.objects
{
	import invaders.pools.*;
	
	import away3d.entities.*;
	
	public class Blast extends GameObject
	{
		public function Blast( mesh:Mesh )
		{
			super();
			
			addChild( mesh );
		}
		
		override public function update():void
		{
			super.update();
			
			scaleX = scaleY = scaleZ += 0.15;
			
			if( scaleX >= 5 )
				removeItem();
			
		}
		
		override public function addItem(parent:GameObjectPool):void 
		{
			super.addItem(parent);
			
			scaleX = scaleY = scaleZ = 0;
		}
	}
}