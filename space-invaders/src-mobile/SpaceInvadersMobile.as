package
{

	import com.away3d.spaceinvaders.GameVariables;
	import com.away3d.spaceinvaders.Main;
	import com.away3d.spaceinvaders.input.AccelerometerInput;
	import com.away3d.spaceinvaders.input.TouchInput;
	import com.away3d.spaceinvaders.save.MobileStateSaveManager;
	import com.away3d.spaceinvaders.utils.ScoreManager;

	public class SpaceInvadersMobile extends Main
	{
		public function SpaceInvadersMobile() {
			super();
		}

		override protected function initStageDims():void {
			GameVariables.windowWidth = stage.fullScreenWidth;
			GameVariables.windowHeight = stage.fullScreenHeight;
		}

		override protected function initInput():void {
			_input = GameVariables.useAccelerometer ? new AccelerometerInput( _scene ) : new TouchInput( _scene );
			addChild( _input );
		}

		override protected function initConsistency():void {
			ScoreManager.instance.saveManager = new MobileStateSaveManager();
		}
	}
}
