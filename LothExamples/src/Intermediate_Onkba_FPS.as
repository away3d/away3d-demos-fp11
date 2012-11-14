/*

AWD file loading example in Away3d

Demonstrates:

How to use the Loader3D object to load an embedded internal awd model.
How to create character interaction in physic world
How to set custom material on a model.

Code by Rob Bateman and LoTh
rob@infiniteturtles.co.uk
http://www.infiniteturtles.co.uk
3dflashlo@gmail.com
http://3dflashlo.wordpress.com

Model and Map by LoTH
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
	import away3d.animators.data.Skeleton;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.extrusions.Elevation;
	
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.core.base.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.library.assets.*;
	import away3d.lights.*;
	import away3d.lights.shadowmaps.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.setTimeout;
	
	import utils.VectorSkyEffects;
	
	[SWF(backgroundColor="#333338", frameRate="60", quality="LOW")]
	public class Intermediate_Onkba_FPS extends Sprite
	{
		// signature swf
		[Embed(source="/../embeds/signature.swf", symbol="Signature")]
		public var SignatureSwf:Class;
		
		private static const FARVIEW:Number = 30000;
		private static const MOUNTAIGN_TOP:Number = 2000;
		private static const SCALE:Number = 2;
		
		private var assetsRoot:String = "assets/onkba/";
		private var textureStrings:Vector.<String>;
		private var textureBitmapData:Vector.<BitmapData>;
		private var n:uint = 0;
		
		private var sunColor:uint = 0xAAAAA9;
		private var sunAmbient:Number = 0.5;
		private var sunDiffuse:Number = 0.0;
		private var sunSpecular:Number = 1.3;
		private var skyColor:uint = 0x333338;
		private var skyAmbient:Number = 0.1;
		private var skyDiffuse:Number = 0.0;
		private var skySpecular:Number = 1.3;
		private var fogColor:uint = 0x333338;
		private var zenithColor:uint = 0x445465;
		private var fogNear:Number = 1000;
		
		
		// engine variables
		private var _view:View3D;
		private var _stats:AwayStats;
		private var _signature:Sprite;
		private var _lightPicker:StaticLightPicker;
		private var _cameraController:HoverController;
		
		// light variables
		private var _sunLight:DirectionalLight;
		private var _skyLight:PointLight;
		private var _skyProbe:LightProbe;
		private var _sky:SkyBox;
		
		// material methode
		private var _fogMethode:FogMethod;
		private var _specularMethod:FresnelSpecularMethod;
		private var _shadowMethod:NearShadowMapMethod;
		private var _rimLightMethod:RimLightMethod;
		private var _terrainMethod:TerrainDiffuseMethod 
		// reflection methode
		private var _reflectionTexture:CubeReflectionTexture;
		private var _fresnelMethod:FresnelEnvMapMethod;
		
		// sky
		private var _skyMap:BitmapCubeTexture;
		private var _skyBitmaps:Vector.<BitmapData>;
		private var _blendmodes:Array = ["add", "darken", "hardlight", "lighten",  "multiply",  "overlay",  "screen", "subtract"];
		
		// materials
		private var _materials:Vector.<TextureMaterial>;
		private var _groundMaterial:TextureMaterial;
		private var _terrainMaterial:TextureMaterial;
		private var _boxMaterial:TextureMaterial;
		private var _heroMaterial:TextureMaterial;
		private var _gunMaterial:TextureMaterial;
		private var _eyesClosedMaterial:TextureMaterial;
		private var _eyesOpenMaterial:TextureMaterial;
		
		// terrain
		private var _terrain:Elevation;
		
		// hero animation variables
		private var transition:CrossfadeTransition = new CrossfadeTransition(0.3);
		private var animator:SkeletonAnimator;
		private var animationSet:SkeletonAnimationSet;
		private var currentRotationInc:Number=0;
		private var movementDirection:Number;
		
		private var currentAnim:String;
		private var currentWeapon:int = 0;
		
		private const WEAPON:Array = ['', 'Gun', 'Machine', 'Sniper', 'Gatling', 'Bazooka']
		private const AMMO:Array = ['', '', '', '', '', 'Rocket']
		private const ANIMATION:Array = ['Idle', 'Walk', 'WalkL', 'WalkR', 'Run', 'CrouchIdle', 'CrouchWalk', 'Reload', 'WaterIdle', 'WaterSwim', 'StandBack', 'StandFace', 'JumpDown'];
		
		// animation 
		private const ANIM_BREATHE:String = "Idle";
		private const ANIM_WALK:String = "Walk";
		private const ANIM_RUN:String = "Run";
		
		private const ROTATION_SPEED:Number = 3;
		private const RUN_SPEED:Number = 1;
		private const WALK_SPEED:Number = 1;
		private const BREATHE_SPEED:Number = 0.7;
		private const RELOAD_SPEED:Number = 1;
		private const JUMP_SPEED:Number = 1;
		
		private var isCrouch:Boolean = false;
		private var isRunning:Boolean = false;
		private var isMoving:Boolean = false;
		private var isSideMove:Boolean = false;
		private var isJump:Boolean = true;
		
		// scene objects
		private var _player:ObjectContainer3D;
		private var _heroPieces:ObjectContainer3D;
		private var _hero:Mesh;
		private var _heroWeapon:Mesh;
		private var _weapons:Vector.<Mesh>;
		private var _bonesVector:Vector.<Mesh>;
		
		// advanced eye
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
		private var _cameraHeight:Number = 40;
		
		private var _isIntro:Boolean = true;
		private var _isReflection:Boolean = false;
		private var _isResize:Boolean;
		private var _cloneActif:Boolean;
		private var _dynamicsEyes:Boolean;
		private var _debugRay:Boolean;
		
		private var _text:TextField;
		
		// awayPhysics
		private var _physics:PhysicsEngine;
		
		
		/**
		 * Constructor
		 */
		public function Intermediate_Onkba_FPS()
		{
			textureBitmapData = new Vector.<BitmapData>();
			textureStrings = new Vector.<String>();
			// terrain map
			textureStrings.push("rock.jpg", "arid.jpg", "sand.jpg" );
			// hero map
			textureStrings.push("onkba_diffuse.png", "onkba_normals.jpg", "onkba_lightmap.jpg");
			// gun map
			textureStrings.push("gun_diffuse.jpg", "gun_normals.jpg", "gun_lightmap.jpg");
			
			textureStrings.push("height.png", "height_n.jpg");
			
			// sky map Bitmap overlay
			textureStrings.push("sky/negy.jpg", "sky/posy.jpg", "sky/posx.jpg", "sky/negz.jpg", "sky/posz.jpg", "sky/negx.jpg");
			
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			initEngine();
			initText();
			initLights();
			initListeners();
			
			// kickoff asset loading
			load(textureStrings[n]);
		}
		
		/**
		 * Create an instructions overlay
		 */
		private function initText():void
		{
			_text = new TextField();
			var format:TextFormat = new TextFormat("Verdana", 9, 0xFFFFFF);
			format.letterSpacing = 1;
			format.leading = 2;
			format.leftMargin = 5;
			_text.defaultTextFormat = format;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.gridFitType = GridFitType.PIXEL;
			_text.y = 3;
			_text.width = 300;
			_text.height = 250;
			_text.selectable = false;
			_text.mouseEnabled = true;
			_text.wordWrap = true;
			_text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			addChild(_text);
		}
		
		
		//-------------------------------------------------------------------------------
		//
		//       3D ENGINE INIT 
		//
		//-------------------------------------------------------------------------------
		
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 60;
            
			// create the view
			_view = new View3D();
			_view.forceMouseMove = true;
			_view.backgroundColor = skyColor;
			_view.antiAlias = 4;
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
		}
		
		
		//-------------------------------------------------------------------------------
		//       LIGHTS
		//-------------------------------------------------------------------------------
		
		private function initLights():void
		{
			// create a light for shadows that mimics the sun's position in the skybox
			_sunLight = new DirectionalLight(-0.5, -1, 0.3);
			_sunLight.color = sunColor;
			_sunLight.ambientColor = sunColor;
			_sunLight.ambient = sunAmbient;
			_sunLight.diffuse = sunDiffuse;
			_sunLight.specular = sunSpecular;
			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.02);
			_view.scene.addChild(_sunLight);
			
			// create a light for ambient effect that mimics the sky
			_skyLight = new PointLight();
			_skyLight.color = zenithColor;
			_skyLight.ambientColor = zenithColor;
			_skyLight.ambient = skyAmbient;
			_skyLight.diffuse = skyDiffuse;
			_skyLight.specular = skySpecular;
			_skyLight.y = 300;
			_skyLight.x = -300;
			_skyLight.z = 500;
			
			_skyLight.radius = 1000;
			_skyLight.fallOff = 2500;
			_view.scene.addChild(_skyLight);
			
			// generate cube texture for sky and probe
			_skyProbe = new LightProbe(_skyMap);
			_view.scene.addChild(_skyProbe);
			
			// create light picker for materials
			_lightPicker = new StaticLightPicker([_sunLight, _skyLight, _skyProbe]);
		}
		
		
		//-------------------------------------------------------------------------------
		//       SKY
		//-------------------------------------------------------------------------------
		
		private function randomSky():void 
		{	
			var i:uint = 0;
			var blend:String = "overlay";
			if (!_isIntro) {
				zenithColor = 0xFFFFFF * Math.random();
				fogColor = 0xFFFFFF * Math.random();
				blend = _blendmodes[uint(Math.random() * _blendmodes.length)];
			}
			
			// add real sky bitmap
			if (_skyBitmaps == null) {
				_skyBitmaps = new Vector.<BitmapData>(6);
				for (i = 0; i < 6; i++) {
					_skyBitmaps[i] = textureBitmapData[11 + i];
				}
			}
			if (_sky) {  
				_view.scene.removeChild(_sky);
				_sky.dispose();
			}
			
			_skyMap = VectorSkyEffects.vectorSky(zenithColor, fogColor, fogColor, 8, _skyBitmaps, blend);
			_fogMethode.fogColor = fogColor;
			_skyProbe.diffuseMap = _skyMap;
			_sky = new SkyBox(_skyMap);
			_view.scene.addChild(_sky);
			
			// test rim Light methode slow down engine
			for ( i=0; i < _materials.length; i++ ) { _materials[i].removeMethod(_rimLightMethod); }
			_rimLightMethod = new RimLightMethod(zenithColor, 0.5, 2.5, RimLightMethod.ADD);
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
			
			// global terrain methode probleme no render ?
			var tiles:Array = [1, 10, 10, 10];
			var sTexture:Array = [Cast.bitmapTexture(textureBitmapData[1]), Cast.bitmapTexture(textureBitmapData[2]), Cast.bitmapTexture(textureBitmapData[0])];
			_terrainMethod = new TerrainDiffuseMethod(sTexture, Cast.bitmapTexture(textureBitmapData[9]) , tiles);
			
			// gobal specular method
			_specularMethod = new FresnelSpecularMethod();
			_specularMethod.normalReflectance = 0.6;
			
			// global shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0005;
			
			// global Rim light method
			_rimLightMethod = new RimLightMethod(zenithColor, 0.5, 2, RimLightMethod.ADD);
			
			// global fog method
			_fogMethode = new FogMethod(fogNear, FARVIEW / 2, fogColor);
			
			
			// 0- hero
			_heroMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[3]));
			_heroMaterial.normalMap = Cast.bitmapTexture(textureBitmapData[4]);
			_heroMaterial.addMethod(new LightMapMethod(Cast.bitmapTexture(textureBitmapData[5])));
			_heroMaterial.gloss = 16;
			_heroMaterial.specular = 0.5;
			_heroMaterial.bothSides = false;
			_heroMaterial.alphaThreshold = 0.9;
			_heroMaterial.alphaPremultiplied = true;
			_materials[0] = _heroMaterial;
			
			// 1- weapon
			_gunMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[6]));
			_gunMaterial.normalMap = Cast.bitmapTexture(textureBitmapData[7]);
			_gunMaterial.addMethod(new LightMapMethod(Cast.bitmapTexture(textureBitmapData[8])));
			_gunMaterial.lightPicker = _lightPicker;
			_gunMaterial.gloss = 16;
			_gunMaterial.specular = 0.6;
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
			b.draw(textureBitmapData[3], new Matrix(1, 0, 0, 1, -283/2, -197/2));
			_eyesOpenMaterial = new TextureMaterial(Cast.bitmapTexture(b));
			_eyesOpenMaterial.gloss = 100;
			_eyesOpenMaterial.specular = 0.8;
			_eyesOpenMaterial.repeat = true;
			_materials[3] = _eyesOpenMaterial;
			
			// 4- ground
			_groundMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[1]));
			_groundMaterial.gloss = 10;
			_groundMaterial.specular = 0.1;
			_groundMaterial.addMethod(_fogMethode);
			_groundMaterial.repeat = true;
			_materials[4] = _groundMaterial;
			
			// 5- terrain
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[9]));
			//_terrainMaterial.diffuseMethod = _terrainMethod;
			_terrainMaterial.normalMap = Cast.bitmapTexture(textureBitmapData[10]);
			_terrainMaterial.gloss = 20;
			_terrainMaterial.specular = .25;
			_terrainMaterial.addMethod(_fogMethode);
			_materials[5] = _terrainMaterial;
			
			// 6- simulation box 
			_boxMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64, true, 0xee885500)));//ee220000
			_boxMaterial.gloss = 10;
			_boxMaterial.specular = 0.1;
			_boxMaterial.alphaBlending = true;
			_boxMaterial.addMethod(_fogMethode);
			_materials[6] = _boxMaterial;
			
			// apply light and effect for all material
			for (var i:int; i < _materials.length; i++ ) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].diffuseLightSources = LightSources.PROBES;
				_materials[i].specularLightSources = LightSources.LIGHTS;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 0.85;
				if (i != 5) _materials[i].addMethod(_rimLightMethod);
			}
			
			// global reflection methode
			if (_isReflection) initReflection();
		}
		
		
		//-------------------------------------------------------------------------------
		//       REFLECTION
		//-------------------------------------------------------------------------------
		
		private function initReflectionCube() : void
		{
			_reflectionTexture = new CubeReflectionTexture(128*2);
			_reflectionTexture.farPlaneDistance = FARVIEW;
			_reflectionTexture.nearPlaneDistance = 250;
			_reflectionTexture.position = new Vector3D(0, 40, 0);
		}
		
		private function initReflection() : void
		{
			if (_isReflection) return;
			_isReflection = true;
			initReflectionCube();
			_fresnelMethod = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod.normalReflectance = 0.3;
			_fresnelMethod.fresnelPower = 0.5;
			_fresnelMethod.alpha = 0.3;
			_materials[0].addMethod(_fresnelMethod);
			_materials[1].addMethod(_fresnelMethod);
		}
		
		
		//-------------------------------------------------------------------------------
		//       3D OBJECT 
		//-------------------------------------------------------------------------------
		
		private function initObjects():void
		{
			//create skybox
            randomSky();
            
			//create mountain like terrain
			_terrain = new Elevation(_terrainMaterial, Cast.bitmapData(textureBitmapData[9]), FARVIEW * 2, MOUNTAIGN_TOP, FARVIEW * 2, 250, 250);
			_view.scene.addChild(_terrain);
			
			// weapon referency
			_weapons = new Vector.<Mesh>(WEAPON.length);
			
			// fake mesh if no weapon 
			_weapons[0] = new Mesh(new CubeGeometry(1,1,1), null);
			
			// Now load Onkba character and weapons
			load("onkba_fps.awd");
		}
		
		
		//-------------------------------------------------------------------------------
		//       GLOBAL LISTENER
		//-------------------------------------------------------------------------------
		
		private function initListeners():void
		{
			//add render loop
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			//add key listeners
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			//navigation
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseLeave);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
			
			//add resize event
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		
		//-------------------------------------------------------------------------------
		//
		//       OO RENDER LOOP   
		//
		//-------------------------------------------------------------------------------
		
		private function onEnterFrame(event:Event):void
		{
			// physic
			if (_physics)_physics.update();
			
			// character animation
			if (_hero) {
				
				// eyes
				if (_dynamicsEyes) updateEyes();
				
				// bones
				if (_debugRay) updateBones();
				
				// hand bone for weapon
				if (animator.globalPose.numJointPoses >= 22) {
					_heroWeapon.transform = animator.globalPose.jointPoses[22].toMatrix3D();
				}
			}
			
			// camera
			if ( _cameraController.distance > 300 && _isIntro) _cameraController.distance --; 
			else  _isIntro = false;
			_cameraController.lookAtPosition = new Vector3D(_player.x, _player.y+_cameraHeight, _player.z);
			_cameraController.update();
			
			// reflection
			if (_isReflection) {
				_reflectionTexture.position = _player.position;
				_reflectionTexture.render(_view);
			}
			
			// view
			_view.render();
		}
		
		
		//-------------------------------------------------------------------------------
		//       LOADING FUNCTION
		//-------------------------------------------------------------------------------
		
		/**
		 * Global binary file loader
		 */
		private function load(url:String):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			switch (url.substring(url.length - 3)) {
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
			loader.load(new URLRequest(assetsRoot + url));
		}
		
		/**
		 * Display current load progress
		 */
		private function loadProgress(e:ProgressEvent):void
		{
			var P:int = int(e.bytesLoaded / e.bytesTotal * 100);
			if (P != 100)
				log('Load : ' + P + ' % | ' + int((e.bytesLoaded / 1024) << 0) + ' ko\n');
			else {
				_text.text = "ONKBA FPS\n\n";
				_text.appendText("Cursor keys / WSAD / ZSQD - move\n");
				_text.appendText("SHIFT - hold down to run\n");
				_text.appendText("O - next weapon\n");
				_text.appendText("R - reload weapon\n");
				_text.appendText("C - crouch\n");
				_text.appendText("\n");
				_text.appendText("U - physics debug !\n")
				_text.appendText("V - reflection !\n")
				_text.appendText("I - full screen\n");
				_text.appendText("N - random sky\n");
				_text.appendText("P - xray bones\n");
				_text.appendText("B - clone\n");
			}
		}
		
		/**
		 * Bitmap find
		 */
		private function parseBitmap(e:Event):void 
		{
			var urlLoader:URLLoader = e.target as URLLoader;
			var loader:Loader = new Loader();
			loader.loadBytes(urlLoader.data);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapComplete, false, 0, true);
			urlLoader.removeEventListener(Event.COMPLETE, parseBitmap);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
		}
		
		private function onBitmapComplete(e:Event):void
		{
			var loader:Loader = LoaderInfo(e.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			textureBitmapData.push(e.target.content.bitmapData);
			loader.unload();
			loader = null;
			n++;
			
			if (n < textureStrings.length){
				// load next bitmap
				load(textureStrings[n]);
			} else {
				// Init material and objects
				initMaterials();
				initObjects();
			}
		}
		
		/**
		 * AWD find
		 */
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
		 * Listener function for AWD asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			var i:int
			if (event.asset.assetType == AssetType.SKELETON) {
				// Create a new skeleton animation set (! 3 joints per vertex for awd exporter in 3dsmax)
				animationSet = new SkeletonAnimationSet(4);
				// Wrap our skeleton animation set in an animator object and add our sequence objects
				animator = new SkeletonAnimator(animationSet, event.asset as Skeleton);
				
			} else if (event.asset.assetType == AssetType.ANIMATION_NODE) {
				//add each animation node to the animation set (! see sequenceFPS.txt in res)
				var animationNode:SkeletonClipNode = event.asset as SkeletonClipNode;
                animationSet.addAnimation(animationNode);
                //log(animationNode.name);
				//animationSet.addAnimation(animationNode.name, animationNode);
				
				// play default idle animation
				//if (animationNode.name == ANIM_BREATHE) jumpDown()//stop();
				if (animationNode.name == "JumpDown") jumpDown();
				
				// disable animation loop 
				for ( i = 0; i< WEAPON.length; i++ ) {
					if (animationNode.name == WEAPON[i] + "JumpDown") animationNode.looping = false;
					if (animationNode.name == WEAPON[i] + "Reload") animationNode.looping = false;
				}
			} else if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				
				// Onkba character
				if (mesh.name == "Onkba") {
					_hero = mesh;
				}
				
				// weapons resources
				for ( i = 0; i < WEAPON.length; i++ ) {
					if (mesh.name == WEAPON[i] + 'Test') {
						if (i == 1) { mesh.rotationY = -5; mesh.rotationZ = 0; mesh.rotationX = 0; mesh.z = 1.6;  mesh.y =-4.2;  }// decal for gun
						if (i == 2) { mesh.rotationY = -5; mesh.rotationZ = -2; mesh.rotationX = 0; mesh.z = 1.6; mesh.y =-5; }// decal for machine
						if (i == 3) { mesh.rotationY = -5; mesh.rotationZ = -5;  mesh.rotationX = 0; mesh.z = 1.8; mesh.y = -4.6; }// decal for sniper
						if (i == 5) {mesh.rotationY = 10; mesh.rotationZ = 0;}// decal for bazooka
						mesh.material = _gunMaterial;
						_weapons[i] = mesh;
					}
				}
				
			}
		}
		
		
		//-------------------------------------------------------------------------------
		//
		//       CHARACTER DEFINE AND PLACE
		//
		//-------------------------------------------------------------------------------
		
		private function onResourceComplete(e:LoaderEvent):void
		{
			var loader3d:Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			var posY:Number = (38 * SCALE);
			//apply our animator to our mesh
			_hero.animator = animator;
			_hero.material = _heroMaterial;
			_hero.scale(SCALE);
			
			// add weapon container
			_heroWeapon = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0xff0000));
			
			_hero.addChild(_heroWeapon);
			
			_player.addChild(_hero);
			_hero.rotationY = 180;
			_hero.y = -posY;
			
			// Optional dynamic eyes ball
			_heroPieces = new ObjectContainer3D();
			_heroPieces.scale(SCALE);
			_heroPieces.y = -posY;
			_player.addChild(_heroPieces);
			_heroPieces.rotationY = 180;
			addHeroEye();
			
			// away3d physics 
			initPhysicsEngine();
		}
		
		
		//-------------------------------------------------------------------------------
		//       CHARACTER OPTIONS
		//-------------------------------------------------------------------------------
		
		/**
		 * Weapons collection
		 */
		private function switchWeapon():void
		{
			currentWeapon++;
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
			animator.playbackSpeed = BREATHE_SPEED;
			if (isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[5];
			else currentAnim = WEAPON[currentWeapon] + ANIMATION[0];
			animator.play(currentAnim, transition);
		}
		
		/**
		 * Character Mouvement
		 */
		private function updateMovement(dir:Number):void
		{
			isMoving = true;
			var anim:String = isRunning ? ANIM_RUN : ANIM_WALK;
			
			if (currentAnim == anim) return;
			
			if(_physics) _physics.characterSpeed(isRunning ? 3 : 1)
			animator.playbackSpeed = dir * (isRunning ? RUN_SPEED : WALK_SPEED);
			if (isCrouch) currentAnim = WEAPON[currentWeapon] + ANIMATION[6];
			else currentAnim = WEAPON[currentWeapon] + anim;
			animator.play(currentAnim, transition);
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
			animator.play(currentAnim, transition);
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
			animator.playbackSpeed = RELOAD_SPEED;
			animator.play(currentAnim, transition, 0);
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
			animator.playbackSpeed = -JUMP_SPEED;
			animator.play(currentAnim, transition, 0);
			
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
			animator.playbackSpeed = JUMP_SPEED;
			animator.play(currentAnim, transition, 0);
			setTimeout(stop, 260);
		}
		
		
		//-------------------------------------------------------------------------------
		//       KEYBOARD
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
					debugPhysics();
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
					if (isCrouch) { isCrouch = false; _cameraHeight = 40; }
					else {isCrouch = true; _cameraHeight = 15;}
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
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			_signature.y = stage.stageHeight - _signature.height;
		}
		
		private function onStageMouseDown(e:MouseEvent):void
		{
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
			_mouseMove = true;
		}
		
		private function onStageMouseLeave(e:Event):void
		{
			_mouseMove = false;
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
		
		/**
		 * log for display info
		 */
		private function log(t:String):void
		{
			_text.htmlText = t;
		}
		
		
		//-------------------------------------------------------------------------------
		//       EYES dynamic    
		//-------------------------------------------------------------------------------
		
		public function addHeroEye():void
		{
			var eyeGeometry:Geometry = new SphereGeometry(1, 32, 24);
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
			_eyeLook = new Mesh(new PlaneGeometry(0.3, 0.3, 1, 1), new ColorMaterial(0xFFFFFF, 1));
			_eyeLook.rotationX = 90;
			_eyeLook.visible = false;
			var h:ColorMaterial = new ColorMaterial(0xFFFFFF, 1);
			var zone:Mesh = new Mesh(new PlaneGeometry(12, 6, 1, 1), h);
			zone.castsShadows = false;
			zone.material.blendMode = BlendMode.MULTIPLY;
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
			if (animator.globalPose.numJointPoses >= 11) {
				_eyes.transform = animator.globalPose.jointPoses[11].toMatrix3D();
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
				var material:ColorMaterial =  new ColorMaterial(0x00ff00);
				material.lightPicker = _lightPicker;
				_bonesVector = new Vector.<Mesh>(animator.globalPose.numJointPoses);
				var mref0:Mesh = new Mesh(new CubeGeometry(3, 0.3, 0.3), material);
				var mref:Mesh = new Mesh(new CubeGeometry(0.7,0.7,0.7), material);
				mref.addChild(mref0); mref0.x = 1.5;
				for (var i:int = 0; i <animator.globalPose.numJointPoses; i++) {
					m = Mesh(mref.clone());
					j =  new Sprite3D(materialBones( "bone " + i ), 4, 4);
					_hero.addChild(m);
					m.addChild(j);
					_bonesVector[i] = m;
				}
			} else { 
				_debugRay = false;
				_heroMaterial.alpha = 1;
				for ( i = 0; i <_bonesVector.length; i++) {
					m = _bonesVector[i];
					_hero.removeChild(m);
					m.dispose();
					_bonesVector[i] = null;
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
			for (var i:int = 0; i <animator.globalPose.numJointPoses; i++) {
				_bonesVector[i].transform = animator.globalPose.jointPoses[i].toMatrix3D();
			}
		}
		
		
		//-------------------------------------------------------------------------------
		//
		//       ++ PHYSICS engines    
		//
		//-------------------------------------------------------------------------------
		
		private function initPhysicsEngine(name:String = "Physics"):void 
		{
			_physics = PhysicsEngine.getInstance();
			
			// add terrain to physic collision 
			_physics.addTerrain(_terrain);
			
			// add player character physics 
			_physics.addCharacter(_player);
			
			// add some box for fun 
			var mesh:Mesh;
			var size:int;
			var isUnactif:Boolean = true;
			for (var i:int = 0; i < 50; i++) {
				size =50 + (Math.random() * 100);
				mesh = new Mesh(new CubeGeometry(size, size, size), _boxMaterial);
				_view.scene.addChild(mesh);
				if (i == 49) isUnactif = false;
				_physics.addObject(mesh, {stop:isUnactif, w: size, h: size, d: size, mass: 1, pos: new Vector3D(300, _terrain.getHeightAt(300, -100) +(151 * (i+1)), -100)});
			}
			
			
		}
        
		private function debugPhysics():void {
			_physics.addDebug(_view);
		}
		
		
	}
}