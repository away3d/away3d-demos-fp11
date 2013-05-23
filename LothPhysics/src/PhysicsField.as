package {
	import away3d.containers.View3D;
	import away3d.core.base.SubGeometry;
	import away3d.core.pick.PickingColliderType;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.lights.DirectionalLight;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.textures.CubeReflectionTexture;
	import away3d.tools.helpers.MeshHelper;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.library.assets.AssetType;
	import away3d.library.AssetLibrary;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPCapsuleShape;
	import awayphysics.collision.shapes.AWPConvexHullShape;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPEvent;
	
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.dynamics.constraintsolver.AWPConeTwistConstraint;
	import awayphysics.dynamics.constraintsolver.AWPGeneric6DofConstraint;
	import awayphysics.dynamics.constraintsolver.AWPHingeConstraint;
	import awayphysics.dynamics.constraintsolver.AWPPoint2PointConstraint;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.debug.AWPDebugDraw;
	
	import flash.filters.BlurFilter;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.filters.ShaderFilter;
	import flash.utils.ByteArray;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import utils.PerlinShape;
	
	[SWF(backgroundColor="#c4d6e7",frameRate="60",width="600",height="600")]
	
	public class PhysicsField extends Sprite {
		[Embed(source="../embeds/water.jpg")]
		private var WATER:Class;
		
		[Embed(source="/../embeds/terrain256.jpg")]
		private var TERRAIN:Class;
		
		[Embed(source="/../embeds/ship.awd",mimeType="application/octet-stream")]
		public static var SHIP:Class;
		
		[Embed(source="/../embeds/building.awd",mimeType="application/octet-stream")]
		public static var BUILDING:Class;
		
		[Embed(source="/../embeds/NormalMap.pbj",mimeType="application/octet-stream")]
		private var NormalMapClass:Class;
		
		private var _normalMapShader:Shader = new Shader(new NormalMapClass());
		private var _normalMapFilters:Array = [new ShaderFilter(_normalMapShader)];
		private var _normalBitmap:BitmapData;
		
		private var _view:View3D;
		private var _stats:AwayStats;
		private var _subStat:Sprite;
		private var _controller:HoverController;
		private var _sunLight:DirectionalLight;
		private var _light:PointLight;
		private var _lightPicker:StaticLightPicker;
		private var _bgColor:uint = 0xc4d6e7;
		private var _skyColors:Array = [_bgColor, 0x55b2de, 0x0685d6, 0x041984];
		private var _skySphere:Mesh;
		private var _skyCube:BitmapCubeTexture;
		//methodes
		private var _reflectionTexture:CubeReflectionTexture;
		private var _fresnelMethod:FresnelEnvMapMethod;
		private var _shadowMapMethod:NearShadowMapMethod;
		private var _fogMethod:FogMethod;
		
		//field variables
		private const _resolution:int = 64;
		private const _factor:uint = 2;
		private const _dimension:int = 10000;
		private const _elevation:int = 1800;
		private const _positionY:int = 800;
		private const _sizeFactor:Number = _dimension / _resolution;
		
		private var _field:Mesh;
		private var _fieldSubGeometry:SubGeometry
		private var _fieldMaterial:TextureMaterial;
		private var _terrainMethode:TerrainDiffuseMethod;
		private var _specularMethod:FresnelSpecularMethod;
		private const _textures:Vector.<BitmapTexture> = new Vector.<BitmapTexture>();
		private const _layers:Vector.<BitmapData> = new Vector.<BitmapData>();
		private const _heights:Vector.<Number> = new Vector.<Number>();
		private const _groundBitmaps:Vector.<BitmapData> = new Vector.<BitmapData>(3, true);
		private const _grounds:Vector.<BitmapScrolling> = new Vector.<BitmapScrolling>(3, true);
		private var _sphereMaterial:ColorMaterial;
		
		//perlin noise variable
		private var _fractal:Boolean;
		private var _numOctaves:uint;
		private var _offsets:Array;
		private var _complex:Number;
		private var _seed:int;
		private var _bigMatrix:Matrix;
		private var _bump:BitmapData;
		private var _bumpBig:BitmapData;
		private var _island:BitmapData;
		private var _fullMap:BitmapData;
		
		//gound map tiles
		private var _tiles:Array = [1, 20, 20, 20];
		private var _multy:Vector3D = new Vector3D();
		
		//physics
		private var _physicsWorld:AWPDynamicsWorld;
		private var _debugDraw:AWPDebugDraw;
		private var _timeStep:Number = 0.0167;
		private var _sphereShape:AWPSphereShape;
		private var _terrainShape:PerlinShape;
		private var _terrainBody:AWPRigidBody;
		private const _rigidCubes:Vector.<AWPRigidBody> = new Vector.<AWPRigidBody>();
		private const _rigidSpheres:Vector.<AWPRigidBody> = new Vector.<AWPRigidBody>();
		
		// defined collison group
		private const collisionGround:int = 1;
		private const collisionShip:int = 2;
		private const collisionBox2:int = 4;
		private const collisionNull:int = 0;
		private const collisionBullet:int = 8;
		private const collisionPlane:int = 16;
		private const collisionBuilding:int = 32;
		private const collisionTree:int = 64;
		private const collisionAll:int = -1;
		
		//mouse navigation
		private const _mouseNav:Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 50, 5000]);
		private var _center:Vector3D = new Vector3D(0, 0, 0);
		private var _move:Boolean = false;
		
		//plane
		private var _plane:Mesh;
		private var _planeMaterial:TextureMaterial;
		private var _waterMethod:SimpleWaterNormalMethod;
		private var _waterfresnel:FresnelSpecularMethod;
		
		//ship
		private var _ship:Mesh;
		private var _shipTop:Mesh;
		private var _shipShape:Mesh;
		private var _shipBody:AWPRigidBody;
		private var _shipJoint:AWPHingeConstraint;
		private var _shipMaterial:TextureMaterial;
		private var _rootBox:AWPRigidBody;
		
		//ship navigation
		private var _rotation:Number;
		private var _speed:Number = 0.5;
		private var _acc:Number = 0.01;
		private var _position:Vector3D = new Vector3D();
		private var _ease:Vector3D = new Vector3D();
		private var _easeRot:Vector3D = new Vector3D();
		
		//buildings
		private var _building:Mesh;
		private var _buildingCollision:Mesh;
		private var _buildingMaterial:TextureMaterial;
		private var _buildingBody:AWPRigidBody;
		
		private const _buildings:Vector.<Mesh> = new Vector.<Mesh>();
		private const _buildingsShape:Vector.<Mesh> = new Vector.<Mesh>();
		private const _buildsBody:Vector.<AWPRigidBody> = new Vector.<AWPRigidBody>();
		
		//trees
		private const _trees:Vector.<Mesh> = new Vector.<Mesh>();
		private const _treesBody:Vector.<AWPRigidBody> = new Vector.<AWPRigidBody>();
		private const _treesPosition:Vector.<Vector3D> = new Vector.<Vector3D>();
		
		private var _target:Mesh;
		private var _isDebug:Boolean = false;
		private var _isShadow:Boolean = false;
		private var _isReflection:Boolean = false;
		private var _isWithField:Boolean;
		
		//key control
		private var _keyFront:Boolean;
		private var _keyBack:Boolean;
		private var _keyLeft:Boolean;
		private var _keyRight:Boolean;
		
		//text
		private var _tf:TextField;
		private var _title:TextField;
		private var _info:String = "\ncontrol: arrow / WASD / ZQSD\nshow debug: N";
		
		private var updateTimer:Timer;
		
		public function PhysicsField() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 8;
			_view.backgroundColor = _bgColor;
			this.addChild(_view);
			
			_stats = new AwayStats(_view, false, true);
			_stats.addEventListener(MouseEvent.CLICK, moveStat);
			
			this.addChild(_stats);
			
			_subStat = new Sprite();
			_subStat.graphics.beginFill(0x000000, 0.2);
			_subStat.graphics.drawRect(0, 54, 100, 31);
			_subStat.graphics.endFill();
			this.addChild(_subStat);
			
			initInfo();
			
			//setup the light
			_sunLight = new DirectionalLight(0.3, -1, -0.3);
			
			_view.scene.addChild(_sunLight);
			_light = new PointLight();
			_light.color = _bgColor;
			_light.y = 4000;
			_view.scene.addChild(_light);
			_lightPicker = new StaticLightPicker([_sunLight, _light]);
			
			//setup the method
			_fogMethod = new FogMethod(1000, _dimension * 0.5, _bgColor);
			
			if (_isShadow) {
				_sunLight.shadowMapper = new NearDirectionalShadowMapper(.6);
				_sunLight.shadowMapper.depthMapSize = 2048;
				_shadowMapMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
				_shadowMapMethod.epsilon = .0007;
				_shadowMapMethod.alpha = 0.6;
			}
			
			//setup the camera
			_view.camera.lens = new PerspectiveLens(80);
			_view.camera.lens.near = 10;
			_view.camera.lens.far = _dimension;
			
			var targetMaterial:TextureMaterial = new TextureMaterial(new BitmapTexture(targetBitmap()));
			//targetMaterial.alphaBlending = true;
			targetMaterial.alphaThreshold = 0.5;
			_target = new Mesh(new PlaneGeometry(100, 100, 1, 1, false, true), targetMaterial);
			_view.scene.addChild(_target);
			
			//setup the camera controller
			_controller = new HoverController(_view.camera, null, 0, 20, 1000, 0, 35);
			_controller.wrapPanAngle = true;
			_controller.autoUpdate = false;
			
			//setup the physics world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = false;
			_physicsWorld.scaling = 100;
			_physicsWorld.gravity = new Vector3D(0, -10, 0);
			
			_sphereMaterial = new ColorMaterial(0xCCCCCC, 1);
			_sphereMaterial.lightPicker = _lightPicker;
			_sphereMaterial.addMethod(_fogMethod);
			_sphereMaterial.specular = 1;
			_sphereMaterial.gloss = 300;
			
			_waterfresnel = new FresnelSpecularMethod();
			_waterfresnel.normalReflectance = .6;
			
			var waterMini:BitmapData = Bitmap(new WATER()).bitmapData;
			var g:Sprite = new Sprite();
			g.graphics.beginBitmapFill(waterMini);
			g.graphics.drawRect(0, 0, 1024, 1024);
			g.graphics.endFill();
			var waterBig:BitmapData = new BitmapData(1024, 1024, false);
			waterBig.draw(g);
			g.graphics.clear();
			g = null;
			var waterNormal:BitmapTexture = new BitmapTexture(waterBig);
			_waterMethod = new SimpleWaterNormalMethod(waterNormal, waterNormal);
			
			_skyCube = CubicSky();
			// setup the plane
			_planeMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, true, 0x45000000)));
			_planeMaterial.alphaBlending = true;
			_planeMaterial.alpha = 0.6;
			_planeMaterial.lightPicker = _lightPicker;
			_planeMaterial.normalMethod = _waterMethod;
			_planeMaterial.specularMethod = _waterfresnel;
			_planeMaterial.specular = 2;
			_planeMaterial.gloss = 100;
			_planeMaterial.repeat = true;
			_planeMaterial.addMethod(new EnvMapMethod(_skyCube));
			_planeMaterial.addMethod(_fogMethod);
			
			_plane = new Mesh(new PlaneGeometry(_dimension, _dimension), _planeMaterial);
			//  _plane.castsShadows = false;
			_view.scene.addChild(_plane);
			
			//mouse interaction
			//_plane.addEventListener(MouseEvent3D.MOUSE_UP, on3DMouseUp);
			//_plane.mouseEnabled = true;
			
			//physics plane
			var shape:AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var body:AWPRigidBody = new AWPRigidBody(shape, null, 0);
			body.friction = 0.1;
			body.restitution = 0.0;
			body.y = -70;
			_physicsWorld.addRigidBodyWithGroup(body, collisionPlane, collisionAll);
			
			//create background invers sphere
			var skyMaterial:TextureMaterial = new TextureMaterial(new BitmapTexture(background()));
			_skySphere = new Mesh(new SphereGeometry(_dimension / 2, 20, 16), skyMaterial);
			_skySphere.geometry.convertToSeparateBuffers();
			MeshHelper.invertFaces(_skySphere);
			_skySphere.castsShadows = false;
			_view.scene.addChild(_skySphere);
			
			//parse ship model
			parseShipModel();
			
			//setup field
			initField();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			
			/*updateTimer = new Timer(3, 0);
			   updateTimer.addEventListener(TimerEvent.TIMER, moveField);
			 updateTimer.start();*/
			
			onResize();
			
			//mouse navigation
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
		}
		
		private function parseShipModel():void {
			AssetLibrary.loadData(new SHIP(), null, null, new AWD2Parser());
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onShipResourceComplete);
		}
		
		private function onShipResourceComplete(event:LoaderEvent):void {
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onShipResourceComplete);
			initShip();
			
			//parse building model
			parseBuildingModel();
		}
		
		private function parseBuildingModel():void {
			AssetLibrary.loadData(new BUILDING(), null, null, new AWD2Parser());
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onBuildingResourceComplete);
		}
		
		private function onBuildingResourceComplete(event:LoaderEvent):void {
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onBuildingResourceComplete);
			initBuilding();
			initTree();
		}
		
		private function onAssetComplete(event:AssetEvent):void {
			var m:Mesh;
			if (event.asset.assetType == AssetType.MESH) {
				m = event.asset as Mesh;
				if (m.name == "shape") {
					_shipShape = m;
				}
				if (m.name == "ship") {
					_ship = m;
				}
				if (m.name == "shipTop") {
					_shipTop = m;
				}
				//for building
				if (m.name == "building") {
					_building = m;
				}
				if (m.name == "collision") {
					_buildingCollision = m;
				}
					//for tree
			}
		}
		
		private function initField():void {
			//setup perlin noise variable
			_fractal = true;
			_offsets = [];
			_numOctaves = 1;
			_complex = 0.15; //12;
			_seed = int(Math.random() * 0xffffffff);
			for (var u:uint = 0; u < _numOctaves; ++u) {
				_offsets[u] = new Point(0, 0);
			}
			//setup the field deformation bitmap
			var b00:BitmapData = new BitmapData(_resolution, _resolution, false);
			var b01:BitmapData = new BitmapData(_resolution * _factor, _resolution * _factor, false);
			var b02:BitmapData = new BitmapData(_resolution * _factor, _resolution * _factor, true);
			
			_bumpBig = b01.clone();
			_bump = b00.clone();
			//_bump0 = b00.clone();
			_island = islandMapCache();
			_bigMatrix = new Matrix();
			_bigMatrix.scale(_factor, _factor);
			
			//setup tile field texture 
			var terrainTiles:BitmapData = Bitmap(new TERRAIN()).bitmapData;
			var bSize:int = 256;
			var r:Rectangle;
			_groundBitmaps[0] = new BitmapData(bSize, bSize, false);
			_groundBitmaps[1] = new BitmapData(bSize, bSize, false);
			_groundBitmaps[2] = new BitmapData(bSize, bSize, false);
			
			r = new Rectangle(0, 0, bSize, bSize);
			_groundBitmaps[2].copyPixels(terrainTiles, r, new Point());
			r = new Rectangle(bSize, 0, bSize, bSize);
			_groundBitmaps[0].copyPixels(terrainTiles, r, new Point());
			r = new Rectangle(bSize * 2, 0, bSize, bSize);
			_groundBitmaps[1].copyPixels(terrainTiles, r, new Point());
			
			//setup scrolling bitmap texture
			_grounds[0] = new BitmapScrolling(_groundBitmaps[0]);
			_grounds[1] = new BitmapScrolling(_groundBitmaps[1]);
			_grounds[2] = new BitmapScrolling(_groundBitmaps[2]);
			
			//setup move multiplycator
			_multy.x = _tiles[1] * (bSize / _resolution);
			_multy.y = _tiles[2] * (bSize / _resolution);
			_multy.z = _tiles[3] * (bSize / _resolution);
			
			//setup material & terrain methode
			_layers[0] = b01.clone();
			_layers[1] = b02.clone();
			_layers[2] = b02.clone();
			_textures[0] = new BitmapTexture(_grounds[0]);
			_textures[1] = new BitmapTexture(_grounds[1]);
			_textures[2] = new BitmapTexture(_grounds[2]);
			
			_textures[3] = new BitmapTexture(b01.clone());
			_terrainMethode = new TerrainDiffuseMethod([_textures[0], _textures[1], _textures[2]], _textures[3], _tiles);
			_specularMethod = new FresnelSpecularMethod();
			_specularMethod.normalReflectance = 0.4;
			
			//normal
			var shaderData:ShaderData = _normalMapShader.data;
			ShaderParameter(shaderData["amount"]).value = [5];
			ShaderParameter(shaderData["soft_sobel"]).value = [1];
			ShaderParameter(shaderData["invert_red"]).value = [-1];
			ShaderParameter(shaderData["invert_green"]).value = [-1];
			_normalBitmap = new BitmapData(_resolution * _factor, _resolution * _factor, false, 0x000000);
			_textures[4] = new BitmapTexture(_normalBitmap);
			
			//setup the field material
			_fieldMaterial = new TextureMaterial(new BitmapTexture(_bumpBig));
			_fieldMaterial.lightPicker = _lightPicker;
			_fieldMaterial.diffuseMethod = _terrainMethode;
			_fieldMaterial.specularMethod = _specularMethod;
			_fieldMaterial.specular = 0.4;
			_fieldMaterial.gloss = 100;
			_fieldMaterial.normalMap = _textures[4];
			if (_isShadow)
				_fieldMaterial.shadowMethod = _shadowMapMethod;
			_fieldMaterial.addMethod(_fogMethod);
			
			//setup the field Mesh
			_field = new Mesh(new PlaneGeometry(_dimension, _dimension, _resolution - 1, _resolution - 1, true, false), _fieldMaterial);
			_field.geometry.convertToSeparateBuffers();
			_field.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			_field.castsShadows = false;
			
			//mouse interaction
			_field.addEventListener(MouseEvent3D.MOUSE_UP, on3DMouseUp);
			_field.mouseEnabled = true;
			
			//setup the field sugGeometry referency
			_fieldSubGeometry = _field.geometry.subGeometries[0] as SubGeometry;
			_fieldSubGeometry.autoDeriveVertexNormals = false;
			_fieldSubGeometry.autoDeriveVertexTangents = false;
			_fieldSubGeometry.autoGenerateDummyUVs = false;
			_view.scene.addChild(_field);
			
			updateField();
			//drawBigMap()
			
			//setup physics field
			_terrainShape = new PerlinShape(_resolution, _resolution, _dimension, _dimension, _elevation, _heights);
			_terrainBody = new AWPRigidBody(_terrainShape, null, 0);
			_terrainBody.friction = 0.3;
			_terrainBody.restitution = 0.0;
			_physicsWorld.addRigidBodyWithGroup(_terrainBody, collisionGround, collisionAll);
			
			_isWithField = true;
		}
		
		private function drawBigMap(N:int = 16):void {
			var _offsetsBig:Array = []
			var pos:int = ((_resolution * N) * 0.5) - _resolution * 0.5;
			for (var u:uint = 0; u < _numOctaves; ++u) {
				_offsetsBig[u] = new Point(-pos, -pos);
			}
			_fullMap = new BitmapData(_resolution * N, _resolution * N, false);
			_fullMap.perlinNoise((_resolution * _complex), (_resolution * _complex), _numOctaves, _seed, false, _fractal, 7, true, _offsetsBig);
			var t:Bitmap = new Bitmap(_fullMap);
			addChild(t);
			var t2:Bitmap = new Bitmap(_bump);
			t2.x = pos;
			t2.y = pos;
			addChild(t2);
		
		}
		
		private function initShip():void {
			var bshape:AWPBoxShape = new AWPBoxShape(200, 200, 200);
			_rootBox = new AWPRigidBody(bshape, null, 0);
			_rootBox.position = _center;
			_physicsWorld.addRigidBodyWithGroup(_rootBox, collisionBox2, collisionNull);
			if (_isReflection) {
				_reflectionTexture = new CubeReflectionTexture(128);
				_reflectionTexture.farPlaneDistance = _dimension;
				_reflectionTexture.nearPlaneDistance = 40;
				_reflectionTexture.position = _center;
				_fresnelMethod = new FresnelEnvMapMethod(_reflectionTexture);
			} else {
				_fresnelMethod = new FresnelEnvMapMethod(_skyCube, 0.5);
			}
			_fresnelMethod.normalReflectance = .3;
			_fresnelMethod.fresnelPower = 0.3;
			
			_shipMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0x333333)));
			_shipMaterial.lightPicker = _lightPicker;
			if (_isShadow)
				_shipMaterial.shadowMethod = _shadowMapMethod;
			_shipMaterial.gloss = 120;
			_shipMaterial.addMethod(_fresnelMethod);
			_ship.material = _shipMaterial;
			_shipTop.material = _shipMaterial;
			
			var shape:AWPConvexHullShape = new AWPConvexHullShape(_shipShape.geometry);
			
			_shipBody = new AWPRigidBody(shape, _ship, 1);
			_shipBody.position = _center.add(new Vector3D(0, 70, 0));
			_shipBody.friction = 0.3;
			_shipBody.restitution = 0.0;
			_shipBody.ccdSweptSphereRadius = 0.5;
			_shipBody.ccdMotionThreshold = 1;
			//_shipBody.linearDamping = 2;
			//_shipBody.angularDamping = 2;
			//_shipBody.addEventListener(AWPEvent.COLLISION_ADDED, collisionAdded);
			
			_physicsWorld.addRigidBodyWithGroup(_shipBody, collisionShip, collisionGround | collisionPlane | collisionBuilding | collisionTree);
			
			_ship.addChild(_shipTop);
			_view.scene.addChild(_ship);
			
			_shipJoint = new AWPHingeConstraint(_shipBody, new Vector3D(0, 0, 0), new Vector3D(1, 0, 1), _rootBox, new Vector3D(0, 60, 0), new Vector3D(1, 0, 1));
			_physicsWorld.addConstraint(_shipJoint, true);
			_shipJoint.setLimit(0, 0.5, 0.2, 0.9, 0);
		}
		
		/*private function collisionAdded(event:AWPEvent):void {
		   if (!(event.collisionObject.collisionFlags & AWPCollisionFlags.CF_STATIC_OBJECT)) {
		   var body:AWPRigidBody = AWPRigidBody(event.collisionObject);
		   var force:Vector3D = event.manifoldPoint.normalWorldOnB.clone();
		   force.scaleBy(-30);
		   body.applyForce(force, event.manifoldPoint.localPointB);
		   }
		 }*/
		private function initBuilding():void {
			_buildingMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0x333333)));
			_buildingMaterial.lightPicker = _lightPicker;
			_buildingMaterial.shadowMethod = _shadowMapMethod;
			_buildingMaterial.gloss = 30;
			_buildingMaterial.addMethod(_fogMethod);
			
			_building.material = _buildingMaterial;
			_view.scene.addChild(_building);
			
			//add building collision to physics
			var shape:AWPConvexHullShape = new AWPConvexHullShape(_buildingCollision.geometry);
			_buildingBody = new AWPRigidBody(shape, _building, 0);
			_physicsWorld.addRigidBodyWithGroup(_buildingBody, collisionBuilding, collisionAll);
		}
		
		private function initTree():void {
			_trees[0] = new Mesh(new CubeGeometry(100, 400, 100), new ColorMaterial(Math.random() * 0xFFFFFF));
			_trees[1] = new Mesh(new CubeGeometry(100, 400, 100), new ColorMaterial(Math.random() * 0xFFFFFF));
			
			var i:uint;
			var tree:Mesh;
			var treeShape:AWPBoxShape = new AWPBoxShape(100, 400, 100);
			var pos:Vector3D;
			
			for (i = 0; i < 50; ++i) {
				pos = new Vector3D();
				pos.x = -(_dimension * 0.5) + Math.random() * _dimension;
				pos.z = -(_dimension * 0.5) + Math.random() * _dimension;
				pos.y = getHeightAt(pos.x, pos.z) + 200;
				
				tree = _trees[int(Math.random() * _trees.length)].clone() as Mesh;
				_treesBody[i] = new AWPRigidBody(treeShape, tree, 0);
				_treesPosition[i] = pos;
				_treesBody[i].position = _treesPosition[i];
				_physicsWorld.addRigidBodyWithGroup(_treesBody[i], collisionTree, collisionAll);
				_view.scene.addChild(tree);
			}
		}
		
		/**
		 * update field defformation and texture
		 */
		private function updateField():void {
			_bump.lock();
			_bump.perlinNoise(_resolution * _complex, _resolution * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			//_bump.draw(_island);
			_bump.unlock();
			
			var i:uint, px:uint, c:uint, n:int;
			var len:uint = _fieldSubGeometry.vertexData.length;
			
			for (i = 1; i < len; i += 3, ++c) {
				px = _bump.getPixel(c % _resolution, _resolution - (c / _resolution));
				// Displace y position by the range
				n = (_elevation * px / 0xffffff - _positionY);
				_fieldSubGeometry.vertexData[i] = n
				_heights[c] = n;
				if (c == 2016) {
					_center = new Vector3D(_fieldSubGeometry.vertexData[i - 1], _fieldSubGeometry.vertexData[i], _fieldSubGeometry.vertexData[i + 1]);
					if (_center.y < -70)
						_center.y = -70;
					_position.y = _center.y + 150;
				}
			}
			
			//update geometry
			_fieldSubGeometry.updateVertexData(_fieldSubGeometry.vertexData);
			
			if (_rootBox)
				_rootBox.position = _center;
			
			//____________________________________________________
			
			if (_factor != 1) {
				_bumpBig.lock();
				_bumpBig.draw(_bump, _bigMatrix);
				_bumpBig.applyFilter(_bumpBig, _bumpBig.rect, new Point(), new BlurFilter(4, 4, 1));
				_bumpBig.unlock();
			}
			//update texture
			layerTerrainBitmap();
			_textures[3].bitmapData = _layers[0];
			
			//update water layer
			BitmapTexture(TextureMaterial(_planeMaterial).texture).bitmapData = _layers[2];
			BitmapTexture(TextureMaterial(_planeMaterial).texture).invalidateContent();
			
			//update field layer
			if (_factor != 1) {
				BitmapTexture(TextureMaterial(_fieldMaterial).texture).bitmapData = _bumpBig;
				_normalBitmap.applyFilter(_bumpBig, _bumpBig.rect, new Point(), _normalMapFilters[0]);
			} else {
				BitmapTexture(TextureMaterial(_fieldMaterial).texture).bitmapData = _bump;
				_normalBitmap.applyFilter(_bump, _bump.rect, new Point(), _normalMapFilters[0]);
			}
			
			BitmapTexture(TextureMaterial(_fieldMaterial).texture).invalidateContent();
			
			//update normal
			_textures[4].bitmapData = _normalBitmap;
			_textures[4].invalidateContent();
		}
		
		/**
		 * get height position on field
		 */
		private function getHeightAt(x:Number = 0, z:Number = 0):Number {
			var col:int = _bump.getPixel((x / _dimension + .5) * (_resolution + 1), (-z / _dimension + .5) * (_resolution + 1)) & 0xffffff;
			return int(_elevation * col / 0xffffff - _positionY);
		}
		
		/**
		 * move field
		 */
		private function moveField(e:TimerEvent = null):void {
			_rotation = int(_controller.panAngle) * (Math.PI / 180);
			if (_shipBody != null) {
				/*  _shipBody.rotationY = int(_controller.panAngle);
				   _rootBox.rotationY = int(_controller.panAngle);
				   _shipBody.linearVelocity = new Vector3D();
				 _shipBody.angularVelocity = new Vector3D();*/
			}
			//acceleration
			if (_keyFront)
				_ease.z += _acc;
			if (_keyBack)
				_ease.z -= _acc;
			if (_keyLeft)
				_ease.x += _acc;
			if (_keyRight)
				_ease.x -= _acc;
			
			//speed limite
			if (_ease.x > _speed)
				_ease.x = _speed;
			if (_ease.z > _speed)
				_ease.z = _speed;
			if (_ease.x < -_speed)
				_ease.x = -_speed;
			if (_ease.z < -_speed)
				_ease.z = -_speed;
			
			//break
			if (!_keyFront && !_keyBack) {
				if (_ease.z > _acc)
					_ease.z -= _acc;
				else if (_ease.z < -_acc)
					_ease.z += _acc;
				else
					_ease.z = 0;
			}
			if (!_keyLeft && !_keyRight) {
				if (_ease.x > _acc)
					_ease.x -= _acc;
				else if (_ease.x < -_acc)
					_ease.x += _acc;
				else
					_ease.x = 0;
			}
			
			//_tf.text = "ship stop" + _info;
			if (_ease.x == 0 && _ease.z == 0)
				return;
			
			//convert ease to camera look rotation
			_easeRot.x = Math.cos(_rotation) * _ease.x - Math.sin(_rotation) * _ease.z;
			_easeRot.z = Math.sin(_rotation) * _ease.x + Math.cos(_rotation) * _ease.z;
			
			var i:uint;
			for (i = 0; i < _numOctaves; ++i) {
				_offsets[i].offset(_easeRot.x, _easeRot.z);
			}
			
			//absolute world position
			_position.x = -int(_offsets[0].x * _sizeFactor);
			_position.z = int(_offsets[0].y * _sizeFactor);
			
			if (_buildingBody != null) {
				_buildingBody.x = _position.x;
				_buildingBody.z = _position.z;
			}
			
			if (_treesBody.length != 0) {
				for (i = 0; i < _treesBody.length; ++i) {
					_treesBody[i].x = _treesPosition[i].x + _position.x;
					_treesBody[i].z = _treesPosition[i].z + _position.z;
				}
			}
			
			if (!_isWithField)
				return;
			
			//update field mesh
			updateField();
			
			//update physics field
			_terrainShape.update(_heights);
			
			//activate shipbody if sleeping
			if (_shipBody.activationState == AWPCollisionObject.ISLAND_SLEEPING)
				_shipBody.activate(true);
			
			//update field material
			_grounds[0].move(_easeRot.x * _multy.x, _easeRot.z * _multy.x);
			_grounds[1].move(_easeRot.x * _multy.y, _easeRot.z * _multy.y);
			_grounds[2].move(_easeRot.x * _multy.z, _easeRot.z * _multy.z);
			/*_textures[0].bitmapData = _grounds[0];
			   _textures[1].bitmapData = _grounds[1];
			 _textures[2].bitmapData = _grounds[2];*/
			_textures[0].invalidateContent();
			_textures[1].invalidateContent();
			_textures[2].invalidateContent();
		
			//_tf.text = "ship move: " + int(_position.x) + "/" + int(_position.y) + "/" + int(_position.z) + "\n" + "ship speed: " + _ease.z.toFixed(2) + "/" + _ease.x.toFixed(2);
			//e.updateAfterEvent();
		}
		
		private function keyDownHandler(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: 
					_keyFront = true;
					break;
				case Keyboard.DOWN: 
				case Keyboard.S: 
					_keyBack = true;
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: 
					_keyLeft = true;
					break;
				case Keyboard.RIGHT: 
				case Keyboard.D: 
					_keyRight = true;
					break;
				case Keyboard.N: 
					debugMode();
					break;
			}
		}
		
		private function keyUpHandler(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: 
					_keyFront = false;
					break;
				case Keyboard.DOWN: 
				case Keyboard.S: 
					_keyBack = false;
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: 
					_keyLeft = false;
					break;
				case Keyboard.RIGHT: 
				case Keyboard.D: 
					_keyRight = false;
					break;
			}
		}
		
		private function debugMode():void {
			if (_isDebug) {
				_isDebug = false;
				_debugDraw.debugMode = AWPDebugDraw.DBG_NoDebug;
				_debugDraw.debugDrawWorld();
			} else {
				_isDebug = true;
				_debugDraw = new AWPDebugDraw(_view, _physicsWorld);
				_debugDraw.debugMode |= AWPDebugDraw.DBG_DrawTransform;
			}
		}
		
		private function updateBody():void {
			
			var i:uint, x:int, y:int, z:int;
			
			/*  var bodyLength:int = _physicsWorld.rigidBodies.length;
			   for (i = 0; i < bodyLength; ++i) {
			   if (_physicsWorld.rigidBodies[i].activationState == AWPCollisionObject.ISLAND_SLEEPING)
			   _physicsWorld.rigidBodies[i].activate(true);
			 }*/
			
			//var cubeLength:int = _rigidCubes.length;
			var sphereLength:int = _rigidSpheres.length;
			for (i = 0; i < sphereLength; ++i) {
				if (_rigidSpheres[i].position.y < -100) {
					x = int(-2000 + Math.random() * 4000);
					z = int(-2000 + Math.random() * 4000);
					if (_isWithField)
						y = getHeightAt(x, z) + 200;
					else
						y = 100;
					_rigidSpheres[i].position = new Vector3D(x, y, z);
					_rigidSpheres[i].linearVelocity = new Vector3D();
				}
			}
		}
		
		private function on3DMouseUp(event:MouseEvent3D):void {
			var mpos:Vector3D = event.localPosition.add(new Vector3D(0, 150, 0));
			var normal:Vector3D = mpos.add(event.sceneNormal.clone());
			
			if (!_sphereShape)
				_sphereShape = new AWPSphereShape(40);
			var pos:Vector3D = _center.add(new Vector3D(0, 150, 0)); // _view.camera.position;
			
			_target.position = mpos;
			_target.lookAt(pos);
			
			var impulse:Vector3D = mpos.subtract(pos);
			impulse.normalize();
			impulse.scaleBy(30);
			_shipTop.lookAt(impulse);
			
			// shoot a sphere
			var sphere:Mesh = new Mesh(new SphereGeometry(40), _sphereMaterial);
			_view.scene.addChild(sphere);
			
			var body:AWPRigidBody = new AWPRigidBody(_sphereShape, sphere, 1);
			body.position = pos;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			body.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			
			//_physicsWorld.addRigidBody(body);
			_physicsWorld.addRigidBodyWithGroup(body, collisionBullet, collisionGround | collisionPlane | collisionBuilding | collisionTree);
			_rigidSpheres.push(body);
			body.applyCentralImpulse(impulse);
		}
		
		/**
		 * stage listener for enterframe
		 */
		private function handleEnterFrame(e:Event):void {
			//camera
			if (_move) {
				_controller.panAngle = 0.3 * (stage.mouseX - _mouseNav[0]) + _mouseNav[2];
				_controller.tiltAngle = 0.3 * (stage.mouseY - _mouseNav[1]) + _mouseNav[3];
			}
			_controller.lookAtPosition = _center.add(new Vector3D(0, 70, 0));
			_controller.update();
			
			//physics
			_physicsWorld.step(_timeStep, 4, _timeStep);
			
			moveField();
			
			updateBody();
			
			if (_reflectionTexture) {
				_reflectionTexture.position = _shipBody.position;
				_reflectionTexture.render(_view);
			}
			
			//_waterMethod.water1OffsetX = _easeRot.x
			//_waterMethod.water1OffsetY = _easeRot.z;
			//animate our lake material
			_waterMethod.water1OffsetX += .0003;
			_waterMethod.water1OffsetY += .0004;
			_waterMethod.water2OffsetX += .0001;
			_waterMethod.water2OffsetY += .0002;
			
			if (_isDebug)
				_debugDraw.debugDrawWorld();
			_view.render();
		
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void {
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_title.y = stage.stageHeight - 26;
			moveStat();
		}
		
		private function moveStat(e:MouseEvent = null):void {
			_subStat.y = stage.stageHeight - 85;
			_stats.x = _subStat.width = stage.stageWidth - 125;
			_stats.y = stage.stageHeight - _stats.height + 4;
			_stats.x = stage.stageWidth - 125;
			if (_stats.height == 88)
				_stats.y--;
		}
		
		/**
		 * stage listener for mouse navigation
		 */
		private function onMouseUp(event:Event):void {
			_move = false;
		}
		
		private function onMouseDown(event:MouseEvent):void {
			_mouseNav[0] = stage.mouseX;
			_mouseNav[1] = stage.mouseY;
			_mouseNav[2] = _controller.panAngle;
			_mouseNav[3] = _controller.tiltAngle;
			_move = true;
		}
		
		private function onMouseWheel(ev:MouseEvent):void {
			_controller.distance -= ev.delta * 5;
			if (_controller.distance < _mouseNav[4])
				_controller.distance = _mouseNav[4];
			else if (_controller.distance > _mouseNav[5])
				_controller.distance = _mouseNav[5];
		}
		
		/**
		 * create bitmapData
		 */
		private function islandMapCache():BitmapData {
			var groundAdd:BitmapData = new BitmapData(_resolution, _resolution, true, 0x000000);
			var g:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(_resolution, _resolution);
			//g.graphics.beginGradientFill("radial", [0x000000, 0x000000, 0x000000, 0x000000], [0, 0.2, 0.5, 1], [0x00, 0x99, 0xAA, 0xEF], m);
			g.graphics.beginGradientFill("radial", [0x000000, 0x000000, 0x000000, 0x000000], [0, 0, 0.15, 0.4], [0x00, 0x99, 0xDD, 0xFF], m);
			
			g.graphics.drawRect(0, 0, _resolution, _resolution);
			groundAdd.draw(g);
			g.graphics.clear();
			return groundAdd;
		}
		
		private function layerTerrainBitmap():void {
			_layers[0].lock;
			_layers[1].lock;
			_layers[2].lock;
			var layerTop:Array = [0x808080, 0x606060];
			
			var p:Point = new Point();
			var rect:Rectangle;
			
			if (_factor != 1) {
				rect = _bumpBig.rect;
				_layers[0] = _bumpBig.clone();
			} else {
				rect = _bump.rect;
				_layers[0] = _bump.clone();
			}
			//green _ mid
			_layers[1].threshold(_layers[0], rect, p, ">", 0xFF000000 + layerTop[0], 0x0000000, 0xFFFFFFFF, true);
			_layers[1].colorTransform(rect, new ColorTransform(0, 1, 0, 1, 0, 255, 0, 0));
			_layers[1].applyFilter(_layers[1], rect, p, new BlurFilter(6, 6, 1));
			//blue _ bottom
			_layers[2].threshold(_layers[0], rect, p, ">", 0xFF000000 + layerTop[1], 0x0000000, 0xFFFFFFFF, true);
			_layers[2].colorTransform(rect, new ColorTransform(0, 0, 1, 1, 0, 0, 255, 0));
			_layers[2].applyFilter(_layers[2], rect, p, new BlurFilter(6, 6, 1));
			_layers[1].unlock;
			_layers[2].unlock;
			//copy chanel from other layer to base layer
			_layers[0].colorTransform(rect, new ColorTransform(1, 0, 0, 1, 255, 0, 0, 0));
			_layers[0].draw(_layers[1]);
			_layers[0].draw(_layers[2]);
			_layers[0].unlock;
		}
		
		private function background():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(512, 512, RadDeg(-90));
			s.graphics.beginGradientFill("linear", _skyColors, [1, 1, 1, 1], [0x88, 0x99, 0xCC, 0xFF], m);
			s.graphics.drawRect(0, 0, 512, 512);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(512, 512, false, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function targetBitmap():BitmapData {
			var s:Sprite = new Sprite();
			s.graphics.lineStyle(10, 0xff0000, 1);
			s.graphics.drawCircle(128, 128, 100);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(256, 256, true, 0x00000000);
			b.draw(s);
			return b;
		}
		
		/**
		 * Math function
		 */
		private function Orbit(H:Number, V:Number, D:Number):Vector3D {
			var p:Vector3D = new Vector3D()
			var phi:Number = RadDeg(H);
			var theta:Number = RadDeg(V);
			p.x = (D * Math.sin(phi) * Math.cos(theta));
			p.z = (D * Math.sin(phi) * Math.sin(theta));
			p.y = (D * Math.cos(phi));
			return p;
		}
		
		private function RadDeg(d:Number):Number {
			return (d * (Math.PI / 180));
		}
		
		/**
		 * add text for engine info
		 */
		private function initInfo():void {
			_title = new TextField();
			_title.selectable = false;
			_title.defaultTextFormat = new TextFormat("courier new", 15, 0xffffff);
			_title.x = 4;
			_title.width = 200;
			_title.height = 20;
			_title.text = "Physics Field";
			_title.mouseEnabled = false;
			this.addChild(_title);
			
			_tf = new TextField();
			_tf.selectable = false;
			_tf.defaultTextFormat = new TextFormat("courier new", 11, 0xffffff);
			_tf.x = 4;
			_tf.y = 4;
			_tf.width = 300;
			_tf.height = 300;
			_tf.text = "test";
			_tf.mouseEnabled = false;
			
			this.addChild(_tf);
		}
		
		private function CubicSky(xl:int = 64):BitmapCubeTexture {
			var h:BitmapData = new BitmapData(xl, xl, false, 0x000000);
			var h2:BitmapData = new BitmapData(xl, xl, false, _skyColors[0]);
			var h3:BitmapData = new BitmapData(xl, xl, false, _skyColors[2]);
			var grad:Sprite = new Sprite();
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(xl, xl);
			grad.graphics.beginGradientFill('radial', [_skyColors[3], _skyColors[2]], [1, 1], [0, 0xDD], matrix);
			grad.graphics.drawRect(0, 0, xl, xl);
			h3.draw(grad);
			matrix = new Matrix();
			matrix.createGradientBox(xl, xl, -Math.PI / 2);
			grad.graphics.clear();
			grad.graphics.beginGradientFill('linear', [_skyColors[0], _skyColors[0], _skyColors[1], _skyColors[2]], [1, 1, 1, 1], [0x00, 0x80, 0xAA, 0xFF], matrix);
			grad.graphics.drawRect(0, 0, xl, xl);
			h.draw(grad);
			grad.graphics.clear();
			grad = null;
			var cc:BitmapCubeTexture = new BitmapCubeTexture(h, h, h3, h2, h, h);
			return cc;
		}
	
	}
}

