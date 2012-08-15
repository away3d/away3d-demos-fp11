package invaders.pools
{
	import invaders.data.*;
	import invaders.events.*;
	import invaders.objects.*;
	import invaders.utils.*;
	
	import away3d.materials.*;
	
	import flash.events.*;
	import flash.utils.*;
	
	public class InvaderPool extends GameObjectPool
	{
		private var _time:uint;
		private var _invaderMaterial:MaterialBase;
		private var _currentTypeIndex:uint;
		
		public var spawnTimeFactor:Number = 1;
		
		public function InvaderPool( invaderMaterial:MaterialBase )
		{
			super(null);
			
			_invaderMaterial = invaderMaterial;
		}
		
		override public function update():void
		{
			super.update();
			
			_time = getTimer();
		}
		
		public function stop():void
		{
			var invader:Invader;
			for each ( invader in _gameObjects)
				if( invader.enabled )
					invader.stopTimers();
		}
		
		public function resume():void
		{
			var invader:Invader;
			for each ( invader in _gameObjects)
				if( invader.enabled )
					invader.resumeTimers();
			
			//reset spawn times
			InvaderFactory.getInstance().resetLastSpawnTimes(_time = getTimer());
		}
		
		private function forwardEvent( event:Event ):void
		{
			dispatchEvent( event );
		}
		
		public function evaluateSpawnInvader( id:uint ):void
		{
			var _invaderData:InvaderData = InvaderFactory.getInstance().getInvaderData(id);
			var elapsedSinceSpawn:int = _time - _invaderData.lastSpawnTime;
			if( elapsedSinceSpawn > _invaderData.spawnRate * spawnTimeFactor * MathUtils.rand( 0.9, 1.1 ) ) {
				var invader:Invader = getInvaderOfType( id );
				dispatchEvent( new GameObjectEvent( GameObjectEvent.GAME_OBJECT_ADDED, invader ) );
				_invaderData.lastSpawnTime = _time;
			}
		}
		
		private function getInvaderOfType( id:uint ):Invader
		{
			// Adds an unused item or creates a new item if none isfound.
			var invader:Invader;
			for each ( invader in _gameObjects) {
				if( !invader.enabled && invader.invaderType == id ) {
					invader.addItem(this);
					return invader;
				}
			}
			
			_currentTypeIndex = id;
			invader = InvaderFactory.getInstance().getInvader(id, _invaderMaterial);
			
			// Listen for when the invader is dead.
			invader.addEventListener( GameObjectEvent.GAME_OBJECT_DEAD, forwardEvent );
			invader.addEventListener( GameObjectEvent.GAME_OBJECT_FIRE, forwardEvent );
			invader.addEventListener( GameObjectEvent.GAME_OBJECT_HIT, forwardEvent );
			
			invader.addItem(this);
			_gameObjects.push( invader );
			
			return invader;
		}
	}
}
