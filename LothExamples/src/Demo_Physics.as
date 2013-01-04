/*

Basic Oimophysic physics 

Demonstrates:

How initialise and use oimophysic in away3d.

Code by LoTh
3dflashlo@gmail.com
http://3dflashlo.wordpress.com
Oimophysic by Saharan
http://el-ement.com

This code is distributed under the MIT License

Copyright (c) The Away Foundation http://www.theawayfoundation.org

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
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.lights.DirectionalLight;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.system.System;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.utils.setTimeout;

	import physics.OimoEngine;

	import utils.AutoSky;
	import utils.LoaderPool;
	import utils.AutoMapPhysics;

	// import games.Particules;
	import com.bit101.components.Style;
	import com.bit101.components.PushButton;
	import com.bit101.components.Component;
	import com.bit101.components.HUISlider;

	[SWF(backgroundColor="#000000", frameRate="60", width = "1200", height = "600")]
	public class Demo_Physics extends Sprite {
		// engine variables
		private var _view : View3D;
		private var _stats : AwayStats;
		// Stage manager and Stage3D instance proxy classes
		private var _stage3DManager : Stage3DManager;
		private var _stage3DProxy : Stage3DProxy;
		// scene objects
		private var _sphere : Mesh;
		private var _sunLight : DirectionalLight;
		private var _lightPicker : StaticLightPicker;
		private var _cameraController : HoverController;
		// material methode
		private var _shadowMethod : NearShadowMapMethod;
		private var _rimLightMethod : RimLightMethod;
		private var _fogMethode : FogMethod;
		private var _reflectionMethod : EnvMapMethod;
		// material
		private var _material01 : TextureMaterial;
		private var _materialEyeBall : TextureMaterial;
		private var _materialBoxeDice : TextureMaterial;
		private var _materialBoxeBrick : TextureMaterial;
		private var _materials : Vector.<TextureMaterial>;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		// other
		private var _text : TextField;
		private var _currentDemo : uint;
		private var _maxDemo : uint;
		private var _bitmaps : Vector.<BitmapData>;
		// ui
		private var _menu : Sprite;
		private var _sliderGravity : HUISlider;

		/**
		 * Constructor
		 */
		public function Demo_Physics() {
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
			_currentDemo = 0;
			_maxDemo = 4;

			initEngine();
			initText();
			initSetting();
			initLights();
			initOimoPhysics();

			// random sky map
			var skyN : uint = uint(1 + Math.random() * 14);

			// kickoff asset loading
			var bitmapStrings : Vector.<String> = new Vector.<String>();
			bitmapStrings.push("sky/pano_" + skyN + ".jpg", "sky/up_" + skyN + ".jpg");

			LoaderPool.log = log;
			LoaderPool.loadBitmaps(bitmapStrings, initAfterBitmapLoad);
			_bitmaps = LoaderPool.bitmaps;

			/*initMaterials();
			 */
			
			/*Particules.getInstance();
			Particules.scene = _view.scene;
			Particules.initParticlesTrail();*/
		}

		/**
		 * Initialise the scene objects
		 */
		private function initAfterBitmapLoad() : void {
			// create skybox
			randomSky();

			// create material
			initMaterials();

			initSceneObject();
			initListeners();
		}

		/**
		 * Initialise the engine
		 */
		private function initEngine() : void {
			_view = new View3D();
			_view.stage3DProxy = _stage3DProxy;
			_view.shareContext = true;
			addChild(_view);
			// setup the camera
			_view.camera.lens = new PerspectiveLens(70);
			_view.camera.lens.far = 20000;
			_view.camera.lens.near = 0.1;
			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 0, 80, 2000, 10, 9);
			_cameraController.minTiltAngle = -90;
			_cameraController.maxTiltAngle = 90;
			_cameraController.autoUpdate = false;
			_cameraController.lookAtPosition = new Vector3D(0, 300, 0);

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
			// create a light for shadows that mimics the sun's position in the skybox
			_sunLight = new DirectionalLight(-0.5, -1, 0.3);
			_sunLight.color = 0xffffff;
			_sunLight.ambientColor = 0xffffff;
			_sunLight.ambient = 0;
			_sunLight.diffuse = 0;
			_sunLight.specular = 0;

			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.3);
			_view.scene.addChild(_sunLight);

			_lightPicker = new StaticLightPicker([_sunLight]);
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			
			// _shadowMethod.epsilon = .0007;
		}

		/**
		 * Create random sky 
		 */
		private function randomSky(e : Event = null) : void {
			AutoSky.scene = _view.scene;
			AutoSky.randomSky(null, _bitmaps, 8);
		    if (_fogMethode != null) _fogMethode.fogColor = AutoSky.fogColor;
			if (_rimLightMethod != null) _rimLightMethod.color = AutoSky.fogColor;
			if (_reflectionMethod != null) _reflectionMethod.envMap = AutoSky.skyMap;
		}

		/**
		 * Initialise scene materials
		 */
		private function initMaterials() : void {
			// methodes
			_rimLightMethod = new RimLightMethod(AutoSky.fogColor, 0.5, 2, RimLightMethod.ADD);
			_reflectionMethod = new EnvMapMethod(AutoSky.skyMap, 0.4);
			_fogMethode = new FogMethod(300, 20000, AutoSky.fogColor);
			
			_materials = new Vector.<TextureMaterial>();

			_material01 = new TextureMaterial(Cast.bitmapTexture(AutoMapPhysics.bitmapCube(0x606060, 0x333333, false, [0.8, 0.1])));
			// _material01 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x44888888)));
			_material01.alphaBlending = true;
			_material01.gloss = 100;
			_material01.specular = 0.5;
			_materials[0] = _material01;

			_materialBoxeBrick = new TextureMaterial(Cast.bitmapTexture(AutoMapPhysics.bitmapCube(0xB7502F, 0x6A2E23, false, [1, 1])));
			// _materialBoxeBrick.alphaBlending = true;
			_materialBoxeBrick.gloss = 40;
			_materialBoxeBrick.specular = 1;
			_materials[1] = _materialBoxeBrick;

			_materialBoxeDice = new TextureMaterial(Cast.bitmapTexture(AutoMapPhysics.bitmapCube(0xEFEFEF, 0xAAAAAA, true, [1, 1])));
			// _materialBoxeDice.alphaBlending = true;
			_materialBoxeDice.gloss = 30;
			_materialBoxeDice.specular = 1;
			_materialBoxeDice.addMethod(_reflectionMethod);
			_materials[2] = _materialBoxeDice;

			_materialEyeBall = new TextureMaterial(Cast.bitmapTexture(AutoMapPhysics.bitmapEyeBall()));
			// _materialEyeBall.alphaBlending = true;
			_materialEyeBall.gloss = 30;
			_materialEyeBall.specular = 1;
			_materialEyeBall.addMethod(_reflectionMethod);
			_materials[3] = _materialEyeBall;

			// for all material
			for (var i : int; i < _materials.length; i++ ) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 1;
				
				if (i != 0) _materials[i].addMethod(_rimLightMethod);
				 _materials[i].addMethod(_fogMethode);
			}

			stage.quality = StageQuality.LOW;
		}

		/**
		 * Initialise OimoPhysics engine
		 */
		private function initOimoPhysics() : void {
			OimoEngine.getInstance();
			OimoEngine.scene = _view.scene;
		}

		/**
		 * Initialise scene object3d
		 */
		private function initSceneObject() : void {
			var i : uint;
			var j : uint;
			var height : uint;
			var width : uint;
			var bw : Number;
			var bh : Number;
			var bd : Number;
			var m : Mesh;
			var px : int, py : int, pz : int;
			var cube : Mesh;
			var sphere : Mesh;

			switch(_currentDemo) {
				case 0 :
					OimoEngine.demoName = '0 - In the box';
					OimoEngine.gravity(-1);
					var ground : Mesh = new Mesh(new CubeGeometry(2000, 50, 2000), _material01);
					var wall0 : Mesh = new Mesh(new CubeGeometry(50, 600, 1000), _material01);
					var wall1 : Mesh = new Mesh(new CubeGeometry(50, 600, 1000), _material01);
					var wall2 : Mesh = new Mesh(new CubeGeometry(950, 600, 50), _material01);
					var wall3 : Mesh = new Mesh(new CubeGeometry(950, 600, 50), _material01);
					ground.castsShadows = false;
					wall0.castsShadows = false;
					wall1.castsShadows = false;
					wall2.castsShadows = false;
					wall3.castsShadows = false;
					OimoEngine.addCube(ground, 2000, 50, 2000, new Vector3D(0, -25, 0));
					OimoEngine.addCube(wall0, 50, 600, 1000, new Vector3D(501, 300, 0));
					OimoEngine.addCube(wall1, 50, 600, 1000, new Vector3D(-501, 300, 0));
					OimoEngine.addCube(wall2, 950, 600, 50, new Vector3D(0, 300, -475));
					OimoEngine.addCube(wall3, 950, 600, 50, new Vector3D(0, 300, 475));
					// the big sphere
					_sphere = new Mesh(new SphereGeometry(150, 30, 20), _materialEyeBall);
					_sphere.geometry.scaleUV(2, 1);
					OimoEngine.addSphere(_sphere, 150, new Vector3D(0, 20000, 0), null, 1, 0.5, 0.5, false);
					// reference mesh for clone
					sphere = new Mesh(new SphereGeometry(50), _materialEyeBall);
					sphere.geometry.scaleUV(2, 1);
					for ( i = 0;i < 200;++i) {
						px = -400 + (Math.random() * 800);
						py = 600 + (100 * i);
						pz = -400 + (Math.random() * 800);
						m = Mesh(sphere.clone());
						OimoEngine.addSphere(m, 50, new Vector3D(px, py, pz), null, 1, 0.5, 0.5, false);
					}
					cube = new Mesh(new CubeGeometry(100, 100, 100), _materialBoxeDice);
					for (i = 0;i < 200;++i) {
						px = -400 + (Math.random() * 800);
						py = 600 + (100 * i);
						pz = -400 + (Math.random() * 800);
						m = Mesh(cube.clone());
						OimoEngine.addCube(m, 100, 100, 100, new Vector3D(px, py, pz), null, 1, 0.5, 0.5, false);
					}
					break;
				case 1 :
					OimoEngine.demoName = '1 - Tower stack destroy';
					OimoEngine.gravity(-0.9);
					height = 40;
					bw = 75;
					bh = 75;
					bd = 120;
					cube = new Mesh(new CubeGeometry(2000, 100, 2000), _material01);
					OimoEngine.addCube(cube, 2000, 100, 2000, new Vector3D(0, -50, 0), null, 1, 0.5, 0.5, true);
					cube = new Mesh(new CubeGeometry(bw, bh, bd), _materialBoxeBrick);
					for ( j = 0; j < height; ++j) {
						for (i = 0; i < 10; ++i) {
							var ang : Number = (Math.PI * 2 / 10 * (i + (j & 1) * 0.5));
							m = Mesh(cube.clone());
							OimoEngine.addCube(m, bw, bh, bd, new Vector3D(Math.cos(ang) * 250, j * bh + bh * 0.5, - Math.sin(ang) * 250), new Vector3D(0, ang, 0), 1, 0.8, 0.5, false);
						}
					}
					// the big sphere
					_sphere = new Mesh(new SphereGeometry(250, 30, 20), _materialEyeBall);
					_sphere.geometry.scaleUV(2, 1);
					OimoEngine.addSphere(_sphere, 250, new Vector3D(0, 20000, 0), null, 1, 0.5, 0.8, false);
					break;
				case 2 :
					OimoEngine.demoName = '2 - Pyramid stack destroy';
					OimoEngine.gravity(-0.9);
					width = 20;
					bw = 80;
					bh = 80;
					bd = 80;
					var ground02 : Mesh = new Mesh(new CubeGeometry(3000, 100, 3000), _material01);
					OimoEngine.addCube(ground02, 3000, 100, 3000, new Vector3D(0, -50, 0), null, 1, 1, 0.5, true);
					cube = new Mesh(new CubeGeometry(bw, bh, bd), _materialBoxeDice);
					for (i = 0; i < width; i++) {
						for (j = i; j < width; ++j) {
							m = Mesh(cube.clone());
							OimoEngine.addCube(m, bw, bh, bd, new Vector3D(((j - i * 0.5 - (width - 1) * 0.5) * bw * 1.1), (i * bh * 1.1 + bh * 0.5), 160), null, 1, 0.5, 0.5, false);
						}
					}
					for (i = 0; i < width; i++) {
						for (j = i; j < width; ++j) {
							m = Mesh(cube.clone());
							OimoEngine.addCube(m, bw, bh, bd, new Vector3D(((j - i * 0.5 - (width - 1) * 0.5) * bw * 1.1), (i * bh * 1.1 + bh * 0.5), -160), null, 1, 0.5, 0.5, false);
						}
					}
					// the big sphere
					_sphere = new Mesh(new SphereGeometry(200, 30, 20), _materialEyeBall);
					_sphere.geometry.scaleUV(2, 1);
					OimoEngine.addSphere(_sphere, 200, new Vector3D(0, 2000, 0), null, 1, 0.5, 0.8, false);
					break;
				case 3 :
					OimoEngine.gravity(-0.9);
					OimoEngine.demoName = '3 - Joint Test';
					var ground03 : Mesh = new Mesh(new CubeGeometry(3000, 100, 3000), _material01);
					OimoEngine.addCube(ground03, 3000, 100, 3000, new Vector3D(0, -50, 0), null, 1, 0.5, 0.5, true);
					var spherex : Mesh = new Mesh(new SphereGeometry(100, 30, 28), _materialEyeBall);
					spherex.geometry.scaleUV(2, 1);
					for ( i = 0;i < 100;i++) {
						m = Mesh(spherex.clone());
						OimoEngine.addSphere(m, 100, new Vector3D(-100, 100 + (100 * i), 100), null, 1, 0.5, 0.5, false);
						OimoEngine.addDistanceJoint(OimoEngine.rigids[i], OimoEngine.rigids[i + 1], 200);
					}
					break;
				case 4 :
					OimoEngine.demoName = '4 - Car test';
					OimoEngine.gravity(0);
					var ground04 : Mesh = new Mesh(new CubeGeometry(10000, 500, 10000), _material01);
					OimoEngine.addCube(ground04, 10000, 500, 10000, new Vector3D(0, -250, 0), null, 1, 0.5, 0.5, true);
					var ground05 : Mesh = new Mesh(new CubeGeometry(10000, 500, 10000), _material01);
					OimoEngine.addCube(ground05, 10000, 500, 10000, new Vector3D(0, 2000, -9000), new Vector3D(35, 0, 0), 1, 0.5, 0.5, true);
					var ground06 : Mesh = new Mesh(new CubeGeometry(10000, 500, 500), _material01);
					OimoEngine.addCube(ground06, 10000, 500, 500, new Vector3D(0, 250, 5000), null, 1, 0.5, 0.5, true);
					_sphere = new Mesh(new SphereGeometry(250, 30, 20), _materialEyeBall);
					_sphere.geometry.scaleUV(2, 1);
					OimoEngine.addSphere(_sphere, 250, new Vector3D(0, 5000, 0), null, 1, 0.5, 0.8, false);
					var chassie : Mesh = new Mesh(new CubeGeometry(200, 50, 300), _materialBoxeBrick);
					var wheel : Mesh = new Mesh(new SphereGeometry(60, 30, 30), _materialEyeBall);
					wheel.geometry.scaleUV(2, 1);
					var posy : int = 5000;
					var posz : int = -10000;
					var chassieRef : uint;
					for ( i = 1;i < 100;++i) {
						py = 200 * i;
						px = int(-4000 + (Math.random() * 8000));
						OimoEngine.addCube(Mesh(chassie.clone()), 200, 50, 300, new Vector3D(px, posy + py, posz), null, 1, 0.5, 0.5, false);
						chassieRef = OimoEngine.rigids.length - 1;
						OimoEngine.addSphere(Mesh(wheel.clone()), 60, new Vector3D(-100 + px, posy + py, 150 + posz), null, 1, 0.5, 0.5, false);
						OimoEngine.addBallJoint(OimoEngine.rigids[chassieRef], OimoEngine.rigids[OimoEngine.rigids.length - 1], false, new Vector3D(-100, 0, 150));
						OimoEngine.addSphere(Mesh(wheel.clone()), 60, new Vector3D(100 + px, posy + py, 150 + posz), null, 1, 0.5, 0.5, false);
						OimoEngine.addBallJoint(OimoEngine.rigids[chassieRef], OimoEngine.rigids[OimoEngine.rigids.length - 1], false, new Vector3D(100, 0, 150));
						OimoEngine.addSphere(Mesh(wheel.clone()), 60, new Vector3D(-100 + px, posy + py, -150 + posz), null, 1, 0.5, 0.5, false);
						OimoEngine.addBallJoint(OimoEngine.rigids[chassieRef], OimoEngine.rigids[OimoEngine.rigids.length - 1], false, new Vector3D(-100, 0, -150));
						OimoEngine.addSphere(Mesh(wheel.clone()), 60, new Vector3D(100 + px, posy + py, -150 + posz), null, 1, 0.5, 0.5, false);
						OimoEngine.addBallJoint(OimoEngine.rigids[chassieRef], OimoEngine.rigids[OimoEngine.rigids.length - 1], false, new Vector3D(100, 0, -150));
					}
					setTimeout(applyG, 260);
					break;
				case 5 :
					OimoEngine.demoName = '5 - Spining tops';
					var groundx : Mesh = new Mesh(new CubeGeometry(1000, 1000, 1000), _materialBoxeDice);
					OimoEngine.addCube(groundx, 1000, 1000, 1000, new Vector3D(0, -250, 0), null, 1, 0.5, 0.5, true);
					break;
			}
		}

		private function applyG(e : Event = null) : void {
			OimoEngine.gravity(-0.9);
		}

		/**
		 * Initialise Listener
		 */
		private function initListeners(e : Event = null) : void {
			_stage3DProxy.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			onResize();
		}

		/**
		 * render loop
		 */
		private function onEnterFrame(e : Event) : void {
			if (_sunLight.ambient < 0.3) _sunLight.ambient += 0.003;
			if (_sunLight.specular < 1) _sunLight.specular += 0.01;
			if (_sunLight.diffuse < 1) _sunLight.diffuse += 0.01;

			//OimoEngine.update();
			log(OimoEngine.info());

			_cameraController.update();

			/*if(_sphere){
			Particules.followTarget1.transform = _sphere.transform;
			Particules.followTarget2.transform = _sphere.transform;
			}*/

			_view.render();
		}

		/**
		 * stage listener for resize events
		 */
		private function onResize(event : Event = null) : void {
			_stage3DProxy.width = stage.stageWidth;
			_stage3DProxy.height = stage.stageHeight;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			_menu.y = stage.stageHeight;
		}

		private function onStageMouseDown(e : MouseEvent) : void {
			if (e.stageY > stage.stageHeight - 30) return;
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
			_mouseMove = true;
		}

		private function onStageMouseUp(e : Event) : void {
			_mouseMove = false;
		}

		private function onStageMouseLeave(e : Event) : void {
			_mouseMove = false;
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
		 * Interface button
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
			new PushButton(_menu, 65, -29, "prev", prevDemo).setSize(60, 30);
			new PushButton(_menu, 130, -29, "next", nextDemo).setSize(60, 30);
			new PushButton(_menu, 130+65, -29, "sky", randomSky).setSize(60, 30);

			_sliderGravity = new HUISlider(_menu, 270, -32, "Gravity", setGravity);
			_sliderGravity.labelPrecision = 2;
			_sliderGravity.minimum = -1;
			_sliderGravity.maximum = 1;
			_sliderGravity.tick = 0.01;
			_sliderGravity.value = -1;
		}

		private function setGravity(e : Event) : void {
			OimoEngine.gravity(_sliderGravity.value);
		}

		private function showSetting(e : Event) : void {
		}

		private function prevDemo(e : Event) : void {
			OimoEngine.clean();
			if (_currentDemo == 0) _currentDemo = _maxDemo;
			else _currentDemo--;
			initSceneObject();
		}

		private function nextDemo(e : Event) : void {
			OimoEngine.clean();
			if (_currentDemo == _maxDemo) _currentDemo = 0;
			else _currentDemo++;
			initSceneObject();
		}

		/**
		 * Initialise interface 
		 */
		private function initText() : void {
			_text = new TextField();
			var format : TextFormat = new TextFormat("Helvetica", 9, 0xdddddd);
			format.letterSpacing = 1;
			format.leftMargin = 5;
			format.leading = 1;
			_text.defaultTextFormat = format;
			_text.y = 5;
			_text.width = 300;
			_text.height = 250;
			_text.selectable = false;
			_text.mouseEnabled = true;
			_text.wordWrap = true;
			addChild(_text);
		}

		/**
		 * Display text
		 */
		private function log(t : String) : void {
			_text.htmlText = t;
		}
	}
}
