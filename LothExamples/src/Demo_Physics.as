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

	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class Demo_Physics extends Sprite {
		// engine variables
		private var _view : View3D;
		private var _text : TextField;
		private var _stats : AwayStats;
		// Stage manager and Stage3D instance proxy classes
		private var _stage3DManager : Stage3DManager;
		private var _stage3DProxy : Stage3DProxy;
		// scene objects
		private var _plane : Mesh;
		private var _sphere : Mesh;
		private var _sphere2 : Mesh;
		private var _cube : Mesh;
		private var _sunLight : DirectionalLight;
		private var _lightPicker : StaticLightPicker;
		private var _cameraController : HoverController;
		private var _shadowMethod : NearShadowMapMethod;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		private var _isResize : Boolean;

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
			initText();

			// create the view
			_view = new View3D();
			_view.stage3DProxy = _stage3DProxy;
			_view.shareContext = true;
			addChild(_view);
			_view.camera.lens.far = 3000;
			addChild(_view);

			// add stats
			addChild(_stats = new AwayStats(_view, false, true));
			_stats.x = stage.stageWidth - _stats.width - 5;
			_stats.alpha = 0.5;
			_stats.y = 2;

			// setup the light
			initLights();
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			// _shadowMethod.epsilon = .0007;

			// setup material
			var material01 : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x10888888)));
			material01.alphaBlending = true;
			material01.gloss = 100;
			material01.specular = 0.3;

			var material02 : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x60ffaa88)));
			material02.alphaBlending = true;
			material02.gloss = 100;
			material02.specular = 0.8;

			var material03 : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x6033aaff)));
			material03.alphaBlending = true;
			material03.gloss = 30;
			material03.specular = 0.3;

			material01.lightPicker = _lightPicker;
			material02.lightPicker = _lightPicker;
			material03.lightPicker = _lightPicker;

			material01.shadowMethod = _shadowMethod;
			material02.shadowMethod = _shadowMethod;
			material03.shadowMethod = _shadowMethod;

			// setup the camera
			_view.camera.lookAt(new Vector3D());
			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 0, 80, 1000, 10, 9);
			_cameraController.minTiltAngle = -90;
			_cameraController.maxTiltAngle = 90;
			_cameraController.autoUpdate = false;
			// setup the scene
			_plane = new Mesh(new CubeGeometry(1000, 30, 1000), material01);
			_view.scene.addChild(_plane);
			var wall0 : Mesh = new Mesh(new CubeGeometry(30, 600, 1000), material01);
			_view.scene.addChild(wall0);
			var wall1 : Mesh = new Mesh(new CubeGeometry(30, 600, 1000), material01);
			_view.scene.addChild(wall1);
			var wall2 : Mesh = new Mesh(new CubeGeometry(1000, 600, 30), material01);
			_view.scene.addChild(wall2);
			var wall3 : Mesh = new Mesh(new CubeGeometry(1000, 600, 30), material01);
			_view.scene.addChild(wall3);
			wall0.castsShadows = false;
			wall1.castsShadows = false;
			wall2.castsShadows = false;
			wall3.castsShadows = false;
			_plane.castsShadows = false;

			// setup physic engine
			OimoPhysics.getInstance();
			OimoPhysics.addCube(_plane, 1000, 10, 1000, 0, 15, 0);
			OimoPhysics.addCube(wall0, 30, 600, 1000, 500, 300, 0);
			OimoPhysics.addCube(wall1, 30, 600, 1000, -500, 300, 0);
			OimoPhysics.addCube(wall2, 1000, 600, 30, 0, 300, -500);
			OimoPhysics.addCube(wall3, 1000, 600, 30, 0, 300, 500);

			// the big sphere
			_sphere = new Mesh(new SphereGeometry(150), material03);
			OimoPhysics.addSphere(_sphere, 150, 0, 500, 0, 10, 600.0, false);
			_view.scene.addChild(_sphere);

			// reference mesh for clone
			_sphere2 = new Mesh(new SphereGeometry(32), material02);
			_cube = new Mesh(new CubeGeometry(50, 50, 50), material03);

			var m : Mesh;
			for (var i : uint = 0;i < 500;i++) {
				m = Mesh(_sphere2.clone());
				_view.scene.addChild(m);
				OimoPhysics.addSphere(m, 32, -100, 50 + (100 * i), 100, 10, 0.0, false);
			}

			for (i = 0;i < 500;i++) {
				m = Mesh(_cube.clone());
				_view.scene.addChild(m);
				OimoPhysics.addCube(m, 50, 50, 50, 100, 50 + (100 * i), - 100, 10, 0.0, false);
			}

			// setup the render loop
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
			OimoPhysics.update();
			log(OimoPhysics.info());
			_cameraController.update();

			if (_isResize) _isResize = false;
			else _view.render();
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
		}

		/**
		 * Initialise the lights
		 */
		private function initLights() : void {
			// create a light for shadows that mimics the sun's position in the skybox
			_sunLight = new DirectionalLight(1, 1, -1);
			_sunLight.color = 0xffffff;
			_sunLight.ambientColor = 0xffffff;
			_sunLight.ambient = 0.3;
			_sunLight.diffuse = 1;
			_sunLight.specular = 1;

			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.5);
			_view.scene.addChild(_sunLight);

			_lightPicker = new StaticLightPicker([_sunLight]);
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
			// stopListeners();
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
