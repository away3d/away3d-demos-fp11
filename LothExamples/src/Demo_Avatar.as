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
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.animators.data.Skeleton;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.events.LoaderEvent;
	import away3d.containers.View3D;
	import away3d.events.AssetEvent;
	import away3d.loaders.Loader3D;
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
	import flash.text.TextField;
	import flash.display.Sprite;
	// import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.ui.Keyboard;

	import utils.AutoMapAvatar;
	import utils.AutoMapSky;
	import utils.BitmapFilterEffects;
	import utils.LoaderPool;

	import com.bit101.components.Style;
	import com.bit101.components.PushButton;

	import games.FractalTerrain;

	[SWF(backgroundColor="#000000", frameRate="60")]
	public class Demo_Avatar extends Sprite {
		private const MOUNTAIGN_TOP : Number = 1500;
		private const FARVIEW : Number = 128 * 100;
		private const FOGNEAR : Number = 400;
		private var _bitmapStrings : Vector.<String>;
		private var _bitmaps : Vector.<BitmapData>;
		private var sunColor : uint = 0xFFFFFF;
		private var skyColor : uint = 0x9090ee;
		private var fogColor : uint = 0xd3eef9;
		private var groundColor : uint = 0xd3eef9;
		// engine variables
		private var _view : View3D;
		private var _stats : AwayStats;
		private var _lightPicker : StaticLightPicker;
		private var _cameraController : HoverController;
		// light variables
		private var _night : Number = 100;
		private var _sunLight : DirectionalLight;
		private var _waterMethod : SimpleWaterNormalMethod;
		private var _fresnelMethod : FresnelSpecularMethod;
		private var _reflectionMethod : EnvMapMethod;
		private var _fogMethode : FogMethod;
		private var _shadowMethod : NearShadowMapMethod;
		private var _rimLightMethod : RimLightMethod;
		// Materials
		private var _materials : Vector.<TextureMaterial>;
		private var _terrainMaterial : TextureMaterial;
		private var _waterMaterial : TextureMaterial;
		// Materials AVATAR
		private var TEX_Avatar : Vector.<TextureMaterial>;
		private var TEX_Hair : Vector.<TextureMaterial>;
		// scene objects
		private var _ground : Mesh;
		// Avatar referency
		private var _cloneStyleWoman : Vector.<Mesh>;
		private var _cloneStyleMan : Vector.<Mesh>;
		private var _skinMesh : Vector.<Mesh>;
		// Hair variable
		private var _cloneHair : Vector.<Mesh>;
		// Avatar structure
		private var _squeleton : Skeleton;
		private var _animationSet : SkeletonAnimationSet;
		// away3d dev
		private var transition : CrossfadeTransition = new CrossfadeTransition(0.25);
		// animation constants
		private const SEQUENCE_MAN : Array = ['Breathe', 'Sit', 'Walk', 'Run'];
		private const SEQUENCE_WOMEN : Array = ['Breathe', 'SitWoman', 'WalkWoman', 'Run'];
		private const SEQSPEED : Array = [0.4, -0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4];
		private var _clones : Vector.<Mesh>;
		private var animators : Vector.<SkeletonAnimator>;
		private var chromosomes : Vector.<int>;
		private const HAIR_COLOR : Array = [0x6E4C44, 0x4F4540, 0xFC6932, 0xE8593A, 0xFFB42B, 0x9A7F60, 0x494344, 0xBBC6CB];
		private var _sTexture : Array;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		private var _isIntro : Boolean = true;
		private var _isRender : Boolean;
		private var _text : TextField;
		private var _capture : BitmapData;
		private var _topPause : Sprite;
		private var _menu : Sprite;

		/**
		 * Constructor
		 */
		public function Demo_Avatar() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}

		/**
		 * Global initialise function
		 */
		private function init(e : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;

			initEngine();
			initText();
			initSetting();
			initLights();

			// kickoff asset loading
			_bitmapStrings = new Vector.<String>();
			_bitmapStrings.push("sky4/negy.jpg", "sky4/posy.jpg", "sky4/posx.jpg", "sky4/negz.jpg", "sky4/posz.jpg", "sky4/negx.jpg");
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
			// Init material and objects
			initMaterials();

			// create skybox
			randomSky();
			// reflection method
			_reflectionMethod = new EnvMapMethod(AutoMapSky.skyMap, 0.8);
			_waterMaterial.addMethod(_reflectionMethod);

			// create noize terrain with image 6 7 8
			FractalTerrain.initGround(_view.scene, _bitmaps, _terrainMaterial, FARVIEW * 2, MOUNTAIGN_TOP);
			FractalTerrain.move(0, 0.03);
			// basic ground
			_ground = new Mesh(new PlaneGeometry(FARVIEW * 2, FARVIEW * 2), _waterMaterial);
			_ground.geometry.scaleUV(40, 40);
			_ground.y = 600;
			// _ground.castsShadows = false;
			_view.scene.addChild(_ground);

			// Avatar character mesh referency
			_skinMesh = new Vector.<Mesh>();
			_cloneStyleMan = new Vector.<Mesh>();
			_cloneStyleWoman = new Vector.<Mesh>();

			// Load awd object with loaderPool
			LoaderPool.loadObject("avatar/avatar.awd", onAssetComplete, onResourceComplete);
		}

		/**
		 * Initialise the engine
		 */
		private function initEngine() : void {
			_view = new View3D();
			addChild(_view);

			// create custom lens
			_view.camera.lens = new PerspectiveLens(70);
			_view.camera.lens.far = FARVIEW;
			_view.camera.lens.near = 1;

			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 180, 0, 1000, 10, 9);
			_cameraController.tiltAngle = 0;
			_cameraController.minTiltAngle = 0;
			_cameraController.maxTiltAngle = 60;
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
				AutoMapSky.randomSky([skyColor, fogColor, groundColor], _bitmaps, 4, "overlay");
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
			_sTexture = [Cast.bitmapTexture(_bitmaps[6]), Cast.bitmapTexture(_bitmaps[7]), Cast.bitmapTexture(_bitmaps[8])];
			// water method
			_waterMethod = new SimpleWaterNormalMethod(Cast.bitmapTexture(_bitmaps[9]), Cast.bitmapTexture(_bitmaps[9]));
			// fresnelMethod
			_fresnelMethod = new FresnelSpecularMethod();
			_fresnelMethod.normalReflectance = .4;
			// Rim light method
			_rimLightMethod = new RimLightMethod(skyColor, 0.5, 2, RimLightMethod.ADD);
			// fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW, 0x000000);
			// shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0007;
			_shadowMethod.alpha = 0.25;

			// 0 _ water texture
			_waterMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x22404060)));
			_waterMaterial.alphaBlending = true;
			_waterMaterial.repeat = true;
			_waterMaterial.gloss = 100;
			_waterMaterial.specular = 1;
			_waterMaterial.normalMethod = _waterMethod;
			_waterMaterial.specularMethod = _fresnelMethod;
			_materials[0] = _waterMaterial;

			// 1 - terrain material
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, false, 0x00)));
			_terrainMaterial.gloss = 5;
			_terrainMaterial.specular = 0.2;
			_materials[1] = _terrainMaterial;

			// n _ avatar materials
			var material : TextureMaterial;
			TEX_Avatar = new Vector.<TextureMaterial>(10);

			for (var i : uint = 0; i < 10; i++) {
				var bitmapData : BitmapData = AutoMapAvatar.avatarBitmap();
				material = new TextureMaterial(Cast.bitmapTexture(bitmapData));
				material.normalMap = Cast.bitmapTexture(BitmapFilterEffects.normalMap(bitmapData));
				material.gloss = 12;
				material.specular = 0.3;
				TEX_Avatar[i] = material;
				_materials.push(material);
			}
			// n _ avatar hair materials
			var color : uint;
			TEX_Hair = new Vector.<TextureMaterial>(10);
			for ( i = 0; i < 10; i++) {
				color = HAIR_COLOR[uint(Math.random() * HAIR_COLOR.length)];
				material = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, color)));
				material.gloss = 12;
				material.specular = 0.3;
				TEX_Hair[i] = material;
				_materials.push(material);
			}

			// apply light and effect for all material
			for (i = 0; i < _materials.length; i++) {
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

			FractalTerrain.update();

			_cameraController.lookAtPosition.y = FractalTerrain.getHeightAt(0, 0);
			_cameraController.update();
			// animate our lake material
			_waterMethod.water1OffsetX += .001;
			_waterMethod.water1OffsetY += .001;
			_waterMethod.water2OffsetX += .0007;
			_waterMethod.water2OffsetY += .0006;

			updateClone();

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
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
			_isRender = false;
			grayPauseEffect();
			log("&#47;&#33;&#92; PAUSE");
			// _stage3DProxy.
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
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
			if (_isIntro) return;
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
				_animationSet = new SkeletonAnimationSet(2);
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
				// Character Men & Woman
				if (mesh.name.substring(0, 4) == "Skin") {
					_skinMesh.push(mesh);
				}
				if (mesh.name.substring(0, 8) == "Hair_Man") {
					_cloneStyleMan.push(mesh);
				}
				if (mesh.name.substring(0, 8) == "Hair_Wom") {
					_cloneStyleWoman.push(mesh);
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

			populate(180, 10, 200, 300);

			log(message());
			initListeners();
		}

		/** 
		 * Populate Clones
		 */
		private function populate(n : int = 10, maxbyline : int = 10, sx : int = 50, sz : int = 50) : void {
			if (!_clones) _clones = new Vector.<Mesh>(n);
			var m : Mesh;
			var j : int, k : int;
			for (var i : int = 0; i < n; ++i) {
				m = addAvatar(2, 2);
				m.z = (j * sz);
				k = (i - (j * maxbyline));
				m.x = -((maxbyline * sx) >> 1) + (k * sx) + (sx / 2);
				m.y = FractalTerrain.getHeightAt(m.x, m.z);
				m.mouseEnabled = m.mouseChildren = false;
				_view.scene.addChild(m);
				_clones[i] = m;

				if (k == maxbyline - 1)
					j++;
			}
			_clones.fixed = true;
		}

		/** 
		 * Duplicate Man or Woman into Avatar with self animation
		 */
		public function addAvatar(Scale : Number = 1, AnimNum : int = -1) : Mesh {
			if (!animators) animators = new Vector.<SkeletonAnimator>();
			if (!chromosomes) chromosomes = new Vector.<int>();
			if (!_cloneHair) _cloneHair = new Vector.<Mesh>();

			// 0:man 1:woman
			var sex : int = rand(1) + 1;
			var hair : Mesh;
			var skin : Mesh = _skinMesh[sex - 1].clone() as Mesh;

			// random skin material
			skin.material = TEX_Avatar[int(Math.random() * 10)];
			skin.scale(Scale);

			// choose random hair style;
			if (sex == 1) hair = _cloneStyleMan[rand(_cloneStyleMan.length - 1)].clone() as Mesh;
			else hair = _cloneStyleWoman[rand(_cloneStyleWoman.length - 1)].clone() as Mesh;
			hair.material = TEX_Hair[int(Math.random() * 10)];
			skin.addChild(hair);

			// create new animator
			var animator : SkeletonAnimator = new SkeletonAnimator(_animationSet, _squeleton);
			// play random animation or Anim
			var num : uint;
			if (AnimNum == -1) num = int(Math.random() * 3);
			else num = AnimNum;

			var anim : String;
			if (sex == 1) anim = SEQUENCE_MAN[num];
			else anim = SEQUENCE_WOMEN[num];
			animator.playbackSpeed = SEQSPEED[num];
			// animator.play(anim, stateTransition);
			skin.animator = animator;
			animator.play(anim);

			_cloneHair.push(hair);
			animators.push(animator);
			chromosomes.push(sex);
			return skin;
		}

		/** 
		 * Play animation
		 */
		public function play(i : int, name : String, speed : Number = 0.5) : void {
			SkeletonAnimator(animators[i]).play(name, transition);
			animators[i].playbackSpeed = speed;
		}

		/** 
		 * Update Hair animation to follow head bone 
		 */
		public function updateClone() : void {
			for (var i : uint = 0; i < animators.length; i++) {
				_cloneHair[i].transform = animators[i].globalPose.jointPoses[15].toMatrix3D();
				_clones[i].y = FractalTerrain.getHeightAt(_clones[i].x, _clones[i].z);
			}
		}

		/**
		 * Remove clone
		 */
		public function deleteLast(skin : Mesh) : void {
			var n : int = animators.length - 1;
			skin.removeChild(_cloneHair[n]);
			animators[n].stop();
			Mesh(_cloneHair[n]).dispose();
			animators.pop();
			_cloneHair.pop();

			if (n == 0) {
				animators = new Vector.<SkeletonAnimator>;
				_cloneHair = new Vector.<Mesh>;
			}
		}

		private function rand(max : Number = 1, min : Number = 0) : Number {
			return Math.floor(Math.random() * (max - min + 1)) + min;
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
		 * Initialise setting 
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
			new PushButton(_menu, 30, -29, ">", showSetting).setSize(30, 30);
			new PushButton(_menu, 65, -29, "64", switch64).setSize(60, 30);
			new PushButton(_menu, 130, -29, "128", switch128).setSize(60, 30);
			new PushButton(_menu, 195, -29, "256", switch256).setSize(60, 30);
		}

		private function switch64(e : Event) : void {
			FractalTerrain.changeResolution(64);
			FractalTerrain.move(0, 0.03);
		}

		private function switch128(e : Event) : void {
			FractalTerrain.changeResolution(128);
			FractalTerrain.move(0, 0.03);
		}

		private function switch256(e : Event) : void {
			FractalTerrain.changeResolution(256);
			FractalTerrain.move(0, 0.03);
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

		private function showSetting(e : MouseEvent) : void {
		}
	}
}