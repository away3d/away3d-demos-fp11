package com.derschmale.away3d.multipass.boot
{
	import away3d.core.math.Plane3D;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.TextureMultiPassMaterial;
//	import away3d.materials.methods.FresnelPlanarReflectionMethod;
	import away3d.textures.PlanarReflectionTexture;
	import away3d.textures.SpecularBitmapTexture;
	import away3d.utils.Cast;

	import com.derschmale.away3d.multipass.data.BitmapLib;
	import com.derschmale.patterns.tasks.Task;

	import flash.utils.Dictionary;

	public class ReplaceMaterialsTask extends Task
	{
		private var _parseTask:ParseSponzaTask;
		private var _normalMaps:Array;
		private var _specularMaps:Array;
		private var _materials : Dictionary = new Dictionary();
		private var _transparents : Array = [
			"sponza_00",
			"sponza_275", "sponza_276", "sponza_277", "sponza_278", "sponza_279", "sponza_280", "sponza_281",
			"sponza_01",
			"sponza_366", "sponza_367", "sponza_368", "sponza_369", "sponza_370", "sponza_371", "sponza_372",
			"sponza_330", "sponza_331", "sponza_332", "sponza_333", "sponza_339", "sponza_340", "sponza_341", "sponza_342",
			"sponza_348", "sponza_349", "sponza_350", "sponza_351",
			"sponza_357", "sponza_358", "sponza_358", "sponza_359", "sponza_360"
		];
		private var _planarReflectionTexture:PlanarReflectionTexture;

		public function ReplaceMaterialsTask(parseTask : ParseSponzaTask)
		{
			_parseTask = parseTask;
		}

		public function get planarReflectionTexture():PlanarReflectionTexture
		{
			return _planarReflectionTexture;
		}

		public function get materials():Dictionary
		{
			return _materials;
		}

		override public function execute():void
		{
			initReflection();
			initTextures();
			replace();
			dispose();
			notifyComplete();
		}

		private function initReflection():void
		{
			_planarReflectionTexture = new PlanarReflectionTexture();
			_planarReflectionTexture.plane = new Plane3D(0, 1, 0);
			_planarReflectionTexture.scale = .25;
		}

		private function initTextures() : void
		{
			_normalMaps = [];
			_specularMaps = [];
			addTextureSet("textures/thorn_diff.png", BitmapLib.thorn_ddn);
			addTextureSet("textures/vase_round.jpg", BitmapLib.vase_round_ddn, BitmapLib.vase_round_spec);
			addTextureSet("textures/background.jpg", BitmapLib.background_ddn);
			addTextureSet("textures/bricks_a_diff.jpg", BitmapLib.bricks_a_ddn, BitmapLib.bricks_a_spec);
			addTextureSet("textures/ceiling_a_diff.jpg", null, BitmapLib.ceiling_a_spec);
			addTextureSet("textures/column_a_diff.jpg", BitmapLib.column_a_ddn, BitmapLib.column_a_spec);
			addTextureSet("textures/curtain_diff.jpg", null, BitmapLib.curtain_spec);
			addTextureSet("textures/curtain_blue_diff.jpg", null, BitmapLib.curtain_spec);
			addTextureSet("textures/curtain_green_diff.jpg", null, BitmapLib.curtain_spec);
			addTextureSet("textures/floor_a_diff.jpg", null, BitmapLib.floor_a_spec);
			addTextureSet("textures/column_c_diff.jpg", BitmapLib.column_c_ddn, BitmapLib.column_c_spec);
			addTextureSet("textures/details_diff.jpg", null, BitmapLib.details_spec);
			addTextureSet("textures/column_b_diff.jpg", BitmapLib.column_b_ddn, BitmapLib.column_b_spec);
			addTextureSet("textures/flagpole_diff.jpg", null, BitmapLib.flagpole_spec);
			addTextureSet("textures/fabric_green_diff.jpg", null, BitmapLib.fabric_spec);
			addTextureSet("textures/fabric_blue_diff.jpg", null, BitmapLib.fabric_spec);
			addTextureSet("textures/fabric_diff.jpg", null, BitmapLib.fabric_spec);
			addTextureSet("textures/chain_texture.png", BitmapLib.chain_texture_ddn);
			addTextureSet("textures/vase_dif.jpg", BitmapLib.vase_ddn);
			addTextureSet("textures/lion.jpg", BitmapLib.lion2_ddn);
		}

		private function addTextureSet(name : String, normalMap : Class, specularMap : Class = null) : void
		{
			_normalMaps[name] = normalMap? Cast.bitmapTexture(normalMap) : null;
			_specularMaps[name] = specularMap? new SpecularBitmapTexture(new specularMap().bitmapData) : null;
		}

		private function replace() : void
		{
			var original : TextureMaterial;
			for each(var mesh : Mesh in _parseTask.meshes) {
				original = mesh.material as TextureMaterial;
				if (!original || mesh.name == "sponza_04") continue;

				mesh.material = getOrCreateMultipass(original);
			}
		}

		private function getOrCreateMultipass(original:TextureMaterial):MaterialBase
		{
			if (_materials[original.texture]) return _materials[original.texture];
			var multipass : TextureMultiPassMaterial = _materials[original.texture] = new TextureMultiPassMaterial(original.texture);

			if (_transparents.indexOf(original.name) != -1)
				multipass.alphaThreshold = .5;

			multipass.mipmap = true;
			multipass.repeat = true;
			multipass.specular = 2;
			applyTextures(multipass.texture.name, multipass);

			/*if (multipass.texture.name == "textures/floor_a_diff.jpg") {
				//add reflection
				var fresnel : FresnelPlanarReflectionMethod = new FresnelPlanarReflectionMethod(_planarReflectionTexture, .6);
				multipass.addMethod(fresnel);
				fresnel.fresnelPower = 2;
				fresnel.normalReflectance = .35;
			}   */

			return multipass;
		}

		private function applyTextures(id : String, multipass : TextureMultiPassMaterial) : void
		{
			if (_normalMaps[id]) multipass.normalMap = _normalMaps[id];
			if (_specularMaps[id]) multipass.specularMap = _specularMaps[id];
		}

		private function dispose():void
		{
			_normalMaps = null;
			_specularMaps = null;
			_transparents = null;
		}
	}
}
