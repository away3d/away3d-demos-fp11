package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.entities.Mesh;

	import com.away3d.spaceinvaders.GameSettings;
	import com.away3d.spaceinvaders.events.GameObjectEvent;
	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.utils.MathUtils;

	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;

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

		public function Invader( invaderType:uint, meshFrame0:Mesh, meshFrame1:Mesh, cellsFrame0:Vector.<Point>, cellsFrame1:Vector.<Point> ) {

			super();

			_invaderType = invaderType;

			_meshFrame0 = meshFrame0.clone() as Mesh;
			_meshFrame1 = meshFrame1.clone() as Mesh;
			addChild( _meshFrame0 );
			addChild( _meshFrame1 );
			toggleFrame();

			_cellsFrame0 = cellsFrame0;
			_cellsFrame1 = cellsFrame1;

			_animationTimer = new Timer( MathUtils.rand( GameSettings.invaderAnimationTimeMS, GameSettings.invaderAnimationTimeMS * 1.5 ) );
			_animationTimer.addEventListener( TimerEvent.TIMER, onAnimationTimerTick );

			_fireTimer = new Timer( MathUtils.rand( GameSettings.invaderFireRateMS, GameSettings.invaderFireRateMS * 1.5 ) );
			_fireTimer.addEventListener( TimerEvent.TIMER, onFireTimerTick );
		}

		public function getInvaderClone():Invader {
			return new Invader( _invaderType, _meshFrame0.clone() as Mesh, _meshFrame1.clone() as Mesh, _cellsFrame0, _cellsFrame1 );
		}

		public function stopTimers():void {
			_animationTimer.stop();
			_fireTimer.stop();
		}

		public function resumeTimers():void {
			if( enabled ) {
				_animationTimer.start();
				_fireTimer.start();
			}
		}

		override public function set enabled( value:Boolean ):void {
			super.enabled = value;
			if( !enabled ) {
				_animationTimer.stop();
				_fireTimer.stop();
			}
			else {
				_animationTimer.start();
				_fireTimer.start();
			}
		}

		private function onFireTimerTick( event:TimerEvent ):void {
			_fireTimer.delay = MathUtils.rand( GameSettings.invaderFireRateMS, GameSettings.invaderFireRateMS * 1.5 );
			dispatchEvent( new GameObjectEvent( GameObjectEvent.FIRE, this ) );
		}

		private function onAnimationTimerTick( event:TimerEvent ):void {
			toggleFrame();
		}

		private function toggleFrame():void {
			_meshFrame0.visible = !_meshFrame0.visible;
			_meshFrame1.visible = !_meshFrame0.visible;
			_currentDefinitionIndex = _meshFrame0.visible ? 0 : 1;
		}

		override public function impact( hitter:GameObject ):void {
			_life -= GameSettings.blasterStrength;
			if( _life <= 0 ) {
				enabled = false;
				dispatchEvent( new GameObjectEvent( GameObjectEvent.DEAD, this, hitter ) );
			}
			super.impact( hitter );
		}

		override public function update():void {
			super.update();
			if( z < _targetSpawnZ && velocity.z < -50 ) { // Slow down warping in
				velocity.z *= 0.75;
			}
		}

		override public function reset():void {
			super.reset();
			x = MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange );
			y = MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange );
			z = GameSettings.maxZ; // Warp in...
			velocity.z = MathUtils.rand( -2500, -1500 );
			_targetSpawnZ = MathUtils.rand( 15000, 20000 );
			scaleX = scaleY = scaleZ = invaderType == InvaderDefinitions.MOTHERSHIP ? 3 : 1;
			_life = InvaderDefinitions.getLifeForInvaderType( _invaderType );
		}

		public function get cellPositions():Vector.<Point> {
			return _currentDefinitionIndex == 0 ? _cellsFrame0 : _cellsFrame1;
		}

		public function get invaderType():uint {
			return _invaderType;
		}
	}
}
