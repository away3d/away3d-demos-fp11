package com.derschmale.away3d.multipass.commands
{
	import away3d.cameras.Camera3D;

	import com.derschmale.away3d.multipass.controller.FlightController;

	import com.derschmale.patterns.commands.Command;

	import flash.display.Stage;

	public class UpdateCameraCommand implements Command
	{
		private var _controller:FlightController;

		public function UpdateCameraCommand(camera : Camera3D, stage : Stage)
		{
			_controller = new FlightController(camera, stage);
			_controller.start();
		}

		public function execute():void
		{
			_controller.update();
		}
	}
}
