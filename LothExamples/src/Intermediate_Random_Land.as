/*

   RANDOM LAND

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
   of this software and associated documentation files (the �Software�), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED �AS IS�, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.

 */
package
{
	import away3d.extrusions.Elevation;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.events.Stage3DEvent;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.controllers.FirstPersonController;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.textures.CubeReflectionTexture;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.textures.BitmapCubeTexture;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.library.assets.AssetType;
	import away3d.primitives.CubeGeometry;
	import away3d.lights.DirectionalLight;
	import away3d.materials.LightSources;
	import away3d.events.MouseEvent3D;
	import away3d.events.LoaderEvent;
	import away3d.containers.View3D;
	import away3d.lights.PointLight;
	import away3d.lights.LightProbe;
	import away3d.primitives.SkyBox;
	import away3d.entities.Sprite3D;
	import away3d.events.AssetEvent;
	import away3d.loaders.Loader3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flash.filters.ColorMatrixFilter;
	import flash.display.StageDisplayState;
	import flash.filters.DropShadowFilter;
	import flash.net.URLLoaderDataFormat;
	import flash.display.StageScaleMode;
	import flash.events.ProgressEvent;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import flash.display.LoaderInfo;
	import flash.display.BitmapData;
	import flash.display.StageAlign;
	import flash.events.MouseEvent;
	import flash.text.GridFitType;
	import flash.utils.setTimeout;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	
	import utils.PixelBlenderEffects;
	import utils.VectorSkyEffects;
	import utils.BitmapMapper;
	
	public class Intermediate_Random_Land extends Sprite
	{
		[Embed(source="/../embeds/signature.swf",symbol="Signature")]
		public var SignatureSwf:Class;
		
		private static const ASSETS_ROOT:String = "assets/onkba/";
		private static const MOUNTAIGN_TOP:Number = 2000;
		private static const FARVIEW:Number = 30000;
		private static const FOGNEAR:Number = 0;
		private static const SCALE:Number = 2;
		
		// start colors
		private var sunColor:uint = 0xAAAAA9;
		private var fogColor:uint = 0x333338;
		private var skyColor:uint = 0x445465;
		
		// bitmaps
		private var _bitmapStrings:Vector.<String>;
		private var _bitmaps:Vector.<BitmapData>;
		private var _num:uint;
		
		// engine variables
		private var _stage3DProxy:Stage3DProxy;
		private var _manager:Stage3DManager;
		private var _view:View3D;
		private var _stats:AwayStats;
		private var _lightPicker:StaticLightPicker;
		private var _cameraController:HoverController;
		// scene objects
		private var _cubeVector:Vector.<Mesh>;
		private var _heroPieces:ObjectContainer3D;
		private var _sunLight:DirectionalLight;
		private var _player:ObjectContainer3D;
		private var _weapons:Vector.<Mesh>;
		private var _bonesFx:Vector.<Mesh>;
		private var _skyProbe:LightProbe;
		private var _terrain:Elevation;
		private var _heroWeapon:Mesh;
		private var _bigBall:Mesh;
		private var _hero:Mesh;
		
		// materials
		private var _terrainMaterial:TextureMaterial;
		private var _boxMaterial:TextureMaterial;
		private var _materials:Vector.<TextureMaterial>;
		// methodes
		private var _reflectionTexture:CubeReflectionTexture;
		private var _specularMethod:FresnelSpecularMethod;
		private var _terrainMethod:TerrainDiffuseMethod;
		private var _fresnelMethod:FresnelEnvMapMethod;
		private var _shadowMethod:NearShadowMapMethod;
		private var _rimLightMethod:RimLightMethod;
		private var _fogMethode:FogMethod;
		
		// sky
		private var _sky:SkyBox;
		private var _skyMap:BitmapCubeTexture;
		private var _skyBitmaps:Vector.<BitmapData>;
		private var _blendmodes:Array = ["add", "darken", "hardlight", "lighten", "multiply", "overlay", "screen", "subtract"];
		
		// navigation
		private var _prevMouseX:Number;
		private var _prevMouseY:Number;
		private var _mouseMove:Boolean;
		private var _cameraHeight:Number;
		
		// demo testing
		private var _isIntro:Boolean = true;
		private var _isReflection:Boolean;
		private var _dynamicsEyes:Boolean;
		private var _cloneActif:Boolean;
		private var _debugRay:Boolean;
		private var _isRender:Boolean;
		
		private var _signature:Sprite;
		private var _text:TextField;
		
		private var _capture:BitmapData;
		private var _topPause:Sprite;
		
		/**
		 * Constructor
		 */
		public function Intermediate_Random_Land()
		{
			_bitmaps = new Vector.<BitmapData>();
			_bitmapStrings = new Vector.<String>();
			// terrain map
			_bitmapStrings.push("rock.jpg", "sand.jpg", "arid.jpg");
			// sky map Bitmap overlay
			_bitmapStrings.push("sky/negy.jpg", "sky/posy.jpg", "sky/posx.jpg", "sky/negz.jpg", "sky/posz.jpg", "sky/negx.jpg");
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		/**
		 * Global initialise function
		 */
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.color = 0x000000;
			stage.frameRate = 60;
			
			_manager = Stage3DManager.getInstance(stage);
			_stage3DProxy = _manager.getFreeStage3DProxy();
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated, false, 0, true);
		}
		
		private function onContextCreated(e:Stage3DEvent):void
		{
			_stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			_stage3DProxy.color = 0x000000;
			_stage3DProxy.antiAlias = 4;
			_stage3DProxy.width = stage.stageWidth;
			_stage3DProxy.height = stage.stageHeight;
			initEngine();
			initText();
			initLights();
			
			// kickoff asset loading
			load(_bitmapStrings[_num]);
		}
		
		//-------------------------------------------------------------------------------
		//
		//       3D ENGINE INIT 
		//
		//-------------------------------------------------------------------------------
		
		private function initEngine():void
		{
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
			_cameraController = new HoverController(_view.camera, null, 22, 0, 500, 10, 90);
			_cameraController.tiltAngle = 10;
			_cameraController.panAngle = 22;
			_cameraController.minTiltAngle = -10;
			_cameraController.maxTiltAngle = 60;
			_cameraController.autoUpdate = false;
			
			// setup the player container 
			_player = new ObjectContainer3D();
			_player.y = 200;
			_view.scene.addChild(_player);
			
			// add signature
			addChild(_signature = new SignatureSwf());
			_signature.y = stage.stageHeight - _signature.height;
			_signature.x = 10;
			
			// add stats
			addChild(_stats = new AwayStats(_view, false, true));
			_stats.x = stage.stageWidth - _stats.width - 5;
			_stats.alpha = 0.5;
			_stats.y = 2;
			
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		//-------------------------------------------------------------------------------
		//       LIGHTS
		//-------------------------------------------------------------------------------
		
		private function initLights():void
		{
			_sunLight = new DirectionalLight(-0.5, -1, 0.3);
			_sunLight.color = sunColor;
			_sunLight.ambientColor = sunColor;
			_sunLight.ambient = 0;
			_sunLight.diffuse = 0;
			_sunLight.specular = 1;
			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.02);
			_view.scene.addChild(_sunLight);
			
			// generate cube texture for sky and probe
			_skyProbe = new LightProbe(_skyMap);
			_view.scene.addChild(_skyProbe);
			
			// create light picker for materials
			_lightPicker = new StaticLightPicker([_sunLight, _skyProbe]);
		}
		
		//-------------------------------------------------------------------------------
		//       SKY
		//-------------------------------------------------------------------------------
		
		private function randomSky():void
		{
			var i:uint = 0;
			var blend:String = "overlay";
			if (!_isIntro)
			{
				skyColor = 0xFFFFFF * Math.random();
				fogColor = 0xFFFFFF * Math.random();
				blend = _blendmodes[uint(Math.random() * _blendmodes.length)];
			}
			
			// add real sky bitmap
			if (_skyBitmaps == null)
			{
				_skyBitmaps = new Vector.<BitmapData>(6);
				for (i = 0; i < 6; i++)
				{
					_skyBitmaps[i] = _bitmaps[3 + i];
				}
			}
			if (_sky)
			{
				_view.scene.removeChild(_sky);
				_sky.dispose();
			}
			
			_skyMap = VectorSkyEffects.vectorSky(skyColor, fogColor, fogColor, 8, _skyBitmaps, blend);
			_fogMethode.fogColor = fogColor;
			_skyProbe.diffuseMap = _skyMap;
			_sky = new SkyBox(_skyMap);
			_view.scene.addChild(_sky);
			
			// test rim Light methode slow down engine
			for (i = 0; i < _materials.length; i++)
			{
				_materials[i].removeMethod(_rimLightMethod);
			}
			_rimLightMethod = new RimLightMethod(skyColor, 0.5, 2.5, RimLightMethod.ADD);
			for (i = 0; i < _materials.length; i++)
			{
				_materials[i].addMethod(_rimLightMethod);
			}
		}
		
		//-------------------------------------------------------------------------------
		//
		//       MATERIAL
		//
		//-------------------------------------------------------------------------------
		
		private function initMaterials():void
		{
			var f:BitmapMapper = new BitmapMapper(2, MOUNTAIGN_TOP);
			_materials = new Vector.<TextureMaterial>();
			
			var tiles:Array = [1, 100, 100, 100];
			var sTexture:Array = [Cast.bitmapTexture(_bitmaps[0]), Cast.bitmapTexture(_bitmaps[1]), Cast.bitmapTexture(_bitmaps[2])];
			_terrainMethod = new TerrainDiffuseMethod(sTexture, Cast.bitmapTexture(BitmapMapper.ground), tiles);
			
			// global shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0005;
			
			// global Rim light method
			//_rimLightMethod = new RimLightMethod(skyColor, 0.5, 2, RimLightMethod.ADD);
			
			// global fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW >> 1, fogColor);
			
			// 0- terrain
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, false, 0x0)));
			
			_terrainMaterial.normalMap = Cast.bitmapTexture(PixelBlenderEffects.normalMap(BitmapMapper.ground));
			_terrainMaterial.diffuseMethod = _terrainMethod;
			_terrainMaterial.gloss = 20;
			_terrainMaterial.specular = .25;
			//_terrainMaterial.repeat = true;
			_terrainMaterial.addMethod(_fogMethode);
			_materials[0] = _terrainMaterial;
			
			// 1- simulation box
			_boxMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0xee100000)));
			_boxMaterial.gloss = 10;
			_boxMaterial.specular = 0.1;
			_boxMaterial.alphaBlending = true;
			_boxMaterial.addMethod(_fogMethode);
			_materials[1] = _boxMaterial;
			
			// for all material
			for (var i:int; i < _materials.length; i++)
			{
				_materials[i].lightPicker = _lightPicker;
				_materials[i].diffuseLightSources = LightSources.PROBES;
				_materials[i].specularLightSources = LightSources.LIGHTS;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 0.85;
					//if (i != 5 || i!=3 || i!=2) _materials[i].addMethod(_rimLightMethod);
			}
		}
		
		//-------------------------------------------------------------------------------
		//       REFLECTION
		//-------------------------------------------------------------------------------
		
		private function initReflectionCube():void
		{
			_reflectionTexture = new CubeReflectionTexture(128 * 2);
			_reflectionTexture.farPlaneDistance = FARVIEW;
			_reflectionTexture.nearPlaneDistance = 50;
			_reflectionTexture.position = new Vector3D(0, 0, 0);
		}
		
		private function initReflection():void
		{
			if (_isReflection)
				return;
			_isReflection = true;
			initReflectionCube();
			_fresnelMethod = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod.normalReflectance = 0.9;
			_fresnelMethod.fresnelPower = 1;
			_fresnelMethod.alpha = 0.5;
			_materials[4].addMethod(_fresnelMethod);
		}
		
		//-------------------------------------------------------------------------------
		//       3D OBJECT 
		//-------------------------------------------------------------------------------
		
		private function initAfterBitmapLoad():void
		{
			// create material
			initMaterials();
			
			// create skybox
			randomSky();
			
			// create terrain
			_terrain = new Elevation(_terrainMaterial, Cast.bitmapData(BitmapMapper.ground), FARVIEW * 2, MOUNTAIGN_TOP, FARVIEW * 2, 250, 250, 255, 0, false);
			_view.scene.addChild(_terrain);
			
			_cameraHeight = _terrain.getHeightAt(0, 0) + 100;
			
			initListeners();
			log(message());
		
			// load Onkba character with weapons
			//load("onkba_fps.awd");
		}
		
		//-------------------------------------------------------------------------------
		//
		//       OO RENDER LOOP   
		//
		//-------------------------------------------------------------------------------
		
		private function onEnterFrame(event:Event = null):void
		{
			if (_sunLight.ambient < 0.5)
				_sunLight.ambient += 0.01;
			
			if (_cameraController.distance > 300 && _isIntro)
				_cameraController.distance--;
			else
				_isIntro = false;
			_cameraController.lookAtPosition = new Vector3D(_player.x, _player.y + _cameraHeight, _player.z);
			_cameraController.update();
			
			/*if (_isReflection) {
			   _reflectionTexture.position = _bigBall.position;
			   _reflectionTexture.render(_view);
			 }*/
			
			_view.render();
		}
		
		//-------------------------------------------------------------------------------
		//       GLOBAL LISTENER
		//-------------------------------------------------------------------------------
		
		private function initListeners(e:Event = null):void
		{
			
			_isRender = true;
			log(message());
			if (e != null)
			{
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
		
		private function stopListeners():void
		{
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
		
		//-------------------------------------------------------------------------------
		//       PAUSE effect
		//-------------------------------------------------------------------------------
		
		private function grayPauseEffect():void
		{
			_capture = new BitmapData(_stage3DProxy.width, _stage3DProxy.height, true, 0x30ff0000);
			
			// damn no way to copy view !!!
			//_capture.draw(_view.stage3DProxy.context3D.)
			//_view.renderer.
			// _stage3DProxy.context3D.drawToBitmapData
			//_stage3DProxy.context3D.drawToBitmapData(_capture);
			//_view.renderer.swapBackBuffer = true;
			
			// add Black and white effect
			_capture.applyFilter(_capture, _capture.rect, new Point(), BitmapMapper.grayScale());
			_topPause = new Sprite();
			addChild(_topPause);
			_topPause.graphics.beginBitmapFill(_capture, null, false, false);
			_topPause.graphics.drawRect(0, 0, stage.width, stage.height);
			_topPause.graphics.endFill();
		}
		
		private function removeGrayPauseEffect():void
		{
			_topPause.graphics.clear();
			removeChild(_topPause);
			_capture = null;
		}
		
		//-------------------------------------------------------------------------------
		//       LOAD binary files
		//-------------------------------------------------------------------------------
		
		private function load(url:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			switch (url.substring(url.length - 3))
			{
				case "AWD": 
				case "awd": 
					loader.addEventListener(Event.COMPLETE, parseAWD, false, 0, true);
					break;
				case "png": 
				case "jpg": 
					loader.addEventListener(Event.COMPLETE, parseBitmap, false, 0, true);
					break;
			}
			loader.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
			loader.load(new URLRequest(ASSETS_ROOT + url));
		}
		
		private function loadProgress(e:ProgressEvent):void
		{
			var P:int = int(e.bytesLoaded / e.bytesTotal * 100);
			log('LOADING : ' + P + ' % | ' + int((e.bytesLoaded / 1024) << 0) + ' ko');
		}
		
		//-------------------------------------------------------------------------------
		//      Bitmaps Loading
		//-------------------------------------------------------------------------------
		
		private function parseBitmap(e:Event):void
		{
			var urlLoader:URLLoader = URLLoader(e.target);
			var loader:Loader = new Loader();
			loader.loadBytes(urlLoader.data);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapComplete, false, 0, true);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			urlLoader.removeEventListener(Event.COMPLETE, parseBitmap);
		}
		
		private function onBitmapComplete(e:Event):void
		{
			_num++;
			_bitmaps.push(e.target.content.bitmapData);
			// Clean loader
			var loader:Loader = LoaderInfo(e.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			loader.unload();
			loader = null;
			// Load next
			if (_num < _bitmapStrings.length)
				load(_bitmapStrings[_num]);
			else
				initAfterBitmapLoad();
		}
		
		//-------------------------------------------------------------------------------
		//       AWD loading
		//-------------------------------------------------------------------------------
		
		private function parseAWD(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var loader3d:Loader3D = new Loader3D(false);
			loader3d.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete, false, 0, true);
			loader3d.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete, false, 0, true);
			loader3d.loadData(loader.data, null, null, new AWD2Parser());
			loader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			loader.removeEventListener(Event.COMPLETE, parseAWD);
			loader = null;
		}
		
		/**
		 *  AWD asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
		
		}
		
		/**
		 *  AWD resource complete event on loader
		 */
		private function onResourceComplete(e:LoaderEvent):void
		{
		
		}
		
		//-------------------------------------------------------------------------------
		//   ||oo||   KEYBOARD
		//-------------------------------------------------------------------------------
		
		/**
		 * Key down listener
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.SHIFT: 
					//	isRunning = true;
					//	if (isMoving) updateMovement(movementDirection);
					break;
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: //fr
					//	updateMovement(movementDirection = 1);
					//	if (_physics){_physics.key_forward(true);}
					break;
				case Keyboard.DOWN: 
				case Keyboard.S: 
					//	updateMovement(movementDirection = -1);
					//	if (_physics){_physics.key_Reverse(true);}
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: //fr
					//	if (!isMoving)updateMovementSide(1);
					//	if (_physics){_physics.key_Left(true);}
					break;
				case Keyboard.RIGHT: 
				case Keyboard.D: 
					//	if (!isMoving)updateMovementSide( -1);
					//	if (_physics){_physics.key_Right(true);}
					break;
				case Keyboard.R: 
					//	reload();
					break;
				case Keyboard.B: 
					//	makeClone();
					break;
				case Keyboard.N: 
					randomSky();
					break;
				case Keyboard.V: 
					//	initReflection();
					break;
				case Keyboard.U: 
					//	if(_physics) _physics.addDebug(_view);
					break;
				case Keyboard.P: 
					//	xRay();
					break;
				case Keyboard.O: 
					//	switchWeapon();
					break;
				case Keyboard.I: 
					fullScreen();
					break;
				case Keyboard.C: 
					//	if (isCrouch) { isCrouch = false; _cameraHeight = 40; }
					//	else {isCrouch = true; _cameraHeight = 15;}
					//	stop();
					break;
				case Keyboard.SPACE: 
					//	if (!isJump) {
					//		jumpUp();
					//		if (_physics) { _physics.key_Jump(true); }
					//	}
					break;
			}
		}
		
		/**
		 * Key up listener
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.SHIFT: 
					//	isRunning = false;
					//if (isMoving)
					//	updateMovement(movementDirection);
					break;
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: //fr
				case Keyboard.DOWN: 
				case Keyboard.S: 
					//isMoving = false;
					//	if (_physics) { _physics.key_forward(false); _physics.key_Reverse(false);  }
					//	stop();
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: //fr
				case Keyboard.RIGHT: 
				case Keyboard.D: 
					//	isSideMove = false;
					//	if (_physics) { _physics.key_Left(false); _physics.key_Right(false); }
					//	stop();
					break;
				case Keyboard.SPACE: 
					//	isJump = false;;
					//	if (_physics){_physics.key_Jump(false);}
					break;
			}
		}
		
		//-------------------------------------------------------------------------------
		//       STAGE AND MOUSE FUNCTION
		//-------------------------------------------------------------------------------
		
		/**
		 * stage full screen
		 */
		private function fullScreen(e:Event = null):void
		{
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		/**
		 * stage listener and mouse control
		 */
		private function onResize(event:Event = null):void
		{
			_stage3DProxy.width = stage.stageWidth;
			_stage3DProxy.height = stage.stageHeight;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			_signature.y = stage.stageHeight - _signature.height;
			if (!_isRender)
				onEnterFrame();
		}
		
		private function onStageMouseDown(e:MouseEvent):void
		{
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
			_mouseMove = true;
		}
		
		private function onStageMouseUp(e:Event):void
		{
			_mouseMove = false;
		}
		
		private function onStageMouseLeave(e:Event):void
		{
			_mouseMove = false;
			stopListeners();
		}
		
		private function onStageMouseMove(e:MouseEvent):void
		{
			if (_mouseMove)
			{
				_cameraController.panAngle += (e.stageX - _prevMouseX);
				_cameraController.tiltAngle += (e.stageY - _prevMouseY);
			}
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
		}
		
		/**
		 * mouseWheel listener
		 */
		private function onStageMouseWheel(e:MouseEvent):void
		{
			_cameraController.distance -= e.delta * 5;
			
			if (_cameraController.distance < 50)
				_cameraController.distance = 50;
			else if (_cameraController.distance > 2000)
				_cameraController.distance = 2000;
		}
		
		/**
		 * mesh listener for mouse over interaction
		 */
		private function onMeshMouseOver(e:MouseEvent3D):void
		{
		/*e.target.showBounds = true;
		   _eyeLook.visible = true;
		 onMeshMouseMove(e);*/
		}
		
		/**
		 * mesh listener for mouse out interaction
		 */
		private function onMeshMouseOut(e:MouseEvent3D):void
		{
		/*e.target.showBounds = false;
		   _eyeLook.visible = false;
		 _eyeLook.position = _eyePosition;*/
		}
		
		/**
		 * mesh listener for mouse move interaction
		 */
		private function onMeshMouseMove(e:MouseEvent3D):void
		{
			//	_eyeLook.position = new Vector3D(e.localPosition.z + 6, e.localPosition.x, e.localPosition.y + 10);
		}
		
		//-------------------------------------------------------------------------------
		//       Interface   
		//-------------------------------------------------------------------------------
		
		private function initText():void
		{
			_text = new TextField();
			var format:TextFormat = new TextFormat("Verdana", 9, 0xdddddd);
			format.letterSpacing = 1;
			format.leading = 1;
			format.leftMargin = 5;
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
		
		public function message():String
		{
			var mes:String = "RANDOM LAND\n\n";
			mes += "ARROW.WSAD.ZSQD - move\n";
			mes += "SHIFT - hold to run\n";
			mes += "I - full screen\n";
			mes += "N - random sky\n";
			return mes;
		}
		
		private function log(t:String):void
		{
			_text.htmlText = t;
		}
	
	}
}