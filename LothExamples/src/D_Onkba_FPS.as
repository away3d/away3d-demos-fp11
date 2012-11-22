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
	
	import utils.VectorSkyEffects;
	import utils.BitmapMapper;
    
    import physics.*;
    
    import com.bit101.components.Style;
    import com.bit101.components.Component;
	import com.bit101.components.PushButton;
    
	public class D_Onkba_FPS extends Sprite
	{
		[Embed(source="/../embeds/signature.swf", symbol="Signature")]
		public var SignatureSwf:Class;
		
		private static const ASSETS_ROOT:String = "assets/";
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
		private var _hero2:Mesh;
		// materials
		private var _boxMaterial:TextureMaterial;
		private var _gunMaterial:TextureMaterial;
		private var _gunMaterial2:TextureMaterial;
		private var _boneMaterial:TextureMaterial;
		private var _heroMaterial:TextureMaterial;
		private var _shereMaterial:TextureMaterial;
		private var _terrainMaterial:TextureMaterial;
		private var _eyesOpenMaterial:TextureMaterial;
		private var _eyesClosedMaterial:TextureMaterial;
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
		private var _blendmodes:Array = ["add", "darken", "hardlight", "lighten",  "multiply",  "overlay",  "screen", "subtract"];
		
		// hero animation variables
		private const ANIMATION:Array = ["Idle", "Walk", "WalkL", "WalkR", "Run", "CrouchIdle", "CrouchWalk", "Reload", "WaterIdle", "WaterSwim", "StandBack", "StandFace", "JumpDown"];
		private const WEAPON:Array = ["", "Gun", "Machine", "Sniper", "Gatling", "Bazooka"];
		private const AMMO:Array = ["", "", "", "", "", "Rocket"];
		private var _animationSet:SkeletonAnimationSet;
		private var _transition:CrossfadeTransition;
		private var _animator:SkeletonAnimator;
		private const ROTATION_SPEED:Number = 3;
		private const RELOAD_SPEED:Number = 1;
		private const IDLE_SPEED:Number = 0.7;
		private const JUMP_SPEED:Number = 1;
		private const WALK_SPEED:Number = 1;
		private const RUN_SPEED:Number = 1;
		private var movementDirection:Number;
		private var currentAnim:String;
		private var currentWeapon:uint;
		// animation phase
		private var isSideMove:Boolean;
		private var isRunning:Boolean;
		private var isCrouch:Boolean;
		private var isMoving:Boolean;
		private var isJump:Boolean;
		
		// hero dynamique eye
		private var _eyePosition:Vector3D; 
		private var _eyes:ObjectContainer3D;
		private var _eyeLook:Mesh;
		private var _eyeL:Mesh;
		private var _eyeR:Mesh;
		private var _eyeCount:int;
		
		// navigation
		private var _prevMouseX:Number;
		private var _prevMouseY:Number;
		private var _mouseMove:Boolean;
		private var _cameraHeight:Number = -100//40;
		
		// demo testing
		private var _isIntro:Boolean = true;
		private var _isReflection:Boolean;
		private var _dynamicsEyes:Boolean;
		private var _cloneActif:Boolean;
		private var _debugRay:Boolean;
		private var _isRender:Boolean;
		
        private var _currentLoadFile:String;
		private var _signature:Sprite;
		private var _text:TextField;
        private var _capture:BitmapData;
        private var _topPause:Sprite;
        
		// optional physics engine
		private var _physics:Object;
		private var _menu:Sprite;
        
		/**
		 * Constructor
		 */
		public function D_Onkba_FPS()
		{
			_bitmaps = new Vector.<BitmapData>();
			_bitmapStrings = new Vector.<String>();
            // sky Bitmap
			_bitmapStrings.push("sky/negy.jpg", "sky/posy.jpg", "sky/posx.jpg", "sky/negz.jpg", "sky/posz.jpg", "sky/negx.jpg");
			// terrain map 6 7 8
			_bitmapStrings.push("rock.jpg", "sand.jpg", "arid.jpg" );
            // terrain map 9 10
			_bitmapStrings.push("height.png", "height_n.jpg");
			// hero map 11 12 13
			_bitmapStrings.push("onkba/onkba_diffuse.png", "onkba/onkba_normals.jpg", "onkba/onkba_lightmap.jpg");
			// gun map 14 15 16
			_bitmapStrings.push("onkba/weapon_diffuse.jpg", "onkba/weapon_normals.jpg", "onkba/weapon_lightmap.jpg");
			// bazooka map 17 18 19
			_bitmapStrings.push("onkba/weapon2_diffuse.jpg", "onkba/weapon2_normals.jpg", "onkba/weapon2_lightmap.jpg");
			
			
			if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		/**
		 * Global initialise function
		 */
		private function init(e:Event=null):void
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
			if (!_isIntro) {
				skyColor = 0xFFFFFF * Math.random();
				fogColor = 0xFFFFFF * Math.random();
				blend = _blendmodes[uint(Math.random() * _blendmodes.length)];
			}
			
			// add real sky bitmap
			if (_skyBitmaps == null) {
				_skyBitmaps = new Vector.<BitmapData>(6);
				for (i = 0; i < 6; i++) {
					_skyBitmaps[i] = _bitmaps[i];
				}
			}
			if (_sky) {  
				_view.scene.removeChild(_sky);
				_sky.dispose();
			}
			
			_skyMap = VectorSkyEffects.vectorSky(skyColor, fogColor, fogColor, 8, _skyBitmaps, blend);
			_fogMethode.fogColor = fogColor;
			_skyProbe.diffuseMap = _skyMap;
			_sky = new SkyBox(_skyMap);
			_view.scene.addChild(_sky);
			
			// test rim Light methode slow down engine
			for ( i=0; i < _materials.length; i++ ) { _materials[i].removeMethod(_rimLightMethod); }
			_rimLightMethod = new RimLightMethod(skyColor, 0.5, 2.5, RimLightMethod.ADD);
			for ( i = 0; i < _materials.length; i++ ) { _materials[i].addMethod(_rimLightMethod); }
		}
		
		//-------------------------------------------------------------------------------
		//
		//       MATERIAL
		//
		//-------------------------------------------------------------------------------
		
		private function initMaterials():void
		{
			_materials = new Vector.<TextureMaterial>();
			
			var tiles:Array = [1, 100, 100, 100];
			var sTexture:Array = [Cast.bitmapTexture(_bitmaps[6]), Cast.bitmapTexture(_bitmaps[7]), Cast.bitmapTexture(_bitmaps[8])];
			_terrainMethod = new TerrainDiffuseMethod(sTexture, Cast.bitmapTexture(_bitmaps[9]) , tiles);
			
			// global shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0005;
			
			// global Rim light method
			_rimLightMethod = new RimLightMethod(skyColor, 0.5, 2, RimLightMethod.ADD);
			
			// global fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW >> 1, fogColor);
			
			// 0- hero
			_heroMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[11]));
			_heroMaterial.normalMap = Cast.bitmapTexture(_bitmaps[12]);
			_heroMaterial.specularMap = Cast.bitmapTexture(_bitmaps[13]);
			_heroMaterial.gloss = 25;
			_heroMaterial.specular = 0.5;
			_heroMaterial.alphaThreshold = 0.9;
			_heroMaterial.alphaPremultiplied = true;
			_materials[0] = _heroMaterial;
			
			// 1- weapon
			_gunMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[14]));
			_gunMaterial.normalMap = Cast.bitmapTexture(_bitmaps[15]);
			_gunMaterial.specularMap = Cast.bitmapTexture(_bitmaps[16]);
			_gunMaterial.gloss = 20;
			_gunMaterial.specular = 0.8;
			_materials[1] = _gunMaterial;
			
			// 2- eye ball close
			var b:BitmapData;
			b = new BitmapData(64, 64, false, 0xA13D1E);
			_eyesClosedMaterial = new TextureMaterial(Cast.bitmapTexture(b));
			_eyesClosedMaterial.gloss = 12;
			_eyesClosedMaterial.specular = 0.6;
			_materials[2] = _eyesClosedMaterial;
			
			// 3- eye ball open from bitmap diffuse onkba
			b = new BitmapData(256/2, 256/2, false);
			b.draw(_bitmaps[11], new Matrix(1, 0, 0, 1, -283/2, -197/2));
			_eyesOpenMaterial = new TextureMaterial(Cast.bitmapTexture(b));
			_eyesOpenMaterial.gloss = 100;
			_eyesOpenMaterial.specular = 0.8;
			_materials[3] = _eyesOpenMaterial;
			
			// 4- sphere reflection test
			_shereMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64,false, 0x00)));
			_shereMaterial.gloss = 90;
			_shereMaterial.specular = 4;
			_shereMaterial.repeat = true;
			_shereMaterial.addMethod(_fogMethode);
			_materials[4] = _shereMaterial;
			
			// 5- terrain
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(_bitmaps[9]));
			
			_terrainMaterial.normalMap = Cast.bitmapTexture(_bitmaps[10]);
			_terrainMaterial.diffuseMethod = _terrainMethod;
			_terrainMaterial.gloss = 20;
			_terrainMaterial.specular = .25;
			_terrainMaterial.addMethod(_fogMethode);
			_materials[5] = _terrainMaterial;
			
			// 6- simulation box 
			_boxMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64, true, 0xee100000)));
			_boxMaterial.gloss = 10;
			_boxMaterial.specular = 0.1;
			_boxMaterial.alphaBlending = true;
			_boxMaterial.addMethod(_fogMethode);
			_materials[6] = _boxMaterial;
			
			// 7- Xray bones 
			_boneMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64, true, 0xee00ff00)));
			_boneMaterial.gloss = 10;
			_boneMaterial.specular = 0.1;
			_boneMaterial.alphaBlending = true;
			_materials[7] = _boneMaterial;
			
			// 8- bazooka
			_gunMaterial2 = new TextureMaterial(Cast.bitmapTexture(_bitmaps[17]));
			_gunMaterial2.normalMap = Cast.bitmapTexture(_bitmaps[18]);
			_gunMaterial2.specularMap = Cast.bitmapTexture(_bitmaps[19]);
			_gunMaterial2.gloss = 20;
			_gunMaterial2.specular = 0.8;
			_materials[8] = _gunMaterial2;
			
			// for all material
			for (var i:int; i < _materials.length; i++ ) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].diffuseLightSources = LightSources.PROBES;
				_materials[i].specularLightSources = LightSources.LIGHTS;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 0.85;
				if (i != 5 || i!=3 || i!=2) _materials[i].addMethod(_rimLightMethod);
			}
		}
		
		//-------------------------------------------------------------------------------
		//       REFLECTION
		//-------------------------------------------------------------------------------
		
		private function initReflectionCube() : void
		{
			_reflectionTexture = new CubeReflectionTexture(128*2);
			_reflectionTexture.farPlaneDistance = FARVIEW;
			_reflectionTexture.nearPlaneDistance = 50;
			_reflectionTexture.position = new Vector3D(0, 0, 0);
		}
		
		private function initReflection() : void
		{
			if (_isReflection) return;
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
			_terrain = new Elevation(_terrainMaterial, Cast.bitmapData(_bitmaps[9]), FARVIEW * 2, MOUNTAIGN_TOP, FARVIEW * 2, 250, 250);
			_view.scene.addChild(_terrain);
			
			// weapon referency
			_weapons = new Vector.<Mesh>(WEAPON.length);
			_weapons[0] = new Mesh(new CubeGeometry(1,1,1), null);
			
			// load Onkba character with weapons
			load("onkba/onkba_fps.awd");
		}
		
		//-------------------------------------------------------------------------------
		//
		//   oo  RENDER LOOP   
		//
		//-------------------------------------------------------------------------------
		
		private function onEnterFrame(event:Event = null):void
		{
			if (_sunLight.ambient < 0.5)_sunLight.ambient += 0.01;
			
			if (_physics)_physics.update();
			
			if (_hero) {
				if (_dynamicsEyes) updateEyes();
				if (_debugRay) updateBones();
				// hand bone for weapon
				if (_animator.globalPose.numJointPoses >= 22) {
					_heroWeapon.transform = _animator.globalPose.jointPoses[22].toMatrix3D();
				}
			}
			
			if ( _cameraController.distance > 300 && _isIntro) _cameraController.distance --; 
			else  _isIntro = false;
			_cameraController.lookAtPosition = new Vector3D(_player.x, _player.y+_cameraHeight, _player.z);
			_cameraController.update();
			
			if (_isReflection) {
				_reflectionTexture.position = _bigBall.position;
				_reflectionTexture.render(_view);
			}
			
			_view.render();
		}
		
		//-------------------------------------------------------------------------------
		//   >>  GLOBAL LISTENER
		//-------------------------------------------------------------------------------
		
		private function initListeners(e:Event=null):void
		{
           
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
		//   ||  PAUSE render
		//-------------------------------------------------------------------------------
		
		private function grayPauseEffect():void
		{
            _capture = new BitmapData(_stage3DProxy.width, _stage3DProxy.height, true, 0x991D1D1D);
            //_stage3DProxy.stage3D.context3D
           // _view.stage3DProxy.context3D.drawToBitmapData(_capture2);
          //  _capture2.draw(_view, null, null, null, new Rectangle(200, 200), false);
           /* _capture = addChild(new Bitmap(new BitmapData(465, 465, false, 0x000000))) as Bitmap ;
            */
           // _capture.applyFilter(_capture, _capture.rect, new Point(), grayScale());
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
			_num++;
			_bitmaps.push(e.target.content.bitmapData);
			// Clean loader
			var loader:Loader = LoaderInfo(e.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			loader.unload();
			loader = null;
			// Load next
			if (_num < _bitmapStrings.length) load(_bitmapStrings[_num]);
			else initAfterBitmapLoad();
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
		 *  AWD asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			var i:int
			if (event.asset.assetType == AssetType.SKELETON) {
				// Create a new skeleton animation set with 4 joints per vertex
				// and Wrap in an animator object 
				_animationSet = new SkeletonAnimationSet(4);
				_animator = new SkeletonAnimator(_animationSet, event.asset as Skeleton);
				
			} else if (event.asset.assetType == AssetType.ANIMATION_NODE) {
				// Add each animation node to the animation set 
				// for detail see sequenceFPS.txt in /3dsmax
				var animationNode:SkeletonClipNode = event.asset as SkeletonClipNode;
				_animationSet.addAnimation(animationNode);
				// disable animation loop 
				for ( i = 0; i< WEAPON.length; i++ ) {
					if (animationNode.name == WEAPON[i] + "JumpDown") animationNode.looping = false;
					if (animationNode.name == WEAPON[i] + "Reload") animationNode.looping = false;
				}
				
			} else if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				
				// Onkba object
				if (mesh.name == "Onkba") {
					_hero = mesh;
				}
                
				// Weapons object
				for ( i = 0; i < WEAPON.length; i++ ) {
					if (mesh.name == WEAPON[i] + 'Test') {
						if (i == 1) { mesh.rotationY = -5; mesh.rotationZ = 0; mesh.rotationX = 0; mesh.z = 1.6;  mesh.y =-4.2;  }// decal for gun
						if (i == 2) { mesh.rotationY = -5; mesh.rotationZ = -2; mesh.rotationX = 0; mesh.z = 1.6; mesh.y =-5; }// decal for machine
						if (i == 3) { mesh.rotationY = -5; mesh.rotationZ = -5;  mesh.rotationX = 0; mesh.z = 1.8; mesh.y = -4.6; }// decal for sniper
						if (i == 5) {mesh.rotationY = 6; mesh.rotationZ = -6; mesh.x = 5; mesh.y =2;mesh.z =-4}// decal for bazooka
						
						if (i != 5) mesh.material = _gunMaterial;
						else mesh.material = _gunMaterial2;
						_weapons[i] = mesh;
					}
				}
			}
		}
		
		/**
		 *  AWD resource complete event on loader
		 */
		private function onResourceComplete(e:LoaderEvent):void
		{
			var loader3d:Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			var posY:Number = (96 * SCALE);
			
			_transition = new CrossfadeTransition(0.3);
			
			//apply our _animator to our mesh
			_hero.animator = _animator;
			_hero.material = _heroMaterial;
			_hero.scale(SCALE);
			
			// add weapon container
			_heroWeapon = new Mesh(new CubeGeometry(1, 1, 1),null);
			_hero.addChild(_heroWeapon);
			
			_player.addChild(_hero);
            
			_hero.rotationY = 180;
			_hero.y =  -posY//_terrain.getHeightAt(0, 0)-200; //-posY;
            
			// Optional dynamic eyes ball
			_heroPieces = new ObjectContainer3D();
			_heroPieces.scale(SCALE);
			_heroPieces.y = -posY;
			_player.addChild(_heroPieces);
			_heroPieces.rotationY = 180;
			addHeroEye();
			
			
			if (_isIntro) {
				isJump = true;
				_animator.playbackSpeed = -JUMP_SPEED;
				jumpDown();
			}
			
			// big ball
			_bigBall = new Mesh(new SphereGeometry(120, 60, 40), _shereMaterial);
			_view.scene.addChild(_bigBall);
			_bigBall.position = new Vector3D( -300, _terrain.getHeightAt( -200, -100) +120);
			// global reflection methode
			//initReflection();
			
			// add some box for fun 
			var num:int = 100;
			var mesh:Mesh, posX:Number, posZ:Number;
			_cubeVector = new Vector.<Mesh>(num);
			for (var i:int = 0; i < num; i++) {
				posX = Number(-(FARVIEW*0.5) + (Math.random() * FARVIEW));
				posZ = Number(-(FARVIEW*0.5) + (Math.random() * FARVIEW));
				mesh = new Mesh(new CubeGeometry(150, 300, 150), _boxMaterial);
				mesh.position =  new Vector3D(posX, _terrain.getHeightAt(posX, posZ) +(150), posZ);
				
				_view.scene.addChild(mesh);
				_cubeVector[i] = mesh;
			}
			
			log(message());
			initListeners();
			
			
			// start away3d physics 
			initPhysicsEngine();
		}
		
		//-------------------------------------------------------------------------------
		//       CHARACTER OPTIONS
		//-------------------------------------------------------------------------------
		
		/**
		 * Weapons collection
		 */
		private function switchWeapon(next:Boolean=true):void
		{
			if (next) currentWeapon++;
			if (currentWeapon > 5) currentWeapon = 0;
			for (var i:int; i < _heroWeapon.numChildren; i++ ) {
				_heroWeapon.removeChild(_heroWeapon.getChildAt(i));
			}
			_heroWeapon.addChild(_weapons[currentWeapon]);
			// Play idle animation
			stop();
		}
		
		/**
		 * Test some Clones
		 */
		private function makeClone(n:int=20):void
		{
			if (!_cloneActif) {
				_cloneActif = true;
				var g:Mesh;
				var decal:int = -(n * 100) / 2;
				for (var j:int = 1; j < n; j++) {
					for (var i:int = 1; i < n; i++) {
						g = Mesh(_hero.clone());
						g.x = decal + (100 * i);
						g.z = (decal + (100 * j));
						g.y = _terrain.getHeightAt(g.x, g.z);
						if (g.x != 0 || g.z != 0)
							_view.scene.addChild(g);
					}
				}
			}
		}
		
		//-------------------------------------------------------------------------------
		//       CHARACTER ANIMATION
		//-------------------------------------------------------------------------------
		
		/**
		 * Character breath animation
		 */
		private function stop():void
		{
			var anim:String;
			if (isCrouch) anim = WEAPON[currentWeapon] + ANIMATION[5];
			else anim = WEAPON[currentWeapon] + ANIMATION[0];
			
			if (currentAnim == anim) return;
			
			currentAnim = anim;
			_animator.playbackSpeed = IDLE_SPEED;
			if (isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[5];
			else currentAnim = WEAPON[currentWeapon] + ANIMATION[0];
			_animator.play(currentAnim, _transition);
		}
		
		/**
		 * Character Mouvement
		 */
		private function updateMovement(dir:Number):void
		{
			isMoving = true;
			var anim:String = isRunning ? "Run" : "Walk";
			
			if (currentAnim == anim) return;
			
			if(_physics) _physics.characterSpeed(isRunning ? 3 : 1)
			_animator.playbackSpeed = dir * (isRunning ? RUN_SPEED : WALK_SPEED);
			if (isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[6];
			else currentAnim = WEAPON[currentWeapon] + anim;
			_animator.play(currentAnim, _transition);
		}
		
		/**
		 * Character Mouvement side
		 */
		private function updateMovementSide(dir:Number):void
		{
			isSideMove = true;
			var anim:String;
			
			if (dir > 0) anim = 'WalkL';
			else anim = 'WalkR';
			
			if (isCrouch) return
			else currentAnim = WEAPON[currentWeapon] + anim;
			_animator.play(currentAnim, _transition);
		}
		
		/**
		 * Character reload animation
		 */
		private function reload():void
		{
			var anim:String;
			if (isCrouch) anim = WEAPON[currentWeapon] + 'CrouchReload';
			else anim = WEAPON[currentWeapon] + 'Reload';
			
			if (currentAnim == anim)  return;
			
			currentAnim = anim;
			_animator.playbackSpeed = RELOAD_SPEED;
			_animator.play(currentAnim, _transition, 0);
		}
		
		/**
		 * Character jump up animation
		 */
		private function jumpUp():void
		{
			isJump = true;
			var anim:String;
			anim = WEAPON[currentWeapon] + 'JumpDown';
			
			if (currentAnim == anim)  return;
			
			currentAnim = anim;
			_animator.playbackSpeed = -JUMP_SPEED;
			_animator.play(currentAnim, _transition, 0);
			
			setTimeout(jumpDown, 260);
		}
		
		/**
		 * Character jump down animation
		 */
		private function jumpDown():void
		{
			var anim:String;
			anim = WEAPON[currentWeapon] + 'JumpDown';
			
			currentAnim = anim;
			_animator.playbackSpeed = JUMP_SPEED;
			if (_isIntro) { _animator.play(currentAnim, null, 1); _animator.playbackSpeed = 0.2; setTimeout(stop, 3000); }
			else {_animator.play(currentAnim, _transition, 0);
				setTimeout(stop, 260);}
		}
		
		//-------------------------------------------------------------------------------
		//   ||oo||   KEYBOARD
		//-------------------------------------------------------------------------------
		
		/**
		 * Key down listener 
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT: 
					isRunning = true;
					if (isMoving) updateMovement(movementDirection);
					break;
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: //fr
					updateMovement(movementDirection = 1);
					if (_physics){_physics.key_forward(true);}
					break;
				case Keyboard.DOWN: 
				case Keyboard.S: 
					updateMovement(movementDirection = -1);
					if (_physics){_physics.key_Reverse(true);}
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: //fr
					if (!isMoving)updateMovementSide(1);
					if (_physics){_physics.key_Left(true);}
					break;
				case Keyboard.RIGHT: 
				case Keyboard.D: 
					if (!isMoving)updateMovementSide( -1);
					if (_physics){_physics.key_Right(true);}
					break;
				case Keyboard.R: 
					reload();
					break;
				case Keyboard.B: 
					makeClone();
					break;
				case Keyboard.N: 
					randomSky();
					break;
				case Keyboard.V: 
					initReflection();
					break;
				case Keyboard.U: 
					if(_physics) _physics.addDebug(_view);
					break;
				case Keyboard.P: 
					xRay();
					break;
				case Keyboard.O: 
					switchWeapon();
					break;
				case Keyboard.I: 
					fullScreen();
					break;
				case Keyboard.C: 
					if (isCrouch) { isCrouch = false; _cameraHeight = -100; }
					else {isCrouch = true; _cameraHeight = -150;}
					stop();
					break;
				case Keyboard.SPACE: 
					if (!isJump) {
						jumpUp();
						if (_physics) { _physics.key_Jump(true); }
					}
					break;
			}
		}
		
		/**
		 * Key up listener
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT: 
					isRunning = false;
					if (isMoving)
						updateMovement(movementDirection);
					break;
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: //fr
				case Keyboard.DOWN: 
				case Keyboard.S:
					isMoving = false;
					if (_physics) { _physics.key_forward(false); _physics.key_Reverse(false);  }
					stop();
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: //fr
				case Keyboard.RIGHT: 
				case Keyboard.D: 
					isSideMove = false;
					if (_physics) { _physics.key_Left(false); _physics.key_Right(false); }
					stop();
					break;
				case Keyboard.SPACE:
					isJump = false;;
					if (_physics){_physics.key_Jump(false);}
					break;
			}
		}
		
		//-------------------------------------------------------------------------------
		//       STAGE AND MOUSE FUNCTION
		//-------------------------------------------------------------------------------
		
		/**
		 * stage full screen
		 */
		private function fullScreen(e:Event=null):void 
		{
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		/**
		 * stage listener and mouse control
		 */
		private function onResize(event:Event=null):void
		{
            _stage3DProxy.width = stage.stageWidth;
            _stage3DProxy.height = stage.stageHeight;
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			_signature.y = stage.stageHeight - _signature.height;
            _menu.y = stage.stageHeight;
			if(!_isRender) onEnterFrame();
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
			e.target.showBounds = true;
			_eyeLook.visible = true;
			onMeshMouseMove(e);
		}
		
		/**
		 * mesh listener for mouse out interaction
		 */
		private function onMeshMouseOut(e:MouseEvent3D):void
		{
			e.target.showBounds = false;
			_eyeLook.visible = false;
			_eyeLook.position = _eyePosition;
		}
		
		/**
		 * mesh listener for mouse move interaction
		 */
		private function onMeshMouseMove(e:MouseEvent3D):void
		{
			_eyeLook.position = new Vector3D(e.localPosition.z + 6, e.localPosition.x, e.localPosition.y + 10);
		}
		
		//-------------------------------------------------------------------------------
		//       EYES dynamic    
		//-------------------------------------------------------------------------------
		
		public function addHeroEye():void
		{
			var eyeGeometry:SphereGeometry = new SphereGeometry(1, 32, 24);
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
			var mat:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, true, 0x00ffffff)));
			mat.alphaBlending = true;
			var zone:Mesh = new Mesh(new PlaneGeometry(12, 6, 1, 1), mat );
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
			
			_dynamicsEyes = true;
		}
		
		private function updateEyes():void
		{
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
				_eyeR.material = _eyesClosedMaterial;
				_eyeL.material = _eyesClosedMaterial;
			}
			if (_eyeCount > 309) {
				_eyeR.material = _eyesOpenMaterial;
				_eyeL.material = _eyesOpenMaterial;
				_eyeCount = 0;
			}
		}
		
		//-------------------------------------------------------------------------------
		//       XRAY view for bone debug    
		//-------------------------------------------------------------------------------
		
		private function xRay():void 
		{
			var m:Mesh;
			var j:Sprite3D;
			if (!_debugRay) {
				_debugRay = true;
				_heroMaterial.alpha = 0.5;
				_bonesFx = new Vector.<Mesh>(_animator.globalPose.numJointPoses);
				var mref0:Mesh = new Mesh(new CubeGeometry(3, 0.3, 0.3), _boneMaterial);
				var mref:Mesh = new Mesh(new CubeGeometry(0.7,0.7,0.7), _boneMaterial);
				mref.addChild(mref0); mref0.x = 1.5;
				for (var i:int = 0; i <_animator.globalPose.numJointPoses; i++) {
					m = Mesh(mref.clone());
					j =  new Sprite3D(materialBones( "bone " + i ), 4, 4);
					_hero.addChild(m);
					m.addChild(j);
					_bonesFx[i] = m;
				}
			} else { 
				_debugRay = false;
				_heroMaterial.alpha = 1;
				for ( i = 0; i <_bonesFx.length; i++) {
					m = _bonesFx[i];
					_hero.removeChild(m);
					m.dispose();
					_bonesFx[i] = null;
				}
			}
		}
		
		private function materialBones(name:String = 'bone'):TextureMaterial 
		{
			var material:TextureMaterial;
			var g:BitmapData = new BitmapData(128, 128, true, 0x00000000);
			var d:Sprite = new Sprite();
			var txt:TextField = new TextField();
			txt.defaultTextFormat = new TextFormat("Verdana", 30, 0x00FF00);
			txt.width = 128;
			txt.height = 128;
			txt.selectable = false;
			txt.mouseEnabled = false;
			txt.wordWrap = true;
			txt.filters = [new DropShadowFilter(1, 45, 0x000000, 1, 4, 4,2,2)];
			d.addChild(txt);
			txt.htmlText = name;
			g.draw(d);
			material = new TextureMaterial(Cast.bitmapTexture(g));
			material.alphaBlending = true;
			return material;
		}
		
		private function updateBones():void
		{
			for (var i:int = 0; i <_animator.globalPose.numJointPoses; i++) {
				_bonesFx[i].transform = _animator.globalPose.jointPoses[i].toMatrix3D();
			}
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
			_text.wordWrap = true;
			_text.selectable = false;
			_text.mouseEnabled = true;
			_text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			addChild(_text);
            
            // add signature
			addChild(_signature = new SignatureSwf());
			_signature.y = stage.stageHeight - _signature.height;
			_signature.x = 10;
		}
		
		public function message():String
		{
			var mes:String = "ARROW.WSAD.ZSQD - move\n";
			mes += "SHIFT - hold to run\n";
			mes += "R - reload weapon\n";
			mes += "O - next weapon\n";
			mes += "C - crouch\n\n";
			mes += "U - physics debug\n";
			mes += "I - full screen\n";
			mes += "N - random sky\n";
			mes += "P - xray bones\n";
			mes += "B - clone\n";
			return mes;
		}
		
		private function log(t:String):void
		{
			_text.htmlText = t;
		}
		
		
		
		// AUTHOR NOTE 
		// Now you can choose you physics engine or don't use any physics 
		// juste disable part you don't whant
		
		//-------------------------------------------------------------------------------
		//
		//       no PHYSICS engines    
		//
		//-------------------------------------------------------------------------------
		
		private function initPhysicsEngine(name:String = 'none'):void 
		{
		
		}
        
		//-------------------------------------------------------------------------------
		//
		//       JIGLIB PHYSICS engines    
		//
		//-------------------------------------------------------------------------------
		/*
		private function initPhysicsEngine(name:String = 'Physics'):void 
		{
		
		}
		*/
		//-------------------------------------------------------------------------------
		//
		//       AWAY PHYSICS engines    
		//
		//-------------------------------------------------------------------------------
		
		/*private function initPhysicsEngine(name:String = 'Physics'):void 
		{
			_physics = AwayPhysics.getInstance();
			
			// add terrain to physic collision 
			_physics.addTerrain(_terrain);
			
			// add player character physics 
			_physics.addCharacter(_player, new Vector3D(0, 400, 0));
			
			// add the big ball
			_physics.addObject(_bigBall, { type:'sphere', r: 120, mass: 1, pos: _bigBall.position } );
			
			// add all cubes
			var size:int;
			var isUnactif:Boolean = false;
			for (var i:int = 0; i < _cubeVector.length; i++) {
				_physics.addObject(_cubeVector[i], { stop:isUnactif, w: 150, h: 300, d: 150, mass: 1, pos: _cubeVector[i].position });
			}
		}*/
		
		
		
	}
}