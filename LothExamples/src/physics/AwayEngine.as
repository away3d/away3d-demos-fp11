package physics {
	// import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.collision.shapes.AWPCollisionShape;
	// import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	// import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	// import awayphysics.events.AWPEvent;
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
		 * Get physics world information
		 */
		static public function info() : String {
			var inf : String;
			/*_fps += (1000 / _world.performance.totalTime - _fps) * 0.5;
			if (_fps > 1000 || _fps != _fps) _fps = 1000;
			inf = _demoName + "\n";
			inf += "Rigid Body Count: " + _world.numRigidBodies;
			inf += "\n" + "Shape Count: " + _world.numShapes + "\n";
			inf += "Contacts Count: " + _world.numContacts + "\n\n";
			inf += "Broad Phase Time: " + _world.performance.broadPhaseTime;
			inf += "ms\n" + "Narrow Phase Time: " + _world.performance.narrowPhaseTime;
			inf += "ms\n" + "Constraints Time: " + _world.performance.constraintsTime;
			inf += "ms\n" + "Update Time: " + _world.performance.updateTime;
			inf += "ms\n" + "Total Time: " + _world.performance.totalTime;
			inf += "ms\n" + "Physics FPS: " + _fps.toFixed(2) + "\n";*/
			return inf;
		}
		
	}
}
