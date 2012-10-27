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

		public function createEntity( x : Number, y : Number, z : Number, velocity : Vector3D, archetypeId:uint, subTypeId:uint = 0 ) : Entity
		{
			var archetype : ArchetypeBase = ArchetypeLibrary.getArchetype(archetypeId);
			var subType : ArchetypeBase = archetype.getSubType(subTypeId);
			var entity : Entity;
			var transform : Transform3D;
			var motion : Motion3D;
			
			//return if entity exists in pool.
			if (subType.entityPool.length) {
				entity = subType.entityPool.pop();
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
				.add( new DataModel(archetype, subType) );
			
			game.addEntity( entity );
			
			var material : MaterialBase = subType.material;
			var entityView:ObjectContainer3D;
			
			switch(subType.Component)
			{
				case Invawayder:
				
					var meshFrame0:Mesh;
					var meshFrame1:Mesh;
					var invawayderArchetype:InvawayderArchetype = subType as InvawayderArchetype;
					
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
					
					var leftBlaster : Mesh = new Mesh( subType.geometry, material );
					var rightBlaster : Mesh = leftBlaster.clone() as Mesh;
					entityView = subType.entityView = new PlayerView(leftBlaster, rightBlaster);
					
					leftBlaster.position = new Vector3D( -GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
					rightBlaster.position = new Vector3D( GameSettings.blasterOffsetH, GameSettings.blasterOffsetV, GameSettings.blasterOffsetD );
					
					entity.add( new Player( view.camera, leftBlaster, rightBlaster ) );
					break;
				
				case Explosion:
					
					var explosionArchetype:ExplosionArchetype = subType as ExplosionArchetype;
					var cellPositions:Vector.<Vector.<Point>> = (ArchetypeLibrary.getArchetype(ArchetypeLibrary.INVAWAYDER).getSubType(subType.id) as InvawayderArchetype).cellPositions;
					var cellContainers:Vector.<ObjectContainer3D>;
					var cellVelocities : Vector.<Vector.<Vector3D>>;
					var cellRotationalVelocities : Vector.<Vector.<Vector3D>>;
					var cellDeathTimers : Vector.<Vector.<uint>>;
					var cellContainer:ObjectContainer3D;
					
					if (explosionArchetype.entityView) {
						entityView = new ObjectContainer3D();
						cellContainers = new Vector.<ObjectContainer3D>();
						cellVelocities = new Vector.<Vector.<Vector3D>>();
						cellRotationalVelocities = new Vector.<Vector.<Vector3D>>();
						cellDeathTimers = new Vector.<Vector.<uint>>();
						for each (cellContainer in explosionArchetype.cellContainers) {
							cellContainer = cellContainer.clone() as ObjectContainer3D;
							cellContainers.push(cellContainer);
							cellVelocities.push(new Vector.<Vector3D>(cellContainer.numChildren));
							cellRotationalVelocities.push(new Vector.<Vector3D>(cellContainer.numChildren));
							cellDeathTimers.push(new Vector.<uint>(cellContainer.numChildren));
							entityView.addChild(cellContainer);
						}
					} else {
						material.lightPicker = cameraLightPicker;
						
						entityView = explosionArchetype.entityView = new ObjectContainer3D();
						
						cellContainers = explosionArchetype.cellContainers = new Vector.<ObjectContainer3D>();
						cellVelocities = new Vector.<Vector.<Vector3D>>();
						cellRotationalVelocities = new Vector.<Vector.<Vector3D>>();
						cellDeathTimers = new Vector.<Vector.<uint>>();
						
						var frame:Vector.<Point>;
						var position:Point;
						for each (frame in cellPositions) {
							cellContainer = new ObjectContainer3D();
							for each (position in frame) {
								cellContainer.addChild(new Mesh( subType.geometry, material ));
							}
							cellContainers.push(cellContainer);
							cellVelocities.push(new Vector.<Vector3D>(cellContainer.numChildren));
							cellRotationalVelocities.push(new Vector.<Vector3D>(cellContainer.numChildren));
							cellDeathTimers.push(new Vector.<uint>(cellContainer.numChildren));
							entityView.addChild(cellContainer);
						}
					}
					
					//passes the cellposition data from invawayder to explosion archetype
					entity.add( new Explosion(cellContainers, cellVelocities, cellRotationalVelocities, cellDeathTimers) );
					break;
					
				default:
					
					if (subType.entityView)
						entityView = subType.entityView.clone() as ObjectContainer3D;
					else
						entityView = subType.entityView = new Mesh(subType.geometry, material);
					
					if (subType.Component != Blast)
						material.lightPicker = lightPicker;
					
					var Component:Class = subType.Component;
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
				(entity.get(DataModel) as DataModel).subType.entityPool.push(entity);
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
