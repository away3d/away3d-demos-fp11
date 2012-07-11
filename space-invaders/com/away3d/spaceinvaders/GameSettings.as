package com.away3d.spaceinvaders
{

	import flash.geom.Point;

	public class GameSettings
	{
		// -----------------------
		// Settings.
		// -----------------------

		// Scene.
		public static const xyRange:Number = 500;

		// Levels.
		public static const levelKillCount:Array = [ 25, 50, 75, 100 ]; // Kills needed to advance to next level
		public static const levelInvaderNum:Array = [ 5, 10, 15, 20 ];  // Max number of simultaneous invaders per level
		public static const levelInvaderProb:Array = [ 0.025, 0.05, 0.1, 0.25 ]; // Invader spawn probability per frame, per level

		// Invaders.
		public static const invaderSizeXY:Number = 25;
		public static const invaderSizeZ:Number = 100;
		public static const deathExplosionIntensity:Number = 2;

		// Player.
		public static const useAccelerometer:Boolean = true;
		public static const accelerometerMotionFactorX:Number = 2;
		public static const accelerometerMotionFactorY:Number = 4;
		public static const accelerometerCenterY:Number = 0.7;
		public static const touchMotionFactor:Number = 7;
		public static const cameraPanRange:Number = 1500;
		public static const cameraMotionEase:Number = 0.1;
		public static const playerHitShake:Number = 100;
	}
}
