package {
	import awayphysics.collision.shapes.AWPCapsuleShape;
    import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPEvent;
	
	import flash.display.DisplayObject;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	import flash.events.Event;
	import flash.display.Sprite;
	
	
	/**
	 * AwayPhysics
	 * @author Yang Li _ muzerly
	 * ...
	 * Compact engine by Loth
	 */
	
	public class PhysicsEngine extends Sprite {
		
		// physics engine
		private static var Singleton:PhysicsEngine;
		protected static var physicsWorld:AWPDynamicsWorld;
		protected static const _timeStep:Number = 1.0 / 30;
		protected static const worldScale:Number = 10;
		private static var _rigid:Vector.<AWPRigidBody>
		private static var _static:Vector.<AWPCollisionObject>
		
		// character
		private var character:AWPKinematicCharacterController;
		private var characterMove:Boolean = false;
		private var keyRight:Boolean = false;
		private var keyLeft:Boolean = false;
		private var keyForward:Boolean = false;
		private var keyReverse:Boolean = false;
		private var keyUp:Boolean = false;
		private var walkDirection:Vector3D = new Vector3D();
		private var walkSpeed:Number = 1;
		private var chRotation:Number = 0;
		
		
		public function PhysicsEngine() {
		}
		
		//-------------------------------------------------------------------------------
		//       Singleton
		//-------------------------------------------------------------------------------
		
		public static function getInstance():PhysicsEngine {
			if (Singleton == null) {
				Singleton = new PhysicsEngine();
				PhysicsEngine.init();
			}
			return Singleton;
		}
		
		//-------------------------------------------------------------------------------
		//       Physics World init
		//-------------------------------------------------------------------------------
		
		public static function init(e:Event = null):void {
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();
			physicsWorld.collisionCallbackOn = true;
			physicsWorld.gravity = new Vector3D(0, -9.8, 0);
			physicsWorld.scaling = worldScale;
			_rigid = new Vector.<AWPRigidBody>;
			_static = new Vector.<AWPCollisionObject>;
		}
		
		//-------------------------------------------------------------------------------
		//       Physics Update
		//-------------------------------------------------------------------------------
		
		public function update():void {
			physicsWorld.step(_timeStep);
			if (character) {
				if (keyLeft && character.onGround()) {
					chRotation -= 3;
					character.ghostObject.rotation = new Vector3D(0, chRotation, 0);
				}
				if (keyRight && character.onGround()) {
					chRotation += 3;
					character.ghostObject.rotation = new Vector3D(0, chRotation, 0);
				}
				if (keyForward) {
					if (walkDirection.length == 0) {
						characterMove = true;
					}
					walkDirection = character.ghostObject.front;
					walkDirection.scaleBy(walkSpeed);
					character.setWalkDirection(walkDirection);
				}
				if (keyReverse) {
					if (walkDirection.length == 0) { 
						characterMove = true;
					}
					walkDirection = character.ghostObject.front;
					walkDirection.scaleBy(-walkSpeed);
					character.setWalkDirection(walkDirection);
				}
				if (keyUp && character.onGround()) {
					character.jump();
				}
				
			}
            
            //debug update
            if (_isDebug) _debugDraw.debugDrawWorld();
		}
		
		//-------------------------------------------------------------------------------
		//       Add body to simulation
		//-------------------------------------------------------------------------------
		
		public function addRigid(body:AWPRigidBody):void {
			physicsWorld.addRigidBody(body);
		}
		
		//-------------------------------------------------------------------------------
		//       Primitive object rigidbody
		//-------------------------------------------------------------------------------
		
		public function addObject(m:*, O:Object):void {
			var o:Object = O || new Object();
			var type:String = o.type || "cube";
			var phyType:String = o.phyType || "rigidbody";
			var body:AWPRigidBody;
			var bodyC:AWPCollisionObject;
			var shape:AWPCollisionShape;
			switch (type) {
				case 'sphere': 
					shape = new AWPSphereShape(o.r || 50);
					break;
				case 'cube': 
					shape = new AWPBoxShape(o.w || 100, o.h || 100, o.d || 100);
					break;
				case 'plane': 
					shape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
					break;
				case 'ground': 
					shape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
					o.phyType = 'collision';
					break;
			}
			switch (phyType) {
				case "rigidbody": 
					body = new AWPRigidBody(shape, m, o.mass || 1);
					body.friction = o.friction || 0.5;
					body.restitution = o.restitution || 0.0;
                    // position rotation
					body.position = o.pos || new Vector3D();
					body.rotation = o.rot || new Vector3D();
					if (o.stop) body.activationState = 2; // static at start
					physicsWorld.addRigidBody(body);
					if (body.mass != 0)_rigid.push(body);
                    else _static.push(body);
					break;
				case "collision": 
					bodyC = new AWPCollisionObject(shape, m);
					bodyC.friction = o.friction || 0.5;
					bodyC.restitution = o.restitution || 0.0;
					bodyC.position = o.pos || new Vector3D();
					bodyC.rotation = o.rot || new Vector3D();
					physicsWorld.addCollisionObject(bodyC);
					_static.push(bodyC);
                    break;
			}
		}
		
		//-------------------------------------------------------------------------------
		//       Triangle mesh import
		//-------------------------------------------------------------------------------
		
		public function addTriangleCollision(O:Object = null):void {
			var o:Object = O || new Object();
			var shape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(o.geometry);
			var body:AWPCollisionObject = new AWPCollisionObject(shape, null);
			physicsWorld.addCollisionObject(body, 1, -1);
		}
		
		public function addTriangleRigidbody(O:Object = null):void {
			var o:Object = O || new Object();
			var shape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(o.geometry);
			var body:AWPRigidBody = new AWPRigidBody(shape, o.mesh, 0);
			physicsWorld.addRigidBody(body);
			var matr:Matrix3D = new Matrix3D();
			matr.position = o.position || new Vector3D();
			body.transform = matr;
		}
		
		//-------------------------------------------------------------------------------
		//       Character 
		//-------------------------------------------------------------------------------
		
		public function addCharacter(container:*):void {
			// create character shape and controller
			//var shape:AWPCapsuleShape = new AWPCapsuleShape(20, 40);
            container.y = -10;
            
            var shape:AWPBoxShape =  new AWPBoxShape(60, 164, 40);//new AWPCapsuleShape(20, 40);
			var ghostObject:AWPGhostObject = new AWPGhostObject(shape, container);
			ghostObject.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;
			ghostObject.addEventListener(AWPEvent.COLLISION_ADDED, characterCollisionAdded);
			character = new AWPKinematicCharacterController(ghostObject, 0.1);
            
			physicsWorld.addCharacter(character);
            character.jumpSpeed = 10;
            character.fallSpeed = 100;
           // character.maxJumpHeight = 1000;
			character.warp(new Vector3D(0, 200, 0));
		}
		
		private function characterCollisionAdded(event:AWPEvent):void {
			if (!(event.collisionObject.collisionFlags & AWPCollisionFlags.CF_STATIC_OBJECT)) {
				var body:AWPRigidBody = AWPRigidBody(event.collisionObject);
				var force:Vector3D = event.manifoldPoint.normalWorldOnB.clone();
				force.scaleBy(-30);
				//body.applyForce(force, event.manifoldPoint.localPointB);
			}
		}
        
		public function characterSpeed(n:Number):void {
            walkSpeed = n;
		}
        
		public function key_forward(c:Boolean):void {
			keyForward = c;
			if (!c) {
				walkDirection.scaleBy(0);
				character.setWalkDirection(walkDirection);
			}
		}
		
		public function key_Reverse(c:Boolean):void {
			keyReverse = c
			if (!c) {
				walkDirection.scaleBy(0);
				character.setWalkDirection(walkDirection);
			}
		}
		
		public function key_Left(c:Boolean):void {
			keyLeft = c;
		}
		
		public function key_Right(c:Boolean):void {
			keyRight = c
		}
		
		public function key_Jump(c:Boolean):void {
			keyUp = c
		}
		
		//-------------------------------------------------------------------------------
		//       Debug 
		//-------------------------------------------------------------------------------
		private var _isDebug:Boolean = false;
        private var _debugDraw:AWPDebugDraw;
        
		public function addDebug(view:*):void 
        {
            if (_isDebug) return;
            _debugDraw = new AWPDebugDraw(view, physicsWorld);
            _debugDraw.debugMode = AWPDebugDraw.DBG_DrawCollisionShapes;
            _isDebug = true;
		}
        
		public function removeDebug():void 
        {
            if (_isDebug) _debugDraw.debugMode = AWPDebugDraw.DBG_NoDebug;
        }
        
		
	}
	
}

