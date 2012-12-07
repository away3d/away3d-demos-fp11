package physics {
	import away3d.entities.Mesh;
	import away3d.containers.Scene3D;

	import com.element.oimo.physics.collision.shape.ShapeConfig;
	import com.element.oimo.physics.collision.shape.SphereShape;
	import com.element.oimo.physics.collision.shape.BoxShape;
	import com.element.oimo.physics.collision.shape.Shape;
	import com.element.oimo.physics.dynamics.RigidBody;
	import com.element.oimo.physics.dynamics.World;
	// import com.element.oimo.physics.OimoPhysics;
	import com.element.oimo.math.Mat33;
	// import com.element.oimo.math.Quat;
	import com.element.oimo.math.Vec3;

	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;

	/**
	 * OimoPhysics
	 * @author Saharan _ http://el-ement.com
	 * @link https://github.com/saharan/OimoPhysics
	 * ...
	 * Compact engine by Loth
	 */
	public class OimoPhysics extends Sprite {
		private static var Singleton : OimoPhysics;
		private static var _meshs : Vector.<Mesh>;
		private static var _rigids : Vector.<RigidBody>;
		private static var _world : World;
		private static var _scene : Scene3D;
		private static var fps : Number;
		private static var _demoName : String;
		private static var _gravity : Number = 100;

		public function OimoPhysics() {
		}

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : OimoPhysics {
			if (Singleton == null) {
				Singleton = new OimoPhysics();
				OimoPhysics.init();
			}
			return Singleton;
		}

		/**
		 * Initialise physics world
		 */
		private static function init(e : Event = null) : void {
			_world = new World();
			_meshs = new Vector.<Mesh>();
			_rigids = new Vector.<RigidBody>();
		}

		/**
		 * Set the away3d scene
		 */
		static public function set scene(Scene : Scene3D) : void {
			_scene = Scene;
		}

		static public function set demoName(name : String) : void {
			_demoName = name;
		}

		static public function set gravity(g : Number) : void {
			_gravity = g;
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

		static public function get rigid() : Vector.<RigidBody> {
			return _world.rigidBodies;
		}

		/**
		 * Add rigid body to simulation
		 */
		static public function addRigid(body : RigidBody) : void {
			_world.addRigidBody(body);
		}

		/**
		 * Remove all object to simulation
		 */
		static public function clean() : void {
			for (var i : uint; i < _meshs.length; ++i) {
				_scene.removeChild(_meshs[i]);
				for (var j : uint; j < _rigids[i].shapes.length; ++j) {
					_world.removeShape(_rigids[i].shapes[j]);
				}
				_world.removeRigidBody(_rigids[i]);
				_meshs[i].dispose();
			}
			// reset the physics world
			init();
		}

		/**
		 * Add physic cube
		 */
		static public function addCube(mesh : Mesh, w : Number, h : Number, d : Number, pos : Vector3D = null, angle : Number = 0, rot : Vector3D = null, density : Number = 10, restitution : Number = 0, isStatic : Boolean = true) : void {
			var rigid : RigidBody;
			var shape : Shape;
			var config : ShapeConfig = new ShapeConfig();
			if (pos == null) pos = new Vector3D();
			if (rot == null) rot = new Vector3D();
			config.position.init(pos.x, pos.y, pos.z);
			// config.rotation.init(rot.x, rot.y, rot.z);
			config.restitution = restitution;
			config.density = density;
			// config.friction = 0.3;
			shape = new BoxShape(w, h, d, config);
			rigid = new RigidBody(angle, rot.x, rot.y, rot.z);
			rigid.linearVelocity.y = -_gravity;
			// rigid.mass = 100;
			rigid.addShape(shape);
			if (isStatic) rigid.setupMass(RigidBody.BODY_STATIC);
			else rigid.setupMass(RigidBody.BODY_DYNAMIC);

			_world.addRigidBody(rigid);
			_scene.addChild(mesh);
			_rigids.push(rigid);
			_meshs.push(mesh);
		}

		/**
		 * Add physic sphere
		 */
		static public function addSphere(mesh : Mesh, r : Number, pos : Vector3D = null, angle : Number = 0, rot : Vector3D = null, density : Number = 10, restitution : Number = 0, isStatic : Boolean = true) : void {
			var rigid : RigidBody;
			var shape : Shape;
			var config : ShapeConfig = new ShapeConfig();
			if (pos == null) pos = new Vector3D();
			if (rot == null) rot = new Vector3D();
			config.position.init(pos.x, pos.y, pos.z);
			// config.rotation.init(rot.x, rot.y, rot.z);
			config.restitution = restitution;
			config.density = density;
			// config.friction = 20;
			shape = new SphereShape(r, config);
			rigid = new RigidBody(angle, rot.x, rot.y, rot.z);
			rigid.linearVelocity.y = -_gravity;
			// rigid.mass = 100;
			rigid.addShape(shape);
			if (isStatic) rigid.setupMass(RigidBody.BODY_STATIC);
			else rigid.setupMass(RigidBody.BODY_DYNAMIC);

			_world.addRigidBody(rigid);
			_scene.addChild(mesh);
			_rigids.push(rigid);
			_meshs.push(mesh);
		}

		/**
		 * Get rigid matrix3d
		 */
		static public function rigidPos(n : uint = 0) : Matrix3D {
			var r : Mat33 = _world.rigidBodies[n].rotation;
			var p : Vec3 = _world.rigidBodies[n].position;
			return new Matrix3D(Vector.<Number>([r.e00, r.e10, -r.e20, 0, r.e01, r.e11, -r.e21, 0, r.e02, r.e12, -r.e22, 0, p.x, p.y, p.z, 1]));
		}

		/**
		 * Get physics world information
		 */
		static public function info() : String {
			var inf : String;
			fps += (1000 / _world.performance.totalTime - fps) * 0.5;
			if (fps > 1000 || fps != fps) fps = 1000;
			inf = _demoName + "\n";
			inf += "Rigid Body Count: " + _world.numRigidBodies;
			inf += "\n" + "Shape Count: " + _world.numShapes + "\n";
			inf += "Contacts Count: " + _world.numContacts + "\n\n";
			inf += "Broad Phase Time: " + _world.performance.broadPhaseTime;
			inf += "ms\n" + "Narrow Phase Time: " + _world.performance.narrowPhaseTime;
			inf += "ms\n" + "Constraints Time: " + _world.performance.constraintsTime;
			inf += "ms\n" + "Update Time: " + _world.performance.updateTime;
			inf += "ms\n" + "Total Time: " + _world.performance.totalTime;
			inf += "ms\n" + "Physics FPS: " + fps.toFixed(2) + "\n";
			return inf;
		}
	}
}

