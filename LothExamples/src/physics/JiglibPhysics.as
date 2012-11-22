package physics{
	import awayphysics.dynamics.vehicle.AWPWheelInfo;
	import awayphysics.dynamics.vehicle.AWPVehicleTuning;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle;
	
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.collision.shapes.AWPConvexHullShape;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.collision.dispatch.AWPGhostObject; 
	import awayphysics.collision.shapes.AWPCompoundShape;
	import awayphysics.collision.shapes.AWPCapsuleShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.events.AWPEvent;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	import flash.events.Event;
	
	/**
	 * AwayPhysics
	 * @author Yang Li _ muzerly
	 * ...
	 * Compact engine by Loth
	 */
	
	public class AwayPhysics extends Sprite {
		protected static const _timeStep:Number = 1.0 / 30;
		protected static const worldScale:Number = 10;
		
		// physics engine
		private static var Singleton:AwayPhysics;
		protected static var physicsWorld:AWPDynamicsWorld;
		
		// collection
		private static var _rigid:Vector.<AWPRigidBody>
		private static var _static:Vector.<AWPCollisionObject>;
		
		// ground
		private var _terrainBody:AWPCollisionObject;
		private var _planeBody:AWPCollisionObject;
		
		// character
		private var character:AWPKinematicCharacterController;
		private var walkDirection:Vector3D = new Vector3D();
		private var characterMove:Boolean = false;
		private var keyForward:Boolean = false;
		private var keyReverse:Boolean = false;
		private var keyRight:Boolean = false;
		private var keyLeft:Boolean = false;
		private var keyUp:Boolean = false;
		private var walkSpeed:Number = 1;
		private var chRotation:Number = 0;
		
		// debug
		private var _isDebug:Boolean = false;
		private var _debugDraw:AWPDebugDraw;
		
		public function AwayPhysics() { }
		
		
		//-------------------------------------------------------------------------------
		//       Singleton
		//-------------------------------------------------------------------------------
		
		public static function getInstance():AwayPhysics 
		{
			if (Singleton == null) {
				Singleton = new AwayPhysics();
				AwayPhysics.init();
			}
			return Singleton;
		}
		
		
		//-------------------------------------------------------------------------------
		//       Physics World init
		//-------------------------------------------------------------------------------
		
		public static function init(e:Event = null):void
		{
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
		
		public function update():void 
		{
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
		
		public function addRigid(body:AWPRigidBody):void 
		{
			physicsWorld.addRigidBody(body);
		}
		
		
		//-------------------------------------------------------------------------------
		//       Primitive object rigidbody
		//-------------------------------------------------------------------------------
		
		public function addObject(m:*, O:Object):void 
		{
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
		
		public function addSimplePlane():void 
		{
			var shape:AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));;
			_planeBody = new AWPCollisionObject(shape, null);
			physicsWorld.addCollisionObject(_planeBody, 1, -1);
		}
		
		public function addTerrain(O:Object = null):void
		{
			var o:Object = O || new Object();
			var shape:AWPBvhTriangleMeshShape 
			if (!_terrainBody) {
				shape = new AWPBvhTriangleMeshShape(o.geometry);
				_terrainBody = new AWPCollisionObject(shape, null);
			}
			physicsWorld.addCollisionObject(_terrainBody, 1, -1);
		}
		
		public function addTriangleCollision(O:Object = null):void 
		{
			var o:Object = O || new Object();
			var shape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(o.geometry);
			var body:AWPCollisionObject = new AWPCollisionObject(shape, null);
			physicsWorld.addCollisionObject(body, 1, -1);
		}
		
		/*public function addTriangleRigidbody(O:Object = null):void {
		var o:Object = O || new Object();
		var shape:AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(o.geometry);
		var body:AWPRigidBody = new AWPRigidBody(shape, o.mesh, 0);
		physicsWorld.addRigidBody(body);
		var matr:Matrix3D = new Matrix3D();
		matr.position = o.position || new Vector3D();
		body.transform = matr;
		}*/
		
		
		//-------------------------------------------------------------------------------
		//
		//       Character 
		//
		//-------------------------------------------------------------------------------
		
		public function addCharacter(container:*, position:Vector3D = null):void 
		{
			// create character shape and controller
			//var shape:AWPBoxShape =  new AWPBoxShape(60, 164, 40);
			var shape:AWPCapsuleShape = new AWPCapsuleShape(41, 81);
			var ghostObject:AWPGhostObject = new AWPGhostObject(shape, container);
			ghostObject.friction = 0.3;
			ghostObject.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;
			ghostObject.addEventListener(AWPEvent.COLLISION_ADDED, characterCollisionAdded);
			character = new AWPKinematicCharacterController(ghostObject, 0.5);
			
			physicsWorld.addCharacter(character);
			
			character.jumpSpeed = 10;
			character.fallSpeed = 10;
			character.maxJumpHeight = 10000;
			character.warp(position || new Vector3D(0, 200, 0));
		}
		
		private function characterCollisionAdded(event:AWPEvent):void 
		{
			if (!(event.collisionObject.collisionFlags & AWPCollisionFlags.CF_STATIC_OBJECT)) {
				var body:AWPRigidBody = AWPRigidBody(event.collisionObject);
				var force:Vector3D = event.manifoldPoint.normalWorldOnB.clone();
				force.scaleBy(-10);
				body.applyForce(force, event.manifoldPoint.localPointB);
			}
		}
		
		public function characterSpeed(n:Number):void 
		{
			walkSpeed = n;
		}
		
		public function key_forward(c:Boolean):void 
		{
			keyForward = c;
			if (!c) {
				walkDirection.scaleBy(0);
				character.setWalkDirection(walkDirection);
			}
		}
		
		public function key_Reverse(c:Boolean):void 
		{
			keyReverse = c
			if (!c) {
				walkDirection.scaleBy(0);
				character.setWalkDirection(walkDirection);
			}
		}
		
		public function key_Left(c:Boolean):void
		{
			keyLeft = c;
		}
		
		public function key_Right(c:Boolean):void 
		{
			keyRight = c
		}
		
		public function key_Jump(c:Boolean):void 
		{
			keyUp = c
		}
		
		
		//-------------------------------------------------------------------------------
		//       Debug 
		//-------------------------------------------------------------------------------
		
		public function addDebug(view:*):void 
		{
			if (_isDebug) { removeDebug(); }
			if (_terrainBody) removeTerrain();
			_debugDraw = new AWPDebugDraw(view, physicsWorld);
			
			_debugDraw.debugMode = AWPDebugDraw.DBG_DrawCollisionShapes;
			_isDebug = true;
		}
		
		public function removeDebug():void 
		{
			_debugDraw.debugMode = AWPDebugDraw.DBG_NoDebug;
			_debugDraw.debugDrawWorld();
			removePlane();
			_isDebug = false;
		}
		
		private function removeTerrain():void 
		{
			if(_terrainBody) physicsWorld.removeCollisionObject(_terrainBody);
			// add basic infinie plane
			addSimplePlane();
		}
		
		private function removePlane():void 
		{
			physicsWorld.removeCollisionObject(_planeBody);
			// add basic infinie plane
			addTerrain();
		}
		
	}
	
}

