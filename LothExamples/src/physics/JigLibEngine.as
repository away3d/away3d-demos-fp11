package physics {
	import jiglib.cof.JConfig;
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.geometry.JTerrain;
	import jiglib.geometry.JTriangleMesh;
	import jiglib.math.JNumber3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3d4.Away3D4Physics;
	import jiglib.plugin.away3d4.Away3D4Mesh;

	import away3d.entities.Mesh;
	import away3d.containers.View3D;

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
	public class JigLibEngine extends Sprite {
		private static var Singleton : JigLibEngine;
		private static var _world : Away3D4Physics;
		private static var _rigids : Vector.<RigidBody>;
		// private static var _static : Vector.<AWPCollisionObject>;
		private static var _view : View3D;

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : JigLibEngine {
			if (Singleton == null) {
				Singleton = new JigLibEngine();
				JigLibEngine.initWorld();
			}
			return Singleton;
		}

		/**
		 * Set the away3d view
		 */
		static public function set scene(View : View3D) : void {
			_view = View;
		}

		/**
		 * Initialise physics world
		 */
		private static function initWorld(e : Event = null) : void {
			_rigids = new Vector.<RigidBody>();

			JConfig.solverType = "FAST";
			JConfig.collToll = 0.5;
			JConfig.deactivationTime = 0.25;
			JConfig.numCollisionIterations = 1;
			JConfig.numContactIterations = 2;
			JConfig.numConstraintIterations = 2;
			JConfig.doShockStep = true;
			_world = new Away3D4Physics(_view, 12);
			_world.engine.setCollisionSystem(true, -500, -500, -500, 20, 20, 20, 100, 100, 100);

			// separate enterframe
			Singleton.addEventListener(Event.ENTER_FRAME, update);
		}

		public static function cleanWorld() : void {
			// clean physics
			_world.engine.removeAllBodies();
			_world.engine.removeAllConstraints();
			_world.engine.removeAllControllers();
			// clean listener
			Singleton.removeEventListener(Event.ENTER_FRAME, update);
		}

		/**
		 * Update physics world
		 */
		private static function update(e : Event = null) : void {
			_world.step(0.2);
		}

		/**
		 *  Primitive object rigidbody
		 */
		public static function addRigid(mesh : Mesh, type : String = "cube", size : Vector3D = null, pos : Vector3D = null, rot : Vector3D = null, setting : Vector3D = null, isStatic : Boolean = false) : void {
			var body : RigidBody;
			if (size == null) size = new Vector3D(100, 100, 100);
			if (setting == null) setting = new Vector3D(10, 0.5, 0);

			switch (type) {
				case 'sphere':
					body = new JSphere(new Away3D4Mesh(mesh), size.x);
					break;
				case 'cube':
					body = new JBox(new Away3D4Mesh(mesh), size.x, size.y, size.z);
					break;
				case 'plane':
					body = new JPlane(new Away3D4Mesh(mesh), new Vector3D(0, 1, 0));
					break;
			}
			body.mass = setting.x;
			body.friction = setting.y;
			body.restitution = setting.z;
			if(isStatic)body.movable = false;
			
			if (pos != null) {
				body.x = pos.x;
				body.y = pos.y;
				body.z = pos.z;
			}
			// if (rot != null) body.rotation = rot;
			_world.addBody(body);
			_rigids.push(body);
		}

		/**
		 * Global world gravity
		 */
		static public function gravity(G : Number) : void {
			_world.engine.setGravity(JNumber3D.getScaleVector(Vector3D.Y_AXIS, G));
		}

		/**
		 *   Triangle mesh import
		 */
		/*	public static function addTriangleCollision(mesh : Mesh) : void {
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
		}*/
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
