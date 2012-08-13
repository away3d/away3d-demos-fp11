package invaders.gameobjects.invaders
{

	import flash.geom.Point;

	public class InvaderDefinitions
	{
		public static const ROUNDED_OCTOPUS_INVADER:uint = 2;
		public static const BUG_INVADER:uint = 0;
		public static const OCTOPUS_INVADER:uint = 1;
		public static const MOTHERSHIP:uint = 3;

		// Invader 1.
		private static const _invaderDefinition0:Array = [
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
		private static const _invaderDefinitionDimensions0:Point = new Point( 11, 8 );

		// Invader 2.
		private static const _invaderDefinition1:Array = [
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
		private static const _invaderDefinitionDimensions1:Point = new Point( 8, 8 );

		// Invader 3.
		private static const _invaderDefinition2:Array = [
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
		private static const _invaderDefinitionDimensions2:Point = new Point( 12, 8 );

		// Invader 4.
		private static const _invaderDefinition3:Array = [
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
		private static const _invaderDefinitionDimensions3:Point = new Point( 16, 7 );

		private static const _invadersDefinitions:Array = [
			_invaderDefinition0,
			_invaderDefinition1,
			_invaderDefinition2,
			_invaderDefinition3
		];

		private static const _invaderDefinitionDimensions:Array = [
			_invaderDefinitionDimensions0,
			_invaderDefinitionDimensions1,
			_invaderDefinitionDimensions2,
			_invaderDefinitionDimensions3
		];

		public static function getLifeForInvaderType( type:uint ):uint {
			switch( type ) {
				case MOTHERSHIP:
					return 20;
				case OCTOPUS_INVADER:
					return 1;
				case BUG_INVADER:
					return 2;
				case ROUNDED_OCTOPUS_INVADER:
					return 4;
			}
			return 0;
		}

		public static function getSpawnRateMSForInvaderType( type:uint ):uint {
			switch( type ) {
				case MOTHERSHIP:
					return 120000;
				case OCTOPUS_INVADER:
					return 20000;
				case BUG_INVADER:
					return 10000;
				case ROUNDED_OCTOPUS_INVADER:
					return 6000;
			}
			return 0;
		}

		public static function getFireRateMSForInvaderType( type:uint ):uint {
			switch( type ) {
				case MOTHERSHIP:
					return 200;
				case OCTOPUS_INVADER:
					return 1000;
				case BUG_INVADER:
					return 1500;
				case ROUNDED_OCTOPUS_INVADER:
					return 2000;
			}
			return 0;
		}

		public static function getPanAmplitudeForInvaderType( type:uint ):uint {
			switch( type ) {
				case MOTHERSHIP:
					return 0;
				case OCTOPUS_INVADER:
					return 500;
				case BUG_INVADER:
					return 250;
				case ROUNDED_OCTOPUS_INVADER:
					return 0;
			}
			return 0;
		}

		public static function getSpeedForInvaderType( type:uint ):uint {
			switch( type ) {
				case MOTHERSHIP:
					return 10;
				case OCTOPUS_INVADER:
					return 25;
				case BUG_INVADER:
					return 50;
				case ROUNDED_OCTOPUS_INVADER:
					return 100;
			}
			return 0;
		}

		public static function getScoreForInvaderType( type:uint ):uint {
			switch( type ) {
				case MOTHERSHIP:
					return 200;
				case OCTOPUS_INVADER:
					return 100;
				case BUG_INVADER:
					return 30;
				case ROUNDED_OCTOPUS_INVADER:
					return 10;
			}
			return 0;
		}

		public static function getDefinitionForInvaderType( type:uint ):Array {
			return _invadersDefinitions[ type ];
		}

		public static function getDefinitionDimensionsForInvaderType( type:uint ):Point {
			return _invaderDefinitionDimensions[ type ];
		}
	}
}
