package invaders.objects
{
	import invaders.pools.*;
	import invaders.utils.*;
	
	import away3d.entities.*;
	
	public class Star extends GameObject
	{
		public function Star( entity:Entity )
		{
			super();
			addChild( entity );
		}
		
		override public function addItem(parent:GameObjectPool):void
		{
			super.addItem(parent);
			var angle:Number = MathUtils.rand( 0, 2 * Math.PI );
			var radius:Number = 2000 + 5000 * Math.random();
			x = radius * Math.cos( angle );
			y = radius * Math.sin( angle );
			z = 5000;
			velocity.z = -100;
		}
	}
}
