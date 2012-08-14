package 
{
	public class GameSettings
	{
		// -----------------------
		// Settings
		// -----------------------

		// General.
		public static const debugMode:Boolean = false; // Shows stats
		public static const useSound:Boolean = true;

		// Scene.
		public static const xyRange:Number = 1000;

		// Level progress.
		public static const killsToAdvanceDifficulty:uint = 10;
		public static const minimumSpawnTime:Number = 0.25;
		public static const spawnTimeDecreasePerLevel:Number = 0.1;

		// Invaders.
		public static const invaderSizeXY:Number = 50;
		public static const invaderSizeZ:Number = 200;
		public static const deathExplosionIntensity:Number = 3;
		public static const invaderAnimationTimeMS:uint = 250;
		public static const impactHitSize:Number = 300;

		// Player.
		public static const blasterOffsetH:Number = 100;
		public static const blasterOffsetV:Number = -100;
		public static const blasterOffsetD:Number = -1000;
		public static const blasterStrength:Number = 1;
		public static const blasterFireRateMS:Number = 50;
		public static const cameraPanRange:Number = 1750;
		public static const panTiltFactor:Number = 0;
		public static const playerHitShake:Number = 200;
		public static const playerLives:uint = 3;

		// Mouse control settings.
		public static const mouseCameraMotionEase:Number = 0.25;
		public static const mouseMotionFactor:Number = 3000;

		// Accelerometer control settings.
		public static const accelerometerCameraMotionEase:Number = 0.05;
		public static const accelerometerMotionFactorX:Number = 5;
		public static const accelerometerMotionFactorY:Number = 10;

		// Stars.
		public static const maxStarNum:uint = 250;
		public static const starSpawnProbability:Number = 0.5;

		// Scene range.
		public static const minZ:Number = -2000;
		public static const maxZ:Number = 50000;
	}
}
