package invaders.objects
{
	import invaders.events.*;
	import invaders.pools.*;
	import invaders.utils.*;
	
	import away3d.entities.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class Invader extends GameObject
	{
		private var _meshFrame0:Mesh;
		private var _meshFrame1:Mesh;
		private var _fireTimer:Timer;
		private var _invaderType:uint;
		private var _targetSpawnZ:Number;
		private var _animationTimer:Timer;
		private var _cellsFrame0:Vector.<Point>;
		private var _cellsFrame1:Vector.<Point>;
		private var _currentDefinitionIndex:uint;
		private var _life:uint;
		private var _panAmplitude:Number;
		private var _panXFreq:Number;
		private var _panYFreq:Number;
		private var _updateCounter:uint;
		private var _spawnX:Number = 0;
		private var _spawnY:Number = 0;
		private var _targetSpeed:Number = 0;
		
		public function Invader( invaderType:uint, meshFrame0:Mesh, meshFrame1:Mesh, cellsFrame0:Vector.<Point>, cellsFrame1:Vector.<Point> )
		{
			super();
			
			_invaderType = invaderType;
			_meshFrame0 = meshFrame0.clone() as Mesh;
			_meshFrame1 = meshFrame1.clone() as Mesh;
			_cellsFrame0 = cellsFrame0;
			_cellsFrame1 = cellsFrame1;
			
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
			var rate:uint = InvaderDefinitions.getFireRateMSForInvaderType( _invaderType );
			return Math.floor( MathUtils.rand( rate, rate * 1.5 ) );
		}

		public function getInvaderClone():Invader
		{
			return new Invader( _invaderType, _meshFrame0.clone() as Mesh, _meshFrame1.clone() as Mesh, _cellsFrame0, _cellsFrame1 );
		}

		public function stopTimers():void
		{
			_animationTimer.stop();
			_fireTimer.stop();
		}

		public function resumeTimers():void
		{
			if( enabled ) {
				_animationTimer.start();
				_fireTimer.start();
			}
		}

		private function onFireTimerTick( event:TimerEvent ):void
		{
			_fireTimer.delay = getFireRate();
			dispatchEvent( new GameObjectEvent( GameObjectEvent.FIRE, this ) );
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

		override public function impact( hitter:GameObject ):void
		{
			super.impact( hitter );
			
			_life -= GameSettings.blasterStrength;
			if( _life <= 0 ) {
				removeItem();
				dispatchEvent( new GameObjectEvent( GameObjectEvent.DEAD, this, hitter ) );
			}
		}

		override public function update():void
		{
			super.update();
			
			_updateCounter++;
			x = _spawnX + _panAmplitude * Math.sin( _panXFreq * _updateCounter );
			y = _spawnY + _panAmplitude * Math.sin( _panYFreq * _updateCounter );
			
			if( z < _targetSpawnZ && velocity.z < _targetSpeed ) { // Slow down warping in
				velocity.z *= 0.75;
			}
		}
		
		override public function addItem(parent:GameObjectPool):void
		{
			super.addItem(parent);
			
			_animationTimer.start();
			_fireTimer.start();
			
			_updateCounter = 0;
			_panAmplitude = InvaderDefinitions.getPanAmplitudeForInvaderType( _invaderType );
			_panXFreq = 0.1 * Math.random();
			_panYFreq = 0.1 * Math.random();
			_spawnX = x = MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange );
			_spawnY = y = MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange );
			var speed:Number = InvaderDefinitions.getSpeedForInvaderType( _invaderType );
			_targetSpeed = -MathUtils.rand( speed * 0.75, speed * 1.25 );
			z = GameSettings.maxZ; // Warp in...
			velocity.z = MathUtils.rand( -2500, -1500 );
			_targetSpawnZ = MathUtils.rand( 15000, 20000 );
			scaleX = scaleY = scaleZ = invaderType == InvaderDefinitions.MOTHERSHIP ? 3 : 1;
			_life = InvaderDefinitions.getLifeForInvaderType( _invaderType );
		}
		
		override public function removeItem():void
		{
			super.removeItem();
			
			_animationTimer.reset();
			_fireTimer.reset();
		}
		
		public function get cellPositions():Vector.<Point>
		{
			return _currentDefinitionIndex == 0 ? _cellsFrame0 : _cellsFrame1;
		}

		public function get invaderType():uint
		{
			return _invaderType;
		}
	}
}
