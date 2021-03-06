package games.shooters {
	import flash.display.Sprite;

	/**
	 * Shooter game satistics 
	 */
	public class Stat extends Sprite {
		private static var Singleton : Stat;
		private static var _score : String;
		private static var shipHealth : int;
		private static var kills : int;
		private static var hits : int;
		private static var points : int;
		private static var misses : int;
		private static var shots : int;
		private static var _gameComplete : int;

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : Stat {
			if (Singleton == null) Singleton = new Stat();
			return Singleton;
		}

		public static function get score() : String {
			return _score;
		}

		// resets all stats to zero for a new game
		public static function initStats() : void {
			_score = "";
			shipHealth = 0;
			kills = 0;
			hits = 0;
			points = 0;
			misses = 0;
			shots = 0;
			_gameComplete = 0;

			update();
		}

		public static function updateStat(type : String, val : int) : void {
			Stat[type] += val;
			update();
		}

		public static function setStat(type : String, val : int) : void {
			Stat[type] = val;
			update();
		}

		private static function update() : void {
			_score = "SCORE " + points + "\n";
			_score = "HEALTH " + shipHealth + "\n";
			_score += "Kill " + kills + "\n";
			_score += "Shot " + shots + "\n";
			_score += "Hit " + hits + "\n";
			_score += "Misse " + misses + "\n";
		}
	}
}