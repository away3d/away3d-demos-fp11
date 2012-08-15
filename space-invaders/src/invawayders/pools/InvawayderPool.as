package invawayders.pools
{
	import invawayders.objects.*;
	
	public class InvawayderPool extends GameObjectPool
	{
		public function InvawayderPool()
		{
			super(null);
		}
		
		public function stop():void
		{
			var invader:Invawayder;
			for each ( invader in _gameObjects)
				if( invader.enabled )
					invader.stopTimers();
		}
		
		public function resume():void
		{
			var invader:Invawayder;
			for each ( invader in _gameObjects)
				if( invader.enabled )
					invader.resumeTimers();
		}
		
		public function getInvaderOfType( id:uint ):Invawayder
		{
			// Adds an unused item or creates a new item if none are found.
			var invader:Invawayder;
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
