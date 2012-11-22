package physics{
	import com.element.oimo.physics.collision.shape.ShapeConfig;
	import com.element.oimo.physics.collision.shape.SphereShape;
	import com.element.oimo.physics.collision.shape.BoxShape;
	import com.element.oimo.physics.collision.shape.Shape;
	import com.element.oimo.physics.dynamics.RigidBody;
	import com.element.oimo.physics.dynamics.World;
	import com.element.oimo.physics.OimoPhysics;
	import com.element.oimo.math.Mat33;
	import com.element.oimo.math.Quat;
	import com.element.oimo.math.Vec3;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	import flash.events.Event;
	
	/**
	 * OimoPhysics
	 * @author Saharan _ http://el-ement.com
	 * @link https://github.com/saharan/OimoPhysics
	 * ...
	 * Compact engine by Loth
	 */
	
	public class OimoPhysics extends Sprite
	{
		//private static const _timeStep:Number = 1.0 / 30;
		//private static const worldScale:Number = 10;
		
		// physics engine
		private static var Singleton:OimoPhysics;
		private static var _world:World;
		
		// collection
		private static var _rigid:Vector.<RigidBody>;
		private var fps:Number;
		
		public function OimoPhysics()
		{
		}
		
		//-------------------------------------------------------------------------------
		//       Singleton enforcer
		//-------------------------------------------------------------------------------
		
		public static function getInstance():OimoPhysics
		{
			if (Singleton == null)
			{
				Singleton = new OimoPhysics();
				OimoPhysics.init();
			}
			return Singleton;
		}
		
		//-------------------------------------------------------------------------------
		//       Physics World init
		//-------------------------------------------------------------------------------
		
		private function init(e:Event = null):void
		{
			_world = new World();
			_rigid = new Vector.<RigidBody>;
		}
		
		//-------------------------------------------------------------------------------
		//       Physics Update
		//-------------------------------------------------------------------------------
		
		static public function update():void
		{
			_world.step();
		}
		
		//-------------------------------------------------------------------------------
		//       Add body to simulation
		//-------------------------------------------------------------------------------
		
		static public function addRigid(body:RigidBody):void
		{
			_world.addRigidBody(body);
		}
		
		//-------------------------------------------------------------------------------
		//       Primitive object rigidbody
		//-------------------------------------------------------------------------------
		
		static public function addObject(m:*, O:Object):void
		{
			var o:Object = O || new Object();
			var type:String = o.type || "cube";
			
			var rigid:RigidBody;
			var shape:Shape;
			var config:ShapeConfig = new ShapeConfig();
			
			rigid = new RigidBody();
			config.restitution = 0;
			config.position.init(o.pos.x || 0, o.pos.y || 0, o.pos.z || 0);
			config.rotation.init();
			
			switch (type)
			{
				case 'sphere': 
					shape = new SphereShape(o.r || 50, config);
					break;
				case 'cube': 
					shape = new BoxShape(o.w || 100, o.h || 100, o.d || 100, c);
					break;
			}
			/*
			   rigid.angularVelocity.x = Math.random() * 2 - 1;
			   rigid.angularVelocity.y = Math.random() * 2 - 1;
			   rigid.angularVelocity.z = Math.random() * 2 - 1;
			 */
			rigid.addShape(shape); // can be multiple
			rigid.setupMass(RigidBody.BODY_STATIC);
			world.addRigidBody(rigid);
		}
		
		//-------------------------------------------------------------------------------
		//       Engine Information
		//-------------------------------------------------------------------------------
		
		static public function info():String
		{
			var inf:String;
			fps += (1000 / world.performance.totalTime - fps) * 0.5;
			if (fps > 1000 || fps != fps)
				fps = 1000;
			
			inf = "Rigid Body Count: " + world.numRigidBodies;
			inf += "\n" + "Shape Count: " + world.numShapes + "\n";
			inf += "Contacts Count: " + world.numContacts + "\n\n";
			inf += "Broad Phase Time: " + world.performance.broadPhaseTime;
			inf += "ms\n" + "Narrow Phase Time: " + world.performance.narrowPhaseTime;
			inf += "ms\n" + "Constraints Time: " + world.performance.constraintsTime;
			inf += "ms\n" + "Update Time: " + world.performance.updateTime;
			inf += "ms\n" + "Total Time: " + world.performance.totalTime;
			inf += "ms\n" + "Physics FPS: " + fps.toFixed(2) + "\n";
			return inf;
		}
	
	}

}

