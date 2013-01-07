package games.shooters {
	import flash.geom.Vector3D;
	import flash.display.Sprite;

	// import flash.events.Event;
	/**
	 * Ship
	 * health and position dispatch
	 */
	public class Ship extends Sprite {
		private static var Singleton : Ship;
		private static var _position : Vector3D;
		// defines the current health of the ship
		private static var _health : Number;
		private static var _maxHealth : Number;

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : Ship {
			if (Singleton == null) Singleton = new Ship();
			return Singleton;
		}

		public static function set position(pos : Vector3D) : void {
			_position = pos;
		}

		public static function get position() : Vector3D {
			return _position;
		}

		// resets all stats to zero for a new game
		public static function initShip() : void {
			_maxHealth = 100;
			reset();
			// separate enterframe
			// Singleton.addEventListener(Event.ENTER_FRAME, update);
		}

		public static function reset() : void {
			_health = _maxHealth;
			Stat.setStat("shipHealth", _health);
		}

		public static function takeDamage(d : int) : void {
			// var s = new SoundTakeDamage();
			// s.play();

			_health -= d;
			if (_health <= 0 ) {
				_health = 0;
				kill();
			} else {
				// SmallExplosion(_position);
			}
			Stat.setStat("shipHealth", _health);
		}

		private static function kill() : void {
		}
		/*private static function update(e : Event = null) : void {
		}*/
	}
}