package invawayders.objects
{
	import invawayders.data.*;
	import invawayders.events.*;
	import invawayders.pools.*;
	import invawayders.utils.*;
	
	import away3d.entities.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class Invawayder extends GameObject
	{
		private var _invaderData:InvawayderData;
		private var _meshFrame0:Mesh;
		private var _meshFrame1:Mesh;
		private var _fireTimer:Timer;
		private var _targetSpawnZ:Number;
		private var _animationTimer:Timer;
		private var _currentDefinitionIndex:uint;
		private var _life:uint;
		private var _panAmplitude:Number;
		private var _panXFreq:Number;
		private var _panYFreq:Number;
		private var _updateCounter:uint;
		private var _spawnX:Number = 0;
		private var _spawnY:Number = 0;
		private var _targetSpeed:Number = 0;
		
		public function get invaderData():InvawayderData
		{
			return _invaderData;
		}
		
		public function Invawayder( invaderData:InvawayderData, meshFrame0:Mesh, meshFrame1:Mesh )
		{
			super();
			
			_invaderData = invaderData;
			_meshFrame0 = meshFrame0;
			_meshFrame1 = meshFrame1;
			
			addChild( _meshFrame0 );
			addChild( _meshFrame1 );
			
			_animationTimer = new Timer( MathUtils.rand( GameSettings.invaderAnimationTimeMS, GameSettings.invaderAnimationTimeMS * 1.5 ) );
			_animationTimer.addEventListener( TimerEvent.TIMER, onAnimationTimerTick );
			
			_fireTimer = new Timer( getFireRate() );
			_fireTimer.addEventListener( TimerEvent.TIMER, onFireTimerTick );
			
			toggleFrame();
		}

		private function getFireRate():uint
		{
			var rate:uint = _invaderData.fireRate;
			return Math.floor( MathUtils.rand( rate, rate * 1.5 ) );
		}

		override public function cloneGameObject():GameObject
		{
			return new Invawayder( _invaderData, _meshFrame0.clone() as Mesh, _meshFrame1.clone() as Mesh);
		}

		public function stopTimers():void
		{
			_animationTimer.stop();
			_fireTimer.stop();
		}

		public function resumeTimers():void
		{
			_animationTimer.start();
			_fireTimer.start();
		}

		private function onFireTimerTick( event:TimerEvent ):void
		{
			_fireTimer.delay = getFireRate();
			dispatchEvent( new GameObjectEvent( GameObjectEvent.GAME_OBJECT_FIRE, this ) );
		}

		private function onAnimationTimerTick( event:TimerEvent ):void
		{
			toggleFrame();
		}

		private function toggleFrame():void
		{
			_meshFrame0.visible = !_meshFrame0.visible;
			_meshFrame1.visible = !_meshFrame0.visible;
			_currentDefinitionIndex = _meshFrame0.visible ? 0 : 1;
		}

		override public function impact( trigger:GameObject ):void
		{
			super.impact( trigger );
			
			_life -= GameSettings.blasterStrength;
			if( _life <= 0 || trigger is Player ) {
				removeItem();
				dispatchEvent( new GameObjectEvent( GameObjectEvent.GAME_OBJECT_DEAD, this, trigger ) );
			}
		}

		override public function update():void
		{
			super.update();
			
			_updateCounter++;
			x = _spawnX + _panAmplitude * Math.sin( _panXFreq * _updateCounter );
			y = _spawnY + _panAmplitude * Math.sin( _panYFreq * _updateCounter );
			
			// Slow down warping in
			if( z < _targetSpawnZ && velocity.z < _targetSpeed )
				velocity.z *= 0.75;
		}
		
		override public function addItem(parent:GameObjectPool):void
		{
			super.addItem(parent);
			
			_animationTimer.start();
			_fireTimer.start();
			
			_updateCounter = 0;
			_panAmplitude = _invaderData.panAmplitude;
			_panXFreq = 0.1 * Math.random();
			_panYFreq = 0.1 * Math.random();
			_spawnX = x = MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange );
			_spawnY = y = MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange );
			var speed:Number = _invaderData.speed;
			_targetSpeed = -MathUtils.rand( speed * 0.75, speed * 1.25 );
			z = GameSettings.maxZ; // Warp in...
			velocity.z = MathUtils.rand( -2500, -1500 );
			_targetSpawnZ = MathUtils.rand( 15000, 20000 );
			scaleX = scaleY = scaleZ = _invaderData.scale;
			_life = _invaderData.life;
		}
		
		override public function removeItem():void
		{
			super.removeItem();
			
			_animationTimer.reset();
			_fireTimer.reset();
		}
		
		public function get cellPositions():Vector.<Point>
		{
			return _currentDefinitionIndex == 0 ? _invaderData.cellsFrame0 : _invaderData.cellsFrame1;
		}
	}
}
