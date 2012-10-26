package com.away3d.invawayders.objects
{
	import away3d.cameras.Camera3D;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.entities.Sprite3D;
	import away3d.entities.TextureProjector;
	import away3d.materials.ColorMaterial;
	import away3d.materials.ColorMultiPassMaterial;
	import away3d.materials.LightSources;
	import away3d.materials.MaterialBase;
	import away3d.materials.MultiPassMaterialBase;
	import away3d.materials.SegmentMaterial;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.TextureMultiPassMaterial;
	import away3d.primitives.CapsuleGeometry;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.LineSegment;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.PrimitiveBase;
	import away3d.primitives.RegularPolygonGeometry;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.TorusGeometry;
	import away3d.primitives.WireframeCube;
	import away3d.primitives.WireframeCylinder;
	import away3d.primitives.WireframePlane;
	import away3d.primitives.WireframePrimitiveBase;
	import away3d.primitives.WireframeSphere;
	import com.away3d.invawayders.events.GameObjectEvent;
	import com.away3d.invawayders.utils.MathUtils;
	import com.away3d.invawayders.utils.SaveStateManager;
	import com.away3d.invawayders.utils.StringUtils;
	import flash.events.AccelerometerEvent;
	import flash.events.ActivityEvent;
	import flash.events.AsyncErrorEvent;
	import flash.events.ContextMenuEvent;
	import flash.events.DRMAuthenticateEvent;
	import flash.events.DRMAuthenticationCompleteEvent;
	import flash.events.DRMAuthenticationErrorEvent;
	import flash.events.DRMCustomProperties;
	import flash.events.DRMDeviceGroupErrorEvent;
	import flash.events.DRMDeviceGroupEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.FocusEvent;
	import flash.events.FullScreenEvent;
	import flash.events.GameInputEvent;
	import flash.events.GeolocationEvent;
	import flash.events.GestureEvent;
	import flash.events.GesturePhase;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IMEEvent;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetDataEvent;
	import flash.events.NetFilterEvent;
	import flash.events.NetMonitorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.PressAndTapGestureEvent;
	import flash.events.ProgressEvent;
	import flash.events.SampleDataEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.ShaderEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.events.SoftKeyboardTrigger;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.events.StatusEvent;
	import flash.events.SyncEvent;
	import flash.events.TextEvent;
	import flash.events.ThrottleEvent;
	import flash.events.ThrottleType;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.events.UncaughtErrorEvents;
	import flash.events.VideoEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.ObjectInput;
	import flash.utils.ObjectOutput;
	import flash.utils.Proxy;
	import flash.utils.SetIntervalTimer;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.describeType;
	import flash.utils.escapeMultiByte;
	import flash.utils.flash_proxy;
	import flash.utils.getAliasName;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import flash.utils.unescapeMultiByte;
	
	
	
	/**
	 * Game object used for the player in the scene.
	 */
	public class Player extends GameObject
	{
		private var _camera:Camera3D;
		private var _shakeTimer:Timer;
		private var _shakeT:Number = 0;
		private var _shakeTimerCount:uint = 10;
		
		private var _fireReleased:Boolean = true;
		private var _fireReleaseTimer:Timer;
		private var _leftBlaster:Mesh;
		private var _rightBlaster:Mesh;
		
		public var targets:Vector.<GameObject>;
		
		public var playerFireCounter:uint;
		
		public var lives:uint;
		
		/**
		 * Creates a new <code>Player</code> object.
		 * 
		 * @param camera The Away3D camera object controlled by the player.
		 * @param material The material used for the player's blaster objects.
		 */
		public function Player( camera:Camera3D, material:MaterialBase )
		{
			super();
			
			addChild( camera );

			_camera = camera;
			
			// Blasters.
			_leftBlaster = new Mesh( new CubeGeometry( 25, 25, 500 ), material );
			_rightBlaster = _leftBlaster.clone() as Mesh;
			
			_leftBlaster.position = new Vector3D( -GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
			_rightBlaster.position = new Vector3D( GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
			
			addChild( _leftBlaster );
			addChild( _rightBlaster );
			
			// used to skae the camera after a hit
			_shakeTimer = new Timer( 25, _shakeTimerCount );
			_shakeTimer.addEventListener( TimerEvent.TIMER, onShakeTimerTick );
			_shakeTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onShakeTimerComplete );
			
			// Used for rapid fire.
			_fireReleaseTimer = new Timer( GameSettings.blasterFireRateMS, 1 );
			_fireReleaseTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onFireReleaseTimerComplete );
		}
		
		/**
		 * updates the firing state of the player's blaster objects.
		 */
		public function updateBlasters():void
		{
			if(_fireReleased) {
				playerFireCounter++;
				
				//kick back on the blasters
				var blaster:Mesh = playerFireCounter % 2 ? _rightBlaster : _leftBlaster;
				blaster.z -= 500;
				
				dispatchEvent( new GameObjectEvent( GameObjectEvent.GAME_OBJECT_FIRE, this ) );
				
				_fireReleased = false;
				_fireReleaseTimer.reset();
				_fireReleaseTimer.start();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void
		{
			super.update();
			
			var dx:Number, dy:Number, dz:Number;
			
			// Check for collisions with invawayders.
			var target:GameObject;
			for each ( target in targets ) {
				if( target.active ) {

					dz = target.z - z;

					if( Math.abs( dz ) < Math.abs( target.velocity.z ) ) {
						dx = target.x - x;
						dy = target.y - y;
						if( Math.sqrt( dx * dx + dy * dy ) < GameSettings.impactHitSize ) {
							impact( target );
							target.impact(this);
						}
					}
				}
			}
			
			// Restore blasters from recoil.
			_leftBlaster.z += 0.25 * (GameSettings.blasterOffsetD - _leftBlaster.z);
			_rightBlaster.z += 0.25 * (GameSettings.blasterOffsetD - _rightBlaster.z);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function impact( trigger:GameObject ):void
		{
			if (!lives)
				return;
			
			//decrease the number of lives
			lives--;
			
			super.impact( trigger );
			
			//shake the camera to give the impression of impact
			_shakeT = 1;
			_shakeTimer.reset();
			_shakeTimer.start();
			
			//check to see if player is dead
			if (!lives)
				dispatchEvent( new GameObjectEvent( GameObjectEvent.GAME_OBJECT_DIE, this, trigger ) );
		}
		
		/**
		 * Handler for shake timer tick events, broadcast for a short time after the player has been hit by a projectile or invawayder. 
		 */
		private function onShakeTimerTick( event:TimerEvent ):void
		{
			var shakeRange:Number = GameSettings.playerHitShake * _shakeT;
			_camera.x = MathUtils.rand( -shakeRange, shakeRange );
			_camera.y = MathUtils.rand( -shakeRange, shakeRange );
			_shakeT = 1 - _shakeTimer.currentCount / _shakeTimerCount;
		}
		
		/**
		 * Handler for shake timer complete events, broadcast when the shake timer has completed. 
		 */
		private function onShakeTimerComplete( event:TimerEvent ):void
		{
			_camera.x = 0;
			_camera.y = 0;
		}
		
		/**
		 * Handler for fire release timer complete events, broadcast when the fire release timer has completed. 
		 */
		private function onFireReleaseTimerComplete( event:TimerEvent ):void
		{
			_fireReleased = true;
		}
	}
}
