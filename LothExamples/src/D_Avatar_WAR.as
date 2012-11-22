/*

AVATAR WAR

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
package
{
	import away3d.extrusions.Elevation;
	import away3d.animators.data.Skeleton;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.transitions.CrossfadeTransition;
	
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
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.textures.BitmapCubeTexture;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.materials.TextureMaterial;
	import away3d.materials.ColorMaterial;
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
	import away3d.events.Stage3DEvent;
	import away3d.events.AssetEvent;
	import away3d.loaders.Loader3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;
	
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
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
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	
	import utils.PixelBlenderEffects;
	import utils.AvatarMapper;
	import utils.VectorSkyEffects;
	import utils.BitmapMapper;
	import utils.CarMove;
	
	import com.bit101.components.Style;
	import com.bit101.components.Component;
	import com.bit101.components.PushButton;
	
	public class D_Avatar_WAR extends Sprite
	{
		//signature swf
		[Embed(source="/../embeds/signature.swf",symbol="Signature")]
		public var SignatureSwf:Class;
		
		private const ASSETS_ROOT:String = "assets/";
		private const SCALE:int = 1;
		private var _id:uint = 0;
		
		private var _stage3DProxy:Stage3DProxy;
		private var _manager:Stage3DManager;
		private var _bitmapStrings:Vector.<String>;
		private var _bitmaps:Vector.<BitmapData>;
		private var _num:uint = 0;
		
		private var sunColor:uint = 0xAAAAA9;
		private var sunAmbient:Number = 0.0;
		private var sunDiffuse:Number = 0.0;
		private var sunSpecular:Number = 1.3;
		private var skyColor:uint = 0x333338;
		private var skyAmbient:Number = 0.1;
		private var skyDiffuse:Number = 0.0;
		private var skySpecular:Number = 1.3;
		private var fogColor:uint = 0x333338;
		private var zenithColor:uint = 0x445465;
		private var fogNear:Number = 1000;
		private var fogFar:Number = 128 * 32 * 2;
		
		//engine variables
		private var _view:View3D;
		private var _stats:AwayStats;
		
		private var _lightPicker:StaticLightPicker;
		private var _cameraController:HoverController;
		
		//light variables
		private var _sunLight:DirectionalLight;
		private var _skyLight:PointLight;
		private var _skyProbe:LightProbe;
		
		private var _reflectionTexture:CubeReflectionTexture;
		private var _fresnelMethod:FresnelEnvMapMethod;
		private var _fresnelMethod2:FresnelEnvMapMethod;
		private var _fogMethode:FogMethod;
		private var _specularMethod:FresnelSpecularMethod;
		private var _shadowMethod:NearShadowMapMethod;
		private var _rimLightMethod:RimLightMethod;
		// sky
		private var _sky:SkyBox;
		private var _skyMap:BitmapCubeTexture;
		private var _skyBitmaps:Vector.<BitmapData>;
		private var _blendmodes:Array = ["add", "darken", "hardlight", "lighten", "multiply", "overlay", "screen", "subtract"];
		
		// Materials
		private var _materials:Vector.<TextureMaterial>;
		private var _groundMaterial:TextureMaterial;
		// Materials AVATAR
		private var TEX_Avatar:Vector.<TextureMaterial>;
		private var TEX_Hair:Vector.<TextureMaterial>;
		private var TEX_Hat:Vector.<TextureMaterial>;
		
		// scene objects
		private var _ground:Mesh;
		private var _vision:Vector.<Mesh>;
		private var _visionCar:Mesh;
		
		// Avatar referency
		private var _cloneStyleWoman:Vector.<Mesh>;
		private var _cloneStyleMan:Vector.<Mesh>;
		private var _skinMesh:Vector.<Mesh>;
		// Hair variable
		private var _cloneHair:Vector.<Mesh>;
		// Avatar structure
		private var _squeleton:Skeleton;
		private var _animationSquel:SkeletonAnimator;
		private var _animationSetSquel:SkeletonAnimationSet;
		private var transition:CrossfadeTransition = new CrossfadeTransition(0.25);
		// animation constants
		private const SEQUENCE:Array = ['Breathe', 'Sit', 'SitWoman', 'Walk', 'Run'];
		private const SEQUENCE_MAN:Array = ['Breathe', 'Sit', 'Walk', 'Run'];
		private const SEQUENCE_WOMEN:Array = ['Breathe', 'SitWoman', 'WalkWoman', 'Run'];
		private const SEQSPEED:Array = [0.4, -0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4];
		private const ROTATION_SPEED:Number = 10;
		private const XFADE_TIME:Number = 0.5;
		
		private var _clones:Vector.<Mesh>;
		private var animators:Vector.<SkeletonAnimator>;
		private var chromosomes:Vector.<int>;
		private const HAIR_COLOR:Array = [0x6E4C44, 0x4F4540, 0xFC6932, 0xE8593A, 0xFFB42B, 0x9A7F60, 0x494344, 0xBBC6CB];
		
		//navigation
		private var _prevMouseX:Number;
		private var _prevMouseY:Number;
		private var _mouseMove:Boolean;
		private var _cameraHeight:Number = 50;
		
		private var _isIntro:Boolean = true;
		private var _isReflection:Boolean = false;
		private var _isResize:Boolean;
		private var _cloneActif:Boolean;
		private var _isRender:Boolean;
		
		private var _currentLoadFile:String;
		private var _text:TextField;
		private var _signature:Sprite;
		private var _capture:BitmapData;
		private var _topPause:Sprite;
		
		private var _mover:CarMove;
		private var _menu:Sprite;
		
		/**
		 * Constructor
		 */
		public function D_Avatar_WAR()
		{
			_bitmaps = new Vector.<BitmapData>();
			_bitmapStrings = new Vector.<String>();
			
			// sky map Bitmap overlay
			_bitmapStrings.push("sky2/negy.jpg", "sky2/posy.jpg", "sky2/posx.jpg", "sky2/negz.jpg", "sky2/posz.jpg", "sky2/negx.jpg");
			
			// terrain map
			_bitmapStrings.push("sand.jpg", "sand_n.jpg", "sand_l.jpg");
			
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
			stage.color = 0x060606;
			stage.frameRate = 60;
			
			_manager = Stage3DManager.getInstance(stage);
			_stage3DProxy = _manager.getFreeStage3DProxy();
			_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated, false, 0, true);
		}
		
		private function onContextCreated(e:Stage3DEvent):void
		{
			_stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			_stage3DProxy.color = 0x060606;
			_stage3DProxy.antiAlias = 4;
			_stage3DProxy.width = stage.stageWidth;
			_stage3DProxy.height = stage.stageHeight;
			initEngine();
			initText();
			initSetting()
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
			_view = new View3D();
			_view.stage3DProxy = _stage3DProxy;
			_view.shareContext = true;
			addChild(_view);
			
			//create custom lens
			_view.camera.lens = new PerspectiveLens(60);
			_view.camera.lens.far = fogFar;
			_view.camera.lens.near = 1;
			
			//setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 120, 0, 600, 10, 9);
			_cameraController.tiltAngle = 0;
			_cameraController.panAngle = 180;
			_cameraController.minTiltAngle = -60;
			_cameraController.maxTiltAngle = 60;
			_cameraController.distance = 600;
			_cameraController.autoUpdate = false;
			
			//add stats
			addChild(_stats = new AwayStats(_view, false, true));
			_stats.x = stage.stageWidth - _stats.width - 5;
			_stats.alpha = 0.5;
			_stats.y = 2;
		}
		
		//-------------------------------------------------------------------------------
		//       LIGHTS
		//-------------------------------------------------------------------------------
		
		private function initLights():void
		{
			log("Light")
			//create a light for shadows that mimics the sun's position in the skybox
			_sunLight = new DirectionalLight(-0.5, -1, 0.3);
			_sunLight.color = sunColor;
			_sunLight.ambientColor = sunColor;
			_sunLight.ambient = 0 //sunAmbient;
			_sunLight.diffuse = sunDiffuse;
			_sunLight.specular = sunSpecular;
			
			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.1);
			_view.scene.addChild(_sunLight);
			
			//create a light for ambient effect that mimics the sky
			_skyLight = new PointLight();
			_skyLight.color = zenithColor //skyColor;
			_skyLight.ambientColor = zenithColor //skyColor;
			_skyLight.ambient = 0;
			_skyLight.diffuse = skyDiffuse;
			_skyLight.specular = skySpecular;
			_skyLight.y = 300;
			_skyLight.x = -300;
			_skyLight.z = 500;
			
			_skyLight.radius = 1000;
			_skyLight.fallOff = 2500;
			_view.scene.addChild(_skyLight);
			
			//generate cube texture for sky and probe
			_skyMap = VectorSkyEffects.vectorSky(zenithColor, fogColor, fogColor, 8);
			
			_skyProbe = new LightProbe(_skyMap);
			_view.scene.addChild(_skyProbe);
			
			//create light picker for materials
			_lightPicker = new StaticLightPicker([_sunLight, _skyLight, _skyProbe]);
			
			stage.addEventListener(Event.RESIZE, onResize);
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
					_skyBitmaps[i] = _bitmaps[i];
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
			
			_materials = new Vector.<TextureMaterial>();
			
			//create global shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0007;
			
			//create Rim light method
			_rimLightMethod = new RimLightMethod(zenithColor, 0.5, 2, RimLightMethod.ADD);
			
			//create global fog method
			_fogMethode = new FogMethod(fogNear, fogFar, fogColor);
			
			// create ground texture
			_groundMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[6]));
			_groundMaterial.normalMap = Cast.bitmapTexture(_bitmaps[7]);
			_groundMaterial.specularMap = Cast.bitmapTexture(_bitmaps[8]);
			_groundMaterial.gloss = 100;
			_groundMaterial.specular = 0.1;
			_groundMaterial.addMethod(_fogMethode);
			_groundMaterial.repeat = true;
			_materials[0] = _groundMaterial;
			
			
			//_____________________________________ avatar materials
			var material:TextureMaterial
			TEX_Avatar = new Vector.<TextureMaterial>(10);
			
			for (var i:uint = 0; i < 10; i++) {
				var bitmapData:BitmapData = AvatarMapper.avatarBitmap();
				material = new TextureMaterial(Cast.bitmapTexture(bitmapData));
				material.normalMap = Cast.bitmapTexture(PixelBlenderEffects.normal(bitmapData));
				//material.specularMethod = fresnelMethod;
				material.gloss = 12;
				material.specular = 0.5;
				
				material.addMethod(_fogMethode);
				TEX_Avatar[i] = material;
				_materials.push(material);
			}
			var color:uint;
			TEX_Hair = new Vector.<TextureMaterial>(10);
			for ( i = 0; i < 10; i++) {
				color = HAIR_COLOR[uint(Math.random() * HAIR_COLOR.length)];
				//material = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, color)));
				material = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, color)));
				//material.specularMethod = fresnelMethod;
				material.gloss = 12;
				material.specular = 0.5;
				
				material.addMethod(_fogMethode);
				TEX_Hair[i] = material;
				_materials.push(material);
			}
			
			
			// apply light and effect for all material
			for (i = 0; i < _materials.length; i++)
			{
				_materials[i].lightPicker = _lightPicker;
				_materials[i].diffuseLightSources = LightSources.PROBES;
				_materials[i].specularLightSources = LightSources.LIGHTS;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 1;
				if (i != 0)
					_materials[i].addMethod(_rimLightMethod);
			}
			
			// global reflection methode
			if (_isReflection)
				initReflection();
		}
		
		//-------------------------------------------------------------------------------
		//       REFLECTION
		//-------------------------------------------------------------------------------
		
		private function initReflectionCube():void
		{
			_reflectionTexture = new CubeReflectionTexture(128 * 2);
			_reflectionTexture.farPlaneDistance = fogFar;
			_reflectionTexture.nearPlaneDistance = 250;
			_reflectionTexture.position = new Vector3D(0, 200, 0);
		}
		
		private function initReflection():void
		{
			if (_isReflection)
				return;
			_isReflection = true;
			initReflectionCube();
			_fresnelMethod = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod.normalReflectance = .5;
			_fresnelMethod.fresnelPower = 0.6;
			_fresnelMethod.alpha = 0.4;
			
			//_materials[1].addMethod(_fresnelMethod);
		}
		
		//-------------------------------------------------------------------------------
		//       3D OBJECT 
		//-------------------------------------------------------------------------------
		
		private function initAfterBitmapLoad():void
		{
			// Init material and objects
			initMaterials();
			
			// create skybox
			randomSky();
			
			// basic ground
			_ground = new Mesh(new PlaneGeometry(fogFar * 2, fogFar * 2), _groundMaterial);
			_ground.geometry.scaleUV(60, 60);
			_ground.y = 0;
			_ground.castsShadows = false;
			_view.scene.addChild(_ground);
			
			// Avatar character mesh referency
			_skinMesh = new Vector.<Mesh>();
			// hair style clone referency
			_cloneStyleMan = new Vector.<Mesh>();
			_cloneStyleWoman = new Vector.<Mesh>();
			
			load("avatar/avatar.awd");
		}
		
		//-------------------------------------------------------------------------------
		//
		//   oo  RENDER LOOP   
		//
		//-------------------------------------------------------------------------------
		
		private function onEnterFrame(event:Event = null):void
		{
			if (_sunLight.ambient < 0.5)
				_sunLight.ambient += 0.01;
			
			updateClone();
			
			_cameraController.update();
			
			// update view
			_view.render();
		}
		
		//-------------------------------------------------------------------------------
		//   >>  GLOBAL LISTENER
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
		
		//-------------------------------------------------------------------------------
		//   ||  PAUSE render
		//-------------------------------------------------------------------------------
		
		private function grayPauseEffect():void
		{
			_capture = new BitmapData(_stage3DProxy.width, _stage3DProxy.height, true, 0x991D1D1D);
			
			// damn no way to copy view !!!
			//_capture.draw(_view.stage3DProxy.context3D.)
			//_view.renderer.
			// _stage3DProxy.context3D.drawToBitmapData
			//_stage3DProxy.context3D.drawToBitmapData(_capture);
			//_view.renderer.swapBackBuffer = true;
			
			// add Black and white effect
			_capture.applyFilter(_capture, _capture.rect, new Point(), BitmapMapper.grayScale());
			_topPause.graphics.beginBitmapFill(_capture, null, false, false);
			_topPause.graphics.drawRect(0, 0, stage.width, stage.height);
			_topPause.graphics.endFill();
		}
		
		private function removeGrayPauseEffect():void
		{
			_topPause.graphics.clear();
			_capture = null;
		}
		
		//-------------------------------------------------------------------------------
		//       LOAD binary files
		//-------------------------------------------------------------------------------
		
		private function load(url:String):void
		{
			_currentLoadFile = url;
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
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorImage, false, 0, true);
			loader.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
			loader.load(new URLRequest(ASSETS_ROOT + url));
		}
		
		private function onErrorImage(e:ErrorEvent):void
		{
			log(e.text.toUpperCase() + " on " + _currentLoadFile);
		}
		
		private function loadProgress(e:ProgressEvent):void
		{
			var P:int = int(e.bytesLoaded / e.bytesTotal * 100);
			log('LOADING : ' + P + ' % | ' + int((e.bytesLoaded / 1024) << 0) + ' ko');
		}
		
		//-------------------------------------------------------------------------------
		//      Bitmaps Parser
		//-------------------------------------------------------------------------------
		
		private function parseBitmap(e:Event):void
		{
			var urlLoader:URLLoader = URLLoader(e.target);
			var loader:Loader = new Loader();
			loader.loadBytes(urlLoader.data);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapComplete, false, 0, true);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			urlLoader.removeEventListener(Event.COMPLETE, parseBitmap);
			urlLoader = null;
		}
		
		private function onBitmapComplete(e:Event):void
		{
			var loader:Loader = LoaderInfo(e.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			_bitmaps.push(e.target.content.bitmapData);
			loader.unload();
			loader = null;
			_num++;
			
			if (_num < _bitmapStrings.length)
				load(_bitmapStrings[_num]);
			else
				initAfterBitmapLoad();
		}
		
		//-------------------------------------------------------------------------------
		//       AWD Parser
		//-------------------------------------------------------------------------------
		
		private function parseAWD(e:Event):void
		{
			var urlLoader:URLLoader = e.target as URLLoader;
			var loader3d:Loader3D = new Loader3D(false);
			loader3d.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete, false, 0, true);
			loader3d.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete, false, 0, true);
			loader3d.loadData(urlLoader.data, null, null, new AWD2Parser());
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			urlLoader.removeEventListener(Event.COMPLETE, parseAWD);
			urlLoader = null;
		}
		
		/**
		 * Listener function for AWD asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			var mesh:Mesh;
			// ++ Skeleton referency same for man and woman
			if (event.asset.assetType == AssetType.SKELETON) {
				_squeleton = event.asset as Skeleton;
				_animationSetSquel = new SkeletonAnimationSet(2);
				// ++ animation by name 
			} else if (event.asset.assetType == AssetType.ANIMATION_NODE) {
				var animationNode:SkeletonClipNode = event.asset as SkeletonClipNode;
				_animationSetSquel.addAnimation(animationNode);
			}
				
			else if (event.asset.assetType == AssetType.MESH) {
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
		
		//-------------------------------------------------------------------------------
		//
		//      AVATAR DEFINE AND PLACE
		//
		//-------------------------------------------------------------------------------
		
		private function onResourceComplete(e:LoaderEvent):void
		{ 
			var loader3d:Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			
			populate(20, 20, 60);
			
			log(message());
			initListeners();
			
			_isIntro = false;
		}
		
		//-------------------------------------------------------------------------------
		//       CLONE
		//-------------------------------------------------------------------------------
		
		/** 
		 * Populate Clones
		 */
		private function populate(n:int = 10, l:int = 10, sx:int = 50, sz:int = 50):void
		{
			if (!_clones) _clones = new Vector.<Mesh>(n);
			var m:Mesh;
			var j:int, k:int;
			for (var i:int = 0; i < n; ++i) {
				m = addAvatar(1.2);
				m.z = (j * sz);
				k = (i - (j * l));
				m.x = -((l * sx) >> 1) + (k * sx) + (sx / 2);
				m.y = 0//Terrain.getHeightAt(m.x, -m.z)
				m.mouseEnabled = m.mouseChildren = false;    
				_view.scene.addChild(m);
				_clones[i] = m;
				
				if (k == l - 1)
					j++;
			}
			_clones.fixed = true;
		}
		
		/** Duplicate Man or Woman into Avatar with self animation */
		public function addAvatar(Scale:Number = 1, AnimNum:int = -1):Mesh 
		{
			if (!animators) animators = new Vector.<SkeletonAnimator>();
			if (!chromosomes) chromosomes = new Vector.<int>();
			if (!_cloneHair) _cloneHair = new Vector.<Mesh>();
			
			// 0:man 1:woman
			var sex:int = rand(1)+1; 
			var hair:Mesh;
			var skin:Mesh = _skinMesh[sex - 1].clone() as Mesh;
			
			// random skin material 
			skin.material = TEX_Avatar[int(Math.random()*10)];
			skin.scale( Scale );
			
			// choose random hair style;
			if (sex == 1) hair = _cloneStyleMan[rand(_cloneStyleMan.length - 1)].clone() as Mesh;
			else hair = _cloneStyleWoman[rand(_cloneStyleWoman.length - 1)].clone() as Mesh;
			hair.material = TEX_Hair[int(Math.random()*10)];
			skin.addChild(hair);
			
			// create new animator
			var animator:SkeletonAnimator = new SkeletonAnimator(_animationSetSquel, _squeleton);
			
			// play random animation or Anim
			var num:int
			if (AnimNum == -1) num = int(Math.random() * 3);
			else num = AnimNum;
			
			var anim:String;
			if (sex == 1) anim = SEQUENCE_MAN[num];
			else anim = SEQUENCE_WOMEN[num];
			animator.playbackSpeed = SEQSPEED[num];
			//animator.play(anim, stateTransition);
			skin.animator = animator;
			animator.play(anim);
			
			_cloneHair.push(hair);
			animators.push(animator);
			chromosomes.push(sex);
			return skin;
		}
		
		//-------------------------------------------------------------------------------
		//       ANIMATION
		//-------------------------------------------------------------------------------
		
		public function play(i:int, name:String, speed:Number = 0.5):void 
		{
			SkeletonAnimator(animators[i]).play(name, transition);
			animators[i].playbackSpeed = speed;
		}
		
		/** 
		 * Update Hair animation to follow head bone 
		 */
		public function updateClone():void 
		{
			for (var i:uint = 0; i < animators.length; i++) {
				_cloneHair[i].transform = animators[i].globalPose.jointPoses[15].toMatrix3D();
			}
		}
		
		public function deleteLast(skin:Mesh):void {
			var n:int = animators.length - 1;
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
		
		private static function rand(max:Number = 1, min:Number = 0):Number {
			return Math.floor(Math.random() * (max - min + 1)) + min;
		}
		
		//-------------------------------------------------------------------------------
		//       KEYBOARD
		//-------------------------------------------------------------------------------
		
		/**
		 * Key down listener for animation
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: //fr
					
					break;
				case Keyboard.DOWN: 
				case Keyboard.S:
					
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: //fr
					
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
				case Keyboard.V: 
					initReflection();
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
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: //fr
				case Keyboard.DOWN: 
				case Keyboard.S:
					
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: //fr
				case Keyboard.RIGHT: 
				case Keyboard.D:
					
					break;
			}
		}
		
		//-------------------------------------------------------------------------------
		//       STAGE AND MOUSE
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
			_menu.y = stage.stageHeight;
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
		
		//-------------------------------------------------------------------------------
		//       Interface   
		//-------------------------------------------------------------------------------
		
		private function initSetting():void
		{
			_menu = new Sprite();
			addChild(_menu);
			_menu.y = stage.stageHeight;
			Style.setStyle("dark");
			Style.BUTTON_FACE = 0x060606;
			Style.DROPSHADOW = 0x000000;
			Style.BACKGROUND = 0x000000;
			Style.BUTTON_DOWN = 0x995522;
			Style.LABEL_TEXT = 0xffffff;
			new PushButton(_menu, 180, -39, ">", showSetting).setSize(40, 40);
		}
		
		private function showSetting(e:MouseEvent):void
		{
		}
		
		private function initText():void
		{
			_topPause = new Sprite();
			addChild(_topPause);
			
			_text = new TextField();
			var format:TextFormat = new TextFormat("Helvetica", 9, 0xdddddd);
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
			
			// add signature
			addChild(_signature = new SignatureSwf());
			_signature.y = stage.stageHeight - _signature.height;
			_signature.x = 10;
		}
		
		private function message():String
		{
			var mes:String = "";
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