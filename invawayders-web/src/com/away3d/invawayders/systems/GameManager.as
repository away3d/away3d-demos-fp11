package com.away3d.invawayders.systems
{
	import com.away3d.invawayders.*;
	import com.away3d.invawayders.archetypes.*;
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
		[Inject(nodeType="com.away3d.invawayders.nodes.InvawayderNode")]
		public var invawayders : NodeList;
		
		[PostConstruct]
		public function setUpListeners() : void
		{
			games.nodeAdded.add( addToGames );
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
			var id : uint;
			
			//update game loop
			for ( game = games.head; game; game = game.next )
			{
				//determine if enough time has passed to spawn another invawayder
				for each (id in InvawayderArchetype.invawayders) {
					var invawayderArchetype : InvawayderArchetype = ArchetypeLibrary.getArchetype(ArchetypeLibrary.INVAWAYDER).getSubType(id) as InvawayderArchetype;
					invawayderArchetype.spawnTimer -= time;
					if( invawayderArchetype.spawnTimer < 0 ) {
						
						creator.createEntity( MathUtils.rand(-GameSettings.xyRange, GameSettings.xyRange ), MathUtils.rand( -GameSettings.xyRange, GameSettings.xyRange), GameSettings.maxZ, new Vector3D(0, 0, MathUtils.rand( -2500, -1500 )), ArchetypeLibrary.INVAWAYDER, id );

						invawayderArchetype.spawnTimer = invawayderArchetype.spawnRate * game.state.spawnTimeFactor * MathUtils.rand( 0.9, 1.1 );
					}
				}
			}
		}	
	}
}
