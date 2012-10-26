package com.away3d.invawayders.systems
{
	import com.away3d.invawayders.*;
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.nodes.*;
	import com.away3d.invawayders.utils.*;
	
	import flash.geom.*;
	
	import net.richardlord.ash.core.*;
	

	
	public class CollisionSystem extends System
	{
		[Inject]
		public var creator : EntityCreator;
		
		[Inject]
		public var saveStateManager : SaveStateManager;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.GameNode")]
		public var gameNodes : NodeList;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.PlayerNode")]
		public var players : NodeList;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.InvawayderNode")]
		public var invawayders : NodeList;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.BulletNode")]
		public var bullets : NodeList;

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
			
			for ( game = gameNodes.head; game; game = game.next )
			{
				//detect collisions between projectiles and invawayders / players
				for ( bullet = bullets.head; bullet; bullet = bullet.next )
				{
					x = bullet.transform.x;
					y = bullet.transform.y;
					z = bullet.transform.z;
					velocity = bullet.motion.velocity;
					
					switch(bullet.dataModel.archetype.id)
					{
						case ArchetypeLibrary.PLAYER_PROJECTILE:
							for ( invawayder = invawayders.head; invawayder; invawayder = invawayder.next )
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
										creator.createEntity(x, y, z, invawayder.motion.velocity, ArchetypeLibrary.INVAWAYDER_BLAST);
										
										//destroy invawayder if life is depleted
										if( invawayder.invawayder.life <= 0)
											destroyInvawayder(game, invawayder, x, y, z, velocity);
									}
								}
							}
							break;
						case ArchetypeLibrary.INVAWAYDER_PROJECTILE:
							for ( player = players.head; player; player = player.next )
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
				for ( player = players.head; player; player = player.next )
				{
					x = player.transform.x;
					y = player.transform.y;
					z = player.transform.z;
					velocity = player.motion.velocity;
					
					for ( invawayder = invawayders.head; invawayder; invawayder = invawayder.next )
					{
						transform = invawayder.transform;
						dz = transform.z - z;
	
						if( Math.abs( dz ) < Math.abs( velocity.z ) ) {
							dx = transform.x - x;
							dy = transform.y - y;
							if( Math.sqrt( dx * dx + dy * dy ) < GameSettings.impactHitSize ) {
								
								//register a hit
								hitPlayer(game, player, transform.x, transform.y, transform.z);
								
								//destroy invawayder
								destroyInvawayder(game, invawayder, x, y, z, velocity);
								
								//show invawayder blast
								creator.createEntity(transform.x, transform.y, transform.z, invawayder.motion.velocity, ArchetypeLibrary.INVAWAYDER_BLAST);
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
			creator.destroyEntity( invawayder.entity );
			
			//create explosion
			//creator.createEntity();
			
			//increase score
			game.state.score += (invawayder.dataModel.archetype as InvawayderArchetype).score;
			
			// Update highscore
			if( game.state.score > game.state.highScore && game.state.lives ) {
				game.state.highScore = game.state.score;
				saveStateManager.saveHighScore(game.state.highScore);
			}
			
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
			
			//show player blast
			creator.createEntity(x, y, z, player.motion.velocity, ArchetypeLibrary.PLAYER_BLAST);
			
			//trigger camera shake
			player.player.shakeCounter = GameSettings.playerCountShake;
		}
	}
}
