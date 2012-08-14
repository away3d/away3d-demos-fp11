package invaders.pools
{
	import invaders.objects.*;
	
	import away3d.entities.*;
	
	public class StarPool extends GameObjectPool
	{
		private var _starMesh:Mesh;
		
		public function StarPool( mesh:Mesh )
		{
			super();
			_starMesh = mesh;
		}
		
		override public function update():void
		{
			if( Math.random() > GameSettings.starSpawnProbability && numChildren < GameSettings.maxStarNum )
			{
				var len:uint = Math.floor( 1 + 4 * Math.random() );
				for( var i:uint; i < len; ++i ) {
					getGameObject();
				}
			}
			super.update();
		}
		
		override protected function createItem():GameObject
		{
			return new Star( _starMesh.clone() as Mesh );
		}
	}
}
