package {
	import away3d.containers.View3D;
	import away3d.core.base.SubGeometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.textures.BitmapTexture;
	
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.debug.AWPDebugDraw;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import utils.PerlinShape;
	
	[SWF(backgroundColor="#000000",frameRate="60",width="1024",height="768")]
	
	public class PhysicsField extends Sprite {
		private var _view:View3D;
		private var _light:PointLight;
		private var lightPicker:StaticLightPicker;
		private var _physicsWorld:AWPDynamicsWorld;
		private var _sphereShape:AWPSphereShape;
		private var _timeStep:Number = 1.0 / 60;
		
		private var _field:Mesh;
		private var _fieldSubGeometry:SubGeometry
		private var _bump:BitmapData;
		private var _inversBump:BitmapData;
		private var _inversMatrix:Matrix;
		
		private var _fieldMaterial:TextureMaterial;
		
		private var _size:int = 64; // 128
		private var _dimension:int = 6000;
		private var _fieldHeight:int = 1500;
		
		// perlin noise variable
		private var _ease:Vector3D;
		private var _fractal:Boolean;
		private var _numOctaves:uint;
		private var _offsets:Array;
		private var _complex:Number;
		private var _seed:int;
		private var _position:Vector3D = new Vector3D(0, 0, 0);
		private var _positionY:int = 0;
		
		// height reference for physics
		private var _heights:Vector.<Number>;
		// pixel reference for mesh deformation
		private var _pixels:ByteArray;
		
		// physics shape and body
		private var _terrainShape:PerlinShape;
		private var _terrainBody:AWPRigidBody;
		
		private var debugDraw:AWPDebugDraw;
		
		private var _rigidCubes:Vector.<AWPRigidBody>;
		private var _rigidSpheres:Vector.<AWPRigidBody>;
		
		public function PhysicsField() {
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_view = new View3D();
			this.addChild(_view);
			this.addChild(new AwayStats(_view));
			
			_light = new PointLight();
			_light.y = 2500;
			_light.z = -4000;
			_light.x = 1000;
			_view.scene.addChild(_light);
			
			lightPicker = new StaticLightPicker([_light]);
			
			_view.camera.lens.far = 10000;
			_view.camera.y = _light.y;
			_view.camera.z = _light.z;
			_view.camera.rotationX = 25;
			
			// init the physics world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = false;
			_physicsWorld.scaling = 200;
			_physicsWorld.gravity = new Vector3D(0, -10, 0);
			
			_rigidCubes = new Vector.<AWPRigidBody>();
			_rigidSpheres = new Vector.<AWPRigidBody>();
			
			debugDraw = new AWPDebugDraw(_view, _physicsWorld);
			debugDraw.debugMode |= AWPDebugDraw.DBG_DrawTransform;
			
			// create the field bump bitmap
			_bump = new BitmapData(_size, _size, false, 0x000000);
			// define perlin noise variable
			_fractal = true;
			_offsets = [];
			_numOctaves = 1;
			_complex = 0.12;
			_ease = new Vector3D();
			_seed = int(Math.random() * 0xffffffff);
			for (var u:uint = 0; u < _numOctaves; ++u) {
				_offsets[u] = new Point(0, 0);
			}
			
			// create invers field bitmap for getPixel method
			_inversBump = new BitmapData(_size, _size, false, 0x000000);
			_inversMatrix = new Matrix();
			_inversMatrix.scale(1, -1);
			_inversMatrix.translate(0, _size);
			
			// create the field Mesh
			_fieldMaterial = new TextureMaterial(new BitmapTexture(_bump));
			_fieldMaterial.lightPicker = lightPicker;
			_fieldMaterial.specular = 0.5;
			_fieldMaterial.gloss = 10;
			
			_field = new Mesh(new PlaneGeometry(_dimension, _dimension, _size - 1, _size - 1, true, false), _fieldMaterial);
			_field.mouseEnabled = true;
			_field.addEventListener(MouseEvent3D.MOUSE_UP, onMouseUp);
			_field.geometry.convertToSeparateBuffers();
			// get the field sugGeometry referency
			_fieldSubGeometry = _field.geometry.subGeometries[0] as SubGeometry;
			_fieldSubGeometry.autoDeriveVertexNormals = true;
			_fieldSubGeometry.autoDeriveVertexTangents = true;
			_view.scene.addChild(_field);
			
			updateField();
			initPhysicsField();
			
			// create a wall
			var material:ColorMaterial = new ColorMaterial(0x402525);
			material.lightPicker = lightPicker;
			material.specular = 0.2;
			var mesh:Mesh;
			
			mesh = new Mesh(new CubeGeometry(_dimension, 3000, 100), material);
			_view.scene.addChild(mesh);
			
			var wallShape:AWPBoxShape = new AWPBoxShape(_dimension, 3000, 100);
			var wallRigidbody:AWPRigidBody = new AWPRigidBody(wallShape, mesh, 0);
			_physicsWorld.addRigidBody(wallRigidbody);
			wallRigidbody.position = new Vector3D(0, 1000, (_dimension / 2) + 50);
			
			mesh = new Mesh(new CubeGeometry(100, 3000, _dimension), material);
			_view.scene.addChild(mesh);
			
			var wallShape2:AWPBoxShape = new AWPBoxShape(100, 3000, _dimension);
			var wallRigidbody2:AWPRigidBody = new AWPRigidBody(wallShape2, mesh, 0);
			_physicsWorld.addRigidBody(wallRigidbody2);
			wallRigidbody2.position = new Vector3D((_dimension / 2) + 50, 1000, 0);
			
			mesh = new Mesh(new CubeGeometry(100, 3000, _dimension), material);
			_view.scene.addChild(mesh);
			
			var wallShape3:AWPBoxShape = new AWPBoxShape(100, 3000, _dimension);
			var wallRigidbody3:AWPRigidBody = new AWPRigidBody(wallShape3, mesh, 0);
			_physicsWorld.addRigidBody(wallRigidbody3);
			wallRigidbody3.position = new Vector3D(-(_dimension / 2) - 50, 1000, 0);
			
			material = new ColorMaterial(0xfc6a11);
			material.lightPicker = lightPicker;
			
			// create rigidbody shapes
			_sphereShape = new AWPSphereShape(100);
			var boxShape:AWPBoxShape = new AWPBoxShape(200, 200, 200);
			
			// create rigidbodies
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
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function updateField():void {
			_bump.lock();
			_inversBump.lock();
			
			_bump.perlinNoise(_size * _complex, _size * _complex, _numOctaves, _seed, false, _fractal, 7, true, _offsets);
			_inversBump.draw(_bump, _inversMatrix);
			
			_bump.unlock();
			_inversBump.unlock();
			
			var i:uint, px:uint;
			var v:Vector.<Number> = _fieldSubGeometry.vertexData;
			
			var l:uint = v.length;
			_heights = new Vector.<Number>(_fieldSubGeometry.numVertices, true);
			var vertex:uint = 0;
			
			_pixels = _inversBump.getPixels(_bump.rect) as ByteArray;
			_pixels.position = 0;
			for (i = 1; i < l; i += 3) {
				px = _pixels.readUnsignedInt() & 0xffffff;
				v[i] = (_fieldHeight * px / 0xffffff - _positionY);
				_heights[vertex] = v[i];
				vertex++;
			}
			
			/*
			   // other methode no need inversBump
			   var c:uint;
			   for (i = 1; i < l; i += 3, ++c) {
			   px = _bump.getPixel(c % _size, _size - (c / _size));
			   // Displace y position by the range
			   v[i] = (_fieldHeight * px / 0xffffff - _positionY);
			   _heights[vertex] = v[i];
			   vertex++;
			   }
			 */
			_fieldSubGeometry.updateVertexData(v);
			
			// update texture
			BitmapTexture(TextureMaterial(_fieldMaterial).texture).invalidateContent();
		}
		
		private function getHeightAt(x:Number = 0, z:Number = 0):Number {
			var col:int = _bump.getPixel((x / _dimension + .5) * (_size + 1), (-z / _dimension + .5) * (_size + 1)) & 0xffffff;
			return int(_fieldHeight * col / 0xffffff - _positionY);
		}
		
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
			_terrainShape = new PerlinShape(_size, _size, _dimension, _dimension, _fieldHeight, _heights);
			_terrainBody = new AWPRigidBody(_terrainShape, null, 0);
			_terrainBody.friction = 0.3;
			_terrainBody.restitution = 0.0;
			_physicsWorld.addRigidBody(_terrainBody);
		}
		
		private function updatePhysicsField():void {
			var i:int;
			var bodyLength:int = _physicsWorld.rigidBodies.length;
			for (i = 0; i < bodyLength; ++i) {
				if (_physicsWorld.rigidBodies[i].activationState == AWPCollisionObject.ISLAND_SLEEPING)
					_physicsWorld.rigidBodies[i].activate(true);
			}
			_terrainShape.update(_heights, _fieldHeight);
		}
		
		private function updateBody():void {
			var i:uint, x:int, y:int, z:int;
			var cubeLength:int = _rigidCubes.length;
			var sphereLength:int = _rigidSpheres.length;
			for (i = 0; i < cubeLength; ++i) {
				if (_rigidCubes[i].position.y < 0) {
					x = int(-2000 + Math.random() * 4000);
					z = int(-2000 + Math.random() * 4000);
					y = getHeightAt(x, z) + 200;
					_rigidCubes[i].position = new Vector3D(x, y, z);
				}
			}
			for (i = 0; i < sphereLength; ++i) {
				if (_rigidSpheres[i].position.y < 0) {
					x = int(-2000 + Math.random() * 4000);
					z = int(-2000 + Math.random() * 4000);
					y = getHeightAt(x, z) + 200;
					_rigidSpheres[i].position = new Vector3D(x, y, z);
				}
			}
		}
		
		private function onMouseUp(event:MouseEvent3D):void {
			var pos:Vector3D = _view.camera.position;
			var mpos:Vector3D = new Vector3D(event.localPosition.x, event.localPosition.y, event.localPosition.z);
			
			var impulse:Vector3D = mpos.subtract(pos);
			impulse.normalize();
			impulse.scaleBy(30);
			
			// shoot a sphere
			var material:ColorMaterial = new ColorMaterial(Math.random() * 0xffffff);
			material.lightPicker = lightPicker;
			
			var sphere:Mesh = new Mesh(new SphereGeometry(100), material);
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
			updateBody();
			_physicsWorld.step(_timeStep, 4, _timeStep);
			
			debugDraw.debugDrawWorld();
			_view.render();
		}
	}
}