package com.away3d.invawayders.objects
{
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.entities.Sprite3D;
	import away3d.entities.TextureProjector;
	import com.away3d.invawayders.pools.GameObjectPool;
	import com.away3d.invawayders.pools.InvawayderPool;
	
	
	/**
	 * Game object used for the blast that occurs when an impact is detected.
	 */
	public class Blast extends GameObject
	{
		private var _mesh:Mesh;
		
		/**
		 * Creates a new <code>Blast</code> object.
		 * 
		 * @param mesh The Away3D mesh object used for the blast in the 3D scene.
		 */
		public function Blast( mesh:Mesh )
		{
			super();
			
			_mesh = mesh;
			
			addChild( mesh );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
			
			scaleX = scaleY = scaleZ += 0.15;
			
			if( scaleX >= 5 )
				clear();
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function cloneGameObject():GameObject
		{
			return new Blast( _mesh.clone() as Mesh );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function add(parent:GameObjectPool):void 
		{
			super.add(parent);
			
			scaleX = scaleY = scaleZ = 0;
		}
	}
}
