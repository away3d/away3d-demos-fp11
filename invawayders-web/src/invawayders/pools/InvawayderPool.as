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
			var invawayder:Invawayder;
			for each ( invawayder in _gameObjects)
				if( invawayder.enabled )
					invawayder.stopTimers();
		}
		
		public function resume():void
		{
			var invawayder:Invawayder;
			for each ( invawayder in _gameObjects)
				if( invawayder.enabled )
					invawayder.resumeTimers();
		}
		
		public function getInvawayderOfType( id:uint ):Invawayder
		{
			// Adds an unused item or creates a new item if none are found.
			var invawayder:Invawayder;
			for each ( invawayder in _gameObjects) {
				if( !invawayder.enabled && invawayder.invawayderData.id == id ) {
					invawayder.addItem(this);
					return invawayder;
				}
			}
			
			return null;
		}
	}
}
