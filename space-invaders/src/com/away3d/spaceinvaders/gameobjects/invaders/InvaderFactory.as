package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;

	import com.away3d.spaceinvaders.GameSettings;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	public class InvaderFactory
	{
		private var _invaders:Dictionary;
		private var _invaderMaterial:MaterialBase;
		private var _definitions:InvaderDefinitions;

		public function InvaderFactory( invaderMaterial:MaterialBase ) {
			_invaderMaterial = invaderMaterial;
			_definitions = new InvaderDefinitions();
			_invaders = new Dictionary();
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
			var invader:Invader = _invaders[ typeIndex ];
			if( !invader ) {
				var definition:Array = _definitions.getDefinitionForInvaderType( typeIndex );
				var dimensions:Point = _definitions.getDefinitionDimensionsForInvaderType( typeIndex );
				var definitionFrame0:Array = definition[ 0 ];
				var definitionFrame1:Array = definition[ 1 ];
				var invaderGeometry0:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definitionFrame0, dimensions );
				var invaderGeometry1:Geometry = new InvaderGeometry( GameSettings.invaderSizeXY, GameSettings.invaderSizeZ, definitionFrame1, dimensions );
				var meshFrame0:Mesh = new Mesh( invaderGeometry0, _invaderMaterial );
				var meshFrame1:Mesh = new Mesh( invaderGeometry1, _invaderMaterial );
				var cellsFrame0:Vector.<Point> = createInvaderCells( definition[ 0 ], dimensions );
				var cellsFrame1:Vector.<Point> = createInvaderCells( definition[ 1 ], dimensions );
				invader = new Invader( typeIndex, meshFrame0, meshFrame1, cellsFrame0, cellsFrame1 );
			}
			else {
				invader = invader.getInvaderClone();
			}
			return invader;
		}
	}
}
