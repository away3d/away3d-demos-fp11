package com.away3d.invawayders.objects
{
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.entities.Sprite3D;
	import away3d.entities.TextureProjector;
	import com.away3d.invawayders.pools.GameObjectPool;
	import com.away3d.invawayders.pools.InvawayderPool;
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
	 * Game object used for an invawayder cell that forms the invawayder as it explodes after being killed.
	 */
	public class InvawayderCell extends GameObject
	{
		private var _mesh:Mesh;
		private var _deathTimer:Timer;
		private var _startFlashingOnCount:uint;
		
		/**
		 * Creates a new <code>InvawayderCell</code> object.
		 * 
		 * @param mesh The Away3D mesh object used for the cell in the 3D scene.
		 */
		public function InvawayderCell( mesh:Mesh )
		{
			super();
			
			_mesh = mesh;
			
			addChild( mesh );
			
			var flashCount:uint = MathUtils.rand(15, 25);
			
			_startFlashingOnCount = flashCount * 0.75;
			
			_deathTimer = new Timer( MathUtils.rand(30, 50), flashCount );
			_deathTimer.addEventListener( TimerEvent.TIMER, onDeathTimerTick );
			_deathTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onDeathTimerComplete );
		}
		
		override public function cloneGameObject():GameObject
		{
			return new InvawayderCell( _mesh.clone() as Mesh );
		}
		
		override public function add(parent:GameObjectPool):void
		{
			super.add(parent);
			
			visible = true;
			
			_deathTimer.start();
		}
		
		override public function clear():void
		{
			super.clear();
			
			_deathTimer.reset();
		}
		
		private function onDeathTimerComplete( event:TimerEvent ):void
		{
			clear();
		}
		
		private function onDeathTimerTick( event:TimerEvent ):void
		{
			if( _deathTimer.currentCount > _startFlashingOnCount )
				visible = !visible;
		}
	}
}
