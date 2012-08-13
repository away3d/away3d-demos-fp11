package invaders.save
{

	import flash.net.SharedObject;

	public class StateSaveManager
	{
		private const SO_NAME:String = "away3dSpaceInvadersUserData";

		public function StateSaveManager() {
		}

		public function saveHighScore( score:uint ):void {
			var sharedObject:SharedObject = SharedObject.getLocal( SO_NAME );
			sharedObject.data.highScore = score;
			sharedObject.flush();
		}

		public function loadHighScore():uint {
			var sharedObject:SharedObject = SharedObject.getLocal( SO_NAME );
			if( sharedObject ) {
				var score:uint = sharedObject.data.highScore;
				if( score ) {
					return score;
				}
			}
			return 0;
		}
	}
}
