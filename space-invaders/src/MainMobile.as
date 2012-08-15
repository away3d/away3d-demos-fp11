package
{
	import invawayders.utils.MobileSaveStateManager;
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
