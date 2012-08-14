package invaders.objects
{
	import invaders.utils.MathUtils;
	import invaders.pools.*;
	
	import away3d.entities.*;
	
	import flash.events.*;
	import flash.utils.*;
	
	public class InvaderCell extends GameObject
	{
		private var _deathTimer:Timer;
		private var _startFlashingOnCount:uint;
		
		public function InvaderCell( cellMesh:Mesh )
		{
			super();
			
			addChild( cellMesh );
			
			var flashCount:uint = MathUtils.rand(15, 25);
			
			_startFlashingOnCount = flashCount * 0.75;
			
			_deathTimer = new Timer( MathUtils.rand(30, 50), flashCount );
			_deathTimer.addEventListener( TimerEvent.TIMER, onDeathTimerTick );
			_deathTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onDeathTimerComplete );
		}
		
		private function onDeathTimerComplete( event:TimerEvent ):void
		{
			removeItem();
		}
		
		private function onDeathTimerTick( event:TimerEvent ):void
		{
			if( _deathTimer.currentCount > _startFlashingOnCount )
				visible = !visible;
		}
		
		override public function addItem(parent:GameObjectPool):void
		{
			super.addItem(parent);
			
			_deathTimer.start();
		}
		
		override public function removeItem():void
		{
			super.removeItem();
			
			visible = true;
			enabled = false;
			_deathTimer.reset();
		}
	}
}
