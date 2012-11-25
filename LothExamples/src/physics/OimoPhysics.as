package physics {
	import com.element.oimo.physics.collision.shape.ShapeConfig;
	import com.element.oimo.physics.collision.shape.SphereShape;
	import com.element.oimo.physics.collision.shape.BoxShape;
	import com.element.oimo.physics.collision.shape.Shape;
	import com.element.oimo.physics.dynamics.RigidBody;
	import com.element.oimo.physics.dynamics.World;
	/*import com.element.oimo.physics.OimoPhysics;
	import com.element.oimo.math.Mat33;
	import com.element.oimo.math.Quat;
	import com.element.oimo.math.Vec3;*/
	import flash.display.Sprite;
	// import flash.geom.Vector3D;
	// import flash.geom.Matrix3D;
	import flash.events.Event;

	/**
	 * OimoPhysics
	 * @author Saharan _ http://el-ement.com
	 * @link https://github.com/saharan/OimoPhysics
	 * ...
	 * Compact engine by Loth
	 */
	public class OimoPhysics extends Sprite {
		// physics engine
		private static var Singleton : OimoPhysics;
		private static var _world : World;
		// collection
		private static var _rigid : Vector.<RigidBody>;
		private static var fps : Number;

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
			_rigid = new Vector.<RigidBody>;
		}

		/**
		 * Update physics world
		 */
		static public function update() : void {
			_world.step();
		}

		static public function get rigid() : Vector.<RigidBody> {
			return _rigid;
		}

		/**
		 * Add rigid body to simulation
		 */
		static public function addRigid(body : RigidBody) : void {
			_world.addRigidBody(body);
		}

		/**
		 * Add physic cube
		 */
		static public function addCube(w : uint, h : uint, d : uint, x : uint = 0, y : uint = 0, z : uint = 0) : void {
			var rigid : RigidBody;
			var shape : Shape;
			var config : ShapeConfig = new ShapeConfig();
			config.position.init(x, y, z);
			config.rotation.init();
			shape = new BoxShape(w, h, d, config);
			rigid = new RigidBody();
			rigid.addShape(shape);
			rigid.setupMass(RigidBody.BODY_STATIC);
			config.restitution = 0;

			_world.addRigidBody(rigid);
			_rigid.push(rigid);
		}

		/**
		 * Add physic sphere
		 */
		static public function addSphere(r : uint, x : uint = 0, y : uint = 0, z : uint = 0) : void {
			var rigid : RigidBody;
			var shape : Shape;
			var config : ShapeConfig = new ShapeConfig();
			config.position.init(x, y, z);
			config.rotation.init();
			shape = new SphereShape(r, config);
			rigid = new RigidBody();
			rigid.addShape(shape);
			rigid.setupMass(RigidBody.BODY_STATIC);
			config.restitution = 0;

			_world.addRigidBody(rigid);
			_rigid.push(rigid);
		}

		/**
		 * Add
		 */
		static public function addObject(y : int = 500) : void {
			var rigid : RigidBody;
			var shape : Shape;
			var config : ShapeConfig = new ShapeConfig();
			config.position.init(0, y, 0);
			config.restitution = 0;

			shape = new BoxShape(100, 100, 100, config);

			rigid = new RigidBody();
			rigid.addShape(shape);
			// can be multiple

			rigid.setupMass(RigidBody.BODY_STATIC);

			/*rigid.angularVelocity.x = 0;
			rigid.angularVelocity.y = 0;
			rigid.angularVelocity.z = 0;*/
			_world.addRigidBody(rigid);
			_rigid.push(rigid);

			/*var o:Object = O || new Object();
			var type:String = o.type || "cube";
			
			var rigid:RigidBody;
			var shape:Shape;
			var config:ShapeConfig = new ShapeConfig();
			
			
			config.position.init(o.pos.x || 0, o.pos.y || 0, o.pos.z || 0);
			config.rotation.init();
			
			switch (type)
			{
			case 'sphere': 
			shape = new SphereShape(o.r || 50, config);
			break;
			case 'cube': 
			shape = new BoxShape(o.w || 100, o.h || 100, o.d || 100, config);
			break;
			}
			
			rigid.angularVelocity.x = Math.random() * 2 - 1;
			rigid.angularVelocity.y = Math.random() * 2 - 1;
			rigid.angularVelocity.z = Math.random() * 2 - 1;
			
			rigid.addShape(shape); // can be multiple
			rigid.setupMass(RigidBody.BODY_STATIC);
			if(_world)*/
		}

		/**
		 * Get physics world information
		 */
		static public function info() : String {
			var inf : String;
			fps += (1000 / _world.performance.totalTime - fps) * 0.5;
			if (fps > 1000 || fps != fps)
				fps = 1000;

			inf = "Rigid Body Count: " + _world.numRigidBodies;
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

