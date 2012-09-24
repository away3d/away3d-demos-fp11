package
{
	import invawayders.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class MainMobile extends Main
	{
		
		/**
		 * Constructor
		 */
		public function MainMobile()
		{
			super();
		}
		
		/**
		 * Initialise the save state of the game
		 */		
		override protected function initSaveState():void
		{
			//initialise the save state manager
			_saveStateManager = new MobileSaveStateManager();
		}
	}
}
