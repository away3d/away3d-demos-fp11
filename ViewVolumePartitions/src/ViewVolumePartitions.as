package
{
	import away3d.containers.View3D;
	import away3d.core.partition.DynamicGrid;
	import away3d.core.partition.NodeBase;
	import away3d.core.partition.Partition3D;
	import away3d.core.partition.ViewVolume;
	import away3d.core.partition.ViewVolumePartition;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.lights.DirectionalLight;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.OBJParser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.SphereGeometry;
	import away3d.utils.Cast;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;

	[SWF(width="1280", height="768", frameRate="60")]
	public class ViewVolumeTest2 extends Sprite
	{
		private var view : View3D;
		private var light : DirectionalLight;
		private var lightPicker : StaticLightPicker;
		private var controller : FlightController;
		private var dynamicGrid : DynamicGrid;
		private var phase : Number = 0;

		[Embed(source="/assets/northRoom.obj", mimeType="application/octet-stream")]
		private var NorthRoomAsset : Class;

		[Embed(source="/assets/eastRoom.obj", mimeType="application/octet-stream")]
		private var EastRoomAsset : Class;

		[Embed(source="/assets/southRoom.obj", mimeType="application/octet-stream")]
		private var SouthRoomAsset : Class;

		[Embed(source="/assets/westRoom.obj", mimeType="application/octet-stream")]
		private var WestRoomAsset : Class;

		[Embed(source="/assets/northEastCorr.obj", mimeType="application/octet-stream")]
		private var NorthEastCorrAsset : Class;

		[Embed(source="/assets/northWestCorr.obj", mimeType="application/octet-stream")]
		private var NorthWestCorrAsset : Class;

		[Embed(source="/assets/southEastCorr.obj", mimeType="application/octet-stream")]
		private var SouthEastCorrAsset : Class;

		[Embed(source="/assets/southWestCorr.obj", mimeType="application/octet-stream")]
		private var SouthWestCorrAsset : Class;

		[Embed(source="/assets/floor_diffuse.jpg")]
		private var FloorDiffuse : Class;

		[Embed(source="/assets/floor_specular.jpg")]
		private var FloorSpecular : Class;

		[Embed(source="/assets/floor_normal.jpg")]
		private var FloorNormal : Class;

		private var meshCount : int;
		private var viewVolumePartition : ViewVolumePartition;

		private static const ENABLE_VIEW_VOLUMES : Boolean = false;

		public function ViewVolumeTest2()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			initView();
			initLight();
			initScene();
			addChild(new AwayStats(view));
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}

		private function onKeyUp(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.ENTER) {
				if (view.scene.partition == viewVolumePartition)
					view.scene.partition = new Partition3D(new NodeBase());
				else
					view.scene.partition = viewVolumePartition;
			}
		}

		private function initLight() : void
		{
			light = new DirectionalLight(-1, -1, 1);
			light.ambient = 1;
			light.ambientColor = 0x404050;
			view.scene.addChild(light);
			lightPicker = new StaticLightPicker([light]);
		}

		private function onEnterFrame(event : Event) : void
		{
//			sphere.x = Math.cos(phase)*100;
//			sphere.y = Math.cos(phase *.32169)*100;
//			sphere.z = Math.sin(phase)*100;
			view.render();

			phase += .01;
		}

		private function initView() : void
		{
			view = new View3D();
			view.camera.lens.far = 3000;
			view.camera.z = -700;
			controller = new FlightController(view.camera, stage);
			controller.start();
			addChild(view);
		}

		private function initPartition() : void
		{
			viewVolumePartition = new ViewVolumePartition();
			view.scene.partition = viewVolumePartition;
			dynamicGrid = new DynamicGrid(new Vector3D(-2000, -220, -2000), new Vector3D(2000, 220, 2000), 50, 1, 50);
			viewVolumePartition.dynamicGrid = dynamicGrid;

			var northRoomVolume : ViewVolume = new ViewVolume(new Vector3D(-204.627, -204.627, 413.703), new Vector3D(231.318, 220.197, 827.406));
			var southRoomVolume : ViewVolume = new ViewVolume(new Vector3D(-200.179, -204.627, -809.612), new Vector3D(235.766, 220.197, -395.909));
			var eastRoomVolume : ViewVolume = new ViewVolume(new Vector3D(587.191, -204.627, -209.076), new Vector3D(1023.14, 220.197, 204.627));
			var westRoomVolume : ViewVolume = new ViewVolume(new Vector3D(-996.445, -204.627, -217.972), new Vector3D(-560.501, 220.197, 195.73));
			var northEastVolume : ViewVolume = new ViewVolume(new Vector3D(231.318, -61, 204.627), new Vector3D(822.595, 61, 666.082));
			var northWestVolume : ViewVolume = new ViewVolume(new Vector3D(-822.595, -61, 195.73), new Vector3D(-204.627, 61, 666.082));
			var southEastVolume : ViewVolume = new ViewVolume(new Vector3D(235.766, -61, -666.082), new Vector3D(822.595, 61, -209.076));
			var southWestVolume : ViewVolume = new ViewVolume(new Vector3D(-822.595, -61, -666.082), new Vector3D(-200.179, 61, -217.972));

			northRoomVolume.addVisibleViewVolume(northRoomVolume, view.scene, dynamicGrid);
			northRoomVolume.addVisibleViewVolume(northEastVolume, view.scene, dynamicGrid);
			northRoomVolume.addVisibleViewVolume(northWestVolume, view.scene, dynamicGrid);

			southRoomVolume.addVisibleViewVolume(southRoomVolume, view.scene, dynamicGrid);
			southRoomVolume.addVisibleViewVolume(southEastVolume, view.scene, dynamicGrid);
			southRoomVolume.addVisibleViewVolume(southWestVolume, view.scene, dynamicGrid);

			eastRoomVolume.addVisibleViewVolume(eastRoomVolume, view.scene, dynamicGrid);
			eastRoomVolume.addVisibleViewVolume(northEastVolume, view.scene, dynamicGrid);
			eastRoomVolume.addVisibleViewVolume(southEastVolume, view.scene, dynamicGrid);

			westRoomVolume.addVisibleViewVolume(westRoomVolume, view.scene, dynamicGrid);
			westRoomVolume.addVisibleViewVolume(northWestVolume, view.scene, dynamicGrid);
			westRoomVolume.addVisibleViewVolume(southWestVolume, view.scene, dynamicGrid);

			northEastVolume.addVisibleViewVolume(northEastVolume, view.scene, dynamicGrid);
			northEastVolume.addVisibleViewVolume(northRoomVolume, view.scene, dynamicGrid);
			northEastVolume.addVisibleViewVolume(eastRoomVolume, view.scene, dynamicGrid);
			northEastVolume.addVisibleViewVolume(northWestVolume, view.scene, dynamicGrid);
			northEastVolume.addVisibleViewVolume(southEastVolume, view.scene, dynamicGrid);

			northWestVolume.addVisibleViewVolume(northWestVolume, view.scene, dynamicGrid);
			northWestVolume.addVisibleViewVolume(northRoomVolume, view.scene, dynamicGrid);
			northWestVolume.addVisibleViewVolume(westRoomVolume, view.scene, dynamicGrid);
			northWestVolume.addVisibleViewVolume(northEastVolume, view.scene, dynamicGrid);
			northWestVolume.addVisibleViewVolume(southWestVolume, view.scene, dynamicGrid);

			southEastVolume.addVisibleViewVolume(southEastVolume, view.scene, dynamicGrid);
			southEastVolume.addVisibleViewVolume(southRoomVolume, view.scene, dynamicGrid);
			southEastVolume.addVisibleViewVolume(eastRoomVolume, view.scene, dynamicGrid);
			southEastVolume.addVisibleViewVolume(southWestVolume, view.scene, dynamicGrid);
			southEastVolume.addVisibleViewVolume(northEastVolume, view.scene, dynamicGrid);

			southWestVolume.addVisibleViewVolume(southWestVolume, view.scene, dynamicGrid);
			southWestVolume.addVisibleViewVolume(westRoomVolume, view.scene, dynamicGrid);
			southWestVolume.addVisibleViewVolume(southRoomVolume, view.scene, dynamicGrid);
			southWestVolume.addVisibleViewVolume(southEastVolume, view.scene, dynamicGrid);
			southWestVolume.addVisibleViewVolume(northWestVolume, view.scene, dynamicGrid);

			viewVolumePartition.addViewVolume(northRoomVolume);
			viewVolumePartition.addViewVolume(southRoomVolume);
			viewVolumePartition.addViewVolume(eastRoomVolume);
			viewVolumePartition.addViewVolume(westRoomVolume);
			viewVolumePartition.addViewVolume(northEastVolume);
			viewVolumePartition.addViewVolume(northWestVolume);
			viewVolumePartition.addViewVolume(southEastVolume);
			viewVolumePartition.addViewVolume(southWestVolume);

//			viewVolumePartition.showDebugBounds = true;
		}

		public function initScene() : void
		{
			AssetLibrary.addEventListener(AssetEvent.MESH_COMPLETE, onMeshComplete);
			AssetLibrary.enableParser(OBJParser);
			AssetLibrary.loadData(new NorthRoomAsset(), new AssetLoaderContext(false));
			AssetLibrary.loadData(new SouthRoomAsset(), new AssetLoaderContext(false));
			AssetLibrary.loadData(new EastRoomAsset(), new AssetLoaderContext(false));
			AssetLibrary.loadData(new WestRoomAsset(), new AssetLoaderContext(false));
			AssetLibrary.loadData(new NorthEastCorrAsset(), new AssetLoaderContext(false));
			AssetLibrary.loadData(new NorthWestCorrAsset(), new AssetLoaderContext(false));
			AssetLibrary.loadData(new SouthEastCorrAsset(), new AssetLoaderContext(false));
			AssetLibrary.loadData(new SouthWestCorrAsset(), new AssetLoaderContext(false));
		}

		private function onMeshComplete(event : AssetEvent) : void
		{
			var material : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(FloorDiffuse));
			material.normalMap = Cast.bitmapTexture(FloorNormal);
			material.specularMap = Cast.bitmapTexture(FloorSpecular);
			var mesh : Mesh = Mesh(event.asset);
			mesh.static = true;
			mesh.material = material;
			mesh.scale(100);
			mesh.material.lightPicker = lightPicker;
			view.scene.addChild(mesh);

			if (++meshCount == 8) {
				if (ENABLE_VIEW_VOLUMES) initPartition();

				initDynamics();
			}
		}

		private function initDynamics() : void
		{
			var sphereGeom : SphereGeometry = new SphereGeometry(4);
			var material : ColorMaterial = new ColorMaterial(0x505050);
			var radius : Number = 10;
			for (var i : int = 0; i < 7000; ++i) {
				material.lightPicker = lightPicker;
				var mesh : Mesh = new Mesh(sphereGeom, material);
				var side : int = Math.random() * 4;
				var offs : Number = (Math.random() - .5) * 1500;
				switch (side) {
					case 0:
						mesh.x = offs;
						mesh.z = 650 - Math.random() * radius;
						break;
					case 1:
						mesh.x = offs;
						mesh.z = Math.random() * radius - 650;
						break;
					case 2:
						mesh.x = 800 - Math.random() * radius;
						mesh.z = offs;
						break;
					case 3:
						mesh.x = Math.random() * radius - 800;
						mesh.z = offs;
						break;
				}
				mesh.y = Math.random() * radius - 30;
				view.scene.addChild(mesh);
			}
		}
	}
}
