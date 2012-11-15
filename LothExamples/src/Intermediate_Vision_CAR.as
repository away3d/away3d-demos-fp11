/*

AWD file loading example in Away3d

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
	public class Intermediate_Vision_CAR extends Sprite
	{
		//signature swf
		[Embed(source="/../embeds/signature.swf", symbol="Signature")]
		public var SignatureSwf:Class;
		
		private static const SCALE:int = 1;
		
		private var assetsRoot:String = "assets/vision/";
		private var textureStrings:Vector.<String>;
		private var textureBitmapData:Vector.<BitmapData>;
		private var n:uint = 0;
		
		private var sunColor:uint = 0xAAAAA9;
		private var sunAmbient:Number = 0.0;
		private var sunDiffuse:Number = 0.0;
		private var sunSpecular:Number = 1.3;
		private var skyColor:uint = 0x333338;
		private var skyAmbient:Number = 0.1;
		private var skyDiffuse:Number = 0.0;
		private var skySpecular:Number = 1.3//0.5;
		private var fogColor:uint = 0x333338;
		private var zenithColor:uint = 0x445465;
		private var fogNear:Number = 1000;
		private var fogFar:Number = 128 * 32 * 2;
		
		//engine variables
		private var _view:View3D;
		private var _stats:AwayStats;
		private var _signature:Sprite;
		private var _lightPicker:StaticLightPicker;
		private var _cameraController:HoverController;
		
		//light variables
		private var _sunLight:DirectionalLight;
		private var _skyLight:PointLight;
		private var _skyProbe:LightProbe;
		private var _sky:SkyBox;
		
		private var _reflectionTexture:CubeReflectionTexture;
		private var _fresnelMethod:FresnelEnvMapMethod;
		private var _fresnelMethod2:FresnelEnvMapMethod;
		private var _fogMethode:FogMethod;
		private var _specularMethod:FresnelSpecularMethod;
		private var _shadowMethod:NearShadowMapMethod;
		private var _rimLightMethod:RimLightMethod;
		// Sky
		private var _skyMap:BitmapCubeTexture;
		
		//Materials
		private var _materials:Vector.<TextureMaterial>;
		private var _groundMaterial:TextureMaterial;
		
		private var _carWhiteMat:TextureMaterial;
		private var _carBlackMat:TextureMaterial;
		private var _carLightMat1:TextureMaterial;
		private var _carLightMat2:TextureMaterial;
		private var _carLightMat3:TextureMaterial;
		private var _carCromeMat:TextureMaterial;
		private var _carWheelMat:TextureMaterial;
		private var _carBlackDoubleMat:TextureMaterial;
		private var _carGlassMat:TextureMaterial;
		
		// scene objects
		private var _ground:Mesh;
		private var _vision:Vector.<Mesh>;
		private var _visionCar:Mesh;
		
		// car parts
		private var _body:Mesh;
		private var _wheel:Mesh;
		private var _wheels:Vector.<Mesh>;
		private var _door:Mesh;
		private var _doors:Vector.<Mesh>;
		private var _sit:Mesh;
		private var _sits:Vector.<Mesh>;
		
		//navigation
		private var _prevMouseX:Number;
		private var _prevMouseY:Number;
		private var _mouseMove:Boolean;
		private var _cameraHeight:Number = 50;
		
		private var _isReflection:Boolean = false;
		private var _isResize:Boolean;
		private var _cloneActif:Boolean;
		
		private var _text:TextField;
		
		/**
		 * Constructor
		 */
		public function Intermediate_Vision_CAR()
		{
			textureBitmapData = new Vector.<BitmapData>();
			textureStrings = new Vector.<String>();
			
			// terrain map
			textureStrings.push("sand.jpg");
			
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
			
			//create the view
			_view = new View3D();
			_view.forceMouseMove = true;
			_view.backgroundColor = skyColor;
			_view.antiAlias = 4;
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
			
			//add signature
			addChild(_signature = new SignatureSwf());
			_signature.y = stage.stageHeight - _signature.height;
			_signature.x = 10;
			
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
			_sunLight.ambient = 0//sunAmbient;
			_sunLight.diffuse = sunDiffuse;
			_sunLight.specular = sunSpecular;
			
			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.1);
			_view.scene.addChild(_sunLight);
			
			//create a light for ambient effect that mimics the sky
			_skyLight = new PointLight();
			_skyLight.color = zenithColor//skyColor;
			_skyLight.ambientColor = zenithColor//skyColor;
			_skyLight.ambient = 0;//skyAmbient;
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
		}
		
		
		//-------------------------------------------------------------------------------
		//       SKY
		//-------------------------------------------------------------------------------
		
		private function randomSky():void 
		{
			zenithColor = 0xFFFFFF * Math.random();
			fogColor = 0xFFFFFF * Math.random();
			
			_skyMap = VectorSkyEffects.vectorSky(zenithColor, fogColor, fogColor, 8);
			_fogMethode.fogColor = fogColor;
			//_skyProbe.diffuseMap = _skyMap;
			_sky.dispose();
			_sky = new SkyBox(_skyMap);
			_view.scene.addChild(_sky);
			
			// test rim Light methode slow down engine
			for (var i:int=0; i < _materials.length; i++ ) {
				_materials[i].removeMethod(_rimLightMethod);
			}
			
			_rimLightMethod = new RimLightMethod(zenithColor, 0.5, 2.5, RimLightMethod.ADD);
			
			for ( i = 0; i < _materials.length; i++ ) {
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
			_groundMaterial = new TextureMaterial(Cast.bitmapTexture(textureBitmapData[0]));
			_groundMaterial.gloss = 100;
			_groundMaterial.specular = 0.1;
			_groundMaterial.addMethod(_fogMethode);
			_groundMaterial.repeat = true;
			_materials[0] = _groundMaterial;
			
			// create car material
			_carWhiteMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64,false, 0x010101)))
			_carWhiteMat.gloss = 100;
			_carWhiteMat.specular = 0.9;
			_materials[1] = _carWhiteMat;
			
			_carBlackMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64,false, 0x090702)));
			_carBlackMat.gloss = 10;
			_carBlackMat.specular = 0.3;
			_materials[2] = _carBlackMat;
			
			_carLightMat1 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0xEEFFFFFF)));
			_carLightMat1.alphaBlending = true;
			_carLightMat1.gloss = 10;
			_carLightMat1.specular = 0.9;
			_materials[3] = _carLightMat1;
			
			_carLightMat2 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0xEEFF1010)));
			_carLightMat2.alphaBlending = true;
			_carLightMat2.gloss = 10;
			_carLightMat2.specular = 0.9;
			_materials[4] = _carLightMat2;
			
			_carLightMat3 = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x60FFFFFF)));
			_carLightMat3.alphaBlending = true;
			_carLightMat3.gloss = 10;
			_carLightMat3.specular = 0.9;
			_materials[5] = _carLightMat3;
			
			_carWheelMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64,false, 0x050301)));
			_carWheelMat.gloss = 100;
			_carWheelMat.specular = 0.5;
			_carWheelMat.bothSides = true;
			_materials[6] = _carWheelMat;
			
			_carBlackDoubleMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64,false, 0x090702)));
			_carBlackDoubleMat.gloss = 10;
			_carBlackDoubleMat.specular = 0.9;
			_carBlackDoubleMat.bothSides = true;
			_materials[7] = _carBlackDoubleMat;
			
			_carCromeMat = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64,64,false, 0x404040)));
			_carCromeMat.gloss = 10;
			_carCromeMat.specular = 0.9;
			_carCromeMat.bothSides = true;
			_materials[8] = _carCromeMat;
			
			_carGlassMat =  new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, true, 0x99010101)));
			_carGlassMat.gloss = 60;
			_carGlassMat.specular = 1;
			_carGlassMat.alphaBlending = true;
			_carGlassMat.bothSides = true;
			//_carGlassMat.specularMethod = _specularMethod;
			_materials[9] = _carGlassMat;
			
			// apply light and effect for all material
			for (var i:int; i < _materials.length; i++ ) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].diffuseLightSources = LightSources.PROBES;
				_materials[i].specularLightSources = LightSources.LIGHTS;
				_materials[i].shadowMethod = _shadowMethod;
				_materials[i].ambient = 1;
				if (i != 0)_materials[i].addMethod(_rimLightMethod);
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
			_reflectionTexture.farPlaneDistance = fogFar;
			_reflectionTexture.nearPlaneDistance = 250;
			_reflectionTexture.position = new Vector3D(0, 200, 0);
		}
		
		private function initReflection() : void
		{
			if (_isReflection) return;
			_isReflection = true;
			initReflectionCube();
			_fresnelMethod = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod.normalReflectance = .5;
			_fresnelMethod.fresnelPower = 0.6;
			_fresnelMethod.alpha = 0.4;
			_fresnelMethod2 = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod2.normalReflectance = 1;
			_fresnelMethod2.fresnelPower = 0.8;
			_fresnelMethod2.alpha = 0.9;
			
			_materials[1].addMethod(_fresnelMethod);
			_materials[8].addMethod(_fresnelMethod2);
			_materials[9].addMethod(_fresnelMethod2);
		}
		
		
		//-------------------------------------------------------------------------------
		//       3D OBJECT 
		//-------------------------------------------------------------------------------
		
		private function initObjects():void
		{
			
			//create skybox
			_sky = new SkyBox(_skyMap);
			_view.scene.addChild(_sky);
			
			// basic ground
			_ground = new Mesh(new PlaneGeometry(fogFar*2, fogFar*2), _groundMaterial);
			_ground.geometry.scaleUV(60, 60);
			_ground.y = 0;
			_ground.castsShadows = false;
			_view.scene.addChild(_ground); 
			
			// Now load High res Vision car
			_vision = new Vector.<Mesh>();
			
			load("vision.awd");
		}
		
		
		//-------------------------------------------------------------------------------
		//       GLOBAL LISTENER
		//-------------------------------------------------------------------------------
		
		private function initListeners(e:Event=null):void
		{
			message();
			if (e != null) {
				stage.removeEventListener(MouseEvent.MOUSE_OVER, initListeners);
				stage.removeEventListener(Event.RESIZE, onResize);
			}
			// add render loop
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
		
		private function stopListeners():void
		{
			log("&#47;&#33;&#92; PAUSE");
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
		
		//-------------------------------------------------------------------------------
		//
		//       OO RENDER LOOP   
		//
		//-------------------------------------------------------------------------------
		
		private function onEnterFrame(event:Event=null):void
		{
			if (_sunLight.ambient < 0.5)_sunLight.ambient += 0.01;
			
			_cameraController.lookAtPosition = new Vector3D(0, _cameraHeight,0);
			_cameraController.update();
			
			// update reflection
			if (_isReflection) _reflectionTexture.render(_view);
			
			// update view
			_view.render();
		}
		
		
		//-------------------------------------------------------------------------------
		//        LOADING FUNCTION
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
				
			}
		}
		
		/**
		 * Display demo instruction
		 */
		private function message():void
		{
			_text.text = "VISION CAR\n\n";
			_text.appendText("I - full screen\n");
			_text.appendText("V - reflection\n");
			_text.appendText("N - random sky\n");
			_text.appendText("B - clone\n");
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
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				if(mesh.name!='top' && mesh.name!='bottom') _vision.push(mesh);
			}
		}
		
		
		//-------------------------------------------------------------------------------
		//
		//       CAR DEFINE AND PLACE
		//
		//-------------------------------------------------------------------------------
		
		private function onResourceComplete(e:LoaderEvent):void
		{
			var loader3d:Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			
			var mesh:Mesh;
			
			// fake empty mesh
			_visionCar = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0)); 
			_sit = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));
			_wheel = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));
			_door = new Mesh(new CubeGeometry(1, 1, 1), new ColorMaterial(0x0, 0));
			
			for (var i:int = 0; i < _vision.length; i++) {
				mesh = _vision[i];
				
				// apply texture by mesh name
				if (mesh.name.substring(0, 5) == 'glass' || mesh.name == 'door_glass') { mesh.material = _carGlassMat; mesh.castsShadows = false; }
				else if (mesh.name == 'crome' || mesh.name == 'Bouchon') mesh.material = _carCromeMat;
				else if (mesh.name == 'frontLightContour') mesh.material = _carLightMat3;
				else if (mesh.name == 'frontLight') mesh.material = _carLightMat1;
				else if (mesh.name == 'light_red') mesh.material = _carLightMat2;
				else if (mesh.name == 'interiorSymetrie' || mesh.name == 'chassisPlus' || mesh.name == 'chassisSymetrie' || mesh.name == 'wheel_j2' || mesh.name == 'sitColor' || mesh.name=='radiateur') 
					mesh.material = _carBlackMat;
				else if (mesh.name == 'door') mesh.material = _carBlackDoubleMat;
				else if (mesh.name == 'wheel') mesh.material = _carWheelMat;
				else mesh.material = _carWhiteMat;
				
				// dispatch car parts
				if (mesh.name.substring(0, 3) == 'sit') _sit.addChild(mesh);
				else if (mesh.name.substring(0, 5) == 'wheel') _wheel.addChild(mesh);
				else if (mesh.name.substring(0, 4) == 'door' ) _door.addChild(mesh);
					// steering wheel
				else if (mesh.name == 'steering') { mesh.position =  new Vector3D( -70, 123, 96); }
					
				else _visionCar.addChild(mesh);
			}
			
			// clone sit
			_sits = new Vector.<Mesh>(4);
			
			for (i = 0; i < 4; i++) {
				_sits[i] = Mesh(_sit.clone());
				if (i == 0) { _sits[i].x = -70; _sits[i].z = 125; }
				else if (i == 1) { _sits[i].x = -70; }
				else if (i == 2) { _sits[i].x = 70; _sits[i].z = 125; }
				else if (i == 3) { _sits[i].x = 70; }
				_visionCar.addChild(_sits[i]);
			}
			
			// clone door
			_doors = new Vector.<Mesh>(2);
			
			for (i = 0; i < 2; i++) {
				_doors[i] = Mesh(_door.clone());
				if (i == 0) { _doors[i].x = 0; _doors[i].z = 0; }
				else if (i == 1) { _doors[i].scaleX = -1 }
				_visionCar.addChild(_doors[i]);
			}
			
			// clone wheel
			_wheels = new Vector.<Mesh>(4);
			
			for (i = 0; i < 4; i++) {
				_wheels[i] = Mesh(_wheel.clone());
				if (i == 0) { _wheels[i].x = -138; _wheels[i].z = 237; }
				else if (i == 1) { _wheels[i].x = -138; _wheels[i].z = -237; }
				else if (i == 2) { _wheels[i].x = 138; _wheels[i].z = 237; _wheels[i].rotationY = 180; }
				else if (i == 3) { _wheels[i].x = 138; _wheels[i].z = -237; _wheels[i].rotationY = 180; }
				_wheels[i].y = 60;
				_visionCar.addChild(_wheels[i]);
			}
			
			
			
			// finaly add vision car mesh
			_view.scene.addChild(_visionCar)
			_visionCar.rotationY = 22.5;
			
			message();
			initListeners();
		}
		
		
		//-------------------------------------------------------------------------------
		//       CLONE
		//-------------------------------------------------------------------------------
		
		private function makeClone(n:int=4):void {
			if (!_cloneActif) {
				_cloneActif = true;
				var g:Mesh;
				var decalx:int = -(n * 400) / 2;
				var decalz:int = -(n * 900) / 2;
				for (var j:int = 1; j < n; j++) {
					for (var i:int = 1; i < n; i++) {
						g = Mesh(_visionCar.clone());
						g.x = decalx + (400 * i);
						g.z = (decalz + (900 * j));
						if (g.x != 0 || g.z != 0)
							_view.scene.addChild(g);
					}
				}
			}
		}
		
		
		//-------------------------------------------------------------------------------
		//       KEYBOARD
		//-------------------------------------------------------------------------------
		
		/**
		 * Key down listener for animation
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.B: 
					makeClone();
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
			switch (event.keyCode) {
			}
		}
		
		
		//-------------------------------------------------------------------------------
		//       STAGE AND MOUSE
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
		 * log for display info
		 */
		private function log(t:String):void
		{
			_text.htmlText = t;
		}
		
	}
}