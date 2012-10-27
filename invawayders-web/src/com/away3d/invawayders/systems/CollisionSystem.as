package com.away3d.invawayders.systems
{
	import com.away3d.invawayders.*;
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.nodes.*;
	import com.away3d.invawayders.utils.*;
	
	import away3d.containers.*;
	
	import flash.geom.*;
	
	import net.richardlord.ash.core.*;
	import net.richardlord.signals.*;
	

	
	public class CollisionSystem extends System
	{
		[Inject]
		public var creator : EntityCreator;
		
		[Inject]
		public var gameStateUpdated : Signal1;
		
		[Inject]
		public var saveStateManager : SaveStateManager;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.GameNode")]
		public var gameNodes : NodeList;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.PlayerNode")]
		public var playerNodes : NodeList;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.InvawayderNode")]
		public var invawayderNodes : NodeList;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.BulletNode")]
		public var bulletNodes : NodeList;

		override public function update( time : Number ) : void
		{
			time *= 1000;
			
			var game : GameNode;
			var bullet : BulletNode;
			var invawayder : InvawayderNode;
			var player : PlayerNode;
			var dx : Number;
			var dy : Number;
			var dz : Number;
			var x : Number;
			var y : Number;
			var z : Number;
			var velocity : Vector3D;
			var transform : Transform3D;
			
			//update collisions when a game is present
			for ( game = gameNodes.head; game; game = game.next )
			{
				//detect collisions between projectiles and invawayders / players
				for ( bullet = bulletNodes.head; bullet; bullet = bullet.next )
				{
					x = bullet.transform.x;
					y = bullet.transform.y;
					z = bullet.transform.z;
					velocity = bullet.motion.velocity;
					
					switch(bullet.dataModel.subType.id)
					{
						case ProjectileArchetype.PLAYER:
							for ( invawayder = invawayderNodes.head; invawayder; invawayder = invawayder.next )
							{
								transform = invawayder.transform;
								dz = transform.z - z;
								
								if( Math.abs( dz ) < Math.abs( velocity.z ) ) {
									dx = transform.x - x;
									dy = transform.y - y;
									if( Math.sqrt( dx * dx + dy * dy ) < GameSettings.impactHitSize * transform.scaleX ) {
										
										//destroy bullet
										creator.destroyEntity( bullet.entity );
										
										//deplete invawayder life
										invawayder.invawayder.life -= GameSettings.blasterStrength;
										
										//show blast
										creator.createEntity(x, y, z, invawayder.motion.velocity, ArchetypeLibrary.BLAST, BlastArchetype.INVAWAYDER);
										
										//destroy invawayder if life is depleted
										if( invawayder.invawayder.life <= 0)
											destroyInvawayder(game, invawayder, x, y, z, velocity);
									}
								}
							}
							break;
						case ProjectileArchetype.INVAWAYDER:
							for ( player = playerNodes.head; player; player = player.next )
							{
								transform = player.transform;
								dz = transform.z - z;
			
								if( Math.abs( dz ) < Math.abs( velocity.z ) ) {
									dx = transform.x - x;
									dy = transform.y - y;
									if( Math.sqrt( dx * dx + dy * dy ) < GameSettings.impactHitSize ) {
										
										//destroy bullet
										creator.destroyEntity( bullet.entity );
										
										//register a hit
										hitPlayer(game, player, x, y, z);
									}
								}
							}
							break;
						default:
					}
				}
				
				//detect collisions between players and invawayders
				for ( player = playerNodes.head; player; player = player.next )
				{
					x = player.transform.x;
					y = player.transform.y;
					z = player.transform.z;
					velocity = player.motion.velocity;
					
					for ( invawayder = invawayderNodes.head; invawayder; invawayder = invawayder.next )
					{
						transform = invawayder.transform;
						dz = transform.z - z;
						
						if( Math.abs( dz ) < Math.abs( invawayder.motion.velocity.z ) ) {
							dx = transform.x - x;
							dy = transform.y - y;
							if( Math.sqrt( dx * dx + dy * dy ) < GameSettings.impactHitSize ) {
								
								//register a hit
								hitPlayer(game, player, transform.x, transform.y, transform.z);
								
								//destroy invawayder
								destroyInvawayder(game, invawayder, x, y, z, velocity);
								
								//show invawayder blast
								creator.createEntity(transform.x, transform.y, transform.z, invawayder.motion.velocity, ArchetypeLibrary.BLAST, BlastArchetype.INVAWAYDER);
							}
						}
					}
					
					if ( player.player.shakeCounter) {
						var shakeRange:Number = GameSettings.playerHitShake * player.player.shakeCounter / GameSettings.playerCountShake;
						player.player.shakeCounter--;
						player.player.camera.x = x + MathUtils.rand( -shakeRange, shakeRange );
						player.player.camera.y = y + MathUtils.rand( -shakeRange, shakeRange );
						player.player.camera.z = -2000;
					} else {
						player.player.camera.x = x;
						player.player.camera.y = y;
						player.player.camera.z = -2000;
					}
				}
				
			}
		}
		
		private function destroyInvawayder(game : GameNode, invawayder : InvawayderNode, x : Number, y : Number, z : Number, velocity : Vector3D) : void
		{
			var transform:Transform3D = invawayder.transform;
			var currentFrame : uint = invawayder.invawayder.currentFrame;
			var archetype : InvawayderArchetype = invawayder.dataModel.subType as InvawayderArchetype;
			var cellPositions : Vector.<Point> = archetype.cellPositions[currentFrame];
			var scale : Number = archetype.scale;
			var i:uint;
			
			creator.destroyEntity( invawayder.entity );
			
			//create explosion
			var explosionEntity : Entity = creator.createEntity(transform.x, transform.y, transform.z, invawayder.motion.velocity, ArchetypeLibrary.EXPLOSION, invawayder.dataModel.subType.id);
			var explositonTransform:Transform3D = explosionEntity.get(Transform3D) as Transform3D;
			var explosion : Explosion = explosionEntity.get(Explosion) as Explosion;
			explosion.currentFrame = currentFrame;
			
			//reset explosion scale
			explositonTransform.scaleX = explositonTransform.scaleY = explositonTransform.scaleZ = scale;
			
			//rest explosion visibility
			for (i=0; i<explosion.cellContainers.length; i++)
				explosion.cellContainers[i].visible = (i == currentFrame);
			
			//reset explosion animation
			var cellContainer:ObjectContainer3D = explosion.cellContainers[currentFrame];
			var cellVelocities:Vector.<Vector3D> = explosion.cellVelocities[currentFrame];
			var cellRotationalVelocities:Vector.<Vector3D> = explosion.cellRotationalVelocities[currentFrame];
			var cellDeathTimers:Vector.<uint> = explosion.cellDeathTimers[currentFrame];
			var intensity:Number = GameSettings.deathExplosionIntensity * MathUtils.rand( 1, 4 );
			var cell:ObjectContainer3D;
			var position:Point;
			var cellVelocity:Vector3D;
			var cellRotationalVelocity:Vector3D;
			
			for (i=0; i<cellPositions.length; i++) {
				position = cellPositions[i];
				cell = cellContainer.getChildAt(i) as ObjectContainer3D;
				cell.visible = true;
				
				//set position of cell
				cell.x = position.x;
				cell.y = position.y;
				
				// Determine explosion velocity of cell.
				var dx:Number = cell.x*scale + transform.x - x;
				var dy:Number = cell.y*scale + transform.y - y;
				var distanceSq:Number = dx * dx + dy * dy;
				var rotSpeed:Number = intensity * 2500 / distanceSq;
				
				//set the rotation velocity of the cell
				cellRotationalVelocity = cellRotationalVelocities[i] ||= new Vector3D();
				cellRotationalVelocity.x = MathUtils.rand( -rotSpeed, rotSpeed );
				cellRotationalVelocity.y = MathUtils.rand( -rotSpeed, rotSpeed );
				cellRotationalVelocity.z = MathUtils.rand( -rotSpeed, rotSpeed );
				
				//set the linear velocity of the cell
				cellVelocity = cellVelocities[i] ||= new Vector3D();
				cellVelocity.x = intensity * MathUtils.rand( GameSettings.cellVelocityMin, GameSettings.cellVelocityMax ) * dx / distanceSq;
				cellVelocity.y = intensity * MathUtils.rand( GameSettings.cellVelocityMin, GameSettings.cellVelocityMax ) * dy / distanceSq;
				cellVelocity.z = intensity * MathUtils.rand( GameSettings.cellVelocityMinZ, GameSettings.cellVelocityMaxZ ) * velocity.z / distanceSq;
				
				//set the death timer of the cell
				cellDeathTimers[i] = MathUtils.rand(GameSettings.deathTimerMin, GameSettings.deathTimerMax);
				
			}
			
			//increase score
			game.state.score += (invawayder.dataModel.subType as InvawayderArchetype).score;
			
			// Update highscore
			if( game.state.score > game.state.highScore && game.state.lives ) {
				game.state.highScore = game.state.score;
				saveStateManager.saveHighScore(game.state.highScore);
			}
			
			//dispatch game state udpated signal
			gameStateUpdated.dispatch( game.state );
			
			//update game level
			if( game.state.levelKills > GameSettings.killsToAdvanceDifficulty ) {
				game.state.levelKills = 0;
				game.state.level++;
				
				game.state.spawnTimeFactor -= GameSettings.spawnTimeFactorPerLevel;
				
				if( game.state.spawnTimeFactor < GameSettings.minimumSpawnTimeFactor )
					game.state.spawnTimeFactor = GameSettings.minimumSpawnTimeFactor;
			}
		}
		
		private function hitPlayer( game : GameNode, player : PlayerNode, x : Number, y : Number, z : Number ) : void
		{
			//deplete player lives
			game.state.lives--;
			
			//dispatch game state udpated signal
			gameStateUpdated.dispatch( game.state );
			
			//show player blast
			creator.createEntity(x, y, z, player.motion.velocity, ArchetypeLibrary.BLAST, BlastArchetype.PLAYER);
			
			//trigger camera shake
			player.player.shakeCounter = GameSettings.playerCountShake;
		}
	}
}
