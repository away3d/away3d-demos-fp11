package com.derschmale.away3d.multipass.commands
{
	import away3d.materials.TextureMultiPassMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.CascadeShadowMapMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.SimpleShadowMapMethodBase;

	import com.derschmale.away3d.multipass.SceneBuilder;

	import com.derschmale.patterns.commands.Command;

	import flash.utils.Dictionary;

	public class InitMaterialsCommand implements Command
	{
		private var _materials : Dictionary;
		private var _sceneBuilder : SceneBuilder;
		private var _cascadeMethod:CascadeShadowMapMethod;

		public function InitMaterialsCommand()
		{
		}

		public function get cascadeMethod():CascadeShadowMapMethod
		{
			return _cascadeMethod;
		}

		public function get materials():Dictionary
		{
			return _materials;
		}

		public function set materials(value:Dictionary):void
		{
			_materials = value;
		}

		public function get sceneBuilder():SceneBuilder
		{
			return _sceneBuilder;
		}

		public function set sceneBuilder(value:SceneBuilder):void
		{
			_sceneBuilder = value;
		}

		public function execute() : void
		{
			var lightPicker : StaticLightPicker = new StaticLightPicker(_sceneBuilder.lights);
			var baseShadowMethod : SimpleShadowMapMethodBase = new FilteredShadowMapMethod(_sceneBuilder.directionalLight);
			var fogMethod : FogMethod = new FogMethod(0, 4000, 0x9090e7);
			_cascadeMethod = new CascadeShadowMapMethod(baseShadowMethod);

			for each (var material : TextureMultiPassMaterial in _materials) {
				material.lightPicker = lightPicker;
				material.shadowMethod = cascadeMethod;
				material.addMethod(fogMethod);
			}
		}
	}
}
