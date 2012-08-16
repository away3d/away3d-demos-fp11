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
			//initialise the save state manager
			_saveStateManager = new MobileSaveStateManager();
			
			init();
		}
	}
}
