/*

SCROLING SHOOTER

Demonstrates:

How to use the Loader3D object to load an embedded internal awd model.
How to create ship control interaction in physic world
How to use particule in a game

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
	import away3d.events.AssetEvent;
	import away3d.library.AssetLibrary;
	import away3d.library.assets.AssetType;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;
	import away3d.events.LoaderEvent;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.lights.DirectionalLight;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.StageDisplayState;
	import flash.filters.DropShadowFilter;
	import flash.display.StageScaleMode;
	import flash.text.AntiAliasType;
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.text.GridFitType;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.system.System;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import utils.AutoSky;
	import utils.LoaderPool;

	import com.bit101.components.Style;
	import com.bit101.components.PushButton;
	import com.bit101.components.HUISlider;
	import com.bit101.components.Component;

	import games.FractalTerrain;
	import games.Particules;
	import games.shooters.Bullet;
	import games.shooters.BulletEnemy;
	import games.shooters.Enemy;
	import games.shooters.Stat;
	import games.shooters.Ship;

	[SWF(backgroundColor="#000000", frameRate="60", width = "1200", height = "600")]
	public class Demo_Shooter extends Sprite {
		[Embed(source="assets/ship.awd", mimeType="application/octet-stream")]
		private var ShipModel : Class;
		[Embed(source="assets/ship.jpg")]
		private var ShipBitmap : Class;
		private const MOUNTAIGN_TOP : Number = 2000;
		private const FARVIEW : Number = 12800;
		private const FOGNEAR : Number = 3200;
		// start colors
		private var sunColor : uint = 0xFFFFEE;
		// bitmaps
		private var _bitmapStrings : Vector.<String>;
		private var _bitmaps : Vector.<BitmapData>;
		// Stage manager and Stage3D instance proxy classes
		private var _stage3DManager : Stage3DManager;
		private var _stage3DProxy : Stage3DProxy;
		// engine variables
		private var _view : View3D;
		private var _stats : AwayStats;
		private var _lightPicker : StaticLightPicker;
		// private var _cameraController : HoverController;
		private var _night : Number = 100;
		// scene objects
		private var _player : ObjectContainer3D;
		private var _enemyShip : Mesh;
		private var _groundWater : Mesh;
		private var _sunLight : DirectionalLight;
		private var _shipMeshs : Vector.<Mesh>;
		// materials
		private var _materials : Vector.<TextureMaterial>;
		private var _terrainMaterial : TextureMaterial;
		private var _waterMaterial : TextureMaterial;
		private var _shipMaterial : TextureMaterial;
		private var _shipWindowMaterial : TextureMaterial;
		private var _enemyMaterial : TextureMaterial;
		// methodes
		private var _shadowMethod : NearShadowMapMethod;
		private var _reflectionMethod : EnvMapMethod;
		private var _fresnelMethod : FresnelSpecularMethod;
		private var _waterMethod : SimpleWaterNormalMethod;
		private var _fogMethode : FogMethod;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		// demo testing
		private var _isIntro : Boolean = true;
		// private var _isRotation : Boolean;
		private var _isRender : Boolean;
		// private var _isShipControl : Boolean;
		// interface
		private var _text : TextField;
		private var _capture : BitmapData;
		private var _topPause : Sprite;
		// ui
		private var _menu : Sprite;
		private var _sliderComplex : HUISlider;
		private var _sliderHeight : HUISlider;
		private var _isChangeResolution : Boolean = false;
		// camera position
		private var _cameraFixed : Vector3D = new Vector3D(0, 1400, 5000);
		private var _cameraTarget : Vector3D = new Vector3D(0, 1000, 3000);
		// player ship variable
		private var _position : Vector3D = new Vector3D(0, 1000, 3000);
		private var _banking : int = 0;
		private var _factor : Number = 4.66;
		private var _isMouseMove : Boolean;
		private var _isShooting : Boolean;
		private var _tmpShoot : int;
		// game variable
		private var _enemyInterval : int = 1;
		private var _bossInterval : int = 30;
		private var _powerupInterval : int = 10;
		private var _enemyTimer : Timer;
		private var _bossTimer : Timer;
		private var _powerupTimer : Timer;

		/**
		 * Constructor
		 */
		public function Demo_Shooter() {
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
			_stage3DProxy.antiAlias = 4;
		}

		/**
		 * Global initialise function
		 */
		private function initFinal(e : Stage3DEvent = null) : void {
			initEngine();
			// initOimoPhysics();
			initText();
			initSetting();
			initLights();

			// random sky map
			var skyN : uint = uint(1 + Math.random() * 14);

			// kickoff asset loading
			_bitmapStrings = new Vector.<String>();
			_bitmapStrings.push("sky/pano_" + skyN + ".jpg", "sky/up_" + skyN + ".jpg");
			_bitmapStrings.push("rock.jpg", "sand2.jpg", "arid.jpg");
			_bitmapStrings.push("water_normals.jpg");

			LoaderPool.log = log;
			LoaderPool.loadBitmaps(_bitmapStrings, initAfterBitmapLoad);
			_bitmaps = LoaderPool.bitmaps;
		}

		/**
		 * Initialise the scene objects
		 */
		private function initAfterBitmapLoad() : void {
			// create skybox
			randomSky();

			// create material
			initMaterials();

			// movable ground
			FractalTerrain.getInstance();
			FractalTerrain.scene = _view.scene;
			// FractalTerrain.addCubicReference(7);
			FractalTerrain.initGround(_bitmaps, _terrainMaterial, FARVIEW * 2, MOUNTAIGN_TOP, 128, true);
			FractalTerrain.move(-1, 0);

			// particule
			Particules.getInstance();
			Particules.scene = _view.scene;
			Particules.initParticlesTrail(0x999999, 0x353535);

			// parse ship model
			_shipMeshs = new Vector.<Mesh>();
			AssetLibrary.enableParser(AWD2Parser);
			AssetLibrary.addEventListener(AssetEvent.MESH_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, initAfterModelParse);
			AssetLibrary.loadData(new ShipModel());

			// init game statistic
			Stat.getInstance();
			Stat.initStats();

			// init player ship
			Ship.getInstance();

			// init bullet for ship
			Bullet.getInstance();
			Bullet.scene = _view.scene;
			Bullet.init(3000);

			// init enemy bullet
			BulletEnemy.getInstance();
			BulletEnemy.scene = _view.scene;
			BulletEnemy.init(3000);

			Enemy.getInstance();
			Enemy.scene = _view.scene;

			// create plane for water
			_groundWater = new Mesh(new PlaneGeometry(FARVIEW * 2, FARVIEW * 2, 6, 6), _waterMaterial);
			_groundWater.geometry.scaleUV(40, 40);
			_groundWater.mouseEnabled = false;
			_view.scene.addChild(_groundWater);
		}

		/**
		 * Listener function for full asset complete 
		 */
		private function initAfterModelParse(event : LoaderEvent = null) : void {
			// init enemy ship
			Enemy.init(_enemyShip, 3000, 1500, _cameraTarget.z);

			// init player ship
			Ship.initShip(_shipMeshs, _player, _shipMaterial, _shipWindowMaterial);

			initListeners();
		}

		/**
		 * Listener function on each mesh complete 
		 */
		private function onAssetComplete(event : AssetEvent) : void {
			if (event.asset.assetType == AssetType.MESH) {
				var mesh : Mesh = event.asset as Mesh;
				if (mesh.name.substr(0, 4) == "ship") _shipMeshs.push(mesh);
				if (mesh.name == "Enemy") {
					_enemyShip = mesh;
					_enemyShip.material = _enemyMaterial;
				}
			}
		}

		/**
		 * Create timer for this level
		 */
		private function initLevel() : void {
			_enemyTimer = new Timer(1000 * _enemyInterval, 0);
			_enemyTimer.addEventListener("timer", enemyTimerHandler);
			_enemyTimer.start();

			// init minibss release timer
			_bossTimer = new Timer(1000 * _bossInterval, 0);
			_bossTimer.addEventListener("timer", miniBossTimerHandler);
			_bossTimer.start();

			// init powerup release timer
			_powerupTimer = new Timer(1000 * _powerupInterval, 0);
			_powerupTimer.addEventListener("timer", powerupHandler);
			_powerupTimer.start();
		}

		/**
		 * stop all timer created in this level
		 */
		private function levelPause() : void {
			_enemyTimer.stop();
			_bossTimer.stop();
			_powerupTimer.stop();
		}

		// this event fires every second and releases an enemy ship
		private function enemyTimerHandler(event : TimerEvent) : void {
			Enemy.addEnemy();
		}

		// this event fires every 30 seconds and releases a miniboss
		private function miniBossTimerHandler(event : TimerEvent) : void {
			// var m = new MiniBoss();
		}

		// this event fires every 10 seconds and releases a power-up
		private function powerupHandler(event : TimerEvent) : void {
			// var m = new Powerup();
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
			_view.camera.lens = new PerspectiveLens(70);
			_view.camera.lens.far = FARVIEW + _cameraTarget.z;
			_view.camera.lens.near = 1;
			_view.forceMouseMove = false;

			_view.camera.y = 1000;
			_view.camera.position = _cameraFixed;
			_view.camera.lookAt(_cameraTarget);

			// setup the player container
			_player = new ObjectContainer3D();
			_view.scene.addChild(_player);

			// add stats
			addChild(_stats = new AwayStats(_view, false, true));
			_stats.x = stage.stageWidth - _stats.width - 5;
			_stats.alpha = 0.5;
			_stats.y = 2;

			stage.addEventListener(Event.RESIZE, onResize);
		}

		/**
		 * Initialise the lights
		 */
		private function initLights() : void {
			_sunLight = new DirectionalLight(0.1, -0.8, 0.3);
			_sunLight.color = sunColor;
			_sunLight.ambientColor = sunColor;
			_sunLight.ambient = 0;
			_sunLight.diffuse = 0;
			_sunLight.specular = 0;
			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.6);
			_view.scene.addChild(_sunLight);

			// create light picker for materials
			_lightPicker = new StaticLightPicker([_sunLight]);
		}

		/**
		 * Create random sky 
		 */
		private function randomSky(e : Event = null) : void {
			AutoSky.scene = _view.scene;
			AutoSky.randomSky(null, _bitmaps, 8);
			if (_fogMethode != null) _fogMethode.fogColor = AutoSky.fogColor;
			if (_reflectionMethod != null) _reflectionMethod.envMap = AutoSky.skyMap;
		}

		/**
		 * Initialise the materials
		 */
		private function initMaterials() : void {
			_materials = new Vector.<TextureMaterial>();

			// shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0007;
			_shadowMethod.alpha = 0.5;
			// fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW + _cameraTarget.z, AutoSky.fogColor);
			// water method
			_waterMethod = new SimpleWaterNormalMethod(Cast.bitmapTexture(_bitmaps[5]), Cast.bitmapTexture(_bitmaps[5]));
			// fresnelMethod
			_fresnelMethod = new FresnelSpecularMethod();
			_fresnelMethod.normalReflectance = 0.8;
			// reflection method
			_reflectionMethod = new EnvMapMethod(AutoSky.skyMap, 0.1);

			// 0 _ water texture
			_waterMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x50404060)));
			_waterMaterial.alphaBlending = true;
			_waterMaterial.repeat = true;
			_waterMaterial.gloss = 10;
			_waterMaterial.specular = 2;
			_waterMaterial.normalMethod = _waterMethod;
			_waterMaterial.specularMethod = _fresnelMethod;
			_waterMaterial.bothSides = true;
			_waterMaterial.addMethod(_reflectionMethod);
			_waterMaterial.addMethod(_fogMethode);
			_materials[0] = _waterMaterial;

			// 1 - terrain material
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, false, 0x808080)));
			_terrainMaterial.gloss = 10;
			_terrainMaterial.specular = 0.2;
			_terrainMaterial.addMethod(_fogMethode);
			_materials[1] = _terrainMaterial;

			// 2 - ship material
			_shipMaterial = new TextureMaterial(Cast.bitmapTexture(ShipBitmap));
			_shipMaterial.gloss = 60;
			_shipMaterial.specular = 1;
			_shipMaterial.bothSides = true;
			_shipMaterial.addMethod(_reflectionMethod);
			_materials[2] = _shipMaterial;

			// 3 - ship window material
			_shipWindowMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x44999999)));
			_shipWindowMaterial.gloss = 60;
			_shipWindowMaterial.specular = 1;
			// _shipWindowMaterial.bothSides = true;
			_shipWindowMaterial.alphaBlending = true;
			_shipWindowMaterial.addMethod(_reflectionMethod);
			_materials[3] = _shipWindowMaterial;

			// 4 - enemy ship material
			_enemyMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x99cc99)));
			_enemyMaterial.gloss = 60;
			_enemyMaterial.specular = 1;
			_enemyMaterial.addMethod(_reflectionMethod);
			_materials[4] = _enemyMaterial;

			// for all material
			for (var i : int; i < _materials.length; i++) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 1;
			}
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
				_fogMethode.fogColor = AutoSky.darken(AutoSky.fogColor, _night);
				AutoSky.night(_night, FARVIEW);
				_night--;
			}

			if (_banking != 0 && !_isMouseMove) {
				if (_banking > 0) _banking--;
				else _banking++;
			}

			// player and ship
			Ship.position = _position.add(new Vector3D(0, 50, 0));
			_player.position = _position.add(new Vector3D(0, 50, 0));
			_player.rotationX = _banking;

			// particule
			Particules.followTarget1.transform = _player.transform;
			Particules.followTarget2.transform = _player.transform;

			if (_isShooting ) {
				if (_tmpShoot == 8) {
					Bullet.shot(_position);
					_tmpShoot = 0;
				} else _tmpShoot++;
			}

			// animate water material
			_waterMethod.water1OffsetX += .001;
			_waterMethod.water1OffsetY += .001;
			_waterMethod.water2OffsetX += .0007;
			_waterMethod.water2OffsetY += .0006;

			_view.render();
			_isMouseMove = false;
			log("poition x:" + _position.x + " y:" + _position.y + "\n" + Stat.score);
		}

		/**
		 * Initialise listener
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
			// navigation
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);

			Enemy.start();
			Bullet.start();
			BulletEnemy.start();

			initLevel();
		}

		/**
		 * Remove listener
		 */
		private function stopListeners() : void {
			if (_isIntro) return;
			grayPauseEffect();
			_isRender = false;
			log("&#47;&#33;&#92; PAUSE");
			_stage3DProxy.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseLeave);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);

			// mouse come back
			stage.addEventListener(MouseEvent.MOUSE_OVER, initListeners);

			Enemy.pause();
			Bullet.pause();
			BulletEnemy.pause();

			levelPause();
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
			_stage3DProxy.width = stage.stageWidth;
			_stage3DProxy.height = stage.stageHeight;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			_menu.y = stage.stageHeight;
			if (!_isRender) onEnterFrame();
		}

		private function onStageMouseDown(e : MouseEvent) : void {
			if (e.stageY > stage.stageHeight - 30) return;
			_isShooting = true;
			_tmpShoot = 8;
		}

		private function onStageMouseUp(e : Event) : void {
			_isShooting = false;
		}

		private function onStageMouseLeave(e : Event) : void {
			stopListeners();
		}

		private function onStageMouseMove(e : MouseEvent) : void {
			_isMouseMove = true;
			if (_prevMouseY > e.stageY) _banking--;
			else if (_prevMouseY < e.stageY) _banking++;

			_position.x = (-(e.stageX - (stage.stageWidth >> 1)) * _factor) >> 0;
			_position.y = (-((e.stageY - (stage.stageHeight >> 1)) * _factor) + _cameraTarget.y) >> 0;
			_position.z = _cameraTarget.z;

			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
		}

		/**
		 * mouseWheel listener
		 */
		private function onStageMouseWheel(e : MouseEvent) : void {
			// _cameraController.distance -= e.delta * 5;
		}

		/**
		 * Interface
		 */
		private function initSetting() : void {
			_menu = new Sprite();
			addChild(_menu);
			_menu.y = stage.stageHeight;
			Style.setStyle("dark");
			Style.DROPSHADOW = 0x000000;
			Style.BACKGROUND = 0x995522;
			Style.LABEL_TEXT = 0xEEEEEE;
			Style.BUTTON_FACE = 0x060606;
			Style.BUTTON_DOWN = 0x995522;
			Style.fontName = "Helvetica";
			Style.embedFonts = false;
			Style.fontSize = 11;
			Component.initStage(stage);
			new PushButton(_menu, 30, -29, ">", showSetting).setSize(30, 30);
			new PushButton(_menu, 65, -29, "64", switch64).setSize(30, 30);
			new PushButton(_menu, 100, -29, "128", switch128).setSize(30, 30);
			new PushButton(_menu, 135, -29, "256", switch256).setSize(30, 30);
			new PushButton(_menu, 170, -29, "fractal", switchFractal).setSize(60, 30);
			new PushButton(_menu, 430, -29, "sky", randomSky).setSize(60, 30);
			new PushButton(_menu, 495, -29, "full screen", fullScreen).setSize(80, 30);

			_sliderHeight = new HUISlider(_menu, 235, -20, "height", setTerrainHeight);
			_sliderHeight.maximum = 4000;
			_sliderHeight.minimum = -4000;
			_sliderHeight.value = MOUNTAIGN_TOP;

			_sliderComplex = new HUISlider(_menu, 235, -32, "complex", setComplex);
			_sliderComplex.labelPrecision = 3;
			_sliderComplex.minimum = 0.001;
			_sliderComplex.maximum = 0.3;
			_sliderComplex.tick = 0.001;
			_sliderComplex.value = 0.12;
		}

		private function setTerrainHeight(event : Event) : void {
			FractalTerrain.changeHeight(_sliderHeight.value);
		}

		private function setComplex(event : Event) : void {
			FractalTerrain.changeComplex(_sliderComplex.value);
		}

		private function switchFractal(e : Event) : void {
			FractalTerrain.changeFractal();
		}

		private function switch64(e : Event) : void {
			_isChangeResolution = true;
			FractalTerrain.changeResolution(64);
			FractalTerrain.move(-1, 0);
		}

		private function switch128(e : Event) : void {
			_isChangeResolution = true;
			FractalTerrain.changeResolution(128);
			FractalTerrain.move(-1, 0);
		}

		private function switch256(e : Event) : void {
			_isChangeResolution = true;
			FractalTerrain.changeResolution(256);
			FractalTerrain.move(-1, 0);
		}

		/**
		 * Create an instructions overlay
		 */
		private function initText() : void {
			_topPause = new Sprite();
			addChild(_topPause);

			_text = new TextField();
			var format : TextFormat = new TextFormat("Helvetica", 9, 0xdddddd, null, null, null, null, null, null, 5, null, null, 1);
			format.letterSpacing = 1;
			_text.defaultTextFormat = format;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.gridFitType = GridFitType.PIXEL;
			_text.y = 5;
			_text.width = 300;
			_text.height = 250;
			_text.wordWrap = true;
			_text.selectable = false;
			_text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			addChild(_text);
		}

		/**
		 * Welcome message
		 */
		private function message() : String {
			var mes : String = "Click to shoot\n";
			// mes += "Click on ship for rotation\n";
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