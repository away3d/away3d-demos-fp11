package
{
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.library.assets.AssetType;
	import flash.utils.Dictionary;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.loaders.parsers.OBJParser;
	import flash.filters.DropShadowFilter;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.core.base.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.lights.*;
	import away3d.lights.shadowmaps.*;
	import away3d.loaders.*;
	import away3d.materials.*;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.utils.*;
	
	import com.derschmale.away3d.multipass.ui.*;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;

	[SWF(frameRate="60", backgroundColor="#000000")]
	public class Main extends Sprite
	{
		//signature swf
    	[Embed(source="/../embeds/signature.swf", symbol="Signature")]
    	public var SignatureSwf:Class;
		
		//skybox
		[Embed(source="/../embeds/textures/sky/hourglass_east.jpg")]
		public static var EnvNegX : Class;
		[Embed(source="/../embeds/textures/sky/hourglass_west.jpg")]
		public static var EnvPosX : Class;
		[Embed(source="/../embeds/textures/sky/hourglass_down.jpg")]
		public static var EnvNegY : Class;
		[Embed(source="/../embeds/textures/sky/hourglass_up.jpg")]
		public static var EnvPosY : Class;
		[Embed(source="/../embeds/textures/sky/hourglass_north.jpg")]
		public static var EnvNegZ : Class;
		[Embed(source="/../embeds/textures/sky/hourglass_south.jpg")]
		public static var EnvPosZ : Class;
		
		[Embed(source="/../embeds/textures/fire.jpg")]
		public static var FlameTexture : Class;
		
		private var _skyMap:BitmapCubeTexture;
		private var _assetsRoot:String = "assets/";
		
		private var diffuseTextureStrings:Vector.<String> = Vector.<String>(["arch_diff.jpg", "background.jpg", "bricks_a_diff.jpg", "ceiling_a_diff.jpg", "chain_texture.png", "column_a_diff.jpg", "column_b_diff.jpg", "column_c_diff.jpg", "curtain_blue_diff.jpg", "curtain_diff.jpg", "curtain_green_diff.jpg", "details_diff.jpg", "fabric_blue_diff.jpg", "fabric_diff.jpg", "fabric_green_diff.jpg", "flagpole_diff.jpg", "floor_a_diff.jpg", "gi_flag.jpg", "lion.jpg", "roof_diff.jpg", "thorn_diff.png", "vase_dif.jpg", "vase_hanging.jpg", "vase_plant.png", "vase_round.jpg"]);
		private var normalTextureStrings:Vector.<String> = Vector.<String>(["arch_ddn.jpg", "background_ddn.jpg", "bricks_a_ddn.jpg", null,                "chain_texture_ddn.jpg", "column_a_ddn.jpg", "column_b_ddn.jpg", "column_c_ddn.jpg", null,                   null,               null,                     null,               null,                   null,              null,                    null,                null,               null,          "lion2_ddn.jpg", null,       "thorn_ddn.jpg", "vase_ddn.jpg",  null,               null,             "vase_round_ddn.jpg"]);
		private var specularTextureStrings:Vector.<String> = Vector.<String>(["arch_spec.jpg", null,            "bricks_a_spec.jpg", "ceiling_a_spec.jpg", null,                "column_a_spec.jpg", "column_b_spec.jpg", "column_c_spec.jpg", "curtain_spec.jpg",      "curtain_spec.jpg", "curtain_spec.jpg",       "details_spec.jpg", "fabric_spec.jpg",      "fabric_spec.jpg", "fabric_spec.jpg",       "flagpole_spec.jpg", "floor_a_spec.jpg", null,          null,       null,            "thorn_spec.jpg", null,           null,               "vase_plant_spec.jpg", "vase_round_spec.jpg"]);
		private var textureDictionary:Dictionary = new Dictionary();
		private var materialDictionary:Dictionary = new Dictionary();
		private var _meshes:Vector.<Mesh> = new Vector.<Mesh>();
		private var loadingTextureStrings:Vector.<String>;
		private var n:uint = 0;
		
		private var _flameData:Vector.<FlameVO> = Vector.<FlameVO>([new FlameVO(new Vector3D(-625, 165, 219), 0xffaa44), new FlameVO(new Vector3D(485, 165, 219), 0xffaa44), new FlameVO(new Vector3D(-625, 165, -148), 0xffaa44), new FlameVO(new Vector3D(485, 165, -148), 0xffaa44)]);
		private var _view:View3D;
		private var _cameraController:FirstPersonController;
		private var _signature:Sprite;
		private var _awayStats:AwayStats;
		
		private var _lightPicker:StaticLightPicker;
		private var _configPanel:ConfigPanel;
		private var _configMediator:ConfigMediator;
		private var _cascadeMethod:CascadeShadowMapMethod;
		private var _fogMethod : FogMethod;
		private var _directionalLight:DirectionalLight;
		private var _lights:Array = new Array();
		private var _flameMaterial:TextureMaterial;
		private var _flameGeometry:PlaneGeometry;
		private var _text:TextField;
				
		//rotation variables
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		//movement variables
		private var _drag:Number = 0.5;
		private var _walkIncrement:Number = 10;
		private var _strafeIncrement:Number = 10;
		private var _walkSpeed:Number = 0;
		private var _strafeSpeed:Number = 0;
		private var _walkAcceleration:Number = 0;
		private var _strafeAcceleration:Number = 0;
		
        /**
         * Constructor
         */
		public function Main()
		{
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
			initUI();
			initListeners();
			
			//kickoff asset loading
			loadingTextureStrings = normalTextureStrings;
			load(loadingTextureStrings[n]);
		}
        /**
         * Initialise the engine
         */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
			//create the view
			_view = new View3D();
			_view.camera.y = 150;
			_view.camera.z = 0;
			addChild(_view);
			
			//setup controller to be used on the camera
			_cameraController = new FirstPersonController(_view.camera, 90, 0, -80, 80);
			
			_lights = new Array();
			
			
            //add signature
			addChild(_signature = new SignatureSwf());
            
            //add stats
            addChild(_awayStats = new AwayStats(_view));
		}
        		
		/**
         * Create an instructions overlay
         */
        private function initText():void
		{
            _text = new TextField();
            _text.defaultTextFormat = new TextFormat("Verdana", 11, 0xFFFFFF);
			_text.embedFonts = true;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.gridFitType = GridFitType.PIXEL;
            _text.width = 300;
            _text.height = 250;
            _text.selectable = false;
            _text.mouseEnabled = true;
            _text.wordWrap = true;
            _text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
            addChild(_text);
        }
		
        /**
         * Initialise the lights
         */
		private function initLights():void
		{
			var shadowMapper : CascadeShadowMapper = new CascadeShadowMapper(3);
			shadowMapper.lightOffset = 10000;
			_directionalLight = new DirectionalLight(-1, -15, 1);
			_directionalLight.shadowMapper = shadowMapper;
			_directionalLight.castsShadows = true;
			_directionalLight.color = 0xeedddd;
			_directionalLight.ambient = .35;
			_directionalLight.ambientColor = 0x808090;
			_view.scene.addChild(_directionalLight);
			_lights.push(_directionalLight);
			
			//creat flame lights
			var flameVO:FlameVO;
			for each (flameVO in _flameData)
			{
				var light : PointLight = flameVO.light = new PointLight();
				light.radius = 200;
				light.fallOff = 600;
				light.color = flameVO.color;
				light.y = 10;
				_lights.push(light);
			}
			
			_lightPicker = new StaticLightPicker(_lights);
			var baseShadowMethod : SimpleShadowMapMethodBase = new FilteredShadowMapMethod(_directionalLight);
			_fogMethod = new FogMethod(0, 4000, 0x9090e7);
			_cascadeMethod = new CascadeShadowMapMethod(baseShadowMethod);
		}
		
        /**
         * Initialise the scene materials
         */		
		private function initMaterials():void
		{
			//create skybox texture map
			_skyMap = new BitmapCubeTexture(Cast.bitmapData(EnvPosX), Cast.bitmapData(EnvNegX), Cast.bitmapData(EnvPosY), Cast.bitmapData(EnvNegY), Cast.bitmapData(EnvPosZ), Cast.bitmapData(EnvNegZ));
			
			//create flame material
			_flameMaterial = new TextureMaterial(Cast.bitmapTexture(FlameTexture));
			_flameMaterial.blendMode = BlendMode.ADD;
			_flameMaterial.animateUVs = true;
			
		}
		        
        /**
         * Initialise the scene objects
         */
        private function initObjects():void
		{
			//create skybox
            _view.scene.addChild(new SkyBox(_skyMap));
			
			//create flame meshes
			_flameGeometry = new PlaneGeometry(40, 80, 1, 1, false, true);
			var flameVO:FlameVO;
			for each (flameVO in _flameData)
			{
				var mesh : Mesh = flameVO.mesh = new Mesh(_flameGeometry, _flameMaterial);
				mesh.position = flameVO.position;
				mesh.subMeshes[0].scaleU = 1/16;
				_view.scene.addChild(mesh);
				mesh.addChild(flameVO.light);
			}
		}
		
		private function initUI():void
		{
			_configPanel = new ConfigPanel();
			_configMediator = new ConfigMediator(_configPanel, _directionalLight, _cascadeMethod);
			addChild(_configPanel);
		}
			
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			onResize();
		}
		        
        /**
         * Global binary file loader
         */
        private function load(url:String):void
		{
            var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.BINARY;
			
            switch (url.substring(url.length - 3)) {
                case "OBJ": 
                case "obj": 
                    loader.addEventListener(Event.COMPLETE, parseOBJ, false, 0, true);
                    break;
                case "png": 
                case "jpg": 
                    loader.addEventListener(Event.COMPLETE, parseBitmap);
					url = "textures/" + url;
                    break;
            }
			
            loader.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
            loader.load(new URLRequest(_assetsRoot + url));
        }
        
        /**
         * Display current load
         */
        private function loadProgress(e:ProgressEvent):void
		{
            var P:int = int(e.bytesLoaded / e.bytesTotal * 100);
            if (P != 100)
                log('Load : ' + P + ' % | ' + int((e.bytesLoaded / 1024) << 0) + ' ko\n');
            else {
	            _text.text = "Cursor keys / WSAD / ZSQD - move\n";
	            _text.appendText("SHIFT - hold down to run\n");
	            _text.appendText("E - punch\n");
	            _text.appendText("SPACE / R - guard\n");
	            _text.appendText("N - random sky\n");
	            _text.appendText("B - clone !\n");
			}
        }
        
        //--------------------------------------------------------------------- BITMAP DISPLAY
        
        private function parseBitmap(e:Event):void 
		{
            log("out");
            var urlLoader:URLLoader = e.target as URLLoader;
            var loader:Loader = new Loader();
            loader.loadBytes(urlLoader.data);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapComplete, false, 0, true);
            urlLoader.removeEventListener(Event.COMPLETE, parseBitmap);
            urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
            loader = null;
        }
        
        private function onBitmapComplete(e:Event):void
		{
            var loader:Loader = LoaderInfo(e.target).loader;
            loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			
			//create bitmap texture in dictionary
			if (!textureDictionary[loadingTextureStrings[n]])
            	textureDictionary[loadingTextureStrings[n]] = (loadingTextureStrings == normalTextureStrings)? Cast.bitmapTexture(e.target.content) : new SpecularBitmapTexture((e.target.content as Bitmap).bitmapData);
				
            loader.unload();
            loader = null;
			
			//skip null textures
			while (n++ < loadingTextureStrings.length - 1)
				if (loadingTextureStrings[n])
					break;
			
            if (n < loadingTextureStrings.length) {
                load(loadingTextureStrings[n]);
			} else if (loadingTextureStrings == normalTextureStrings) {
				n = 0;
				loadingTextureStrings = specularTextureStrings;
				load(loadingTextureStrings[n]);
			} else {
            	load("sponza.obj");
            }
        }
		
        /**
         * Load AWD
         */
        private function parseOBJ(e:Event):void
		{
            var loader:URLLoader = e.target as URLLoader;
            var loader3d:Loader3D = new Loader3D(false);
			var context:AssetLoaderContext = new AssetLoaderContext();
			context.mapUrl("sponza.mtl", _assetsRoot + "sponza.mtl");
            loader3d.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete, false, 0, true);
            loader3d.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete, false, 0, true);
            loader3d.loadData(loader.data, context, null, new OBJParser());
			
            loader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
            loader.removeEventListener(Event.COMPLETE, parseOBJ);
            loader = null;
        }
        
        /**
         * Listener function for asset complete event on loader
         */
        private function onAssetComplete(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.TEXTURE) {
				//create multipass material
				var material:TextureMultiPassMaterial = new TextureMultiPassMaterial(event.asset as BitmapTexture);
				material.lightPicker = _lightPicker;
				material.shadowMethod = _cascadeMethod;
				material.addMethod(_fogMethod);
				material.mipmap = true;
				material.repeat = true;
				material.specular = 2;
				
				var name:String = event.asset.name.split("/")[2];
				var textureIndex:int = diffuseTextureStrings.indexOf(name);
				var textureName:String;
				
				if (textureIndex == -1)
					return;
				
				//use alpha transparancy if texture is png
				if (name.substring(name.length - 3) == "png")
					material.alphaThreshold = 0.5;
				
				//add normal map if it exists
				if ((textureName = diffuseTextureStrings[textureIndex]))
					material.normalMap = textureDictionary[textureName];
				
				//add specular map if it exists
				if ((textureName = specularTextureStrings[textureIndex]))
					material.specularMap = textureDictionary[textureName];
				
				//add to material dictionary
				materialDictionary[name] = material;
				
			} else if (event.asset.assetType == AssetType.MESH) {
				//store meshes
				_meshes.push(event.asset as Mesh);
			}
		}
		
        /**
         * Check if all resource loaded
         */
        private function onResourceComplete(e:LoaderEvent):void
		{
            var loader3d:Loader3D = e.target as Loader3D;
            loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
            loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			
			//reassign materials
			var mesh:Mesh;
			for each (mesh in _meshes) {
				if (!(mesh.material is TextureMaterial) || mesh.name == "sponza_04")
					continue;
				var material:TextureMultiPassMaterial = materialDictionary[(mesh.material as TextureMaterial).texture.name.split("/")[2]];
				if (material)
					mesh.material = material;
					
				_view.scene.addChild(mesh);
			}
			
			initMaterials();
			initObjects();
        }
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			
			if (_move) {
				_cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle;
				_cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle;
				
			}
			
			if (_walkSpeed || _walkAcceleration) {
				_walkSpeed = (_walkSpeed + _walkAcceleration)*_drag;
				if (Math.abs(_walkSpeed) < 0.01)
					_walkSpeed = 0;
				_cameraController.incrementWalk(_walkSpeed);
			}
			
			if (_strafeSpeed || _strafeAcceleration) {
				_strafeSpeed = (_strafeSpeed + _strafeAcceleration)*_drag;
				if (Math.abs(_strafeSpeed) < 0.01)
					_strafeSpeed = 0;
				_cameraController.incrementStrafe(_strafeSpeed);
			}
			
			//animate flames
			var flameVO:FlameVO;
			for each (flameVO in _flameData) {
				//update flame light
				var light : PointLight = flameVO.light;
				
				if (!light)
					continue;
				
				light.fallOff = 380+Math.random()*20;
				light.radius = 200+Math.random()*30;
				light.diffuse = .9+Math.random()*.1;
				
				//update flame mesh
				var mesh : Mesh = flameVO.mesh;
				
				if (!mesh)
					continue;
				
				var subMesh : SubMesh = mesh.subMeshes[0];
				subMesh.offsetU += 1/16;
				subMesh.offsetU %= 1;
				mesh.rotationY = Math.atan2(mesh.x - _view.camera.x, mesh.z - _view.camera.z)*180/Math.PI;
			}
			
			_view.render();
		}
		
				
		/**
		 * Key down listener for camera control
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
					_walkAcceleration = _walkIncrement;
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					_walkAcceleration = -_walkIncrement;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					_strafeAcceleration = -_strafeIncrement;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					_strafeAcceleration = _strafeIncrement;
					break;
				case Keyboard.F:
					_cameraController.fly = !_cameraController.fly;
			}
		}
		
		/**
		 * Key up listener for camera control
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.DOWN:
				case Keyboard.S:
					_walkAcceleration = 0;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.RIGHT:
				case Keyboard.D:
					_strafeAcceleration = 0;
					break;
			}
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			_move = true;
			_lastPanAngle = _cameraController.panAngle;
			_lastTiltAngle = _cameraController.tiltAngle;
			_lastMouseX = stage.mouseX;
			_lastMouseY = stage.mouseY;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_configPanel.x = stage.stageWidth - _configPanel.width - 20;
			_configPanel.y = 20;
			
			_signature.y = stage.stageHeight - _signature.height;
			
			_awayStats.x = stage.stageWidth - _awayStats.width;
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

import away3d.entities.*;
import away3d.lights.*;

import flash.geom.*;

internal class FlameVO
{
	public var position : Vector3D;
	public var color : uint;
	public var mesh : Mesh;
	public var light : PointLight;
	
	public function FlameVO(position : Vector3D, color : uint)
	{
		this.position = position;
		this.color = color;
	}
}