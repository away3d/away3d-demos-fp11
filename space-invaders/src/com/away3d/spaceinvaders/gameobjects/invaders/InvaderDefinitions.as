package com.away3d.spaceinvaders.gameobjects.invaders
{

	import flash.geom.Point;

	public class InvaderDefinitions
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

		public function getDefinitionForInvaderType( type:uint ):Array {
			return _invadersDefinitions[ type ];
		}

		public function getDefinitionDimensionsForInvaderType( type:uint ):Point {
			return _invaderDefinitionDimensions[ type ];
		}

		public function get numDefinitions():uint {
			return _invadersDefinitions.length;
		}
	}
}
