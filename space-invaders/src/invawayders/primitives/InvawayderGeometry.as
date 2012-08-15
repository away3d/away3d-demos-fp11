package invawayders.primitives
{
	import away3d.core.base.*;
	import away3d.primitives.*;
	
	import flash.geom.*;
	
	public class InvawayderGeometry extends PrimitiveBase
	{
		private var _definitionMatrix:Vector.<uint>;
		private var _gridDimensions:Point;
		private var _cellSizeXY:Number;
		private var _cellSizeZ:Number;
		
		private var _rawVertices:Vector.<Number>;
		private var _rawNormals:Vector.<Number>;
		private var _rawTangents:Vector.<Number>;
		private var _rawIndices:Vector.<uint>;
		private var _rawUvs:Vector.<Number>;
		private var _currentIndex:uint;
		
		public function InvawayderGeometry( cellSizeXY:Number, cellSizeZ:Number, definitionMatrix:Vector.<uint>, gridDimensions:Point )
		{
			super();
			_cellSizeXY = cellSizeXY;
			_cellSizeZ = cellSizeZ;
			_definitionMatrix = definitionMatrix;
			_gridDimensions = gridDimensions;
		}
		
		protected override function buildGeometry( target:SubGeometry ):void
		{

			_rawVertices = new Vector.<Number>();
			_rawNormals = new Vector.<Number>();
			_rawTangents = new Vector.<Number>();
			_rawUvs = new Vector.<Number>();
			_rawIndices = new Vector.<uint>();
			_currentIndex = 0;
			
			var i:uint, j:uint;
			var posX:Number, posY:Number;
			var offX:Number, offY:Number;
			var p0:Vector3D, p1:Vector3D, p2:Vector3D, p3:Vector3D, p4:Vector3D, p5:Vector3D, p6:Vector3D, p7:Vector3D;
			
			var lenX:uint = _gridDimensions.x;
			var lenY:uint = _gridDimensions.y;
			offX = _cellSizeXY / 2 - ( lenX / 2 ) * _cellSizeXY;
			offY = -_cellSizeXY / 2 + ( lenY / 2 ) * _cellSizeXY;
			var halfCellSizeXY:Number = _cellSizeXY / 2;
			var halfCellSizeZ:Number = _cellSizeZ / 2;
			
			for( j = 0; j < lenY; j++ ) {
				for( i = 0; i < lenX; i++ ) {
					if( isCellActiveAtCoordinates( i, j ) == 1 ) {
						var neighbors:Vector3D = areNeighborsActiveAtCoordinates( i, j );
						posX = offX + i * _cellSizeXY;
						posY = offY - j * _cellSizeXY;
						p0 = new Vector3D( posX - halfCellSizeXY, posY + halfCellSizeXY, -halfCellSizeZ );
						p1 = new Vector3D( posX + halfCellSizeXY, posY + halfCellSizeXY, -halfCellSizeZ );
						p2 = new Vector3D( posX - halfCellSizeXY, posY - halfCellSizeXY, -halfCellSizeZ );
						p3 = new Vector3D( posX + halfCellSizeXY, posY - halfCellSizeXY, -halfCellSizeZ );
						p4 = new Vector3D( posX - halfCellSizeXY, posY + halfCellSizeXY,  halfCellSizeZ );
						p5 = new Vector3D( posX + halfCellSizeXY, posY + halfCellSizeXY,  halfCellSizeZ );
						p6 = new Vector3D( posX - halfCellSizeXY, posY - halfCellSizeXY,  halfCellSizeZ );
						p7 = new Vector3D( posX + halfCellSizeXY, posY - halfCellSizeXY,  halfCellSizeZ );
						if( neighbors.x == 0 ) { // LEFT
							addFace(
								p4, p0, p6, p2,
								new Vector3D( -1, 0, 0 )
							);
						}
						if( neighbors.y == 0 ) { // RIGHT
							addFace(
								p1, p5, p3, p7,
								new Vector3D( 1, 0, 0 )
							);
						}
						if( neighbors.z == 0 ) { // TOP
							addFace(
								p1, p0, p5, p4,
								new Vector3D( -1, 0, 0 )
							);
						}
						if( neighbors.w == 0 ) { // BOTTOM
							addFace(
								p7, p6, p3, p2,
								new Vector3D( -1, 0, 0 )
							);
						}
						// FRONT (always).
						addFace(
							p0, p1, p2, p3,
							new Vector3D( 0, 0, -1 )
						);
						// BACK (never).
					}
				}
			}
			
			// Report geom data.
	        target.updateVertexData(        _rawVertices );
	        target.updateVertexNormalData(  _rawNormals );
			target.updateVertexTangentData( _rawTangents );
			target.updateUVData(            _rawUvs );
			target.updateIndexData(         _rawIndices);
			_rawVertices = null;
			_rawNormals  = null;
			_rawIndices  = null;
			_rawTangents = null;
			_rawUvs      = null;
		}
		
		private function addFace( p0:Vector3D, p1:Vector3D, p2:Vector3D, p3:Vector3D, normal:Vector3D ):void
		{
			_rawVertices.push( p0.x, p0.y, p0.z );
			_rawVertices.push( p1.x, p1.y, p1.z );
			_rawVertices.push( p2.x, p2.y, p2.z );
			_rawVertices.push( p3.x, p3.y, p3.z );
			_rawNormals.push( normal.x, normal.y, normal.z );
			_rawNormals.push( normal.x, normal.y, normal.z );
			_rawNormals.push( normal.x, normal.y, normal.z );
			_rawNormals.push( normal.x, normal.y, normal.z );
			_rawTangents.push( 0, 0, 0 ); // Ignoring tangents ( ok as long as color materials are used ).
			_rawTangents.push( 0, 0, 0 );
			_rawTangents.push( 0, 0, 0 );
			_rawTangents.push( 0, 0, 0 );
			_rawUvs.push( 0, 0, 0 ); // Ignoring UVs ( ok as long as color materials are used ).
			_rawUvs.push( 0, 0, 0 );
			_rawUvs.push( 0, 0, 0 );
			_rawUvs.push( 0, 0, 0 );
			_rawIndices.push( _currentIndex + 0, _currentIndex + 1, _currentIndex + 2 );
			_rawIndices.push( _currentIndex + 1, _currentIndex + 3, _currentIndex + 2 );
			_currentIndex += 4;
		}
		
		/*
			Replied Vector3D represents the following:
				  z
				x n y
				  w
			with n being the cell at the current coordinates
			and each x, y, z, w value being 1 if the neighbor is active or 0 otherwise.
		 */
		private function areNeighborsActiveAtCoordinates( i:uint, j:uint ):Vector3D
		{
			var reply:Vector3D = new Vector3D();
			reply.x = i == 					   0 ? 0 : isCellActiveAtCoordinates( i - 1, j     );
			reply.y = i == _gridDimensions.x - 1 ? 0 : isCellActiveAtCoordinates( i + 1, j     );
			reply.z = j == 					   0 ? 0 : isCellActiveAtCoordinates( i,     j - 1 );
			reply.w = j == _gridDimensions.y - 1 ? 0 : isCellActiveAtCoordinates( i,     j + 1 );
			return reply;
		}
		
		private function isCellActiveAtCoordinates( i:uint, j:uint ):uint
		{
			var cellIndex:uint = j * _gridDimensions.x + i;
			return _definitionMatrix[ cellIndex ];
		}
		
		override protected function buildUVs( target:SubGeometry ) : void
		{
			target.updateUVData( _rawUvs );
		}
	}
}