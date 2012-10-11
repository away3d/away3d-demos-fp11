package com.derschmale.away3d.multipass.commands
{
	import away3d.containers.View3D;
	import away3d.textures.PlanarReflectionTexture;

	import com.derschmale.patterns.commands.Command;

	public class RenderReflectionCommand implements Command
	{
		private var _view:View3D;
		private var _texture:PlanarReflectionTexture;

		public function RenderReflectionCommand(texture : PlanarReflectionTexture, view:View3D)
		{
			_view = view;
			_texture = texture;
		}

		public function execute():void
		{
			_texture.render(_view);
		}
	}
}
