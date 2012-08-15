package invawayders.pools
{
	import invawayders.objects.*;
	
	public class InvaderPool extends GameObjectPool
	{
		public function InvaderPool()
		{
			super(null);
		}
		
		public function stop():void
		{
			var invader:Invader;
			for each ( invader in _gameObjects)
				if( invader.enabled )
					invader.stopTimers();
		}
		
		public function resume():void
		{
			var invader:Invader;
			for each ( invader in _gameObjects)
				if( invader.enabled )
					invader.resumeTimers();
		}
		
		public function getInvaderOfType( id:uint ):Invader
		{
			// Adds an unused item or creates a new item if none are found.
			var invader:Invader;
			for each ( invader in _gameObjects) {
				if( !invader.enabled && invader.invaderData.id == id ) {
					invader.addItem(this);
					return invader;
				}
			}
			
			return null;
		}
	}
}
