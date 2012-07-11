package com.away3d.spaceinvaders
{

	import flash.geom.Point;

	public class GameSettings
	{
		// -----------------------
		// Settings.
		// -----------------------

		// Scene.
		public static const xyRange:Number = 1000;

		// Level progress.
		public static const killsToAdvanceDifficulty:uint = 5;
		public static const invaderCountIncreasePerLevel:uint = 5;
		public static const initialSpawnTime:Number = 2;
		public static const minimumSpawnTime:Number = 0.25;
		public static const spawnTimeDecreasePerLevel:Number = 0.1;

		// Invaders.
		public static const invaderSizeXY:Number = 25;
		public static const invaderSizeZ:Number = 100;
		public static const deathExplosionIntensity:Number = 2;

		// Player.
		public static const useAccelerometer:Boolean = false;
		public static const accelerometerMotionFactorX:Number = 2;
		public static const accelerometerMotionFactorY:Number = 4;
		public static const accelerometerCenterY:Number = 0.7;
		public static const touchMotionFactor:Number = 7;
		public static const cameraPanRange:Number = 1500;
		public static const mouseCameraMotionEase:Number = 0.25;
		public static const accelerometerCameraMotionEase:Number = 0.1;
		public static const touchCameraMotionEase:Number = 0.25;
		public static const playerHitShake:Number = 100;
	}
}
