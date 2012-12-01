/*

AVATAR

Demonstrates:

How to use the Loader3D object to load an embedded internal awd model.
How to limite size of AWD export by using away3d clone.
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
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.animators.data.Skeleton;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.materials.TextureMaterial;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.events.LoaderEvent;
	import away3d.containers.View3D;
	import away3d.events.AssetEvent;
	import away3d.loaders.Loader3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;
	import away3d.primitives.*;

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
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.system.System;

	import utils.AutoMapSky;
	import utils.LoaderPool;

	[SWF(backgroundColor="#000000", frameRate="60")]
	public class Demo_Simple extends Sprite {
		private const FARVIEW : Number = 128 * 100;
		private const FOGNEAR : Number = 400;
		private var _bitmapStrings : Vector.<String>;
		private var _bitmaps : Vector.<BitmapData>;
		private var sunColor : uint = 0xFFFFFF;
		private var skyColor : uint = 0x9090ee;
		private var fogColor : uint = 0xd3eef9;
		private var groundColor : uint = 0xd3eef9;
		// Stage manager and Stage3D instance proxy classes
		private var _stage3DManager : Stage3DManager;
		private var _stage3DProxy : Stage3DProxy;
		// engine variables
		private var _view : View3D;
		private var _stats : AwayStats;
		private var _lightPicker : StaticLightPicker;
		private var _cameraController : HoverController;
		// light variables
		private var _night : Number = 100;
		private var _sunLight : DirectionalLight;
		private var _fogMethode : FogMethod;
		private var _shadowMethod : NearShadowMapMethod;
		// Materials
		private var _materials : Vector.<TextureMaterial>;
		private var _terrainMaterial : TextureMaterial;
		private var _simpleMaterial : TextureMaterial;
		// scene objects
		private var _ground : Mesh;
		private var _skinMesh : Vector.<Mesh>;
		// Avatar structure
		private var _squeleton : Skeleton;
		private var _animationSet : SkeletonAnimationSet;
		// away3d dev
		private var transition : CrossfadeTransition = new CrossfadeTransition(0.25);
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		private var _isIntro : Boolean = true;
		private var _isRender : Boolean;
		private var _text : TextField;
		private var _capture : BitmapData;
		private var _topPause : Sprite;

		/**
		 * Constructor
		 */
		public function Demo_Simple() {
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
		 * Initialise the scene objects
		 */
		private function initAfterBitmapLoad() : void {
			// Create the NURBS mesh
			// NURBS constructor
			/*var controlNet : Vector.<NURBSVertex>;
			controlNet.push(new NURBSVertex(-200, 0, -150, 1));
			controlNet.push(new NURBSVertex(-200, -100, -75, 1));
			controlNet.push(new NURBSVertex(-200, -100, 0, 1));
			controlNet.push(new NURBSVertex(-200, -100, 75, 1));
			controlNet.push(new NURBSVertex(-200, 0, 150, 1));

			controlNet.push(new NURBSVertex(-100, -100, -150, 1));
			controlNet.push(new NURBSVertex(-100, -100, -75, 1));
			controlNet.push(new NURBSVertex(-100, -100, 0, 1));
			controlNet.push(new NURBSVertex(-100, -100, 75, 1));
			controlNet.push(new NURBSVertex(-100, -100, 150, 1));

			controlNet.push(new NURBSVertex(0, -100, -150, 1));
			controlNet.push(new NURBSVertex(0, -100, -75, 1));
			controlNet.push(new NURBSVertex(0, 250, 0, 6));
			controlNet.push(new NURBSVertex(0, -100, 75, 1));
			controlNet.push(new NURBSVertex(0, -100, 150, 1));

			controlNet.push(new NURBSVertex(100, -100, -150, 1));
			controlNet.push(new NURBSVertex(100, -100, -75, 1));
			controlNet.push(new NURBSVertex(100, -100, 0, 1));
			controlNet.push(new NURBSVertex(100, -100, 75, 1));
			controlNet.push(new NURBSVertex(100, -100, 150, 1));

			controlNet.push(new NURBSVertex(200, 0, -150, 1));
			controlNet.push(new NURBSVertex(200, -100, -75, 1));
			controlNet.push(new NURBSVertex(200, -100, 0, 1));
			controlNet.push(new NURBSVertex(200, -100, 75, 1));
			controlNet.push(new NURBSVertex(200, 0, 150, 1));
			// new NURBS(ctrlPnts, uNumPnts, vNumPnts, init);
			var nurbsMesh : NURBSGeometry = new NURBSGeometry(controlNet, 5, 5, 5, 5, 20, 20);*/
			// (controlNet, 5, 5, { name:"nurbsModel", uSegments:20, vSegments:20 });

			// Init material and objects
			initMaterials();
			//var eee : Mesh = new Mesh(nurbsMesh, _simpleMaterial);
			//_view.scene.addChild(eee);
			// create skybox
			randomSky();

			// basic ground
			_ground = new Mesh(new PlaneGeometry(FARVIEW * 2, FARVIEW * 2), _terrainMaterial);
			_view.scene.addChild(_ground);

			_skinMesh = new Vector.<Mesh>();

			// Load awd object with loaderPool
			LoaderPool.loadObject("simple/simple.awd", onAssetComplete, onResourceComplete);
		}

		/**
		 * Initialise the engine
		 */
		private function initEngine() : void {
			_view = new View3D();
			_view.stage3DProxy = _stage3DProxy;
			_view.shareContext = true;
			addChild(_view);

			// create custom lens
			_view.camera.lens = new PerspectiveLens(70);
			_view.camera.lens.far = FARVIEW;
			_view.camera.lens.near = 1;

			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 180, 0, 300, 10, 9);
			_cameraController.tiltAngle = 0;
			_cameraController.minTiltAngle = -90;
			_cameraController.maxTiltAngle = 90;
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
			_sunLight = new DirectionalLight(0.1, -0.8, 0.3);
			_sunLight.color = sunColor;
			_sunLight.ambientColor = sunColor;
			_sunLight.ambient = 0;
			_sunLight.diffuse = 0;
			_sunLight.specular = 0;

			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.4);
			_view.scene.addChild(_sunLight);

			_lightPicker = new StaticLightPicker([_sunLight]);
			stage.addEventListener(Event.RESIZE, onResize);
		}

		/**
		 * Create random sky 
		 */
		private function randomSky() : void {
			AutoMapSky.scene = _view.scene;
			if (_isIntro) {
				AutoMapSky.randomSky([skyColor, fogColor, groundColor], _bitmaps, 8, "overlay");
				_fogMethode.fogColor = AutoMapSky.darken(AutoMapSky.fogColor, 100);
			} else {
				AutoMapSky.randomSky(null, _bitmaps, 4, "add");
				_fogMethode.fogColor = AutoMapSky.fogColor;
			}
		}

		/**
		 * Initialise the materials
		 */
		private function initMaterials() : void {
			_materials = new Vector.<TextureMaterial>();

			// fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW, 0x000000);
			// shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0007;
			_shadowMethod.alpha = 0.25;

			// 0 - simple material
			_simpleMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, false, 0x00ff00)));
			_simpleMaterial.gloss = 5;
			_simpleMaterial.specular = 0.2;
			_materials[0] = _simpleMaterial;

			// 1 - terrain material
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, false, 0xFF0000)));
			_terrainMaterial.gloss = 5;
			_terrainMaterial.specular = 0.2;
			_materials[1] = _terrainMaterial;

			// apply light and effect for all material
			for (var i : uint = 0; i < _materials.length; i++) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 1;
				_materials[i].addMethod(_fogMethode);
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
				_fogMethode.fogColor = AutoMapSky.darken(AutoMapSky.fogColor, _night);
				AutoMapSky.night(_night, FARVIEW);
				_night--;
			}

			_cameraController.update();

			// update view
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
			// add render loop
			// _stage3DProxy.
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

		/**
		 * Remove Listener
		 */
		private function stopListeners() : void {
			if (_isIntro) return;
			_isRender = false;
			grayPauseEffect();
			log("&#47;&#33;&#92; PAUSE");
			// _stage3DProxy.
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
		 * Listener function for awd asset complete event on loader3D
		 */
		private function onAssetComplete(event : AssetEvent) : void {
			var mesh : Mesh;
			// ++ Skeleton referency same for man and woman
			if (event.asset.assetType == AssetType.SKELETON) {
				_squeleton = event.asset as Skeleton;
				_animationSet = new SkeletonAnimationSet(3);
			} 
			// ++ animation by name
			// for away3d dev 
			else if (event.asset.assetType == AssetType.ANIMATION_NODE) {
				var animationNode : SkeletonClipNode = event.asset as SkeletonClipNode;
				_animationSet.addAnimation(animationNode);
			}
			// for away3d master
			/*else if (event.asset.assetType == AssetType.ANIMATION_STATE) {
			var animationState:SkeletonAnimationState = event.asset as SkeletonAnimationState;
			_animationSet.addState(animationState.name, animationState);
			}*/ else if (event.asset.assetType == AssetType.MESH) {
				mesh = Mesh(event.asset);
				// set default texture
				mesh.material = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, false, 0x000000)));
				// Character Men & Woman
				if (mesh.name == "Cylinder001") {
					_skinMesh.push(mesh);
				}
			}
		}

		/** 
		 * Populate Clones
		 */
		private function onResourceComplete(e : LoaderEvent) : void {
			var loader3d : Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);

			var skin : Mesh = _skinMesh[0].clone() as Mesh;
			skin.material = _simpleMaterial;
			var animator : SkeletonAnimator = new SkeletonAnimator(_animationSet, _squeleton);
			skin.scale(2);
			skin.animator = animator;
			animator.play("Basic", transition);
			_view.scene.addChild(skin);

			log(message());
			initListeners();
		}

		/**
		 * Listener Key down
		 */
		private function onKeyDown(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
					// fr
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
					// fr
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					break;
				// options
				case Keyboard.B:
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
		 * Listener Key up 
		 */
		private function onKeyUp(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
				// fr
				case Keyboard.DOWN:
				case Keyboard.S:
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
				// fr
				case Keyboard.RIGHT:
				case Keyboard.D:
					break;
			}
		}

		/**
		 * Listener stage full screen
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
			if (_view != null) {
				_view.width = stage.stageWidth;
				_view.height = stage.stageHeight;
				_stats.x = stage.stageWidth - _stats.width;
				if (!_isRender) onEnterFrame();
			}
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
		 * Listener mouseWheel 
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
			var mes : String = "";
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
	}
}