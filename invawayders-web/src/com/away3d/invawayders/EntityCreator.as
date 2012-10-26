package com.away3d.invawayders
{
	import com.away3d.invawayders.archetypes.*;
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.graphics.*;
	import com.away3d.invawayders.primitives.*;
	
	import away3d.containers.*;
	import away3d.entities.Mesh;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;

	import net.richardlord.ash.core.*;
	
	import flash.geom.*;
	
	
	public class EntityCreator
	{
		[Inject]
		public var game : Game;
		
		[Inject]
		public var view : View3D;
		
		[Inject(name="lightPicker")]
		public var lightPicker : StaticLightPicker;
		
		[Inject(name="cameraLightPicker")]
		public var cameraLightPicker : StaticLightPicker;
		
		public function EntityCreator()
		{
		}
		
		public function createGame() : Entity
		{
			var gameEntity : Entity = new Entity()
				.add( new GameState() );
			game.addEntity( gameEntity );
			return gameEntity;
		}

		public function createEntity( x : Number, y : Number, z : Number, velocity : Vector3D, archetypeId:uint ) : Entity
		{
			var archetype : ArchetypeBase = ArchetypeLibrary.getArchetype(archetypeId);
			var entity : Entity;
			var transform : Transform3D;
			var motion : Motion3D;
			
			//return if entity exists in pool.
			if (archetype.entityPool.length) {
				entity = archetype.entityPool.pop();
				transform = entity.get(Transform3D) as Transform3D;
				transform.x = x;
				transform.y = y;
				transform.z = z;
				motion = entity.get(Motion3D) as Motion3D;
				motion.velocity = velocity;
				game.addEntity( entity );
				return entity;
			}
			
			//create new entity
			entity = new Entity()
				.add( new Transform3D(x, y, z) )
				.add( new Motion3D(velocity) )
				.add( new DataModel(archetype) );
			
			game.addEntity( entity );
			
			var material : MaterialBase = archetype.material;
			
			switch(archetype.Component)
			{
				case Invawayder:
				
					var meshFrame0:Mesh;
					var meshFrame1:Mesh;
					var entityView:ObjectContainer3D;
					var invawayderArchetype:InvawayderArchetype = archetype as InvawayderArchetype;
					
					//if invawayder view exists, create a clone from the mesh frames
					if (invawayderArchetype.entityView) {
						meshFrame0 = invawayderArchetype.meshFrame0.clone() as Mesh;
						meshFrame1 = invawayderArchetype.meshFrame1.clone() as Mesh;
						entityView = new InvawayderView(meshFrame0, meshFrame1);
					} else {
						//grab invawayder dimensions data
						var dimensions:Point = invawayderArchetype.dimensions;
						
						//grab invawayder cell definition data
						var definitionFrame0:Vector.<uint> = invawayderArchetype.cellDefinitions[ 0 ];
						var definitionFrame1:Vector.<uint> = invawayderArchetype.cellDefinitions[ 1 ];
						
						//define cell positions for invawayder data
						invawayderArchetype.cellPositions = Vector.<Vector.<Point>>([createInvawayderCellPositions( definitionFrame0, dimensions ), createInvawayderCellPositions( definitionFrame1, dimensions )]);
						
						material.lightPicker = lightPicker;
						
						//define mesh objects frames for invawayder entity
						meshFrame0 = invawayderArchetype.meshFrame0 = new Mesh( new InvawayderGeometry( GameSettings.invawayderSizeXY, GameSettings.invawayderSizeZ, definitionFrame0, dimensions ), material );
						meshFrame1 = invawayderArchetype.meshFrame1 = new Mesh( new InvawayderGeometry( GameSettings.invawayderSizeXY, GameSettings.invawayderSizeZ, definitionFrame1, dimensions ), material );
						entityView = invawayderArchetype.entityView = new InvawayderView(meshFrame0, meshFrame1);
					}
					
					entity.add( new Invawayder( meshFrame0, meshFrame1 ) );
					break;
					
				case Player:
					
					material.lightPicker = cameraLightPicker;
					
					var leftBlaster : Mesh = new Mesh( archetype.geometry, material );
					var rightBlaster : Mesh = leftBlaster.clone() as Mesh;
					entityView = archetype.entityView = new PlayerView(leftBlaster, rightBlaster);
					
					leftBlaster.position = new Vector3D( -GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
					rightBlaster.position = new Vector3D( GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
					
					entity.add( new Player( view.camera, leftBlaster, rightBlaster ) );
					break;
					
				default:
					
					if (archetype.entityView)
						entityView = archetype.entityView.clone() as ObjectContainer3D;
					else
						entityView = archetype.entityView = new Mesh(archetype.geometry, material);
					
					if (archetype.Component != Blast)
						material.lightPicker = lightPicker;
					
					var Component:Class = archetype.Component;
					entity.add( new Component() );
					break;
			}
			
			entity.add( new Display( entityView ) );
			
			return entity;
		}
		
		public function destroyEntity( entity : Entity ) : void
		{
			game.removeEntity( entity );
			
			//push entity into entity pool for archetype
			if (entity.get(DataModel))
				(entity.get(DataModel) as DataModel).archetype.entityPool.push(entity);
		}
				
		/**
		 * Internal function used to create cell position data for each invawayder data instance's cell definition data.
		 * 
		 * @param definition The vector of unsigned integers representing the cell definition of the invawayder to be processed.
		 * @param gridDimensions A point vector representing the 2D width and height of the invawayder's cell definition.
		 * 
		 * @return A vector of point data representing the cell positions of the invawayder data.
		 */
		private function createInvawayderCellPositions( definition:Vector.<uint>, gridDimensions:Point ):Vector.<Point>
		{
			var cellPositions:Vector.<Point> = new Vector.<Point>();
			
			var i:uint, j:uint;
			var cellSize:Number = GameSettings.invawayderSizeXY;
			var lenX:uint = gridDimensions.x;
			var lenY:uint = gridDimensions.y;
			var offX:Number = -( lenX - 1 ) * cellSize / 2;
			var offY:Number = (lenY - 1 ) * cellSize / 2;
			
			for( j = 0; j < lenY; j++ )
				for( i = 0; i < lenX; i++ )
					if( definition[ j * lenX + i ] )
						cellPositions.push( new Point( offX + i * cellSize, offY - j * cellSize ) );
			
			return cellPositions;
		}
	}
}
