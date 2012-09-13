package invawayders.objects
{
	import invawayders.events.*;
	import invawayders.pools.*;
	
	import away3d.containers.*;
	import away3d.errors.*;
	
	import flash.geom.*;
	
	public class GameObject extends ObjectContainer3D
	{
		public var velocity:Vector3D = new Vector3D();
		
		public var rotationalVelocity:Vector3D = new Vector3D();
		
		public var active:Boolean;
		
		public function GameObject()
		{
			super();
		}
		
		public function update():void
		{
			// Move.
			x += velocity.x;
			y += velocity.y;
			z += velocity.z;
			
			// Rotate.
			rotationX += rotationalVelocity.x;
			rotationY += rotationalVelocity.y;
			rotationZ += rotationalVelocity.z;
		}
		
		public function cloneGameObject():GameObject
		{
			throw new AbstractMethodError();
		}
		
		public function impact( trigger:GameObject ):void 
		{
			dispatchEvent( new GameObjectEvent( GameObjectEvent.GAME_OBJECT_HIT, this, trigger ) );
		}
		
		public function add(parent:GameObjectPool):void
		{
			active = true;
			
			dispatchEvent( new GameObjectEvent( GameObjectEvent.GAME_OBJECT_ADD, this ) );
			
			transform = new Matrix3D();
			velocity = new Vector3D();
			rotationalVelocity = new Vector3D();
			
			parent.addChild(this);
		}
		
		public function clear():void
		{
			active = false;
			
			if (parent)
				parent.removeChild(this);
		}
	}
}