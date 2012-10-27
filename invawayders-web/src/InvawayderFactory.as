package 
{
	import away3d.core.base.CompactSubGeometry;
	import away3d.core.base.Geometry;
	import away3d.core.base.IMaterialOwner;
	import away3d.core.base.IRenderable;
	import away3d.core.base.ISubGeometry;
	import away3d.core.base.Object3D;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.base.SubGeometry;
	import away3d.core.base.SubGeometryBase;
	import away3d.core.base.SubMesh;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.entities.Sprite3D;
	import away3d.entities.TextureProjector;
	import away3d.materials.ColorMaterial;
	import away3d.materials.ColorMultiPassMaterial;
	import away3d.materials.LightSources;
	import away3d.materials.MaterialBase;
	import away3d.materials.MultiPassMaterialBase;
	import away3d.materials.SegmentMaterial;
	import away3d.materials.SinglePassMaterialBase;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.TextureMultiPassMaterial;
	import com.away3d.invawayders.archetypes.ArchetypeBase;
	import com.away3d.invawayders.archetypes.BugInvawayderArchetype;
	import com.away3d.invawayders.archetypes.InvawayderArchetype;
	import com.away3d.invawayders.archetypes.ProjectileArchetype;
	import com.away3d.invawayders.archetypes.MothershipInvawayderArchetype;
	import com.away3d.invawayders.archetypes.PlayerProjectileArchetype;
	import com.away3d.invawayders.archetypes.RoundedOctopusInvawayderArchetype;
	import com.away3d.invawayders.objects.Blast;
	import com.away3d.invawayders.objects.GameObject;
	import com.away3d.invawayders.objects.Invawayder;
	import com.away3d.invawayders.objects.InvawayderCell;
	import com.away3d.invawayders.objects.Player;
	import com.away3d.invawayders.objects.Projectile;
	import com.away3d.invawayders.primitives.InvawayderGeometry;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	
	
	
	
	/**
	 * Singleton factory class for the creation of invawayder forms used throughout the game
	 */
	public class InvawayderFactory
	{
		//static instance variable
		private static var _instance:InvawayderFactory;
		
		//different invawayder types
		public static const BUG_INVAWAYDER:uint = 0;
		public static const OCTOPUS_INVAWAYDER:uint = 1;
		public static const ROUNDED_OCTOPUS_INVAWAYDER:uint = 2;
		public static const MOTHERSHIP_INVAWAYDER:uint = 3;
		
		//internal array of invawayder data instances, one for each type
		private var _invawayders:Vector.<InvawayderArchetype> = Vector.<InvawayderArchetype>([
			new BugInvawayderArchetype(),
			new OctopusInvawayderData(),
			new RoundedOctopusInvawayderArchetype(),
			new MothershipInvawayderArchetype()
		]);
		
		/**
		 * Returns an InvawayderFactory instance
		 */
		public static function getInstance():InvawayderFactory
		{
			if (_instance)
				return _instance;
			
			_instance = new InvawayderFactory();
			
			return _instance;
		}
		
		/**
		 * Returns an array of invawayder data instances, one for each type
		 */
		public function get invawayders():Vector.<InvawayderArchetype>
		{
			return _invawayders;
		}
		
		/**
		 * Returns an invawayder instance based on the given invawayder id and material instance.
		 * 
		 * @param id An unsigned integer representing the id of the invawayder whole instance is required.
		 * @param material An instance of the material obejct to be used for the invawayder instance.
		 * @return An instance of an invawayder object with type defined by the given invawayder id.
		 */
		public function getInvawayder( id:uint, material:MaterialBase ):Invawayder
		{
			var invawayderData:InvawayderArchetype = _invawayders[id];
			
			//if invawayder object already exists, create and return a clone
			if (invawayderData.invawayder)
				return invawayderData.invawayder.cloneGameObject() as Invawayder;
			
			//grab invawayder dimensions data
			var dimensions:Point = invawayderData.dimensions;
			
			//grab invawayder cell definition data
			var definitionFrame0:Vector.<uint> = invawayderData.cellDefinitions[ 0 ];
			var definitionFrame1:Vector.<uint> = invawayderData.cellDefinitions[ 1 ];
			
			//define mesh objects frames for invawayder data
			var meshFrame0:Mesh = new Mesh( new InvawayderGeometry( GameSettings.invawayderSizeXY, GameSettings.invawayderSizeZ, definitionFrame0, dimensions ), material );
			var meshFrame1:Mesh = new Mesh( new InvawayderGeometry( GameSettings.invawayderSizeXY, GameSettings.invawayderSizeZ, definitionFrame1, dimensions ), material );
			
			//define cell positions for invawayder data
			invawayderData.cellPositions = Vector.<Vector.<Point>>([createInvawayderCellPositions( definitionFrame0, dimensions ), createInvawayderCellPositions( definitionFrame1, dimensions )]);
			
			// create and return invawayder object
			return invawayderData.invawayder = new Invawayder( invawayderData, meshFrame0, meshFrame1 );
		}
		
		/**
		 * Utility function to reset the spawn times of all invawayder data in the factory.
		 * 
		 * @param time The time in milliseconds used to reset all existing spawn times.
		 */
		public function resetLastSpawnTimes(time:uint):void
		{
			var invawayderData:InvawayderArchetype;
			for each (invawayderData in _invawayders)
				invawayderData.spawnTimer = time;
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
