package com.away3d.invawayders.systems
{
	import com.away3d.invawayders.*;
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.nodes.*;
	import com.away3d.invawayders.utils.*;
	
	import net.richardlord.ash.core.*;
	import net.richardlord.signals.*;
	
	import flash.geom.*;


	
	public class GameManager extends System
	{
		[Inject]
		public var creator : EntityCreator;
		
		[Inject]
		public var saveStateManager : SaveStateManager;
		
		[Inject]
		public var gameStateUpdated : Signal1;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.GameNode")]
		public var games : NodeList;
		[Inject(nodeType="com.away3d.invawayders.nodes.PlayerNode")]
		public var players : NodeList;
		[Inject(nodeType="com.away3d.invawayders.nodes.InvawayderNode")]
		public var invawayders : NodeList;
		[Inject(nodeType="com.away3d.invawayders.nodes.BulletNode")]
		public var bullets : NodeList;
		[Inject(nodeType="com.away3d.invawayders.nodes.BlastNode")]
		public var blasts : NodeList;
		
		[PostConstruct]
		public function setUpListeners() : void
		{
			invawayders.nodeAdded.add( addToInvawayders );
			bullets.nodeAdded.add( addToBullets );
			games.nodeAdded.add( addToGames );
			blasts.nodeAdded.add( addToBlasts );
		}
		
		private function addToInvawayders( node : InvawayderNode ) : void
		{
			var invawayder : Invawayder = node.invawayder;
			var archetype : InvawayderArchetype = node.dataModel.archetype as InvawayderArchetype;
			
			//randomise invawayder properties
			invawayder.panXFreq = 0.1 * Math.random();
			invawayder.panYFreq = 0.1 * Math.random();
			invawayder.spawnX = node.transform.x;
			invawayder.spawnY = node.transform.y;
			invawayder.targetSpeed = -archetype.speed * MathUtils.rand( 0.75, 1.25 );
			invawayder.targetSpawnZ = MathUtils.rand( 15000, 20000 );
			invawayder.life = archetype.life;
			invawayder.fireTimer = getFireTimer(archetype);
			invawayder.animationTimer = getAnimationTimer();
			invawayder.movementCounter = 0;
			
			node.transform.scaleX = node.transform.scaleY = node.transform.scaleZ = archetype.scale;
		}
		
		private function addToBullets( node : BulletNode ) : void
		{
			//offset projectiles from the mothership by a random amount
			if (node.dataModel.archetype.id == ArchetypeLibrary.MOTHERSHIP_PROJECTILE) {
				node.transform.x += MathUtils.rand( -700, 700 );
				node.transform.y += MathUtils.rand( -150, 150 );
			}
		}
		
		private function addToBlasts( node : BlastNode ) : void
		{
			//reset scale to zero
			node.transform.scaleX = node.transform.scaleY = node.transform.scaleZ = 0;
		}
		
		private function addToGames( game : GameNode ) : void
		{
			//load the last highscore
			game.state.highScore = saveStateManager.loadHighScore();
			
			gameStateUpdated.dispatch( game.state );
		}
		
		override public function update( time : Number ) : void
		{
			time *= 1000;
			
			var game : GameNode;
			var invawayderNode : InvawayderNode;
			var blastNode : BlastNode;
			var transform : Transform3D;
			var id : uint;
			
			//do nothing until a game is created
			if (games.empty)
				return;
			
			//update game loop
			for ( game = games.head; game; game = game.next )
			{
				
				//determine if enough time has passed to spawn another invawayder
				for each (id in ArchetypeLibrary.INVAWAYDERS) {
					var invawayderArchetype : InvawayderArchetype = ArchetypeLibrary.getArchetype(id) as InvawayderArchetype;
					invawayderArchetype.spawnTimer -= time;
					if( invawayderArchetype.spawnTimer < 0 ) {
						
						creator.createEntity( MathUtils.rand(-GameSettings.xyRange, GameSettings.xyRange ), MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange), GameSettings.maxZ, new Vector3D(0, 0, MathUtils.rand( -2500, -1500 )), id );

						invawayderArchetype.spawnTimer = invawayderArchetype.spawnRate * game.state.spawnTimeFactor * MathUtils.rand( 0.9, 1.1 );
					}
				}
				
				//update invawayder animations
				for ( invawayderNode = invawayders.head; invawayderNode; invawayderNode = invawayderNode.next )
				{
					var dataModel : DataModel = invawayderNode.dataModel;
					var invawayder : Invawayder = invawayderNode.invawayder;
					transform = invawayderNode.transform;
					var archetype : InvawayderArchetype = dataModel.archetype as InvawayderArchetype;
					
					//perform wobble movement in the x / y plane
					invawayder.movementCounter++;
					transform.x = invawayder.spawnX + archetype.panAmplitude * Math.sin( invawayder.panXFreq * invawayder.movementCounter );
					transform.y = invawayder.spawnY + archetype.panAmplitude * Math.sin( invawayder.panYFreq * invawayder.movementCounter );
					
					// Slow down warping in
					if( transform.z < invawayder.targetSpawnZ && invawayderNode.motion.velocity.z < invawayder.targetSpeed )
						invawayderNode.motion.velocity.z *= 0.75;
					
					invawayder.animationTimer -= time;
					
					//perform animation
					if (invawayder.animationTimer < 0) {
						invawayder.meshFrame0.visible = !invawayder.meshFrame0.visible;
						invawayder.meshFrame1.visible = !invawayder.meshFrame0.visible;
						
						//reset time to animate
						invawayder.animationTimer = getAnimationTimer();
					}
					
					invawayder.fireTimer -= time;
					
					//fire projectile
					if (invawayder.fireTimer < 0) {
						creator.createEntity(transform.x, transform.y, transform.z, new Vector3D(0, 0, -100), ArchetypeLibrary.INVAWAYDER_PROJECTILE);
						
						//reset time to fire
						invawayder.fireTimer = getFireTimer(archetype);
					}
				}
				
				//update blast animations
				for ( blastNode = blasts.head; blastNode; blastNode = blastNode.next )
				{
					transform = blastNode.transform;
					
					//scale up the blast
					var scale : Number = transform.scaleX = transform.scaleY = transform.scaleZ += 0.15;
					
					if (scale > 5)
						creator.destroyEntity(blastNode.entity);
				}
			}
			
		}
		
		private function getFireTimer( archetype : InvawayderArchetype ) : Number
		{
			return Math.floor( archetype.fireRate * MathUtils.rand( 1, 1.5 ) );
		}
		
		private function getAnimationTimer() : Number
		{
			return MathUtils.rand( GameSettings.invawayderAnimationTimeMS, GameSettings.invawayderAnimationTimeMS * 1.5 );
		}
			
	}
}
