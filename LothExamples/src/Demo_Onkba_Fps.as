/*

ONKBA FPS

Demonstrates:

How to use the Loader3D object to load an embedded internal awd model.
How to create character interaction in physic world
How to set custom material on a model.

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
	import away3d.animators.data.Skeleton;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.library.assets.AssetType;
	import away3d.primitives.CubeGeometry;
	import away3d.lights.DirectionalLight;
	import away3d.events.MouseEvent3D;
	import away3d.events.LoaderEvent;
	import away3d.containers.View3D;
	import away3d.entities.Sprite3D;
	import away3d.events.AssetEvent;
	import away3d.loaders.Loader3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.StageDisplayState;
	import flash.filters.DropShadowFilter;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.events.MouseEvent;
	import flash.text.GridFitType;
	import flash.utils.setTimeout;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.system.System;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;

	import com.bit101.components.Style;
	import com.bit101.components.PushButton;

	import utils.AutoSky;
	import utils.LoaderPool;

	import games.FractalTerrain;
	import games.Player;

	// import physics.OimoEngine;
	[SWF(frameRate="60", backgroundColor = "#000000", width = "1200", height = "600")]
	public class Demo_Onkba_Fps extends Sprite {
		private const MOUNTAIGN_TOP : Number = 2000;
		private const SWIM_TOP : Number = -105;
		private const FARVIEW : Number = 12800;
		private const FOGNEAR : Number = 300;
		private const HERO_SIZE : Number = 1.5;
		// start colors
		private var groundColor : uint = 0x333338;
		private var sunColor : uint = 0xFFFFFF;
		private var fogColor : uint = 0x333338;
		private var skyColor : uint = 0x445465;
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
		private var _cameraController : HoverController;
		// scene objects
		// private var _player : ObjectContainer3D;
		private var _groundWater : Mesh;
		private var _heroPieces : Mesh;
		// ObjectContainer3D;
		private var _sunLight : DirectionalLight;
		private var _weapons : Vector.<Mesh>;
		private var _bullets : Vector.<Mesh>;
		private var _bonesFx : Vector.<Mesh>;
		private var _heroWeapon : Mesh;
		private var _heroOnkba : Mesh;
		private var _heroSia : Mesh;
		private var _shirt : Mesh;
		private var _hair : Mesh;
		// materials
		private var _boxMaterial : TextureMaterial;
		private var _gunMaterial : TextureMaterial;
		private var _gunMaterial2 : TextureMaterial;
		private var _boneMaterial : TextureMaterial;
		private var _onkbaMaterial : TextureMaterial;
		private var _siaMaterial : TextureMaterial;
		private var _shirtMaterial : TextureMaterial;
		private var _shereMaterial : TextureMaterial;
		private var _terrainMaterial : TextureMaterial;
		private var _eyesOpenMaterial : TextureMaterial;
		private var _eyesClosedMaterial : TextureMaterial;
		private var _eyesClosedSiaMaterial : TextureMaterial;
		private var _nullMaterial : TextureMaterial;
		private var _waterMaterial : TextureMaterial;
		private var _basicMaterial : TextureMaterial;
		private var _materials : Vector.<TextureMaterial>;
		// methodes
		private var _shadowMethod : NearShadowMapMethod;
		private var _rimLightMethod : RimLightMethod;
		private var _fogMethode : FogMethod;
		private var _fresnelMethod : FresnelSpecularMethod;
		private var _waterMethod : SimpleWaterNormalMethod;
		// hero animation variables
		private const ANIMATION : Array = ["Idle", "Walk", "WalkL", "WalkR", "Run", "CrouchIdle", "CrouchWalk", "Reload", "WaterIdle", "WaterSwim", "StandBack", "StandFace", "JumpDown", "TrowGrenade", "CrouchGrenade", "IdleDrive"];
		// private const ANIMATION_FALL : Array = ["FallBack", "FallBackMid", "FallFace", "FallFaceBack", "FallRight", "FallRightMid", "FallLeft", "FallLeftMid"];
		private const WEAPON : Array = ["", "Gun", "ShoutGun", "Sniper", "Gatling", "Bazooka"];
		private const BULLET : Array = ["", "08mm", "09mm", "12mm", "15mm", "Rocket"];
		private var _animationSet : SkeletonAnimationSet;
		private var _transition : CrossfadeTransition;
		private var _animator : SkeletonAnimator;
		private const RELOAD_SPEED : Number = 1;
		private const IDLE_SPEED : Number = 0.7;
		private const JUMP_SPEED : Number = 1;
		private const WALK_SPEED : Number = 1;
		private const RUN_SPEED : Number = 1.5;
		private var movementDirection : Number;
		private var currentAnim : String;
		private var currentWeapon : uint;
		// animation phase
		private var _isSwiming : Boolean;
		private var _isSideMove : Boolean;
		private var _isRunning : Boolean;
		private var _isCrouch : Boolean;
		private var _isMoving : Boolean;
		private var _isJump : Boolean;
		// weapon decal
		private var _weaponsDecals : Vector.<Vector3D>;
		private var _weaponsDecalsWom : Vector.<Vector3D>;
		private var _weaponsRotation : Vector.<Vector3D>;
		// hero dynamique eye
		private var _eyePosition : Vector3D;
		private var _eyes : ObjectContainer3D;
		private var _eyeLook : Mesh;
		private var _eyeL : Mesh;
		private var _eyeR : Mesh;
		private var _eyeCount : int;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		private var _cameraHeight : Number = 100;
		private var _night : Number = 100;
		// demo testing
		private var _isIntro : Boolean = true;
		private var _isMan : Boolean = true;
		private var _isShirt : Boolean = true;
		private var _isDynamicsEyes : Boolean;
		private var _isDebugRay : Boolean;
		private var _isRender : Boolean;
		private var _text : TextField;
		private var _capture : BitmapData;
		private var _topPause : Sprite;
		private var _menu : Sprite;

		/**
		 * Constructor
		 */
		public function Demo_Onkba_Fps() {
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
			// initOimoPhysics();
			initText();
			initSetting();
			initLights();

			// random sky map
			var skyN : uint = uint(1 + Math.random() * 6);

			// kickoff asset loading
			_bitmapStrings = new Vector.<String>();
			_bitmapStrings.push("sky/pano_" +skyN + ".jpg", "sky/up_" + skyN + ".jpg");
			// 2 3 4
			_bitmapStrings.push("rock.jpg", "sand2.jpg", "arid.jpg");
			// hero map 5 6 7
			_bitmapStrings.push("onkba/onkba_diffuse.png", "onkba/onkba_normals.jpg", "onkba/onkba_lightmap.jpg");
			// gun map 8 9 10 
			_bitmapStrings.push("onkba/weapon_diffuse.jpg", "onkba/weapon_normals.jpg", "onkba/weapon_lightmap.jpg");
			// bazooka map 11 12 13
			_bitmapStrings.push("onkba/weapon2_diffuse.jpg", "onkba/weapon2_normals.jpg", "onkba/weapon2_lightmap.jpg");
			// Sia map 14 
			_bitmapStrings.push("onkba/sia_diffuse.jpg");
			// water map 15
			_bitmapStrings.push("water_normals.jpg");

			LoaderPool.log = log;
			LoaderPool.loadBitmaps(_bitmapStrings, initAfterBitmapLoad);
			_bitmaps = LoaderPool.bitmaps;
		}

		/**
		 * Initialise the scene objects
		 */
		private function initAfterBitmapLoad() : void {
			// create material
			initMaterials();

			// create skybox
			randomSky();

			// create noize terrain with image 6 7 8
			FractalTerrain.getInstance();
			FractalTerrain.scene = _view.scene;
			FractalTerrain.addCubicReference(1);
			FractalTerrain.initGround(_bitmaps, _terrainMaterial, FARVIEW * 2, MOUNTAIGN_TOP, 128, true);

			// setup the player container
			Player.getInstance();
			Player.scene = _view.scene;
			Player.initPlayer();
			// _player = new ObjectContainer3D();
			// _view.scene.addChild(_player);

			// basic water ground
			_groundWater = new Mesh(new PlaneGeometry(FARVIEW * 2, FARVIEW * 2, 6, 6), _waterMaterial);
			_groundWater.geometry.scaleUV(60, 60);
			// _groundWater.castsShadows = false;
			_view.scene.addChild(_groundWater);

			// weapon referency
			_weapons = new Vector.<Mesh>(WEAPON.length);
			_weapons[0] = new Mesh(new PlaneGeometry(1, 1), _nullMaterial);

			// weapon decal
			_weaponsDecals = new Vector.<Vector3D>(WEAPON.length);
			_weaponsDecalsWom = new Vector.<Vector3D>(WEAPON.length);
			_weaponsRotation = new Vector.<Vector3D>(WEAPON.length);
			_weaponsDecals[0] = new Vector3D();
			_weaponsDecalsWom[0] = new Vector3D();
			_weaponsRotation[0] = new Vector3D();

			// bullet referency
			_bullets = new Vector.<Mesh>(BULLET.length);
			_bullets[0] = new Mesh(new PlaneGeometry(1, 1), _nullMaterial);

			// load Onkba character with weapons
			LoaderPool.loadObject("onkba/onkba_sia_fps.awd", onAssetComplete, onResourceComplete);
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
			_view.camera.lens.far = FARVIEW;
			_view.camera.lens.near = 0.1;

			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 22, 0, 500, 10, 90);
			_cameraController.tiltAngle = 10;
			_cameraController.panAngle = 22;
			_cameraController.minTiltAngle = -10;
			_cameraController.maxTiltAngle = 60;
			_cameraController.autoUpdate = false;

			// add stats
			addChild(_stats = new AwayStats(_view, false, true));
			_stats.x = stage.stageWidth - _stats.width - 5;
			_stats.alpha = 0.5;
			_stats.y = 2;

			stage.addEventListener(Event.RESIZE, onResize);
		}

		/**
		 * Initialise OimoPhysics engine
		 */
		/*private function initOimoPhysics() : void {
		OimoEngine.getInstance();
		OimoEngine.scene = _view.scene;
		}*/
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
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.3);
			_view.scene.addChild(_sunLight);

			// generate cube texture for sky and probe
			// _skyProbe = new LightProbe(_skyMap);
			// _view.scene.addChild(_skyProbe);

			// create light picker for materials
			_lightPicker = new StaticLightPicker([_sunLight]);
		}

		/**
		 * Create random sky 
		 */
		private function randomSky() : void {
			AutoSky.scene = _view.scene;
			if (_isIntro) AutoSky.randomSky([skyColor, fogColor, groundColor], _bitmaps, 8);
			else AutoSky.randomSky(null, _bitmaps, 8);
			_fogMethode.fogColor = AutoSky.fogColor;
		}

		/**
		 * Initialise scene materials
		 */
		private function initMaterials() : void {
			_materials = new Vector.<TextureMaterial>();

			// shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0007;
			_shadowMethod.alpha = 0.5;
			// global Rim light method
			_rimLightMethod = new RimLightMethod(skyColor, 0.5, 2, RimLightMethod.ADD);
			// global fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW, fogColor);
			// water method
			_waterMethod = new SimpleWaterNormalMethod(Cast.bitmapTexture(_bitmaps[15]), Cast.bitmapTexture(_bitmaps[15]));
			// fresnelMethod
			_fresnelMethod = new FresnelSpecularMethod();
			_fresnelMethod.normalReflectance = 0.9;

			// 0 - onkba hero
			_onkbaMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[5]));
			_onkbaMaterial.normalMap = Cast.bitmapTexture(_bitmaps[6]);
			_onkbaMaterial.specularMap = Cast.bitmapTexture(_bitmaps[7]);
			_onkbaMaterial.gloss = 25;
			_onkbaMaterial.specular = 0.8;
			_materials[0] = _onkbaMaterial;

			// 1 - weapon
			_gunMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[8]));
			_gunMaterial.normalMap = Cast.bitmapTexture(_bitmaps[9]);
			_gunMaterial.specularMap = Cast.bitmapTexture(_bitmaps[10]);
			_gunMaterial.gloss = 20;
			_gunMaterial.specular = 0.8;
			_materials[1] = _gunMaterial;

			// 2 - eye ball close
			var b : BitmapData;
			b = new BitmapData(64, 64, false, 0xA13D1E);
			_eyesClosedMaterial = new TextureMaterial(Cast.bitmapTexture(b));
			_eyesClosedMaterial.gloss = 12;
			_eyesClosedMaterial.specular = 0.6;
			_materials[2] = _eyesClosedMaterial;

			// 3- eye ball open from bitmap diffuse onkba
			b = new BitmapData(256 / 2, 256 / 2, false);
			b.draw(_bitmaps[9], new Matrix(1, 0, 0, 1, -283 / 2, -197 / 2));
			_eyesOpenMaterial = new TextureMaterial(Cast.bitmapTexture(b));
			_eyesOpenMaterial.gloss = 100;
			_eyesOpenMaterial.specular = 0.8;
			_materials[3] = _eyesOpenMaterial;

			// 4 - sphere reflection test
			_shereMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x00)));
			_shereMaterial.gloss = 90;
			_shereMaterial.specular = 4;
			_shereMaterial.repeat = true;
			_shereMaterial.addMethod(_fogMethode);
			_materials[4] = _shereMaterial;

			// 5 - terrain material
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, false, 0x808080)));
			_terrainMaterial.gloss = 10;
			_terrainMaterial.specular = 0.2;
			_materials[5] = _terrainMaterial;

			// 6 - simulation box
			_boxMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0xee100000)));
			_boxMaterial.gloss = 10;
			_boxMaterial.specular = 0.1;
			_boxMaterial.alphaBlending = true;
			_boxMaterial.addMethod(_fogMethode);
			_materials[6] = _boxMaterial;

			// 7 - Xray bones
			_boneMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0xee00ff00)));
			_boneMaterial.gloss = 10;
			_boneMaterial.specular = 0.1;
			_boneMaterial.alphaBlending = true;
			_materials[7] = _boneMaterial;

			// 8 - bazooka
			_gunMaterial2 = new TextureMaterial(Cast.bitmapTexture(_bitmaps[11]));
			_gunMaterial2.normalMap = Cast.bitmapTexture(_bitmaps[12]);
			_gunMaterial2.specularMap = Cast.bitmapTexture(_bitmaps[13]);
			_gunMaterial2.gloss = 20;
			_gunMaterial2.specular = 0.8;
			_materials[8] = _gunMaterial2;

			// 9 - hero shirt
			_shirtMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[5]));
			// _shirtMaterial.normalMap = Cast.bitmapTexture(_bitmaps[10]);
			// _shirtMaterial.specularMap = Cast.bitmapTexture(_bitmaps[11]);
			_shirtMaterial.gloss = 5;
			_shirtMaterial.specular = 0.1;
			_shirtMaterial.alphaThreshold = 0.9;
			_shirtMaterial.alphaPremultiplied = true;
			_shirtMaterial.bothSides = true;
			_materials[9] = _shirtMaterial;

			// 10 - sia hero
			_siaMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[14]));
			// _siaMaterial.normalMap = Cast.bitmapTexture(_bitmaps[10]);
			// _siaMaterial.specularMap = Cast.bitmapTexture(_bitmaps[11]);
			_siaMaterial.gloss = 25;
			_siaMaterial.specular = 0.8;
			_materials[10] = _siaMaterial;

			// 11 - eye ball close sia
			var b2 : BitmapData;
			b2 = new BitmapData(64, 64, false, 0x483445);
			_eyesClosedSiaMaterial = new TextureMaterial(Cast.bitmapTexture(b2));
			_eyesClosedSiaMaterial.gloss = 12;
			_eyesClosedSiaMaterial.specular = 0.6;
			_materials[11] = _eyesClosedSiaMaterial;

			// 12 _ water texture
			_waterMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x50404060)));
			_waterMaterial.alphaBlending = true;
			_waterMaterial.repeat = true;
			_waterMaterial.gloss = 20;
			_waterMaterial.specular = 2;
			_waterMaterial.normalMethod = _waterMethod;
			_waterMaterial.specularMethod = _fresnelMethod;
			_waterMaterial.bothSides = true;
			_waterMaterial.addMethod(_fogMethode);
			_materials[12] = _waterMaterial;

			// fake material for hiding mesh
			_nullMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, true, 0x00000000)));
			_nullMaterial.alphaBlending = true;

			// for all material
			for (var i : int; i < _materials.length; i++ ) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 1;
				// if (i != 5) _materials[i].addMethod(_rimLightMethod);
			}

			_basicMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, false, 0x000000)));
		}

		/**
		 * Navigation and render loop
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

			FractalTerrain.update();

			if ( FractalTerrain.cubePoints[0].y < SWIM_TOP) {
				_isSwiming = true;
				Player.position = new Vector3D(FractalTerrain.cubePoints[0].x, SWIM_TOP, FractalTerrain.cubePoints[0].z);
			} else {
				_isSwiming = false;
				Player.position = FractalTerrain.cubePoints[0];
			}

			// _player.position = FractalTerrain.cubePoints[0];

			if (_heroOnkba) {
				if (_isDynamicsEyes) updateEyes();
				if (_isDebugRay) updateBones();
				// hand bone for weapon
				if (_animator.globalPose.numJointPoses >= 22) {
					_heroWeapon.transform = _animator.globalPose.jointPoses[22].toMatrix3D();
				}
			}
			if ( _cameraController.distance > 300 && _isIntro) _cameraController.distance--;

			// _cameraController.lookAtPosition = new Vector3D(_player.x, _player.y + _cameraHeight, _player.z);
			_cameraController.lookAtPosition = Player.position.add(new Vector3D(0, _cameraHeight, 0));
			_cameraController.update();

			// animate water material
			_waterMethod.water1OffsetX += .001;
			_waterMethod.water1OffsetY += .001;
			_waterMethod.water2OffsetX += .0007;
			_waterMethod.water2OffsetY += .0006;

			_view.render();
		}

		/**
		 * Initialise Listener
		 */
		private function initListeners(e : Event = null) : void {
			_isRender = true;
			log(message());
			if (e != null) {
				removeGrayPauseEffect();
				stage.removeEventListener(MouseEvent.MOUSE_OVER, initListeners);
			}
			_stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}

		/**
		 * Remove Listener
		 */
		private function stopListeners() : void {
			if (_isIntro) return;
			grayPauseEffect();
			_isRender = false;
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
		 *  AWD asset complete event on loader
		 */
		private function onAssetComplete(event : AssetEvent) : void {
			var i : uint;
			if (event.asset.assetType == AssetType.SKELETON) {
				// Create a new skeleton animation set with 3 joints per vertex
				// and Wrap in an animator object
				_animationSet = new SkeletonAnimationSet(3);
				_animator = new SkeletonAnimator(_animationSet, event.asset as Skeleton);
			} else if (event.asset.assetType == AssetType.ANIMATION_NODE) {
				// Add each animation node to the animation set
				// for detail see sequenceFPS.txt in /3dsmax
				var animationNode : SkeletonClipNode = event.asset as SkeletonClipNode;
				_animationSet.addAnimation(animationNode);
				// disable animation loop*
				if (animationNode.name == "TrowGrenade") animationNode.looping = false;
				if (animationNode.name == "CrouchGrenade") animationNode.looping = false;
				for ( i = 0; i < WEAPON.length; i++ ) {
					if (animationNode.name == WEAPON[i] + "JumpDown") animationNode.looping = false;
					if (animationNode.name == WEAPON[i] + "Reload") animationNode.looping = false;
				}
			} else if (event.asset.assetType == AssetType.MESH) {
				var mesh : Mesh = event.asset as Mesh;
				// set default texture
				mesh.material = _basicMaterial;

				// Sia character object
				if (mesh.name == "Sia") {
					_heroSia = mesh;
				}
				// Sia hair object
				if (mesh.name == "Hair") {
					_hair = mesh;
				}
				// Onkba character object
				if (mesh.name == "Onkba") {
					_heroOnkba = mesh;
				}
				// Shirt object
				if (mesh.name == "Shirt") {
					_shirt = mesh;
				}

				// Weapons object
				for ( i = 0; i < WEAPON.length; i++ ) {
					if (mesh.name == WEAPON[i]) {
						// Gun
						if (i == 1) {
							_weaponsDecals[1] = new Vector3D(0, -4.2, 1.6);
							_weaponsDecalsWom[1] = new Vector3D(0, -4.2, 1.6);
							_weaponsRotation[1] = new Vector3D(0, -5, 0);
						}
						// ShoutGun
						if (i == 2) {
							_weaponsDecals[2] = new Vector3D(0, -5, 1.6);
							_weaponsDecalsWom[2] = new Vector3D(0, -5, 1.6);
							_weaponsRotation[2] = new Vector3D(0, -5, -2);
						}
						// Sniper
						if (i == 3) {
							_weaponsDecals[3] = new Vector3D(0, -4.6, 1.8);
							_weaponsDecalsWom[3] = new Vector3D(0, -4.6, 1.8);
							_weaponsRotation[3] = new Vector3D(0, -5, -5);
						}
						// Gateling
						if (i == 4) {
							_weaponsDecals[4] = new Vector3D(0, 1.8, -4.6);
							_weaponsDecalsWom[4] = new Vector3D(0, 1.8, -4.6);
							_weaponsRotation[4] = new Vector3D(0, -5, -5);
						}
						// Basokaa
						if (i == 5) {
							_weaponsDecals[5] = new Vector3D(5, 2, -4);
							_weaponsDecalsWom[5] = new Vector3D(5, 2, -4);
							_weaponsRotation[5] = new Vector3D(0, 6, -6);
						}
						// decal for bazooka

						if (i != 5) mesh.material = _gunMaterial;
						else mesh.material = _gunMaterial2;
						_weapons[i] = mesh;
					}
				}
				// Weapons object
				for ( i = 0; i < BULLET.length; i++ ) {
					if (mesh.name == BULLET[i]) {
						mesh.material = _gunMaterial2;
						_bullets[i] = mesh;
					}
				}
			}
		}

		/**
		 *  AWD resource complete event on loader
		 */
		private function onResourceComplete(e : LoaderEvent) : void {
			var loader3d : Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);

			_transition = new CrossfadeTransition(0.3);
			// apply our _animator to sia character
			_heroSia.animator = _animator;
			_heroSia.material = _siaMaterial;
			_hair.animator = _animator;
			_hair.material = _siaMaterial;

			// apply our animator to onkba character
			_heroOnkba.animator = _animator;
			_heroOnkba.material = _onkbaMaterial;

			// do the same for shirt
			_shirt.animator = _animator;
			_shirt.material = _shirtMaterial;

			// add weapon container
			_heroWeapon = new Mesh(new PlaneGeometry(1, 1), _nullMaterial);
			_heroWeapon.castsShadows = false;
			// Dynamic eyes ball
			_heroPieces = new Mesh(new PlaneGeometry(1, 1), _nullMaterial);
			_heroWeapon.castsShadows = false;

			Player.add(_heroOnkba);
			Player.add(_shirt);
			Player.add(_heroWeapon);
			Player.add(_heroPieces);

			Player.scale = (HERO_SIZE);

			// _player.addChild(_heroSia);
			/*_player.addChild(_heroOnkba);
			_player.addChild(_shirt);
			_player.addChild(_heroWeapon);
			_player.addChild(_heroPieces);
			_player.scale(HERO_SIZE);*/

			addHeroEye();

			if (_isIntro) {
				_isJump = true;
				_animator.playbackSpeed = -JUMP_SPEED;
				jumpDown();
			}

			// add some box for fun
			/*var num : int = 100;
			var mesh : Mesh, posX : Number, posZ : Number;
			_cubeVector = new Vector.<Mesh>(num);
			for (var i : int = 0; i < num; i++) {
			posX = Number(-(FARVIEW * 0.5) + (Math.random() * FARVIEW));
			posZ = Number(-(FARVIEW * 0.5) + (Math.random() * FARVIEW));
			mesh = new Mesh(new CubeGeometry(150, 300, 150), _boxMaterial);
			mesh.position = new Vector3D(posX, _terrain.getHeightAt(posX, posZ), posZ);
			_view.scene.addChild(mesh);
			_cubeVector[i] = mesh;
			}*/

			log(message());
			initListeners();

			// start away3d physics 
			// initPhysicsEngine();
		}

		/**
		 * Weapons collection
		 */
		private function switchWeapon(next : Boolean = true) : void {
			if (next) currentWeapon++;
			if (currentWeapon > 5) currentWeapon = 0;
			for (var i : int; i < _heroWeapon.numChildren; i++ ) {
				_heroWeapon.removeChild(_heroWeapon.getChildAt(i));
			}
			var mesh : Mesh = _weapons[currentWeapon];
			if (_isMan) mesh.position = _weaponsDecals[currentWeapon];
			else mesh.position = _weaponsDecalsWom[currentWeapon];
			mesh.rotationX = _weaponsRotation[currentWeapon].x;
			mesh.rotationY = _weaponsRotation[currentWeapon].y;
			mesh.rotationZ = _weaponsRotation[currentWeapon].z;
			_heroWeapon.addChild(mesh);
			// Play idle animation
			stop();
		}

		/**
		 * Test some Clones
		 */
		/*private function makeClone(n : int = 20) : void {
		if (!_cloneActif) {
		_cloneActif = true;
		var g : Mesh;
		var decal : int = -(n * 100) / 2;
		for (var j : int = 1; j < n; j++) {
		for (var i : int = 1; i < n; i++) {
		g = Mesh(_heroOnkba.clone());
		g.x = decal + (100 * i);
		g.z = (decal + (100 * j));
		g.y = _terrain.getHeightAt(g.x, g.z);
		if (g.x != 0 || g.z != 0)
		_view.scene.addChild(g);
		}
		}
		}
		}*/
		/**
		 * Character breath animation
		 */
		private function stop() : void {
			var anim : String;
			if (_isSwiming) anim = WEAPON[currentWeapon] + ANIMATION[8];
			else {
				if (_isCrouch) anim = WEAPON[currentWeapon] + ANIMATION[5];
				else anim = WEAPON[currentWeapon] + ANIMATION[0];
			}

			if (currentAnim == anim) return;
			// FractalTerrain.move(0, 0);
			FractalTerrain.move(0, 0);
			currentAnim = anim;
			_animator.playbackSpeed = IDLE_SPEED;
			if (_isSwiming) currentAnim = WEAPON[currentWeapon] + ANIMATION[8];
			else {
				if (_isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[5];
				else currentAnim = WEAPON[currentWeapon] + ANIMATION[0];
			}
			_animator.play(currentAnim, _transition);
		}

		/**
		 * Character Mouvement
		 */
		private function updateMovement(dir : Number) : void {
			_isMoving = true;
			var anim : String = _isRunning ? "Run" : "Walk";

			if (currentAnim == anim) return;

			_animator.playbackSpeed = dir * (_isRunning ? RUN_SPEED : WALK_SPEED);
			FractalTerrain.move(0, _animator.playbackSpeed / 20);

			if (_isSwiming) currentAnim = WEAPON[currentWeapon] + ANIMATION[9];
			else {
				if (_isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[6];
				else currentAnim = WEAPON[currentWeapon] + anim;
			}
			_animator.play(currentAnim, _transition);
		}

		/**
		 * Character Mouvement side
		 */
		private function updateMovementSide(dir : Number) : void {
			_isSideMove = true;
			var anim : String;
			if (dir > 0) anim = 'WalkL';
			else anim = 'WalkR';
			FractalTerrain.move(dir / 100, 0);
			if (_isCrouch) return;
			else currentAnim = WEAPON[currentWeapon] + anim;
			_animator.play(currentAnim, _transition);
		}

		/**
		 * Character reload animation
		 */
		private function reload() : void {
			var anim : String;
			if (_isCrouch) anim = WEAPON[currentWeapon] + 'CrouchReload';
			else anim = WEAPON[currentWeapon] + 'Reload';

			if (currentAnim == anim) return;

			currentAnim = anim;
			_animator.playbackSpeed = RELOAD_SPEED;
			_animator.play(currentAnim, _transition, 0);
		}

		/**
		 * Character jump up animation
		 */
		private function jumpUp() : void {
			_isJump = true;
			var anim : String;
			anim = WEAPON[currentWeapon] + 'JumpDown';

			if (currentAnim == anim) return;

			currentAnim = anim;
			_animator.playbackSpeed = -JUMP_SPEED;
			_animator.play(currentAnim, _transition, 0);

			setTimeout(jumpDown, 260);
		}

		/**
		 * Character jump down animation
		 */
		private function jumpDown() : void {
			var anim : String;
			anim = WEAPON[currentWeapon] + 'JumpDown';

			currentAnim = anim;
			_animator.playbackSpeed = JUMP_SPEED;
			if (_isIntro) {
				_animator.play(currentAnim, null, 1);
				_animator.playbackSpeed = 0.2;
				setTimeout(stop, 3000);
			} else {
				_animator.play(currentAnim, _transition, 0);
				setTimeout(stop, 260);
			}
		}

		/**
		 * Character trow grenade
		 */
		private function trowGrenade(e : Event = null) : void {
			if (_isCrouch) {
				currentAnim = "CrouchGrenade";
				_animator.play(currentAnim, _transition, 0);
				setTimeout(stop, 2500);
			} else {
				currentAnim = "TrowGrenade";
				_animator.play(currentAnim, _transition, 0);
				setTimeout(stop, 2500);
			}
		}

		/**
		 * Key down listener 
		 */
		private function onKeyDown(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					_isRunning = true;
					if (_isMoving) updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
					// fr
					updateMovement(movementDirection = 1);
					// if (_physics){_physics.key_forward(true);}
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					updateMovement(movementDirection = -1);
					// if (_physics){_physics.key_Reverse(true);}
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
					// fr
					if (!_isMoving) updateMovementSide(1);
					// if (_physics){_physics.key_Left(true);}
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					if (!_isMoving) updateMovementSide(-1);
					// if (_physics){_physics.key_Right(true);}
					break;
				case Keyboard.R:
					reload();
					break;
				case Keyboard.O:
					switchWeapon();
					break;
				case Keyboard.G:
					trowGrenade();
					break;
				case Keyboard.I:
					fullScreen();
					break;
				case Keyboard.C:
				case Keyboard.CONTROL:
					if (_isCrouch) {
						_isCrouch = false;
						_cameraHeight = 100;
					} else if (!_isSwiming) {
						_isCrouch = true;
						_cameraHeight = 50;
					}
					stop();
					break;
				case Keyboard.SPACE:
					if (!_isJump) {
						jumpUp();
					}
					break;
			}
		}

		/**
		 * Key up listener
		 */
		private function onKeyUp(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					_isRunning = false;
					if (_isMoving)
						updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
				// fr
				case Keyboard.DOWN:
				case Keyboard.S:
					_isMoving = false;
					// if (_physics) { _physics.key_forward(false); _physics.key_Reverse(false);  }
					stop();
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
				// fr
				case Keyboard.RIGHT:
				case Keyboard.D:
					_isSideMove = false;
					// if (_physics) { _physics.key_Left(false); _physics.key_Right(false); }
					stop();
					break;
				case Keyboard.SPACE:
					_isJump = false;
					// if (_physics){_physics.key_Jump(false);}
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
		 * Stage listener for resize events
		 */
		private function onResize(event : Event = null) : void {
			_stage3DProxy.width = stage.stageWidth;
			_stage3DProxy.height = stage.stageHeight;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			if (!_isRender) onEnterFrame();
			_menu.y = stage.stageHeight;
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
		 * mesh listener for mouse over interaction
		 */
		private function onMeshMouseOver(e : MouseEvent3D) : void {
			Mesh(e.target).showBounds = true;
			_eyeLook.visible = true;
			onMeshMouseMove(e);
		}

		/**
		 * mesh listener for mouse out interaction
		 */
		private function onMeshMouseOut(e : MouseEvent3D) : void {
			Mesh(e.target).showBounds = false;
			_eyeLook.visible = false;
			_eyeLook.position = _eyePosition;
		}

		/**
		 * mesh listener for mouse move interaction
		 */
		private function onMeshMouseMove(e : MouseEvent3D) : void {
			_eyeLook.position = new Vector3D(e.localPosition.z + 6, e.localPosition.x, e.localPosition.y + 10);
		}

		/**
		 * Create dynamique eye follow mouse
		 */
		public function addHeroEye() : void {
			var eyeGeometry : SphereGeometry = new SphereGeometry(1, 32, 24);
			eyeGeometry.scaleUV(2, 1);
			_eyes = new ObjectContainer3D();
			_eyeR = new Mesh(eyeGeometry, _eyesOpenMaterial);
			_eyeR.castsShadows = false;
			_eyes.addChild(_eyeR);
			_eyeL = new Mesh(eyeGeometry, _eyesOpenMaterial);
			_eyeL.castsShadows = false;
			_eyes.addChild(_eyeL);
			_eyeR.z = _eyeL.z = 3.9;
			_eyeR.x = _eyeL.x = 5.6;
			_eyeR.y = 1.75;
			_eyeL.y = -1.75;
			_heroPieces.addChild(_eyes);
			_eyeLook = new Mesh(new PlaneGeometry(0.3, 0.3, 1, 1), new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0xffffff))));
			_eyeLook.rotationX = 90;
			_eyeLook.visible = false;
			var mat : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, true, 0x00ffffff)));
			mat.alphaBlending = true;
			var zone : Mesh = new Mesh(new PlaneGeometry(12, 6, 1, 1), mat);
			zone.castsShadows = false;
			zone.addEventListener(MouseEvent3D.MOUSE_MOVE, onMeshMouseMove);
			zone.addEventListener(MouseEvent3D.MOUSE_OVER, onMeshMouseOver);
			zone.addEventListener(MouseEvent3D.MOUSE_OUT, onMeshMouseOut);
			zone.mouseEnabled = true;
			zone.rotationX = 90;
			zone.rotationZ = 90;
			zone.z = 10;
			zone.x = 6;
			zone.y = 0.22;
			_eyeLook.z = 10.2;
			_eyeLook.x = 6;
			_eyeLook.y = 0.22;
			_eyePosition = _eyeLook.position;
			_eyes.addChild(zone);
			_eyes.addChild(_eyeLook);
			_isDynamicsEyes = true;
		}

		private function moveEyesSexe() : void {
			if (_isMan) {
				_eyeR.z = _eyeL.z = 3.9;
				_eyeR.x = _eyeL.x = 5.6;
			} else {
				_eyeR.z = _eyeL.z = 1.82;
				_eyeR.x = _eyeL.x = 4.75;
			}
		}

		/**
		 * Listene dynamique eye follow mouse
		 */
		private function updateEyes() : void {
			// get the head bone
			if (_animator.globalPose.numJointPoses >= 11) {
				_eyes.transform = _animator.globalPose.jointPoses[11].toMatrix3D();
			}
			// look
			_eyeR.lookAt(_eyeLook.position.add(new Vector3D(0, 1.4, 0)), new Vector3D(0, 1, 1));
			_eyeL.lookAt(_eyeLook.position.add(new Vector3D(0, -1.4, 0)), new Vector3D(0, 1, 1));

			// open close eye
			_eyeCount++;
			if (_eyeCount > 300) {
				if (_isMan) {
					_eyeR.material = _eyesClosedMaterial;
					_eyeL.material = _eyesClosedMaterial;
				} else {
					_eyeR.material = _eyesClosedSiaMaterial;
					_eyeL.material = _eyesClosedSiaMaterial;
				}
			}
			if (_eyeCount > 309) {
				_eyeR.material = _eyesOpenMaterial;
				_eyeL.material = _eyesOpenMaterial;
				_eyeCount = 0;
			}
		}

		/**
		 * Xray view debug bone
		 */
		private function xRay(e : Event = null) : void {
			var m : Mesh;
			var j : Sprite3D;
			if (!_isDebugRay) {
				_isDebugRay = true;
				_onkbaMaterial.alpha = 0.5;
				_siaMaterial.alpha = 0.5;
				_bonesFx = new Vector.<Mesh>(_animator.globalPose.numJointPoses);
				var mref0 : Mesh = new Mesh(new CubeGeometry(3, 0.3, 0.3), _boneMaterial);
				var mref : Mesh = new Mesh(new CubeGeometry(0.7, 0.7, 0.7), _boneMaterial);
				mref.addChild(mref0);
				mref0.x = 1.5;
				for (var i : int = 0; i < _animator.globalPose.numJointPoses; i++) {
					m = Mesh(mref.clone());
					j = new Sprite3D(materialBones("bone " + i), 4, 4);
					// _heroOnkba.addChild(m);
					// _player.addChild(m);
					Player.add(m);
					m.addChild(j);
					_bonesFx[i] = m;
				}
			} else {
				_isDebugRay = false;
				_onkbaMaterial.alpha = 1;
				_siaMaterial.alpha = 1;
				for ( i = 0; i < _bonesFx.length; i++) {
					m = _bonesFx[i];
					// _heroOnkba.removeChild(m);
					// _player.removeChild(m);
					Player.remove(m);
					m.dispose();
					_bonesFx[i] = null;
				}
			}
		}

		private function materialBones(name : String = 'bone') : TextureMaterial {
			var material : TextureMaterial;
			var g : BitmapData = new BitmapData(128, 128, true, 0x00000000);
			var d : Sprite = new Sprite();
			var txt : TextField = new TextField();
			txt.defaultTextFormat = new TextFormat("Verdana", 30, 0x00FF00);
			txt.width = 128;
			txt.height = 128;
			txt.selectable = false;
			txt.mouseEnabled = false;
			txt.wordWrap = true;
			txt.filters = [new DropShadowFilter(1, 45, 0x000000, 1, 4, 4, 2, 2)];
			d.addChild(txt);
			txt.htmlText = name;
			g.draw(d);
			material = new TextureMaterial(Cast.bitmapTexture(g));
			material.alphaBlending = true;
			return material;
		}

		private function updateBones() : void {
			for (var i : int = 0; i < _animator.globalPose.numJointPoses; i++) {
				_bonesFx[i].transform = _animator.globalPose.jointPoses[i].toMatrix3D();
			}
		}

		/**
		 * Interface
		 */
		private function initSetting() : void {
			_menu = new Sprite();
			addChild(_menu);
			_menu.y = stage.stageHeight;
			Style.setStyle("dark");
			Style.LABEL_TEXT = 0xffffff;
			Style.DROPSHADOW = 0x000000;
			Style.BACKGROUND = 0x000000;
			Style.BUTTON_FACE = 0x060606;
			Style.BUTTON_DOWN = 0x995522;
			Style.fontName = "Helvetica";
			Style.embedFonts = false;
			Style.fontSize = 11;
			new PushButton(_menu, 30, -29, ">", showSetting).setSize(30, 30);
			new PushButton(_menu, 65, -29, "WEAPON", switchWeapon).setSize(60, 30);
			new PushButton(_menu, 130, -29, "SHIRT", switchShirt).setSize(60, 30);
			new PushButton(_menu, 195, -29, "GENDER", switchGender).setSize(60, 30);
			new PushButton(_menu, 260, -29, "X-RAY", xRay).setSize(60, 30);
		}

		private function switchShirt(e : Event = null) : void {
			if (_isShirt) {
				Player.remove(_shirt);
				_isShirt = false;
			} else if (_isMan) {
				Player.add(_shirt);
				_isShirt = true;
			}
		}

		/**
		 * Man or woman character
		 */
		private function switchGender(e : Event = null) : void {
			if (_isMan) {
				Player.remove(_heroOnkba);
				Player.add(_heroSia);
				Player.add(_hair);
				// _player.removeChild(_heroOnkba);
				// _player.addChild(_heroSia);
				_isMan = false;
				switchShirt();
				moveEyesSexe();
			} else {
				Player.remove(_heroSia);
				Player.remove(_hair);
				Player.add(_heroOnkba);

				// _player.removeChild(_heroSia);
				// _player.addChild(_heroOnkba);
				_isMan = true;
				switchShirt();
				moveEyesSexe();
			}
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
			_text.wordWrap = true;
			_text.selectable = false;
			_text.mouseEnabled = true;
			_text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			addChild(_text);
		}

		/**
		 * Welcome message
		 */
		public function message() : String {
			var mes : String = "ARROW.WSAD.ZSQD - move\n";
			mes += "SHIFT - hold to run\n";
			mes += "R - reload weapon\n";
			mes += "C, Ctrl - crouch\n";
			mes += "O - next weapon\n";
			mes += "SPACE - jump\n";
			mes += "G - grenade\n\n";
			mes += "I - full screen\n";
			mes += "N - random sky\n";
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