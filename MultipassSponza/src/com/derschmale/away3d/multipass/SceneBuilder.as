package com.derschmale.away3d.multipass
{
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.lights.shadowmaps.CascadeShadowMapper;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import away3d.utils.Cast;

	import com.derschmale.away3d.multipass.data.BitmapLib;

	import flash.display.BlendMode;

	public class SceneBuilder
	{
		private var _view:View3D;
		private var _directionalLight:DirectionalLight;
		private var _lights:Array;
		private var _flameMaterial:TextureMaterial;
		private var _flameGeometry:PlaneGeometry;
		private var _flameMeshes:Vector.<Mesh>;
		private var _flameLights:Vector.<PointLight>;

		public function SceneBuilder()
		{
		}

		public function get flameMeshes():Vector.<Mesh>
		{
			return _flameMeshes;
		}

		public function get flameLights():Vector.<PointLight>
		{
			return _flameLights;
		}

		public function get lights():Array
		{
			return _lights;
		}

		public function get view():View3D
		{
			return _view;
		}

		public function get directionalLight():DirectionalLight
		{
			return _directionalLight;
		}

		public function create(meshes : Array) : View3D
		{
			_view = new View3D();
//			_view.depthPrepass = true;
			_lights = new Array();
			_flameMeshes = new Vector.<Mesh>();
			_flameLights = new Vector.<PointLight>();

			initCamera();
			initSkyBox();
			initOverheadLight();
			initFlames();
			addMeshes(meshes);

			return _view;
		}

		private function initOverheadLight():void
		{
			var shadowMapper : CascadeShadowMapper = new CascadeShadowMapper(3);
			shadowMapper.lightOffset = 10000;
			_directionalLight = new DirectionalLight(-1, -15, 1);
			_directionalLight.shadowMapper = shadowMapper;
			_directionalLight.castsShadows = true;
			_directionalLight.color = 0xeedddd;
			_directionalLight.ambient = .35;
			_directionalLight.ambientColor = 0x808090;
			_view.scene.addChild(_directionalLight);
			_lights.push(_directionalLight);
		}

		private function initCamera():void
		{
			_view.camera.y = 150;
			_view.camera.z = 0;
		}

		private function initSkyBox():void
		{
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(
					Cast.bitmapData(BitmapLib.SkyBoxMaxX), Cast.bitmapData(BitmapLib.SkyBoxMinX),
					Cast.bitmapData(BitmapLib.SkyBoxMaxY), Cast.bitmapData(BitmapLib.SkyBoxMinY),
					Cast.bitmapData(BitmapLib.SkyBoxMaxZ), Cast.bitmapData(BitmapLib.SkyBoxMinZ)
			);

			_view.scene.addChild(new SkyBox(cubeTexture));
		}

		public function addMeshes(meshes : Array) : void
		{
			var scene : Scene3D = _view.scene;

			for each(var mesh : Mesh in meshes) {
//				mesh.showBounds = true;
				mesh.ignoreTransform = true;
				scene.addChild(mesh);
			}
		}

		private function initFlames():void
		{
			_flameMaterial = new TextureMaterial(Cast.bitmapTexture(BitmapLib.Flame));
			_flameMaterial.blendMode = BlendMode.ADD;
			_flameMaterial.animateUVs = true;
			_flameGeometry = new PlaneGeometry(40, 80, 1, 1, false, true);

			addFlame(-625, 165, 219, 0xffaa44);
			addFlame(485, 165, 219, 0xffaa44);
			addFlame(-625, 165, -148, 0xffaa44);
			addFlame(485, 165, -148, 0xffaa44);
		}

		private function addFlame(x : Number, y : Number, z : Number, color : uint) : void
		{
			var pointLight : PointLight = new PointLight();
			pointLight.radius = 200;
			pointLight.fallOff = 600;
			pointLight.color = color;
			pointLight.y = 10;
			_flameLights.push(pointLight);
			_lights.push(pointLight);

			var flame : Mesh = new Mesh(_flameGeometry, _flameMaterial);
			flame.x = x;
			flame.y = y;
			flame.z = z;
			flame.subMeshes[0].scaleU = 1/16;
			_flameMeshes.push(flame);
			_view.scene.addChild(flame);
			flame.addChild(pointLight);
		}
	}
}
