/*

   AVATAR WAR

   Demonstrates:

   How to use the Loader3D object to load an embedded internal awd model.
   How to limite size of AWD animation export by using away3d clone.
   How to set custom material by using mesh name

   Code, model and map by LoTh
   3dflashlo@gmail.com
   http://3dflashlo.wordpress.com

   This code is distributed under the MIT License

   Copyright (c)

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the “Software”), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.

 */
package {
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.textures.CubeReflectionTexture;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.materials.TextureMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.library.assets.AssetType;
	import away3d.primitives.CubeGeometry;
	import away3d.lights.DirectionalLight;
	import away3d.events.LoaderEvent;
	import away3d.containers.View3D;
	import away3d.events.AssetEvent;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.StageQuality;
	import flash.display.StageDisplayState;
	import flash.filters.DropShadowFilter;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.events.MouseEvent;
	import flash.text.GridFitType;
	import flash.text.TextFormat;
	import flash.system.System;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.ui.Keyboard;

	import utils.AutoMapSky;
	import utils.LoaderPool;

	import games.CarMove;
	import games.FractalTerrain;

	import com.bit101.components.Style;
	import com.bit101.components.PushButton;

	[SWF(backgroundColor="#000000", frameRate="60")]
	public class Demo_Vision_Car extends Sprite {
		private const MOUNTAIGN_TOP : Number = 600;
		private const FARVIEW : Number = 30000;
		private const FOGNEAR : Number = 0;
		private var groundColor : uint = 0x333338;
		private var sunColor : uint = 0xAAAAA9;
		private var fogColor : uint = 0x333338;
		private var skyColor : uint = 0x445465;
		private var _bitmapStrings : Vector.<String>;
		private var _bitmaps : Vector.<BitmapData>;
		// Stage manager and Stage3D instance proxy classes
		private var _stage3DManager : Stage3DManager;
		private var _stage3DProxy : Stage3DProxy;
		// engine variables
		private var _view : View3D;
		private var _stats : AwayStats;
		private var _lightPicker : StaticLightPicker;
		private var _cameraController : HoverController;
		// light variables
		private var _sunLight : DirectionalLight;
		private var _reflectionTexture : CubeReflectionTexture;
		private var _reflectionMethod : EnvMapMethod;
		private var _fresnelMethod : FresnelEnvMapMethod;
		private var _fresnelMethod2 : FresnelEnvMapMethod;
		private var _fresnelMethod3 : FresnelSpecularMethod;
		private var _fogMethode : FogMethod;
		private var _shadowMethod : NearShadowMapMethod;
		private var _waterMethod : SimpleWaterNormalMethod;
		// Materials
		private var _materials : Vector.<TextureMaterial>;
		private var _terrainMaterial : TextureMaterial;
		private var _waterMaterial : TextureMaterial;
		private var _carIntern : TextureMaterial;
		private var _carIntern2 : TextureMaterial;
		private var _carWhiteMat : TextureMaterial;
		private var _carBlackMat : TextureMaterial;
		private var _carLightMat1 : TextureMaterial;
		private var _carLightMat2 : TextureMaterial;
		private var _carLightMat3 : TextureMaterial;
		private var _carCromeMat : TextureMaterial;
		private var _carWheelMat : TextureMaterial;
		private var _carBlackDoubleMat : TextureMaterial;
		private var _carGlassMat : TextureMaterial;
		// scene objects
		private var _ground : Mesh;
		private var _vision : Vector.<Mesh>;
		private var _visionCar : Mesh;
		// car parts
		private var _wheel : Mesh;
		private var _wheels : Vector.<Mesh>;
		private var _door : Mesh;
		private var _driveWheel : Mesh;
		private var _doors : Vector.<Mesh>;
		private var _sit : Mesh;
		private var _sits : Vector.<Mesh>;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		private var _cameraHeight : Number = 80;
		private var _night : Number = 100;
		private var _isIntro : Boolean = true;
		private var _isReflection : Boolean;
		private var _cloneActif : Boolean;
		private var _isRender : Boolean;
		private var _text : TextField;
		private var _capture : BitmapData;
		private var _topPause : Sprite;
		private var _menu : Sprite;

		/**
		 * Constructor
		 */
		public function Demo_Vision_Car() {
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}

		/**
		 * Work around IE flash embedding issues
		 */
		private function init(e : Event) : void {
			if (e != null) removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			System.pauseForGCIfCollectionImminent(1);
			if ((stage.stageWidth != 0) && (stage.stageHeight != 0)) initProxies();
			else stage.addEventListener(Event.RESIZE, onResizeTesting);
		}

		/**
		 * Testing if stage height != 0
		 */
		private function onResizeTesting(e : Event) : void {
			if ((stage.stageWidth != 0) && (stage.stageHeight != 0)) {
				stage.removeEventListener(Event.RESIZE, onResizeTesting);
				initProxies();
			}
		}

		/**
		 * Initialise the Stage3D proxies
		 */
		private function initProxies() : void {
			// Define a new Stage3DManager for the Stage3D objects
			_stage3DManager = Stage3DManager.getInstance(stage);

			// Create a new Stage3D proxy for the first Stage3D scene
			_stage3DProxy = _stage3DManager.getFreeStage3DProxy();
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, initFinal);
			_stage3DProxy.color = 0x000000;
		}

		/**
		 * Global initialise function
		 */
		private function initFinal(e : Stage3DEvent = null) : void {
			initEngine();
			initText();
			initSetting();
			initLights();

			// random sky map
			var skyN : uint = uint(1 + Math.random() * 6);

			// kickoff asset loading
			_bitmapStrings = new Vector.<String>();
			_bitmapStrings.push("sky" + skyN + "/negy.jpg", "sky" + skyN + "/posy.jpg", "sky" + skyN + "/posx.jpg", "sky" + skyN + "/negz.jpg", "sky" + skyN + "/posz.jpg", "sky" + skyN + "/negx.jpg");
			_bitmapStrings.push("rock.jpg", "sand.jpg", "arid.jpg");
			_bitmapStrings.push("water_normals.jpg");
			LoaderPool.log = log;
			LoaderPool.loadBitmaps(_bitmapStrings, initAfterBitmapLoad);
			_bitmaps = LoaderPool.bitmaps;
		}

		/**
		 * Initialise the scene object
		 */
		private function initAfterBitmapLoad() : void {
			// Init material and objects
			initMaterials();

			// create skybox
			randomSky();

			// reflection method
			_reflectionMethod = new EnvMapMethod(AutoMapSky.skyMap, 0.8);
			_waterMaterial.addMethod(_reflectionMethod);

			// create noize terrain with image 6 7 8
			FractalTerrain.initGround(_view.scene, _bitmaps, _terrainMaterial, FARVIEW * 2, MOUNTAIGN_TOP);

			// basic ground
			_ground = new Mesh(new PlaneGeometry(FARVIEW * 2, FARVIEW * 2), _waterMaterial);
			_ground.geometry.scaleUV(60, 60);
			_ground.castsShadows = false;
			_view.scene.addChild(_ground);
			_ground.y = 300;
			// Now load High res Vision car
			_vision = new Vector.<Mesh>();

			// load vision car model
			LoaderPool.loadObject("vision/vision.awd", onAssetComplete, onResourceComplete);
		}

		/**
		 * Initialise the engine
		 */
		private function initEngine() : void {
			// create the view
			_view = new View3D();
			_view.stage3DProxy = _stage3DProxy;
			_view.shareContext = true;
			addChild(_view);

			// create custom lens
			_view.camera.lens = new PerspectiveLens(60);
			_view.camera.lens.far = FARVIEW;
			_view.camera.lens.near = 1;

			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 120, 0, 600, 10, 9);
			_cameraController.tiltAngle = 0;
			_cameraController.panAngle = 180;
			_cameraController.minTiltAngle = -60;
			_cameraController.maxTiltAngle = 60;
			_cameraController.distance = 600;
			_cameraController.autoUpdate = false;

			// add stats
			addChild(_stats = new AwayStats(_view, false, true));
			_stats.x = stage.stageWidth - _stats.width - 5;
			_stats.alpha = 0.5;
			_stats.y = 2;
		}

		/**
		 * Initialise the lights
		 */
		private function initLights() : void {
			_sunLight = new DirectionalLight(-0.5, -1, 0.3);
			_sunLight.color = sunColor;
			_sunLight.ambientColor = sunColor;
			_sunLight.ambient = 0;
			_sunLight.diffuse = 0;
			_sunLight.specular = 0;

			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.1);
			_view.scene.addChild(_sunLight);

			_lightPicker = new StaticLightPicker([_sunLight]);

			stage.addEventListener(Event.RESIZE, onResize);
		}

		/**
		 * Create random sky 
		 */
		private function randomSky() : void {
			AutoMapSky.scene = _view.scene;
			if (_isIntro) AutoMapSky.randomSky([skyColor, fogColor, groundColor], _bitmaps, 8);
			else AutoMapSky.randomSky(null, _bitmaps, 8);
			_fogMethode.fogColor = AutoMapSky.fogColor;
		}

		/**
		 * Initialise scene materials
		 */
		private function initMaterials() : void {
			_materials = new Vector.<TextureMaterial>();

			// create global shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0007;

			// create global fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW, fogColor);

			// water method
			_waterMethod = new SimpleWaterNormalMethod(Cast.bitmapTexture(_bitmaps[9]), Cast.bitmapTexture(_bitmaps[9]));
			// fresnelMethod
			_fresnelMethod3 = new FresnelSpecularMethod();
			_fresnelMethod3.normalReflectance = 0.4;

			// 0 - terrain material
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, false, 0x00)));
			_terrainMaterial.gloss = 10;
			_terrainMaterial.specular = 0.2;
			_materials[0] = _terrainMaterial;
			// 1 - car material
			_carWhiteMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x090702)));
			_carWhiteMat.gloss = 100;
			_carWhiteMat.specular = 0.9;
			_materials[1] = _carWhiteMat;
			// 2 - car material black
			_carBlackMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x090702)));
			_carBlackMat.gloss = 10;
			_carBlackMat.specular = 0.3;
			_materials[2] = _carBlackMat;
			// 3 - car light material
			_carLightMat1 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0xEEFFFFFF)));
			_carLightMat1.alphaBlending = true;
			_carLightMat1.gloss = 10;
			_carLightMat1.specular = 0.9;
			_materials[3] = _carLightMat1;
			// 4 - car light back material
			_carLightMat2 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0xEEFF1010)));
			_carLightMat2.alphaBlending = true;
			_carLightMat2.gloss = 10;
			_carLightMat2.specular = 0.9;
			_materials[4] = _carLightMat2;
			// 5 - car light front material
			_carLightMat3 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x60FFFFFF)));
			_carLightMat3.alphaBlending = true;
			_carLightMat3.gloss = 10;
			_carLightMat3.specular = 0.9;
			_materials[5] = _carLightMat3;
			// 6 - tire wheels material
			_carWheelMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x080912)));
			_carWheelMat.gloss = 100;
			_carWheelMat.specular = 0.5;
			_carWheelMat.bothSides = true;
			_materials[6] = _carWheelMat;
			// 7 - double side black car
			_carBlackDoubleMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x090702)));
			_carBlackDoubleMat.gloss = 10;
			_carBlackDoubleMat.specular = 0.3;
			_carBlackDoubleMat.bothSides = true;
			_materials[7] = _carBlackDoubleMat;
			// 8 - chrome
			_carCromeMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x404040)));
			_carCromeMat.gloss = 10;
			_carCromeMat.specular = 0.9;
			_carCromeMat.bothSides = true;
			_materials[8] = _carCromeMat;
			// 9 - car windows
			_carGlassMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x99010101)));
			_carGlassMat.gloss = 60;
			_carGlassMat.specular = 1;
			_carGlassMat.alphaBlending = true;
			_carGlassMat.bothSides = true;
			_materials[9] = _carGlassMat;
			// 10 - car interior 1
			_carIntern = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0xcfccaa)));
			_carIntern.gloss = 30;
			_carIntern.specular = 0.9;
			_materials[10] = _carIntern;
			// 11 - car interior 2
			_carIntern2 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x383533)));
			_carIntern2.gloss = 10;
			_carIntern2.specular = 1;
			_materials[11] = _carIntern2;
			// 12 - water texture
			_waterMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x22404060)));
			_waterMaterial.alphaBlending = true;
			_waterMaterial.repeat = true;
			_waterMaterial.gloss = 100;
			_waterMaterial.specular = 1;
			_waterMaterial.normalMethod = _waterMethod;
			_waterMaterial.specularMethod = _fresnelMethod3;
			_materials[12] = _waterMaterial;

			// apply light and effect for all material
			for (var i : int; i < _materials.length; i++) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 1;
			}
		}

		/**
		 * Initialise the reflextion cube
		 */
		private function initReflectionCube() : void {
			_reflectionTexture = new CubeReflectionTexture(128 * 2);
			_reflectionTexture.farPlaneDistance = FARVIEW;
			_reflectionTexture.nearPlaneDistance = 250;
			_reflectionTexture.position = new Vector3D(0, 200, 0);
		}

		/**
		 * Initialise the reflection methode
		 */
		private function initReflection() : void {
			if (_isReflection) return;
			_isReflection = true;
			initReflectionCube();
			_fresnelMethod = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod.normalReflectance = .5;
			_fresnelMethod.fresnelPower = 0.6;
			_fresnelMethod.alpha = 0.4;
			_fresnelMethod2 = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod2.normalReflectance = 1;
			_fresnelMethod2.fresnelPower = 0.8;
			_fresnelMethod2.alpha = 0.9;

			_materials[1].addMethod(_fresnelMethod);
			_materials[8].addMethod(_fresnelMethod2);
			_materials[9].addMethod(_fresnelMethod2);
		}

		/**
		 * Render loop
		 */
		private function onEnterFrame(event : Event = null) : void {
			if (_sunLight.ambient < 0.3) _sunLight.ambient += 0.003;
			if (_sunLight.specular < 1) _sunLight.specular += 0.01;
			if (_sunLight.diffuse < 1) _sunLight.diffuse += 0.01;
			else _isIntro = false;

			if (_night > 0) {
				_fogMethode.fogColor = AutoMapSky.darken(AutoMapSky.fogColor, _night);
				AutoMapSky.night(_night, FARVIEW);
				_night--;
			}

			CarMove.update();
			if (_visionCar) {
				_visionCar.position = new Vector3D(CarMove.position.x * 10, FractalTerrain.getHeightAt(CarMove.position.x * 10, CarMove.position.z * 10), CarMove.position.z * 10);
				_visionCar.rotationY = CarMove.angle + 180;
				_driveWheel.rotationZ = (CarMove.steering * 180);
				// wheels steering
				_wheels[1].rotationY = CarMove.steering * 60;
				_wheels[3].rotationY = 180 + (CarMove.steering * 60);
				// wheels rotation
				_wheels[0].rotationX -= CarMove.speed * 6;
				_wheels[1].rotationX -= CarMove.speed * 6;
				_wheels[2].rotationX += CarMove.speed * 6;
				_wheels[3].rotationX += CarMove.speed * 6;
			}

			_cameraController.lookAtPosition = _visionCar.position.add(new Vector3D(0, _cameraHeight, 0));
			_cameraController.update();

			// animate our lake material
			_waterMethod.water1OffsetX += .001;
			_waterMethod.water1OffsetY += .001;
			_waterMethod.water2OffsetX += .0007;
			_waterMethod.water2OffsetY += .0006;

			// update reflection
			if (_isReflection) {
				_reflectionTexture.position = _visionCar.position.add(new Vector3D(0, 250, 0));
				_reflectionTexture.render(_view);
			}

			// update view
			_view.render();
		}

		/*
		 * Initialise Listener
		 */
		private function initListeners(e : Event = null) : void {
			_isRender = true;
			log(message());
			if (e != null) {
				removeGrayPauseEffect();
				stage.removeEventListener(MouseEvent.MOUSE_OVER, initListeners);
			}
			// add render loop
			_stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			// add key listeners
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			// navigation
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}

		/*
		 * Remove Listener
		 */
		private function stopListeners() : void {
			if (_isIntro) return;
			_isRender = false;
			grayPauseEffect();
			log("&#47;&#33;&#92; PAUSE");
			_stage3DProxy.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseLeave);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);

			// mouse come back
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.MOUSE_OVER, initListeners);
		}

		/**
		 *  Function pause if leave stage
		 */
		private function grayPauseEffect() : void {
			_capture = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x40000000);
			_topPause.graphics.beginBitmapFill(_capture, null, false, false);
			_topPause.graphics.drawRect(0, 0, stage.width, stage.height);
			_topPause.graphics.endFill();
		}

		/**
		 *  Function unpause if on stage
		 */
		private function removeGrayPauseEffect() : void {
			_topPause.graphics.clear();
			_capture = null;
		}

		/**
		 * Listener function for AWD asset complete event on loader
		 */
		private function onAssetComplete(event : AssetEvent) : void {
			if (event.asset.assetType == AssetType.MESH) {
				var mesh : Mesh = event.asset as Mesh;
				if (mesh.name != 'top' && mesh.name != 'bottom')
					_vision.push(mesh);
			}
		}

		/**
		 * Listener on all resource complete
		 */
		private function onResourceComplete(e : LoaderEvent) : void {
			/*var loader3d : Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);*/

			var mesh : Mesh;
			_visionCar = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));
			_sit = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));
			_wheel = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));
			_door = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));
			_driveWheel = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));

			for (var i : int = 0; i < _vision.length; i++) {
				mesh = _vision[i];

				// apply texture by mesh name
				if (mesh.name.substring(0, 5) == 'glass' || mesh.name == 'door_glass') {
					mesh.material = _carGlassMat;
					mesh.castsShadows = false;
				} else if (mesh.name == 'crome' || mesh.name == 'Bouchon')
					mesh.material = _carCromeMat;
				else if (mesh.name == 'frontLightContour')
					mesh.material = _carLightMat3;
				else if (mesh.name == 'Plaques')
					mesh.material = _carCromeMat;
				else if (mesh.name == 'sitBase')
					mesh.material = _carIntern;
				else if (mesh.name == 'sitColor' || mesh.name == 'steering')
					mesh.material = _carIntern2;
				else if (mesh.name == 'frontLight')
					mesh.material = _carLightMat1;
				else if (mesh.name == 'light_red')
					mesh.material = _carLightMat2;
				else if (mesh.name == 'interiorSymetrie' || mesh.name == 'chassisPlus' || mesh.name == 'chassisSymetrie' || mesh.name == 'wheel_j2' || mesh.name == 'radiateur')
					mesh.material = _carBlackMat;
				else if (mesh.name == 'door')
					mesh.material = _carBlackDoubleMat;
				else if (mesh.name == 'wheel')
					mesh.material = _carWheelMat;
				else
					mesh.material = _carWhiteMat;

				// dispatch car parts
				if (mesh.name.substring(0, 3) == 'sit')
					_sit.addChild(mesh);
				else if (mesh.name.substring(0, 5) == 'wheel')
					_wheel.addChild(mesh);
				else if (mesh.name.substring(0, 4) == 'door')
					_door.addChild(mesh);
				// steering wheel
				else if (mesh.name == 'steering') {
					_driveWheel.addChild(mesh);
					_visionCar.addChild(_driveWheel);
					_driveWheel.position = new Vector3D(70, 123, -96);
				} else
					_visionCar.addChild(mesh);
			}

			// clone sit
			_sits = new Vector.<Mesh>(4);

			for (i = 0; i < 4; i++) {
				_sits[i] = Mesh(_sit.clone());
				if (i == 0) {
					_sits[i].x = -70;
					_sits[i].z = 125;
				} else if (i == 1) {
					_sits[i].x = -70;
				} else if (i == 2) {
					_sits[i].x = 70;
					_sits[i].z = 125;
				} else if (i == 3) {
					_sits[i].x = 70;
				}
				_visionCar.addChild(_sits[i]);
			}

			// clone door
			_doors = new Vector.<Mesh>(2);

			for (i = 0; i < 2; i++) {
				_doors[i] = Mesh(_door.clone());
				if (i == 0) {
					_doors[i].x = 0;
					_doors[i].z = 0;
				} else if (i == 1) {
					_doors[i].scaleX = -1;
				}
				_visionCar.addChild(_doors[i]);
			}

			// clone wheel
			_wheels = new Vector.<Mesh>(4);

			for (i = 0; i < 4; i++) {
				_wheels[i] = Mesh(_wheel.clone());
				if (i == 0) {
					_wheels[i].x = -138;
					_wheels[i].z = 237;
				} else if (i == 1) {
					_wheels[i].x = -138;
					_wheels[i].z = -237;
				} else if (i == 2) {
					_wheels[i].x = 138;
					_wheels[i].z = 237;
					_wheels[i].rotationY = 180;
				} else if (i == 3) {
					_wheels[i].x = 138;
					_wheels[i].z = -237;
					_wheels[i].rotationY = 180;
				}
				_wheels[i].y = 60;
				_visionCar.addChild(_wheels[i]);
			}

			// finaly add vision car mesh
			_view.scene.addChild(_visionCar);
			// if (_isReflection)
			initReflection();

			log(message());
			initListeners();
		}

		/**
		 * Create some clone
		 */
		private function makeClone(n : int = 4) : void {
			if (!_cloneActif) {
				_cloneActif = true;
				var g : Mesh;
				var decalx : int = -(n * 400) / 2;
				var decalz : int = -(n * 900) / 2;
				for (var j : int = 1; j < n; j++) {
					for (var i : int = 1; i < n; i++) {
						g = Mesh(_visionCar.clone());
						g.x = decalx + (400 * i);
						g.z = (decalz + (900 * j));
						if (g.x != 0 || g.z != 0)
							_view.scene.addChild(g);
					}
				}
			}
		}

		/**
		 * Key down listener for animation
		 */
		private function onKeyDown(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
					// fr
					CarMove.up(true);
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					CarMove.down(true);
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
					// fr
					CarMove.left(true);
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					CarMove.right(true);
					break;
				// options
				case Keyboard.B:
					makeClone();
					break;
				case Keyboard.N:
					randomSky();
					break;
				case Keyboard.I:
					fullScreen();
					break;
			}
		}

		/**
		 * Key up listener
		 */
		private function onKeyUp(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
				// fr
				case Keyboard.DOWN:
				case Keyboard.S:
					CarMove.up(false);
					CarMove.down(false);
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
				// fr
				case Keyboard.RIGHT:
				case Keyboard.D:
					CarMove.right(false);
					CarMove.left(false);
					break;
			}
		}

		/**
		 * stage full screen
		 */
		private function fullScreen(e : Event = null) : void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}

		/**
		 * stage listener and mouse control
		 */
		private function onResize(event : Event = null) : void {
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			_menu.y = stage.stageHeight;
			if (!_isRender)
				onEnterFrame();
		}

		private function onStageMouseDown(e : MouseEvent) : void {
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
			_mouseMove = true;
		}

		private function onStageMouseUp(e : Event) : void {
			_mouseMove = false;
		}

		private function onStageMouseLeave(e : Event) : void {
			_mouseMove = false;
			stopListeners();
		}

		private function onStageMouseMove(e : MouseEvent) : void {
			if (_mouseMove) {
				_cameraController.panAngle += (e.stageX - _prevMouseX);
				_cameraController.tiltAngle += (e.stageY - _prevMouseY);
			}
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
		}

		/**
		 * mouseWheel listener
		 */
		private function onStageMouseWheel(e : MouseEvent) : void {
			_cameraController.distance -= e.delta * 5;

			if (_cameraController.distance < 50)
				_cameraController.distance = 50;
			else if (_cameraController.distance > 2000)
				_cameraController.distance = 2000;
		}

		/**
		 * Initialise interface
		 */
		private function initSetting() : void {
			_menu = new Sprite();
			addChild(_menu);
			_menu.y = stage.stageHeight;
			Style.setStyle("dark");
			Style.DROPSHADOW = 0x000000;
			Style.BACKGROUND = 0x000000;
			Style.LABEL_TEXT = 0xffffff;
			Style.BUTTON_FACE = 0x060606;
			Style.BUTTON_DOWN = 0x995522;
			Style.fontName = "Helvetica";
			Style.embedFonts = false;
			Style.fontSize = 11;
			new PushButton(_menu, 30, -29, ">", showSetting).setSize(30, 30);
		}

		/**
		 * Create an instructions overlay
		 */
		private function initText() : void {
			_topPause = new Sprite();
			addChild(_topPause);

			_text = new TextField();
			var format : TextFormat = new TextFormat("Helvetica", 9, 0xdddddd);
			format.letterSpacing = 1;
			format.leftMargin = 5;
			format.leading = 1;
			_text.defaultTextFormat = format;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.gridFitType = GridFitType.PIXEL;
			_text.y = 5;
			_text.width = 300;
			_text.height = 250;
			_text.selectable = false;
			_text.mouseEnabled = true;
			_text.wordWrap = true;
			_text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			addChild(_text);
		}

		/**
		 * Welcome message
		 */
		private function message() : String {
			var mes : String = "ARROW.WSAD.ZSQD - move\n";
			mes += "I - full screen\n";
			mes += "N - random sky\n";
			mes += "B - clone\n";
			return mes;
		}

		/**
		 * Display text
		 */
		private function log(t : String) : void {
			_text.htmlText = t;
		}

		private function showSetting(e : MouseEvent) : void {
		}
	}
}