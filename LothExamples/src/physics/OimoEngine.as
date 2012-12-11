package physics {
	import away3d.entities.Mesh;
	import away3d.containers.Scene3D;

	import com.element.oimo.physics.constraint.joint.DistanceJoint;
	import com.element.oimo.physics.constraint.joint.JointConfig;
	import com.element.oimo.physics.constraint.joint.BallJoint;
	import com.element.oimo.physics.constraint.joint.Joint;
	import com.element.oimo.physics.collision.shape.ShapeConfig;
	import com.element.oimo.physics.collision.shape.SphereShape;
	import com.element.oimo.physics.collision.shape.BoxShape;
	import com.element.oimo.physics.collision.shape.Shape;
	import com.element.oimo.physics.dynamics.RigidBody;
	import com.element.oimo.physics.dynamics.World;
	import com.element.oimo.math.Mat33;
	import com.element.oimo.math.Vec3;

	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;

	/**
	 * OimoPhysics alpha release 7 
	 * @author Saharan _ http://el-ement.com
	 * @link https://github.com/saharan/OimoPhysics
	 * ...
	 * Compact engine for away3d by Loth
	 * 
	 * OimoPhysics use international system units 
	 * 0.1 to 10 meters max for dynamique body
	 * in away3d mutliply by scale 100
	 */
	final public class OimoEngine extends Sprite {
		private static const SCALE : uint = 100;
		private static const USCALE : Number = 0.01;
		private static var Singleton : OimoEngine;
		private static var _world : World;
		private static var _rigids : Vector.<RigidBody>;
		private static var _joints : Vector.<Joint>;
		private static var _scene : Scene3D;
		private static var _meshs : Vector.<Mesh>;
		private static var _demoName : String;
		private static var _fps : Number;

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : OimoEngine {
			if (Singleton == null) {
				Singleton = new OimoEngine();
				OimoEngine.init();
			}
			return Singleton;
		}

		/**
		 * Initialise physics world
		 */
		private static function init(e : Event = null) : void {
			_meshs = new Vector.<Mesh>();
			_rigids = new Vector.<RigidBody>();
			_joints = new Vector.<Joint>();
			_world = new World();
		}

		/**
		 * Set the away3d scene
		 */
		static public function set scene(Scene : Scene3D) : void {
			_scene = Scene;
		}

		static public function gravity(g : Number) : void {
			_world.gravity = new Vec3(0, g, 0);
		}

		/**
		 * Update physics world
		 */
		static public function update() : void {
			for (var i : uint = 0; i < _meshs.length; i++) {
				_meshs[i].transform = rigidPos(i);
			}
			_world.step();
		}

		/**
		 * Get the current rigid body list
		 */
		static public function get rigids() : Vector.<RigidBody> {
			return _rigids;
		}

		/**
		 * Get rigid matrix3d
		 */
		static public function rigidPos(n : uint = 0) : Matrix3D {
			var r : Mat33 = _world.rigidBodies[n].rotation;
			var p : Vec3 = _world.rigidBodies[n].position;
			return new Matrix3D(Vector.<Number>([r.e00, r.e10, -r.e20, 0, r.e01, r.e11, -r.e21, 0, r.e02, r.e12, -r.e22, 0, p.x * SCALE, p.y * SCALE, p.z * SCALE, 1]));
		}

		/**
		 * Remove all object to simulation
		 */
		static public function clean() : void {
			var i : uint;
			var j : uint;
			// remove joints
			for (j = 0; j < _joints.length; ++j) {
				_world.removeJoint(_joints[j]);
			}
			// remove mesh and rigid
			for ( i = 0 ; i < _meshs.length; ++i) {
				for ( j = 0 ; j < _rigids[i].shapes.length; ++j) {
					_world.removeShape(_rigids[i].shapes[j]);
				}
				_world.removeRigidBody(_rigids[i]);
				_scene.removeChild(_meshs[i]);
				_meshs[i].dispose();
			}
			// reset the physics world
			init();
		}

		/**
		 * Add physic cube shape
		 */
		static public function addCube(mesh : Mesh, w : Number, h : Number, d : Number, pos : Vector3D = null, angle : Number = 0, rot : Vector3D = null, Density : Number = 1, Friction : Number = 0.5, Restitution : Number = 0.5, isStatic : Boolean = true) : void {
			var shape : Shape;
			var config : ShapeConfig = new ShapeConfig();
			if (pos == null) pos = new Vector3D();
			if (rot == null) rot = new Vector3D();
			config.position.init(pos.x * USCALE, pos.y * USCALE, pos.z * USCALE);
			config.rotation.init();
			config.density = Density;
			config.friction = Friction;
			config.restitution = Restitution;
			shape = new BoxShape(w * USCALE, h * USCALE, d * USCALE, config);

			addRigid(mesh, shape, angle, rot, isStatic);
		}

		/**
		 * Add physic sphere shape
		 */
		static public function addSphere(mesh : Mesh, r : Number, pos : Vector3D = null, angle : Number = 0, rot : Vector3D = null, Density : Number = 1, Friction : Number = 0.5, Restitution : Number = 0.5, isStatic : Boolean = true) : void {
			var shape : Shape;
			var config : ShapeConfig = new ShapeConfig();
			if (pos == null) pos = new Vector3D();
			if (rot == null) rot = new Vector3D();
			config.position.init(pos.x * USCALE, pos.y * USCALE, pos.z * USCALE);
			config.rotation.init();
			config.density = Density;
			config.friction = Friction;
			config.restitution = Restitution;
			shape = new SphereShape(r * USCALE, config);

			addRigid(mesh, shape, angle, rot, isStatic);
		}

		/**
		 * Add rigid body to simulation
		 */
		static public function addRigid(mesh : Mesh, shape : Shape, angle : Number = 0, rot : Vector3D = null, isStatic : Boolean = true) : void {
			var rigid : RigidBody;
			rigid = new RigidBody(angle, rot.x, rot.y, rot.z);
			rigid.addShape(shape);
			if (isStatic) rigid.setupMass(RigidBody.BODY_STATIC);
			else rigid.setupMass(RigidBody.BODY_DYNAMIC);

			// add to listing
			_rigids.push(rigid);
			_meshs.push(mesh);
			// showtime
			_world.addRigidBody(rigid);
			_scene.addChild(mesh);
		}

		/**
		 * Add ball joint
		 */
		static public function addBallJoint(rigid1 : RigidBody, rigid2 : RigidBody, collision : Boolean = true) : void {
			var config : JointConfig = new JointConfig();
			/*config.localRelativeAnchorPosition1 = rigid1.position;
			config.localRelativeAnchorPosition2 = rigid2.position;*/
			config.allowCollide = collision;
			var j : BallJoint = new BallJoint(rigid1, rigid2, config);

			_joints.push(j);
			_world.addJoint(j);
		}

		/**
		 * Add distance joint
		 */
		static public function addDistanceJoint(rigid1 : RigidBody, rigid2 : RigidBody, distance : Number, collision : Boolean = true) : void {
			var config : JointConfig = new JointConfig();
			/*config.localRelativeAnchorPosition1 = rigid1.position;
			config.localRelativeAnchorPosition2 = rigid2.position;*/
			config.allowCollide = collision;
			var j : DistanceJoint = new DistanceJoint(rigid1, rigid2, distance * USCALE, config);

			_joints.push(j);
			_world.addJoint(j);
		}

		/**
		 * Set current demo name
		 */
		static public function set demoName(name : String) : void {
			_demoName = name;
		}

		/**
		 * Get physics world information
		 */
		static public function info() : String {
			var inf : String;
			_fps += (1000 / _world.performance.totalTime - _fps) * 0.5;
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
			inf += "ms\n" + "Physics FPS: " + _fps.toFixed(2) + "\n";
			return inf;
		}
	}
}

