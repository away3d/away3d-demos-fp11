package com.derschmale.away3d.multipass.boot
{
	import away3d.textures.PlanarReflectionTexture;

	import com.derschmale.patterns.tasks.MacroTask;

	import flash.utils.Dictionary;

	public class Bootstrap extends MacroTask
	{
		private var _parseSponza:ParseSponzaTask;
		private var _replaceMaterials:ReplaceMaterialsTask;

		public function Bootstrap()
		{
			super();
			addTask(_parseSponza = new ParseSponzaTask());
			addTask(_replaceMaterials = new ReplaceMaterialsTask(_parseSponza));
		}

		public function get planarReflectionTexture():PlanarReflectionTexture
		{
			return _replaceMaterials.planarReflectionTexture;
		}

		public function get loadedMeshes():Array
		{
			return _parseSponza.meshes;
		}

		public function get materials():Dictionary
		{
			return _replaceMaterials.materials;
		}
	}
}
