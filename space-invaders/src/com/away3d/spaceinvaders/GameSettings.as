package com.away3d.spaceinvaders
{

	import flash.geom.Point;

	public class GameSettings
	{
		// General.
		public static const debugMode:Boolean = false;

		// Scene.
		public static const xyRange:Number = 1000;

		// Projectiles.
		public static const projectilesDieOnImpact:Boolean = true;

		// Level progress.
		public static const killsToAdvanceDifficulty:uint = 10;
		public static const minimumSpawnTime:Number = 0.25;
		public static const spawnTimeDecreasePerLevel:Number = 0.1;

		// Invaders.
		public static const invaderSizeXY:Number = 25;
		public static const invaderSizeZ:Number = 100;
		public static const deathExplosionIntensity:Number = 2;
		public static const invaderFireRateMS:Number = 4000;

		// Player.
		public static const useAccelerometer:Boolean = false;
		public static const accelerometerMotionFactorX:Number = 2;
		public static const accelerometerMotionFactorY:Number = 4;
		public static const accelerometerCenterY:Number = 0.7;
		public static const touchMotionFactor:Number = 4;
		public static const cameraPanRange:Number = 1500;
		public static const mouseCameraMotionEase:Number = 0.25;
		public static const accelerometerCameraMotionEase:Number = 0.1;
		public static const touchCameraMotionEase:Number = 0.25;
		public static const playerHitShake:Number = 100;
	}
}
