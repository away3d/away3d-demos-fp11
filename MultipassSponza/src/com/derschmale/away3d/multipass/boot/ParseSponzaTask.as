package com.derschmale.away3d.multipass.boot
{
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.library.AssetLibrary;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.OBJParser;
	import away3d.materials.MaterialBase;

	import com.derschmale.patterns.tasks.Task;

	public class ParseSponzaTask extends Task
	{
		[Embed(source="/../embeds/meshes/sponza.obj", mimeType="application/octet-stream")]
		private var SponzaObj:Class;

		[Embed(source="/../embeds/meshes/sponza.mtl", mimeType="application/octet-stream")]
		private var SponzaMtl:Class;

		private var _materials:Array;
		private var _meshes:Array;
		private const _totalAssets:int = 383;	// I know this
		private var _assetsCompleted:int;

		public function ParseSponzaTask()
		{
		}

		public function get materials():Array
		{
			return _materials;
		}

		public function get meshes():Array
		{
			return _meshes;
		}

		override public function execute():void
		{
			initContainers();
			initListeners();
			AssetLibrary.loadData(new SponzaObj(), createLoaderContext(), null, new OBJParser());
		}

		private function initContainers():void
		{
			_materials = [];
			_meshes = [];
		}

		private function createLoaderContext():AssetLoaderContext
		{
			var context:AssetLoaderContext = new AssetLoaderContext();
			context.mapUrlToData("sponza.mtl", new SponzaMtl());
			return context;
		}

		private function initListeners():void
		{
			AssetLibrary.addEventListener(AssetEvent.MESH_COMPLETE, onMeshComplete);
			AssetLibrary.addEventListener(AssetEvent.MATERIAL_COMPLETE, onMaterialComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}

		private function onLoadError(event:LoaderEvent):void
		{
			trace(event.message);
		}

		private function onMaterialComplete(event:AssetEvent):void
		{
			var material:MaterialBase = MaterialBase(event.asset);
			_materials[material.name] = material;
			notifyAssetAdded();
		}

		private function onMeshComplete(event:AssetEvent):void
		{
			var mesh:Mesh = Mesh(event.asset);
			if (mesh.name != "sponza_04")	// do not include GI flag
				_meshes[mesh.name] = mesh;
			notifyAssetAdded()
		}

		private function notifyAssetAdded():void
		{
			++_assetsCompleted;
			updateCompletion(_assetsCompleted, _totalAssets);
		}

		private function onResourceComplete(event:LoaderEvent):void
		{
			removeListeners();
			notifyComplete();
		}

		private function removeListeners():void
		{
			AssetLibrary.removeEventListener(AssetEvent.MESH_COMPLETE, onMeshComplete);
			AssetLibrary.removeEventListener(AssetEvent.MATERIAL_COMPLETE, onMaterialComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}
	}
}
