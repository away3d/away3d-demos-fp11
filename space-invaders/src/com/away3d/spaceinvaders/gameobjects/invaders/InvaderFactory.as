package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;

	import com.away3d.spaceinvaders.GameSettings;

	import flash.geom.Point;

	public class InvaderFactory
	{
		public static const ROUNDED_OCTOPUS_INVADER:uint = 2;
		public static const BUG_INVADER:uint = 0;
		public static const OCTOPUS_INVADER:uint = 1;
		public static const MOTHERSHIP:uint = 3;

		// Invader 1.
		private const _invaderDefinition0:Array = [
			[
				0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,
				0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
				0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0,
				0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1,
				1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1,
				0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0
			],
			[
				0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,
				1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1,
				1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1,
				1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0,
				0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0
			]
		];
		private const _invaderDefinitionDimensions0:Point = new Point( 11, 8 );

		// Invader 2.
		private const _invaderDefinition1:Array = [
			[
				0, 0, 0, 1, 1, 0, 0, 0,
				0, 0, 1, 1, 1, 1, 0, 0,
				0, 1, 1, 1, 1, 1, 1, 0,
				1, 1, 0, 1, 1, 0, 1, 1,
				1, 1, 1, 1, 1, 1, 1, 1,
				0, 0, 1, 0, 0, 1, 0, 0,
				0, 1, 0, 1, 1, 0, 1, 0,
				1, 0, 1, 0, 0, 1, 0, 1
			],
			[
				0, 0, 0, 1, 1, 0, 0, 0,
				0, 0, 1, 1, 1, 1, 0, 0,
				0, 1, 1, 1, 1, 1, 1, 0,
				1, 1, 0, 1, 1, 0, 1, 1,
				1, 1, 1, 1, 1, 1, 1, 1,
				0, 0, 1, 0, 0, 1, 0, 0,
				0, 1, 0, 0, 0, 0, 1, 0,
				0, 0, 1, 0, 0, 1, 0, 0
			]
		];
		private const _invaderDefinitionDimensions1:Point = new Point( 8, 8 );

		// Invader 3.
		private const _invaderDefinition2:Array = [
			[
				0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
				0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0,
				0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0,
				1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
			],
			[
				0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0,
				0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0,
				0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 0,
				0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0
			]
		];
		private const _invaderDefinitionDimensions2:Point = new Point( 12, 8 );

		// Invader 4.
		private const _invaderDefinition3:Array = [
			[
				0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
				0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
				0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
				0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 0, 0,
				0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
			],
			[
				0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
				0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,
				0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
				0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0,
				1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
				0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0,
				0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0
			]
		];
		private const _invaderDefinitionDimensions3:Point = new Point( 16, 7 );

		private const _invadersDefinitions:Array = [
			_invaderDefinition0,
			_invaderDefinition1,
			_invaderDefinition2,
			_invaderDefinition3
		];
		private const _invaderDefinitionDimensions:Array = [
			_invaderDefinitionDimensions0,
			_invaderDefinitionDimensions1,
			_invaderDefinitionDimensions2,
			_invaderDefinitionDimensions3
		];

		private var _invaderVOs:Vector.<InvaderVO>;

		public function InvaderFactory( invaderMaterial:MaterialBase ) {

			// Create value objects that each invader type.
			_invaderVOs = new Vector.<InvaderVO>();
			for( var i:uint; i < _invadersDefinitions.length; ++i ) {
				var invaderVO:InvaderVO = new InvaderVO();
				invaderVO.typeIndex = i;
				var definition:Array = _invadersDefinitions[ i ];
				invaderVO.definitionFrame0 = definition[ 0 ];
				invaderVO.definitionFrame1 = definition[ 1 ];
				var invaderGeometry0:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definition[ 0 ], _invaderDefinitionDimensions[ i ] );
				var invaderGeometry1:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definition[ 1 ], _invaderDefinitionDimensions[ i ] );
				invaderVO.meshFrame0 = new Mesh( invaderGeometry0, invaderMaterial );
				invaderVO.meshFrame1 = new Mesh( invaderGeometry1, invaderMaterial );
				invaderVO.cellsFrame0 = createInvaderCells( definition[ 0 ], _invaderDefinitionDimensions[ i ] );
				invaderVO.cellsFrame1 = createInvaderCells( definition[ 1 ], _invaderDefinitionDimensions[ i ] );
				_invaderVOs.push( invaderVO );
			}

		}

		private function createInvaderCells( definition:Array, gridDimensions:Point ):Vector.<Point> {

			var positions:Vector.<Point> = new Vector.<Point>();

			var i:uint, j:uint;
			var cellIndex:uint;
			var cellSize:Number;
			var lenX:uint, lenY:uint;
			var posX:Number, posY:Number;
			var offX:Number, offY:Number;

			cellSize = GameSettings.invaderSizeXY;
			lenX = gridDimensions.x;
			lenY = gridDimensions.y;
			offX = cellSize / 2 - ( lenX / 2 ) * cellSize;
			offY = -cellSize / 2 + ( lenY / 2 ) * cellSize;

			for( j = 0; j < lenY; j++ ) {
				for( i = 0; i < lenX; i++ ) {
					cellIndex = j * lenX + i;
					if( definition[ cellIndex ] == 1 ) {
						posX = offX + i * cellSize;
						posY = offY - j * cellSize;
						positions.push( new Point( posX, posY ) );
					}
				}
			}

			return positions;
		}

		public function createInvaderOfType( typeIndex:uint ):Invader {
			var invaderVO:InvaderVO = _invaderVOs[ typeIndex ];
			return new Invader( invaderVO );
		}
	}
}
