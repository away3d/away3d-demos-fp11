package {
	import away3d.containers.View3D;
	import away3d.core.base.SubGeometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.controllers.HoverController;
	import away3d.cameras.lenses.PerspectiveLens;
	
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
	import flash.utils.ByteArray;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import utils.PerlinShape;
	
	[SWF(backgroundColor="#808080",frameRate="60",width="600",height="600")]
	
	public class PhysicsField extends Sprite {
		private var _view:View3D;
		private var _controller:HoverController;
		private var _sunLight:DirectionalLight;
		private var _light:PointLight;
		private var lightPicker:StaticLightPicker;
		private var _bgColor:uint = 0x808080;
		
		//field variables
		private var _resolution:int = 64;
		private var _dimension:int = 4000;
		private var _elevation:int = 500;
		private var _field:Mesh;
		private var _fieldSubGeometry:SubGeometry
		private var _fieldMaterial:TextureMaterial;
		private var _terrainMethode:TerrainDiffuseMethod;
		private var _specularMethod:FresnelSpecularMethod;
		private const _textures:Vector.<BitmapTexture> = new Vector.<BitmapTexture>();
		private const _layers:Vector.<BitmapData> = new Vector.<BitmapData>();
		private const _heights:Vector.<Number> = new Vector.<Number>();
		
		//perlin noise variable
		private var _bump:BitmapData;
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
		
		//mouse navigation
		private const _mouseNav:Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 50, 5000]);
		private var _center:Vector3D = new Vector3D(0, 50, 0);
		private var _move:Boolean = false;
		
		//ship
		private var _ship:Mesh;
		private var _shipBody:AWPRigidBody;
		private var _shipJoint:AWPHingeConstraint;
		
		public function PhysicsField() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_view = new View3D();
			_view.antiAlias = 8;
			_view.backgroundColor = _bgColor;
			this.addChild(_view);
			this.addChild(new AwayStats(_view));
			
			_sunLight = new DirectionalLight(0, -1, 0);
			_view.scene.addChild(_sunLight);
			
			_light = new PointLight();
			_light.z = 2000;
			_view.scene.addChild(_light);
			
			lightPicker = new StaticLightPicker([_sunLight, _light]);
			
			//setup the camera
			_view.camera.lens = new PerspectiveLens(70);
			_view.camera.lens.near = 10;
			_view.camera.lens.far = 10000;
			
			//setup the camera controller
			_controller = new HoverController(_view.camera, null, 0, 20, 2500, -5, 35);
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
			
			//setup perlin noise variable
			_fractal = true;
			_offsets = [];
			_numOctaves = 1;
			_complex = 0.07 //12;
			_ease = new Vector3D();
			_seed = int(Math.random() * 0xffffffff);
			for (var u:uint = 0; u < _numOctaves; ++u) {
				_offsets[u] = new Point(0, 0);
			}
			
			//setup the field deformation bitmap
			var b01:BitmapData = new BitmapData(_resolution, _resolution, false);
			var b02:BitmapData = new BitmapData(_resolution, _resolution, true);
			
			_bump = b01.clone();
			_island = islandMapCache();
			
			//setup material terrain methode
			_layers[0] = b01.clone();
			_layers[1] = b02.clone();
			_layers[2] = b02.clone();
			_textures[0] = new BitmapTexture(new BitmapData(64, 64, false, 0xcc4237));
			_textures[1] = new BitmapTexture(new BitmapData(64, 64, false, 0xb99c56));
			_textures[2] = new BitmapTexture(new BitmapData(64, 64, false, _bgColor));
			_textures[3] = new BitmapTexture(layerTerrainBitmap(_bump));
			_terrainMethode = new TerrainDiffuseMethod([_textures[0], _textures[1], _textures[2]], _textures[3], [1, 10, 10, 10]);
			_specularMethod = new FresnelSpecularMethod();
			_specularMethod.fresnelPower = 100;
			_specularMethod.normalReflectance = 0.3;
			
			//setup the field material
			_fieldMaterial = new TextureMaterial(new BitmapTexture(_bump));
			//_fieldMaterial = new TextureMaterial(new BitmapTexture(b01.clone()));
			_fieldMaterial.lightPicker = lightPicker;
			_fieldMaterial.diffuseMethod = _terrainMethode;
			_fieldMaterial.specularMethod = _specularMethod;
			_fieldMaterial.specular = 0.3;
			_fieldMaterial.gloss = 100;
			
			//setup the field Mesh
			_field = new Mesh(new PlaneGeometry(_dimension, _dimension, _resolution - 1, _resolution - 1, true, false), _fieldMaterial);
			_field.geometry.convertToSeparateBuffers();
			_field.addEventListener(MouseEvent3D.MOUSE_UP, on3DMouseUp);
			_field.mouseEnabled = true;
			
			//setup the field sugGeometry referency
			_fieldSubGeometry = _field.geometry.subGeometries[0] as SubGeometry;
			_fieldSubGeometry.autoDeriveVertexNormals = true;
			_fieldSubGeometry.autoDeriveVertexTangents = true;
			_view.scene.addChild(_field);
			
			updateField();
			initPhysicsField();
			
			// create a wall
			/*var material:ColorMaterial = new ColorMaterial(0x402525);
			   material.lightPicker = lightPicker;
			   material.specular = 0.2;
			
			   material = new ColorMaterial(0xfc6a11);
			 material.lightPicker = lightPicker;*/
			
			// create rigidbody shapes
			
			/*var boxShape:AWPBoxShape = new AWPBoxShape(200, 200, 200);
			
			   // create rigidbodies
			   var mesh:Mesh;
			   var body:AWPRigidBody;
			   var i:int, x:int, y:int, z:int;
			   for (i = 0; i < 18; i++) {
			   // create boxes
			   material = new ColorMaterial(Math.random() * 0xffffff);
			   material.lightPicker = lightPicker;
			   // material.color =;
			   mesh = new Mesh(new CubeGeometry(200, 200, 200), material);
			   _view.scene.addChild(mesh);
			   body = new AWPRigidBody(boxShape, mesh, 1);
			   body.friction = .6;
			   body.restitution = 0;
			   //body.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;;
			   x = int(-2000 + Math.random() * 4000);
			   z = int(-2000 + Math.random() * 4000);
			   y = getHeightAt(x, z) + 200;
			   body.position = new Vector3D(x, y, z);
			   body.ccdSweptSphereRadius = 0.5;
			   body.ccdMotionThreshold = 1;
			   _physicsWorld.addRigidBody(body);
			   _rigidCubes.push(body);
			   }
			 */
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			//mouse navigation
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
		}
		
		/**
		 * update field defformation and texture
		 */
		[Inline]
		
		private function updateField():void {
			_bump.lock();
			_bump.perlinNoise(_resolution * _complex, _resolution * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			_bump.draw(_island);
			_bump.unlock();
			
			var i:uint, px:uint, c:uint, n:uint;
			var len:uint = _fieldSubGeometry.vertexData.length;
			
			for (i = 1; i < len; i += 3, ++c) {
				px = _bump.getPixel(c % _resolution, _resolution - (c / _resolution));
				// Displace y position by the range
				n = (_elevation * px / 0xffffff - _positionY);
				_fieldSubGeometry.vertexData[i] = n
				_heights[c] = n;
			}
			
			//update geometry
			_fieldSubGeometry.updateVertexData(_fieldSubGeometry.vertexData);
			
			//update texture
			_textures[3].bitmapData = layerTerrainBitmap(_bump);
			BitmapTexture(TextureMaterial(_fieldMaterial).texture).invalidateContent();
			
			_center.y = getHeightAt() + 50;
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
					_position.z++;
					break;
				case Keyboard.DOWN: 
					_position.z--;
					break;
				case Keyboard.LEFT: 
					_position.x++;
					break;
				case Keyboard.RIGHT: 
					_position.x--;
					break;
			}
			move();
		}
		
		private function initPhysicsField():void {
			_terrainShape = new PerlinShape(_resolution, _resolution, _dimension, _dimension, _elevation, _heights);
			_terrainBody = new AWPRigidBody(_terrainShape, null, 0);
			_terrainBody.friction = 0.5;
			_terrainBody.restitution = 0.1;
			_physicsWorld.addRigidBody(_terrainBody);
		}
		
		private function updatePhysicsField():void {
			var i:int;
			var bodyLength:int = _physicsWorld.rigidBodies.length;
			for (i = 0; i < bodyLength; ++i) {
				if (_physicsWorld.rigidBodies[i].activationState == AWPCollisionObject.ISLAND_SLEEPING)
					_physicsWorld.rigidBodies[i].activate(true);
			}
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
			if (!_sphereShape)
				_sphereShape = new AWPSphereShape(50);
			var pos:Vector3D = _view.camera.position;
			var mpos:Vector3D = new Vector3D(event.localPosition.x, event.localPosition.y, event.localPosition.z);
			
			var impulse:Vector3D = mpos.subtract(pos);
			impulse.normalize();
			impulse.scaleBy(30);
			
			// shoot a sphere
			var material:ColorMaterial = new ColorMaterial(Math.random() * 0xffffff);
			material.lightPicker = lightPicker;
			
			var sphere:Mesh = new Mesh(new SphereGeometry(50), material);
			_view.scene.addChild(sphere);
			
			var body:AWPRigidBody = new AWPRigidBody(_sphereShape, sphere, 1);
			body.position = pos;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			//body.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;;
			_physicsWorld.addRigidBody(body);
			_rigidSpheres.push(body);
			body.applyCentralImpulse(impulse);
		}
		
		private function handleEnterFrame(e:Event):void {
			if (_move) {
				_controller.panAngle = 0.3 * (stage.mouseX - _mouseNav[0]) + _mouseNav[2];
				_controller.tiltAngle = 0.3 * (stage.mouseY - _mouseNav[1]) + _mouseNav[3];
			}
			_controller.lookAtPosition = _center;
			_controller.update();
			
			updateBody();
			_physicsWorld.step(_timeStep, 4, _timeStep);
			
			debugDraw.debugDrawWorld();
			_view.render();
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
		
		private function layerTerrainBitmap(B:BitmapData):BitmapData {
			_layers[0].lock;
			_layers[1].lock;
			_layers[2].lock;
			var layerTop:Array = [0x808080, 0x505050];
			var rect:Rectangle = B.rect;
			var p:Point = new Point();
			// red _ top
			_layers[0] = B.clone();
			_layers[0].colorTransform(rect, new ColorTransform(1, 0, 0, 1, 255, 0, 0, 0));
			// green _ mid
			_layers[1].threshold(B, rect, p, ">", 0xFF000000 + layerTop[0], 0x0000000, 0xFFFFFFFF, true);
			_layers[1].colorTransform(rect, new ColorTransform(0, 1, 0, 1, 0, 255, 0, 0));
			_layers[1].applyFilter(_layers[1], rect, p, new BlurFilter(4, 4, 1));
			// blue _ bottom
			_layers[2].threshold(B, rect, p, ">", 0xFF000000 + layerTop[1], 0x0000000, 0xFFFFFFFF, true);
			_layers[2].colorTransform(rect, new ColorTransform(0, 0, 1, 1, 0, 0, 255, 0));
			_layers[2].applyFilter(_layers[2], rect, p, new BlurFilter(4, 4, 1));
			_layers[1].unlock;
			_layers[2].unlock;
			// copy chanel from other layer to base layer
			_layers[0].draw(_layers[1]);
			_layers[0].draw(_layers[2]);
			_layers[0].unlock;
			return _layers[0];
		}
	}
}