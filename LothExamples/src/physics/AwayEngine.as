package physics {
	import away3d.primitives.CubeGeometry;
	// import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	// import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.dynamics.AWPDynamicsWorld;
	// import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	// import awayphysics.events.AWPEvent;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.vehicle.AWPWheelInfo;
	import awayphysics.dynamics.vehicle.AWPVehicleTuning;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle;
	import awayphysics.collision.shapes.AWPSphereShape;
	// import awayphysics.collision.shapes.AWPCapsuleShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.collision.shapes.AWPCompoundShape;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.collision.shapes.AWPConvexHullShape;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;

	import away3d.entities.Mesh;

	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	import flash.events.Event;

	/**
	 * OimoPhysics alpha release 8 
	 * @author Saharan _ http://el-ement.com
	 * @link https://github.com/saharan/OimoPhysics
	 * ...
	 * Compact engine for away3d by Loth
	 * 
	 * OimoPhysics use international system units 
	 * 0.1 to 10 meters max for dynamique body
	 * in away3d mutliply by scale 100
	 */
	public class AwayEngine extends Sprite {
		private static const SCALE : uint = 100;
		private static const TimeStep : Number = 1.0 / 60;
		private static var Singleton : AwayEngine;
		private static var _world : AWPDynamicsWorld;
		private static var _rigids : Vector.<AWPRigidBody>;
		private static var _static : Vector.<AWPCollisionObject>;

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : AwayEngine {
			if (Singleton == null) {
				Singleton = new AwayEngine();
				AwayEngine.initWorld();
			}
			return Singleton;
		}

		/**
		 * Initialise physics world
		 */
		private static function initWorld(e : Event = null) : void {
			_rigids = new Vector.<AWPRigidBody>();
			_static = new Vector.<AWPCollisionObject>;
			_world = AWPDynamicsWorld.getInstance();
			_world.initWithDbvtBroadphase();
			_world.collisionCallbackOn = false;
			_world.gravity = new Vector3D(0, -10, 0);
			_world.scaling = SCALE;

			// separate enterframe
			Singleton.addEventListener(Event.ENTER_FRAME, update);
		}

		/**
		 * Update physics world
		 */
		private static function update(e : Event = null) : void {
			_world.step(TimeStep, 4);
		}

		/**
		 *  Primitive object rigidbody
		 */
		public static function addRigid(mesh : Mesh, type : String = "cube", size : Vector3D = null, pos : Vector3D = null, rot : Vector3D = null, setting : Vector3D = null, isActif : Boolean = true) : void {
			var body : AWPRigidBody;
			var shape : AWPCollisionShape;
			if (size == null) size = new Vector3D(100, 100, 100);
			if (setting == null) setting = new Vector3D(10, 0.5, 0);

			switch (type) {
				case 'sphere':
					shape = new AWPSphereShape(size.x);
					break;
				case 'cube':
					shape = new AWPBoxShape(size.x, size.y, size.z);
					break;
				case 'cylinder':
					shape = new AWPCylinderShape(size.x, size.y);
				case 'plane':
					shape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
					break;
			}
			body = new AWPRigidBody(shape, mesh, setting.x);
			body.friction = setting.y;
			body.restitution = setting.z;
			if (pos != null) body.position = pos;
			if (rot != null) body.rotation = rot;
			if (!isActif) body.activationState = 2;
			_world.addRigidBody(body);
			_rigids.push(body);
		}

		public static function addCollision(mesh : Mesh, type : String = "cube", size : Vector3D = null, pos : Vector3D = null, rot : Vector3D = null, setting : Vector3D = null) : void {
			var body : AWPCollisionObject;
			var shape : AWPCollisionShape;
			if (size == null) size = new Vector3D(100, 100, 100);
			if (setting == null) setting = new Vector3D(0, 0.5, 0);
			switch (type) {
				case 'sphere':
					shape = new AWPSphereShape(size.x);
					break;
				case 'cube':
					shape = new AWPBoxShape(size.x, size.y, size.z);
					break;
				case 'plane':
					shape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
					break;
			}
			body = new AWPCollisionObject(shape, mesh);
			body.friction = setting.y;
			body.restitution = setting.z;
			if (pos != null) body.position = pos;
			if (rot != null) body.rotation = rot;
			_world.addCollisionObject(body);
			_static.push(body);
		}

		/**
		 *   Triangle mesh import
		 */
		public static function addTriangleCollision(mesh : Mesh) : void {
			var shape : AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(mesh.geometry);
			var body : AWPCollisionObject = new AWPCollisionObject(shape, null);
			_world.addCollisionObject(body, 1, -1);
		}

		public static function addTriangleRigidbody(mesh : Mesh, position : Vector3D = null) : void {
			var shape : AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(mesh.geometry);
			var body : AWPRigidBody = new AWPRigidBody(shape, mesh, 0);
			_world.addRigidBody(body);
			var matr : Matrix3D = new Matrix3D();
			if (position) {
				matr.position = position;
				body.transform = matr;
			}
		}

		/**
		 * Convex shape
		 */
		private static function createConvexShape(mesh : Mesh) : AWPCompoundShape {
			var shapeConvex : AWPConvexHullShape = new AWPConvexHullShape(mesh.geometry);
			var shape : AWPCompoundShape = new AWPCompoundShape();
			shape.addChildShape(shapeConvex);
			return shape;
		}

		public static function addCarSimulator() : void {
			// create the chassis body
			var content : Mesh = new Mesh(new CubeGeometry(20, 20, 20), null);
			var carShape : AWPCompoundShape = createConvexShape(Mesh(content.clone()));
			// var carShape : AWPBoxShape = new AWPBoxShape(20, 20, 20);
			var wheels : Vector.<Mesh> = new Vector.<Mesh>(4);
			// createCarWheels();
			var carBody : AWPRigidBody = new AWPRigidBody(carShape, content, 1000);
			carBody.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			carBody.friction = 0.5;
			carBody.restitution = 0.0;
			carBody.linearDamping = 0.3;
			carBody.angularDamping = 0.3;
			var scale : Number = 2.54;
			// add to world physics
			_world.addRigidBody(carBody);

			// create veicule setting
			var turning : AWPVehicleTuning = new AWPVehicleTuning();
			with (turning) {
				frictionSlip = 1.1;
				// friction between the tyre and the ground. 0.8 for realistic cars, can increased for better handling
				suspensionStiffness = 60;
				// 10.0 = Offroad buggy, 50 = Sports car, 200 = F1 Car
				suspensionDamping = 0.2;
				// 0.1 to 0.3 are good values
				suspensionCompression = 0.8;
				maxSuspensionTravelCm = 3 * scale;
				// The maximum distance the suspension can be compressed (centimetres)
				maxSuspensionForce = 100000;
			}

			// car vehicle
			var car : AWPRaycastVehicle = new AWPRaycastVehicle(turning, carBody);
			_world.addVehicle(car);

			// wheels setting
			var radius : int = 17 * scale;
			var suspResist : int = 5 * scale;
			var posX : int = 39 * scale;
			var posY : int = 17 * scale;
			var posZ : int = 60 * scale;

			var wDirection : Vector3D = new Vector3D(0, -1, 0);
			var wAxeCS : Vector3D = new Vector3D(-1, 0, 0);
			car.addWheel(wheels[0], new Vector3D(posX, posY, posZ), wDirection, wAxeCS, suspResist, radius, turning, true);
			car.addWheel(wheels[1], new Vector3D(-posX, posY, posZ), wDirection, wAxeCS, suspResist, radius, turning, true);
			car.addWheel(wheels[2], new Vector3D(posX, posY, -posZ), wDirection, wAxeCS, suspResist, radius, turning, false);
			car.addWheel(wheels[3], new Vector3D(-posX, posY, -posZ), wDirection, wAxeCS, suspResist, radius, turning, false);

			// wheels settings
			for (var i : int = 0; i < car.getNumWheels(); i++) {
				var wheel : AWPWheelInfo = car.getWheelInfo(i);
				wheel.wheelsDampingRelaxation = 4.5;
				// 4.5;
				wheel.wheelsDampingCompression = 4.5;
				// 4.5;
				wheel.suspensionRestLength1 = 5 * scale;
				// 9 * _scale;
				wheel.rollInfluence = 0.2;
				// 0.01;
			}
		}

		/**
		 * Get physics world information
		 */
		static public function info() : String {
			var inf : String;
			return inf;
		}
	}
}