//=============================================================
//   BITMAP SCROLLING
//=============================================================
/*
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.geom.Matrix;

   internal class BitmapScrolling extends BitmapData {
   private var _map:BitmapData;
   private var _matrix:Matrix;
   private var _content:Shape;
   private var _canvas:Graphics;
   private var _size:int;
   private var _limit:Number;

   public function BitmapScrolling(B:BitmapData) {
   super(B.width, B.height, false);
   _size = B.width;
   _map = B;
   _matrix = new Matrix();
   _content = new Shape();
   _limit = _size;
   _canvas = _content.graphics;
   move();
   }

   public function move(x:Number = 0, y:Number = 0):void {
   _matrix.translate(x, y);
   if (_matrix.ty > _limit)
   _matrix.ty = 0;
   else if (_matrix.ty < -_limit)
   _matrix.ty = 0;
   if (_matrix.tx > _limit)
   _matrix.tx = 0;
   else if (_matrix.tx < -_limit)
   _matrix.tx = 0;
   _canvas.beginBitmapFill(_map, _matrix, true, false);
   _canvas.drawRect(0, 0, _size, _size);
   _canvas.endFill();
   this.lock();
   this.draw(_content);
   _canvas.clear();
   this.unlock();
   }
 }*/

//=============================================================
//   BITMAP SCROLLING WITH COPYPIXEL
//=============================================================

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;

internal class BitmapScrolling extends BitmapData {
	private var _mapScroll:BitmapData;
	private var _size:int;
	private var _rec:Rectangle;
	private var _p:Point = new Point();
	private var _p0:Point = new Point();
	
	public function BitmapScrolling(B:BitmapData) {
		_size = B.width;
		super(_size, _size, false);
		_rec = B.rect;
		_mapScroll = new BitmapData(_size * 2, _size * 2, false);
		_mapScroll.copyPixels(B, _rec, new Point());
		_mapScroll.copyPixels(B, _rec, new Point(0, _size));
		_mapScroll.copyPixels(B, _rec, new Point(_size, 0));
		_mapScroll.copyPixels(B, _rec, new Point(_size, _size));
		move();
	}
	
	public function move(x:Number = 0, y:Number = 0):void {
		_p.offset(x, y);
		if (_p.y > _size)
			_p.y = 0;
		else if (_p.y < 0)
			_p.y = _size;
		if (_p.x > _size)
			_p.x = 0;
		else if (_p.x < 0)
			_p.x = _size;
		_rec.x = _p.x;
		_rec.y = _p.y;
		this.lock();
		this.copyPixels(_mapScroll, _rec, _p0);
		this.unlock();
	}
}