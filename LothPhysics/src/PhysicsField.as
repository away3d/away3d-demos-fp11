package {
	import away3d.containers.View3D;
	import away3d.core.base.SubGeometry;
	import away3d.core.pick.PickingColliderType;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.textures.CubeReflectionTexture;
	import away3d.tools.helpers.MeshHelper;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPCapsuleShape;
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
	
	import utils.PerlinShape;
	
	[SWF(backgroundColor="#c4d6e7",frameRate="60",width="600",height="600")]
	
	public class PhysicsField extends Sprite {
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
		private var _skySphere:Mesh;
		private var _skyMaterial:TextureMaterial;
		
		//methodes
		private var _reflectionTexture:CubeReflectionTexture;
		private var _fresnelMethod:FresnelEnvMapMethod;
		private var _fogMethod:FogMethod;
		
		//field variables
		private var _resolution:int = 64;
		private var _dimension:int = 10000;
		private var _elevation:int = 2000;
		private var _factor:uint = 2;
		private var _field:Mesh;
		private var _fieldSubGeometry:SubGeometry
		private var _fieldMaterial:TextureMaterial;
		private var _terrainMethode:TerrainDiffuseMethod;
		private var _specularMethod:FresnelSpecularMethod;
		private const _textures:Vector.<BitmapTexture> = new Vector.<BitmapTexture>();
		private const _layers:Vector.<BitmapData> = new Vector.<BitmapData>();
		private const _heights:Vector.<Number> = new Vector.<Number>();
		
		private var _sphereMaterial:ColorMaterial;
		
		//perlin noise variable
		private var _bigMatrix:Matrix;
		private var _bump:BitmapData;
		private var _bumpBig:BitmapData;
		private var _island:BitmapData;
		private var _ease:Vector3D;
		private var _fractal:Boolean;
		private var _numOctaves:uint;
		private var _offsets:Array;
		private var _complex:Number;
		private var _seed:int;
		private var _position:Vector3D = new Vector3D(0, 0, 0);
		private var _positionY:int = 0;
		
		//physics
		private var _physicsWorld:AWPDynamicsWorld;
		private var debugDraw:AWPDebugDraw;
		private var _timeStep:Number = 0.0167;
		private var _sphereShape:AWPSphereShape;
		private var _terrainShape:PerlinShape;
		private var _terrainBody:AWPRigidBody;
		private const _rigidCubes:Vector.<AWPRigidBody> = new Vector.<AWPRigidBody>();
		private const _rigidSpheres:Vector.<AWPRigidBody> = new Vector.<AWPRigidBody>();
		
		// defined collison group
		private const collsionGround:int = 1;
		private const collsionBox:int = 2;
		private const collsionBox2:int = 4;
		private const collsionNull:int = 0;
		private const collsionHero:int = 8;
		//private const collsionCone : int = 8;
		//private const collsionSphere : int = 16;
		private const collisionAll:int = -1;
		
		//mouse navigation
		private const _mouseNav:Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 50, 5000]);
		private var _center:Vector3D = new Vector3D(0, 50, 0);
		private var _move:Boolean = false;
		private var _speed:Number = 0.5;
		//plane
		private var _plane:Mesh;
		private var _planeMaterial:ColorMaterial;
		
		//ship
		private var _ship:Mesh;
		private var _shipBody:AWPRigidBody;
		private var _shipJoint:AWPHingeConstraint;
		private var _shipdMaterial:TextureMaterial;
		private var _rootBox:AWPRigidBody;
		
		private var _tf:TextField;
		private var _title:TextField;
		
		private var _sf:Mesh;
		
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
			_view.antiAlias = 4;
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
			_sunLight = new DirectionalLight(0, -1, 0.85);
			_view.scene.addChild(_sunLight);
			_light = new PointLight();
			_light.y = 2000;
			_view.scene.addChild(_light);
			_lightPicker = new StaticLightPicker([_sunLight, _light]);
			
			//setup the method
			_fogMethod = new FogMethod(1000, _dimension / 2, _bgColor);
			
			//setup the camera
			_view.camera.lens = new PerspectiveLens(80);
			_view.camera.lens.near = 10;
			_view.camera.lens.far = _dimension;
			
			_sf = new Mesh(new CubeGeometry(50, 50, 100), new ColorMaterial(0x00ff00));
			_view.scene.addChild(_sf);
			
			//setup the camera controller
			_controller = new HoverController(_view.camera, null, 0, 20, 1000, 0, 35);
			_controller.wrapPanAngle = true;
			_controller.autoUpdate = false;
			_controller.lookAtPosition = _center;
			
			//setup the physics world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = false;
			_physicsWorld.scaling = 100;
			_physicsWorld.gravity = new Vector3D(0, -10, 0);
			
			//setup the physics debug
			debugDraw = new AWPDebugDraw(_view, _physicsWorld);
			debugDraw.debugMode |= AWPDebugDraw.DBG_DrawTransform;
			
			_sphereMaterial = new ColorMaterial(0xCCCCCC, 1);
			_sphereMaterial.lightPicker = _lightPicker;
			_sphereMaterial.addMethod(_fogMethod);
			_sphereMaterial.specular = 1;
			_sphereMaterial.gloss = 300;
			
			// setup the plane
			_planeMaterial = new ColorMaterial(_bgColor, 0.1);
			_planeMaterial.lightPicker = _lightPicker;
			_planeMaterial.addMethod(_fogMethod);
			_planeMaterial.specular = 1;
			_planeMaterial.gloss = 10;
			_plane = new Mesh(new PlaneGeometry(_dimension, _dimension, 6, 6), _planeMaterial);
			_view.scene.addChild(_plane);
			_plane.y = _elevation - _elevation / 1.618;
			
			//_plane.mouseEnabled = true;
			//_plane.mouseChildren = true;
			// _plane.shaderPickingDetails = true;
			// _plane.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			//_plane.addEventListener(MouseEvent3D.MOUSE_UP, on3DMouseUp);
			
			//setup perlin noise variable
			_fractal = true;
			_offsets = [];
			_numOctaves = 1;
			_complex = 0.11; //12;
			_ease = new Vector3D();
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
			_island = islandMapCache();
			_bigMatrix = new Matrix();
			_bigMatrix.scale(_factor, _factor);
			
			//setup material & terrain methode
			_layers[0] = b01.clone();
			_layers[1] = b02.clone();
			_layers[2] = b02.clone();
			_textures[0] = new BitmapTexture(new BitmapData(64, 64, false, 0x30cc40));
			_textures[1] = new BitmapTexture(new BitmapData(64, 64, false, 0xb99c56));
			_textures[2] = new BitmapTexture(new BitmapData(64, 64, false, 0xcccc00));
			_textures[3] = new BitmapTexture(b01.clone()); //new BitmapTexture(layerTerrainBitmap());
			_terrainMethode = new TerrainDiffuseMethod([_textures[0], _textures[1], _textures[2]], _textures[3], [1, 10, 10, 10]);
			_specularMethod = new FresnelSpecularMethod();
			//_specularMethod.fresnelPower = 300;
			_specularMethod.normalReflectance = 0.4;
			
			//normal
			var shaderData:ShaderData = _normalMapShader.data;
			ShaderParameter(shaderData["amount"]).value = [6];
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
			_fieldMaterial.addMethod(_fogMethod);
			
			//setup the field Mesh
			_field = new Mesh(new PlaneGeometry(_dimension, _dimension, _resolution - 1, _resolution - 1, true, false), _fieldMaterial);
			_field.geometry.convertToSeparateBuffers();
			_field.pickingCollider = PickingColliderType.AS3_FIRST_ENCOUNTERED;
			_field.addEventListener(MouseEvent3D.MOUSE_UP, on3DMouseUp);
			_field.mouseEnabled = true;
			
			//setup the field sugGeometry referency
			_fieldSubGeometry = _field.geometry.subGeometries[0] as SubGeometry;
			_fieldSubGeometry.autoDeriveVertexNormals = false;
			_fieldSubGeometry.autoDeriveVertexTangents = false;
			_view.scene.addChild(_field);
			
			updateField();
			initPhysicsField();
			
			//create background invers sphere
			_skyMaterial = new TextureMaterial(new BitmapTexture(background()));
			_skySphere = new Mesh(new SphereGeometry(_dimension / 2, 20, 16), _skyMaterial);
			_skySphere.geometry.convertToSeparateBuffers();
			MeshHelper.invertFaces(_skySphere);
			_skySphere.castsShadows = false;
			_view.scene.addChild(_skySphere);
			initShip();
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			
			//mouse navigation
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
		}
		private var _hero:AWPKinematicCharacterController
		
		private function initShip():void {
			
			/* var cshape:AWPCapsuleShape = new AWPCapsuleShape(100, 30);
			   var ghostObject:AWPGhostObject = new AWPGhostObject(cshape, null);
			   ghostObject.friction = 0.3;
			   ghostObject.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;
			   _hero = new AWPKinematicCharacterController(ghostObject, 0.1);
			   _physicsWorld.addCharacter(_hero, collsionHero, collsionGround);
			   //_physicsWorld.addRigidBodyWithGroup(_hero, collsionHero, collsionGround);
			   _hero.warp(_center.add(new Vector3D(0,1000,0)));
			 */
			var bshape:AWPBoxShape = new AWPBoxShape(100, 20, 100);
			_rootBox = new AWPRigidBody(bshape, null, 0);
			_rootBox.position = _center.add(new Vector3D(0, 0, 0));
			//_physicsWorld.addRigidBody(_rootBox);
			_physicsWorld.addRigidBodyWithGroup(_rootBox, collsionBox2, collsionNull);
			
			_reflectionTexture = new CubeReflectionTexture(128);
			_reflectionTexture.farPlaneDistance = _dimension;
			_reflectionTexture.nearPlaneDistance = 40;
			_reflectionTexture.position = _center;
			_fresnelMethod = new FresnelEnvMapMethod(_reflectionTexture);
			_fresnelMethod.normalReflectance = .6;
			_fresnelMethod.fresnelPower = 2;
			
			_shipdMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0x333333)));
			_shipdMaterial.lightPicker = _lightPicker;
			_shipdMaterial.addMethod(_fresnelMethod);
			
			_ship = new Mesh(new SphereGeometry(130), _shipdMaterial);
			_ship.scaleY = (0.5);
			// _ship.movePivot(0, -100, 0);
			//var shape:AWPSphereShape = new AWPSphereShape(100);
			var shape:AWPCylinderShape = new AWPCylinderShape(120, 200);
			//var shape:AWPBoxShape = new AWPBoxShape(200, 200, 200);
			_shipBody = new AWPRigidBody(shape, _ship, 1);
			_shipBody.position = _center.add(new Vector3D(0, 100, 0));
			_shipBody.friction = 0.3;
			_shipBody.restitution = 0;
			_shipBody.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			_shipBody.ccdSweptSphereRadius = 0.5;
			_shipBody.ccdMotionThreshold = 1;
			//   _shipBody.linearDamping = 2;
			//	_shipBody.angularDamping = 2;
			//_shipBody.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;
			//_shipBody.addEventListener(AWPEvent.COLLISION_ADDED, collisionAdded);
			
			//_shipBody.ccdSweptSphereRadius = 0.5;
			//_shipBody.ccdMotionThreshold = 1;
			//_physicsWorld.addRigidBody(_shipBody);
			_physicsWorld.addRigidBodyWithGroup(_shipBody, collsionBox, collisionAll);
			
			_view.scene.addChild(_ship);
			
			_shipJoint = new AWPHingeConstraint(_shipBody, new Vector3D(0, -100, 0), new Vector3D(0, 1, 0), _rootBox, new Vector3D(0, 5, 0), new Vector3D(0, 1, 0));
			_physicsWorld.addConstraint(_shipJoint, true);
			_shipJoint.setLimit(1, 30, 0.9, 0.9, 0.3);
			//  _shipJoint.angularOnly = true;
		}
		
		private function collisionAdded(event:AWPEvent):void {
			if (!(event.collisionObject.collisionFlags & AWPCollisionFlags.CF_STATIC_OBJECT)) {
				var body:AWPRigidBody = AWPRigidBody(event.collisionObject);
				var force:Vector3D = event.manifoldPoint.normalWorldOnB.clone();
				force.scaleBy(-30);
				body.applyForce(force, event.manifoldPoint.localPointB);
			}
		}
		
		/**
		 * update field defformation and texture
		 */
		private function updateField():void {
			_bump.lock();
			//	
			_bump.perlinNoise(_resolution * _complex, _resolution * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			//_bump.draw(_island);
			_bump.unlock();
			if (_factor != 1) {
				_bumpBig.lock();
				_bumpBig.draw(_bump, _bigMatrix);
				_bumpBig.applyFilter(_bumpBig, _bumpBig.rect, new Point(), new BlurFilter(4, 4, 1));
				_bumpBig.unlock();
			}
			
			var i:uint, px:uint, c:uint, n:uint;
			var len:uint = _fieldSubGeometry.vertexData.length;
			
			for (i = 1; i < len; i += 3, ++c) {
				px = _bump.getPixel(c % _resolution, _resolution - (c / _resolution));
				// Displace y position by the range
				n = (_elevation * px / 0xffffff - _positionY);
				_fieldSubGeometry.vertexData[i] = n
				_heights[c] = n;
				if (c == 2016) { //_center.y = n;
					_center = new Vector3D(_fieldSubGeometry.vertexData[i - 1], _fieldSubGeometry.vertexData[i], _fieldSubGeometry.vertexData[i + 1]);
				}
			}
			//var normal:Vector3D = _fieldSubGeometry.faceNormals[];
			//update geometry
			_fieldSubGeometry.updateVertexData(_fieldSubGeometry.vertexData);
			
			//update texture
			layerTerrainBitmap();
			_textures[3].bitmapData = _layers[0];
			
			//_normalBitmap.lock();
			//_normalBitmap.applyFilter(_bump, _bump.rect, new Point(), _normalMapFilters[0]);
			if (_factor != 1) {
				BitmapTexture(TextureMaterial(_fieldMaterial).texture).bitmapData = _bumpBig;
				_normalBitmap.applyFilter(_bumpBig, _bumpBig.rect, new Point(), _normalMapFilters[0]);
			} else {
				BitmapTexture(TextureMaterial(_fieldMaterial).texture).bitmapData = _bump;
				_normalBitmap.applyFilter(_bump, _bump.rect, new Point(), _normalMapFilters[0]);
			}
			_tf.text = "num" + _fieldSubGeometry.faceNormals.length;
			BitmapTexture(TextureMaterial(_fieldMaterial).texture).invalidateContent();
			//_normalBitmap.unlock();
			_textures[4].bitmapData = _normalBitmap;
			_textures[4].invalidateContent();
			
			//_center.y = getHeightAt();
			if (_rootBox)
				_rootBox.position = _center;
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
		private function move():void {
			var i:uint;
			for (i = 0; i < _numOctaves; ++i) {
				_offsets[i].x = _position.x;
				_offsets[i].y = _position.z;
			}
			updateField();
			updatePhysicsField();
		}
		
		private function keyDownHandler(event:KeyboardEvent):void {
			switch (event.keyCode) {
				case Keyboard.UP: 
				case Keyboard.W: 
				case Keyboard.Z: 
					_position.z += _speed;
					break;
				case Keyboard.DOWN: 
				case Keyboard.S: 
					_position.z -= _speed;
					break;
				case Keyboard.LEFT: 
				case Keyboard.A: 
				case Keyboard.Q: 
					_position.x += _speed;
					break;
				case Keyboard.RIGHT: 
				case Keyboard.D: 
					_position.x -= _speed;
					break;
			}
			move();
		}
		
		private function initPhysicsField():void {
			_terrainShape = new PerlinShape(_resolution, _resolution, _dimension, _dimension, _elevation, _heights);
			_terrainBody = new AWPRigidBody(_terrainShape, null, 0);
			_terrainBody.friction = 0.1;
			_terrainBody.restitution = 0.0;
			//_physicsWorld.addRigidBody(_terrainBody);
			_physicsWorld.addRigidBodyWithGroup(_terrainBody, collsionGround, collisionAll);
		
		}
		
		private function updatePhysicsField():void {
			/*var i:int;
			   var bodyLength:int = _physicsWorld.rigidBodies.length;
			   for (i = 0; i < bodyLength; ++i) {
			   if (_physicsWorld.rigidBodies[i].activationState == AWPCollisionObject.ISLAND_SLEEPING)
			   _physicsWorld.rigidBodies[i].activate(true);
			 }*/
			_terrainShape.update(_heights, _elevation);
		}
		
		private function updateBody():void {
			var i:uint, x:int, y:int, z:int;
			//var cubeLength:int = _rigidCubes.length;
			var sphereLength:int = _rigidSpheres.length;
			/*for (i = 0; i < cubeLength; ++i) {
			   if (_rigidCubes[i].position.y < 0) {
			   x = int(-2000 + Math.random() * 4000);
			   z = int(-2000 + Math.random() * 4000);
			   y = getHeightAt(x, z) + 200;
			   _rigidCubes[i].position = new Vector3D(x, y, z);
			   _rigidCubes[i].linearVelocity = new Vector3D();
			   }
			 }*/
			for (i = 0; i < sphereLength; ++i) {
				if (_rigidSpheres[i].position.y < 0) {
					x = int(-2000 + Math.random() * 4000);
					z = int(-2000 + Math.random() * 4000);
					y = getHeightAt(x, z) + 200;
					_rigidSpheres[i].position = new Vector3D(x, y, z);
					_rigidSpheres[i].linearVelocity = new Vector3D();
				}
			}
		}
		
		private function on3DMouseUp(event:MouseEvent3D):void {
			var uv:Point = event.uv;
			
			// var mpos:Vector3D = new Vector3D(int(event.localPosition.x), 500, int(event.localPosition.z));
			var mpos:Vector3D = new Vector3D(int(event.localPosition.x), int(event.localPosition.y), int(event.localPosition.z)); //event.scenePosition;//new Vector3D( uv.x , 500, uv.y);
			//mpos= _plane.entity.sceneTransform.transformVector(_plane.localPosition);
			var normal:Vector3D = mpos.add(event.sceneNormal.clone());
			_tf.text = "Vector" + mpos + "\n n:" + normal;
			_sf.position = mpos;
			_sf.lookAt(normal);
			
			if (!_sphereShape)
				_sphereShape = new AWPSphereShape(50);
			var pos:Vector3D = _view.camera.position;
			//var mpos:Vector3D = new Vector3D(event.localPosition.x, event.localPosition.y, event.localPosition.z);
			
			var impulse:Vector3D = mpos.subtract(pos);
			impulse.normalize();
			impulse.scaleBy(30);
			
			// shoot a sphere
			//var material:ColorMaterial = new ColorMaterial(Math.random() * 0xffffff);
			//material.lightPicker = _lightPicker;
			
			var sphere:Mesh = new Mesh(new SphereGeometry(50), _sphereMaterial);
			_view.scene.addChild(sphere);
			
			var body:AWPRigidBody = new AWPRigidBody(_sphereShape, sphere, 1);
			body.position = pos;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			body.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			
			_physicsWorld.addRigidBody(body);
			_rigidSpheres.push(body);
			body.applyCentralImpulse(impulse);
		}
		
		/**
		 * stage listener for enterframe
		 */
		private function handleEnterFrame(e:Event):void {
			if (_move) {
				_controller.panAngle = 0.3 * (stage.mouseX - _mouseNav[0]) + _mouseNav[2];
				_controller.tiltAngle = 0.3 * (stage.mouseY - _mouseNav[1]) + _mouseNav[3];
			}
			_controller.lookAtPosition = _center.add(new Vector3D(0, 50, 0));
			_controller.update();
			/*if (_shipBody){_shipBody.linearVelocity = new Vector3D();
			   _shipBody.linearDamping = 0;
			 }*/ //.warp(_center);
			updateBody();
			_physicsWorld.step(_timeStep, 4, _timeStep);
			
			if (_reflectionTexture) {
				_reflectionTexture.position = _shipBody.position;
				_reflectionTexture.render(_view);
			}
			
			debugDraw.debugDrawWorld();
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
			g.graphics.beginGradientFill("radial", [0x000000, 0x000000, 0x000000, 0x000000], [0, 0.2, 0.5, 1], [0x00, 0x99, 0xAA, 0xEF], m);
			g.graphics.drawRect(0, 0, _resolution, _resolution);
			groundAdd.draw(g);
			g.graphics.clear();
			return groundAdd;
		}
		
		private function layerTerrainBitmap():void {
			
			//_bumpBig.lock();
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
			//_layers[1].applyFilter(_layers[1], rect, p, new BlurFilter(10, 10, 1));
			//blue _ bottom
			_layers[2].threshold(_layers[0], rect, p, ">", 0xFF000000 + layerTop[1], 0x0000000, 0xFFFFFFFF, true);
			_layers[2].colorTransform(rect, new ColorTransform(0, 0, 1, 1, 0, 0, 255, 0));
			//_layers[2].applyFilter(_layers[2], rect, p, new BlurFilter(10, 10, 1));
			_layers[1].unlock;
			_layers[2].unlock;
			//copy chanel from other layer to base layer
			_layers[0].colorTransform(rect, new ColorTransform(1, 0, 0, 1, 255, 0, 0, 0));
			_layers[0].draw(_layers[1]);
			_layers[0].draw(_layers[2]);
			_layers[0].applyFilter(_layers[0], rect, p, new BlurFilter(6, 6, 1));
			_layers[0].unlock;
		}
		
		private function background():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(512, 512, RadDeg(-90));
			s.graphics.beginGradientFill("linear", [_bgColor, 0x55b2de, 0x0685d6, 0x041984], [1, 1, 1, 1], [0x90, 0xAA, 0xCC, 0xFF], m);
			s.graphics.drawRect(0, 0, 512, 512);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(512, 512, false, 0x00000000);
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
	}
}