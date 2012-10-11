package com.derschmale.away3d.multipass.commands
{
	import away3d.containers.View3D;

	import com.derschmale.patterns.commands.Command;

	public class RenderViewCommand implements Command
	{
		private var _view:View3D;

		public function RenderViewCommand(view:View3D)
		{
			_view = view;
		}

		public function execute():void
		{
			_view.render();
		}
	}
}
