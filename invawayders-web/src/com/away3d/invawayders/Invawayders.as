package com.away3d.invawayders
{
	import com.away3d.invawayders.nodes.GameNode;
	import com.away3d.invawayders.nodes.PlayerNode;
	import away3d.materials.lightpickers.StaticLightPicker;
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.input.*;
	import com.away3d.invawayders.sounds.*;
	import com.away3d.invawayders.systems.*;
	import com.away3d.invawayders.utils.*;
	
	import away3d.containers.*;
	
	import net.richardlord.ash.core.*;
	import net.richardlord.ash.integration.swiftsuspenders.*;
	import net.richardlord.ash.tick.*;
	import net.richardlord.signals.*;
	
	import org.swiftsuspenders.*;
	
	import flash.geom.*;
	
	public class Invawayders
	{
		private var view : View3D;
		private var soundLibrary : SoundLibrary;
		private var accelerometerPoll : AccelerometerPoll;
		private var injector : Injector;
		private var game : Game;
		
		private var gameManager : GameManager;
		
		private var entityCreator : EntityManager;
		
		private var tickProvider : FrameTickProvider;
		
		/**
		 * A signal that is dispatched whenever the game state is updated
		 */
		public var gameStateUpdated : Signal1 = new Signal1( GameState );
		
		public function Invawayders( view : View3D, saveStateManager : SaveStateManager, cameraLightPicker : StaticLightPicker, lightPicker : StaticLightPicker, stageProperties : StageProperties )
		{
			this.view = view;
			
			//setup the sound library
			soundLibrary = SoundLibrary.getInstance();
			
			//setup accelerometer poll
			accelerometerPoll = new AccelerometerPoll();
			
			//setup injector for game
			injector = new Injector();
			game = new SwiftSuspendersGame( injector );
			
			//establish injector maps
			injector.map( Game ).toValue( game );
			injector.map( View3D ).toValue( view );
			injector.map( StaticLightPicker, "cameraLightPicker" ).toValue( cameraLightPicker );
			injector.map( StaticLightPicker, "lightPicker" ).toValue( lightPicker );
			injector.map( SaveStateManager ).toValue( saveStateManager );
			injector.map( StageProperties ).toValue( stageProperties );
			injector.map( SoundLibrary ).toValue( soundLibrary );
			injector.map( EntityManager ).asSingleton();
			injector.map( KeyPoll ).toValue( new KeyPoll( view.stage ) );
			injector.map( MousePoll ).toValue( new MousePoll( view ) );
			injector.map( AccelerometerPoll ).toValue( accelerometerPoll );
			injector.map( Signal1 ).toValue( gameStateUpdated );
			
			//create game manager system
			gameManager = new GameManager();
			
			//add game systems
			game.addSystem( gameManager, SystemPriorities.manager );
			game.addSystem( new AnimationSystem(), SystemPriorities.animations );
			game.addSystem( new PlayerControlSystem(), SystemPriorities.control );
			game.addSystem( new MovementSystem(), SystemPriorities.move );
			game.addSystem( new CollisionSystem(), SystemPriorities.collisions );
			game.addSystem( new SoundSystem(), SystemPriorities.sounds );
			game.addSystem( new RenderSystem(), SystemPriorities.render );
			
			//create entity creator
			entityCreator = injector.getInstance( EntityManager );
			
			//setup the tick provider
			tickProvider = new FrameTickProvider( view );
			tickProvider.add( game.update );
			
			//upload all archetypes content to the gpu
			
			var archetype:ArchetypeBase;
			var subType:ArchetypeBase;
			var entity : Entity;
			for each (archetype in ArchetypeLibrary.archetypes) {
				if (archetype.subTypes.length) {
					for each (subType in archetype.subTypes)
						entity = entityCreator.createEntity(0, 0, 0, new Vector3D(), archetype.id, subType? subType.id : 0);
				} else {
					entity = entityCreator.createEntity(0, 0, 0, new Vector3D(), archetype.id);
				}
			}
		}
		
		/**
		 * Restarts the game. Called by the play button or restart button
		 */
		public function restart():void
		{
			// Reset all game entities
			var entity : Entity;
			for each (entity in game.entities)
				entityCreator.destroyEntity(entity);
			
			//create a new game
			entityCreator.createGame();
			
			//resume play
			resume();
		}
		
		/**
		 * Halts the game logic. Called by the pause button or when the player's lives decrease to zero
		 */
		public function pause():void
		{
			//play sound
			soundLibrary.playSound( SoundLibrary.UFO, 0.5 );
			
			//remove player node
			entityCreator.destroyEntity(game.getNodeList(PlayerNode).head.entity);
			
			tickProvider.stop();
		}
		
		/**
		 * Resumes the game. Called on game start or by the resume button.
		 */
		public function resume():void
		{
			//play sound
			soundLibrary.playSound( SoundLibrary.UFO, 0.5 );
			
			//reset accelerometer center
			accelerometerPoll.centerY = accelerometerPoll.accelerometerY;
			
			//reset spawn times
			var id : uint;
			var invawayderArchetype : InvawayderArchetype;
			for each (id in InvawayderArchetype.invawayders) {
				invawayderArchetype = ArchetypeLibrary.getArchetype(ArchetypeLibrary.INVAWAYDER).getSubType(id) as InvawayderArchetype;
				invawayderArchetype.spawnTimer = invawayderArchetype.spawnRate * gameManager.games.head.state.spawnTimeFactor * MathUtils.rand( 0.9, 1.1 );
			}
			
			entityCreator.createEntity(0, 0, -1000, new Vector3D(), ArchetypeLibrary.PLAYER);
			
			tickProvider.start();
		}
		
		
		/**
		 * Ends the game. Called on game over.
		 */
		public function end():void
		{
			//remove game
			entityCreator.destroyEntity(game.getNodeList(GameNode).head.entity);
			
			//remove player node
			entityCreator.destroyEntity(game.getNodeList(PlayerNode).head.entity);
		}
	}
}
