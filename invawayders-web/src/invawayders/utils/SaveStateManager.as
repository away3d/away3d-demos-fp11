package invawayders.utils
{
	import flash.net.*;
	
	public class SaveStateManager
	{
		private const INVAWAYDERS_SO_NAME:String = "invawaydersUserData";
		
		public function saveHighScore( highScore:uint ):void
		{
			var sharedObject:SharedObject = SharedObject.getLocal( INVAWAYDERS_SO_NAME );
			sharedObject.data.highScore = highScore;
			sharedObject.flush();
		}

		public function loadHighScore():uint
		{
			var sharedObject:SharedObject = SharedObject.getLocal( INVAWAYDERS_SO_NAME );
			return sharedObject.data.highScore;
		}
	}
}
