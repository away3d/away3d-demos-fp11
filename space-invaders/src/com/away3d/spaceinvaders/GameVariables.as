package com.away3d.spaceinvaders
{


	public class GameVariables
	{
		// -----------------------
		// Settings
		// -----------------------

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
		public static const invaderSizeXY:Number = 50;
		public static const invaderSizeZ:Number = 200;
		public static const deathExplosionIntensity:Number = 3;
		public static const invaderFireRateMS:Number = 4000;
		public static const invaderAnimationTimeMS:uint = 250;
		public static const impactHitSize:Number = 300;

		// Player.
		public static const cameraPanRange:Number = 1500;
		public static const panTiltFactor:Number = 0.005;
		public static const playerHitShake:Number = 200;
		public static const playerLives:uint = 3;

		// Mouse control settings.
		public static const mouseCameraMotionEase:Number = 0.25;
		public static const mouseMotionFactor:Number = 2500;

		// Accelerometer control settings.
		public static const useAccelerometer:Boolean = true;
		public static const accelerometerCameraMotionEase:Number = 0.05;
		public static const accelerometerMotionFactorX:Number = 5;
		public static const accelerometerMotionFactorY:Number = 10;
		public static const accelerometerCenterY:Number = 0.6;

		// Touch control settings.
		public static const touchMotionFactor:Number = 2;
		public static const touchCameraMotionEase:Number = 0.25;

		// Stars.
		public static const maxStarNum:uint = 50;

		// Scene range.
		public static const minZ:Number = -1000;
		public static const maxZ:Number = 50000;

		// -----------------------
		// Variables
		// -----------------------

		public static var windowWidth:Number = 0;
		public static var windowHeight:Number = 0;
	}
}
