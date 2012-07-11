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

		// Levels.
		public static const levelKillCount:Array = [ 25, 50, 75, 100 ]; // Kills needed to advance to next level
		public static const levelInvaderNum:Array = [ 5, 10, 15, 20 ];  // Max number of simultaneous invaders per level
		public static const levelInvaderProb:Array = [ 0.025, 0.05, 0.1, 0.25 ]; // Invader spawn probability per frame, per level
		public static const levelInvaderMaxFireRate:Array = [ 1000, 750, 500, 250 ]; // Invader spawn probability per frame, per level

		// Invaders.
		public static const invaderSizeXY:Number = 25;
		public static const invaderSizeZ:Number = 100;
		public static const deathExplosionIntensity:Number = 2;

		// Player.
		public static const cameraMotionEase:Number = 0.25;
	}
}
