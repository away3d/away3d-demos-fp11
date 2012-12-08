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
	import away3d.cameras.lenses.PerspectiveLens;
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
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.system.System;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.events.Event;

	import physics.OimoPhysics;

	import com.bit101.components.Style;
	import com.bit101.components.PushButton;
	import com.bit101.components.Component;

	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class Demo_Physics extends Sprite {
		// engine variables
		private var _view : View3D;
		private var _stats : AwayStats;
		// Stage manager and Stage3D instance proxy classes
		private var _stage3DManager : Stage3DManager;
		private var _stage3DProxy : Stage3DProxy;
		// scene objects
		private var _sphere : Mesh;
		private var _sphere2 : Mesh;
		private var _cube : Mesh;
		private var _sunLight : DirectionalLight;
		private var _lightPicker : StaticLightPicker;
		private var _cameraController : HoverController;
		private var _shadowMethod : NearShadowMapMethod;
		// material
		private var _material01 : TextureMaterial;
		private var _material02 : TextureMaterial;
		private var _material03 : TextureMaterial;
		private var _material04 : TextureMaterial;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		// other
		private var _menu : Sprite;
		private var _text : TextField;
		private var _currentDemo : uint;
		private var _maxDemo : uint;

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
			_currentDemo = 0;
			_maxDemo = 2;
			initEngine();
			initText();
			initSetting();
			initLights();
			initOimoPhysics();
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
			_view.camera.lens = new PerspectiveLens(80);
			_view.camera.lens.far = 6000;
			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 0, 80, 1300, 10, 9);
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
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.5);
			_view.scene.addChild(_sunLight);

			_lightPicker = new StaticLightPicker([_sunLight]);
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			// _shadowMethod.epsilon = .0007;
		}

		/**
		 * Initialise scene materials
		 */
		private function initMaterials() : void {
			// setup material
			_material01 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x44888888)));
			_material01.alphaBlending = true;
			_material01.bothSides = true;
			_material01.gloss = 100;
			_material01.specular = 0.5;

			_material02 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x8800A0C8)));
			_material02.alphaBlending = true;
			_material02.gloss = 30;
			_material02.specular = 1;

			_material03 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x88F9642D)));
			_material03.alphaBlending = true;
			_material03.bothSides = true;
			_material03.gloss = 30;
			_material03.specular = 1;

			_material04 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x887CD8EF)));
			_material04.alphaBlending = true;
			_material04.gloss = 30;
			_material04.specular = 1;

			_material01.lightPicker = _lightPicker;
			_material02.lightPicker = _lightPicker;
			_material03.lightPicker = _lightPicker;
			_material04.lightPicker = _lightPicker;

			_material01.shadowMethod = _shadowMethod;
			_material02.shadowMethod = _shadowMethod;
			_material03.shadowMethod = _shadowMethod;
			_material04.shadowMethod = _shadowMethod;
		}

		/**
		 * Initialise OimoPhysics engine
		 */
		private function initOimoPhysics() : void {
			OimoPhysics.getInstance();
			OimoPhysics.scene = _view.scene;
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

			switch(_currentDemo) {
				case 0 :
					OimoPhysics.demoName = '0 - Push the limite';
					OimoPhysics.gravity(-9.8);
					var ground : Mesh = new Mesh(new CubeGeometry(1000, 100, 1000), _material01);
					var wall0 : Mesh = new Mesh(new CubeGeometry(50, 600, 1000), _material01);
					var wall1 : Mesh = new Mesh(new CubeGeometry(50, 600, 1000), _material01);
					var wall2 : Mesh = new Mesh(new CubeGeometry(1000, 600, 50), _material01);
					var wall3 : Mesh = new Mesh(new CubeGeometry(1000, 600, 50), _material01);
					ground.castsShadows = false;
					wall0.castsShadows = false;
					wall1.castsShadows = false;
					wall2.castsShadows = false;
					wall3.castsShadows = false;
					OimoPhysics.addCube(ground, 1000, 100, 1000, new Vector3D(0, 0, 0));
					OimoPhysics.addCube(wall0, 50, 600, 1000, new Vector3D(500, 300, 0));
					OimoPhysics.addCube(wall1, 50, 600, 1000, new Vector3D(-500, 300, 0));
					OimoPhysics.addCube(wall2, 1000, 600, 50, new Vector3D(0, 300, -500));
					OimoPhysics.addCube(wall3, 1000, 600, 50, new Vector3D(0, 300, 500));
					// the big sphere
					_sphere = new Mesh(new SphereGeometry(150, 30, 20), _material04);
					OimoPhysics.addSphere(_sphere, 150, new Vector3D(0, 500, 0), 0, null, 1, 0.5, 0.5, false);
					// reference mesh for clone
					_sphere2 = new Mesh(new SphereGeometry(32), _material02);
					_cube = new Mesh(new CubeGeometry(50, 50, 50), _material03);
					for ( i = 0;i < 500;i++) {
						m = Mesh(_sphere2.clone());
						OimoPhysics.addSphere(m, 32, new Vector3D(-100, 50 + (100 * i), 100), 0, null, 1, 0.5, 0.5, false);
					}
					for (i = 0;i < 500;i++) {
						m = Mesh(_cube.clone());
						OimoPhysics.addCube(m, 50, 50, 50, new Vector3D(100, 50 + (100 * i), - 100), 0, null, 1, 0.5, 0.5, false);
					}
					break;
				case 1 :
					OimoPhysics.demoName = '1 - The tower stack';
					OimoPhysics.gravity(-9.8);
					height = 20;
					bw = 60;
					bh = 75;
					bd = 120;
					var ground01 : Mesh = new Mesh(new CubeGeometry(1000, 30, 1000), _material01);
					OimoPhysics.addCube(ground01, 1000, 10, 1000, new Vector3D(0, -10, 0));
					var bbox : Mesh = new Mesh(new CubeGeometry(bw, bh, bd), _material03);
					for ( j = 0; j < height; j++) {
						for (i = 0; i < 10; i++) {
							var ang : Number = Math.PI * 2 / 10 * (i + (j & 1) * 0.5);
							m = Mesh(bbox.clone());
							OimoPhysics.addCube(m, bw, bh, bd, new Vector3D(Math.cos(ang) * 250, j * bh + bh * 0.5, Math.sin(ang) * 250), ang, new Vector3D(0, 1, 0), 1, 0.5, 0.5, false);
						}
					}
					break;
				case 2 :
					OimoPhysics.demoName = '2 - The pyramid stack';
					OimoPhysics.gravity(-9.8);
					width = 20;
					bw = 80;
					bh = 50;
					bd = 70;
					var ground02 : Mesh = new Mesh(new CubeGeometry(2000, 30, 1000), _material01);
					OimoPhysics.addCube(ground02, 2000, 10, 1000, new Vector3D(0, -10, 0));
					var pbox : Mesh = new Mesh(new CubeGeometry(bw, bh, bd), _material03);
					for (i = 0; i < width; i++) {
						for (j = i; j < width; j++) {
							m = Mesh(pbox.clone());
							OimoPhysics.addCube(m, bw, bh, bd, new Vector3D(((j - i * 0.5 - (width - 1) * 0.5) * bw * 1.1), (i * bh * 1.1 + bh * 0.5), 0), 0, null, 1, 0.5, 0.5, false);
						}
					}
					// the big sphere
					_sphere = new Mesh(new SphereGeometry(150, 30, 20), _material04);
					OimoPhysics.addSphere(_sphere, 150, new Vector3D(0, 2000, 0), 0, null, 5, 0.3, 0.2, false);
					break;
				case 3 :
					OimoPhysics.demoName = '3 - Compound shapes';
					break;
				case 4 :
					OimoPhysics.demoName = '4 - Dominoes days';
					break;
				case 5 :
					OimoPhysics.demoName = '5 - Spining tops';
					break;
			}
		}

		/**
		 * Initialise Listener
		 */
		private function initListeners(e : Event = null) : void {
			_stage3DProxy.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
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
		private function _onEnterFrame(e : Event) : void {
			if (_sunLight.ambient < 0.3) _sunLight.ambient += 0.003;
			if (_sunLight.specular < 1) _sunLight.specular += 0.01;
			if (_sunLight.diffuse < 1) _sunLight.diffuse += 0.01;
			OimoPhysics.update();
			log(OimoPhysics.info());
			_cameraController.update();
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
		}

		private function showSetting(e : Event) : void {
		}

		private function prevDemo(e : Event) : void {
			OimoPhysics.clean();
			if (_currentDemo == 0) _currentDemo = _maxDemo;
			else _currentDemo--;
			initSceneObject();
		}

		private function nextDemo(e : Event) : void {
			OimoPhysics.clean();
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
