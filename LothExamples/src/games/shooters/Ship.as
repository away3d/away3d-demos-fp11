package games.shooters {
	import away3d.entities.Mesh;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TextureMaterial;

	import flash.geom.Vector3D;
	import flash.display.Sprite;

	import com.greensock.TweenNano;
	import com.greensock.easing.Quad;

	// import flash.events.Event;
	/**
	 * Ship
	 * health and position dispatch
	 */
	public class Ship extends Sprite {
		private static var Singleton : Ship;
		private static var _position : Vector3D;
		private static var _shipMeshs : Vector.<Mesh>;
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
		public static function initShip(shipParts : Vector.<Mesh>, container : ObjectContainer3D, mat : TextureMaterial, mat2 : TextureMaterial) : void {
			_maxHealth = 100;
			_shipMeshs = shipParts;
			var m : Mesh;
			var i : int;

			// add the reverse wing to ship
			for (i = 0; i < shipParts.length; i++) {
				if (shipParts[i].name == "ship_wing") {
					m = Mesh(shipParts[i].clone());
					m.name = "ship_wing_r";
					m.scaleZ = -1;
					m.z = 45;
					_shipMeshs.push(m);
				}
				if (shipParts[i].name == "ship_wing_end") {
					m = Mesh(shipParts[i].clone());
					m.name = "ship_wing_end_r";
					m.scaleZ = -1;
					m.z = 90;
					_shipMeshs.push(m);
				}
			}

			for (i = 0; i < _shipMeshs.length; i++) {
				if (_shipMeshs[i].name == "ship_cockpit_glass") _shipMeshs[i].material = mat2;
				else _shipMeshs[i].material = mat;
				container.addChild(_shipMeshs[i]);
				if (_shipMeshs[i].name == "ship_wing_end") _shipMeshs[i].rotationX = 25;
				if (_shipMeshs[i].name == "ship_wing_end_r") _shipMeshs[i].rotationX = -25;
			}

			reset();

			// separate enterframe
			// Singleton.addEventListener(Event.ENTER_FRAME, update);
		}

		private static function dislocate() : void {
			var i : int;
			var velocity : Vector3D, rotation : Vector3D;
			var m : Mesh;
			for (i = 0; i < _shipMeshs.length; i++) {
				m = _shipMeshs[i];
				velocity = new Vector3D(Math.random() * 300 -150, -(Math.random() * 400+200) , Math.random() * 300 -150);
				rotation = new Vector3D(Math.random() * 360, Math.random() * 360, Math.random() * 360);
				TweenNano.to(m, 2, {x:velocity.x, y:velocity.y, z:velocity.z, rotationX:rotation.x, rotationY:rotation.y, rotationZ:rotation.z, ease:Quad.easeOut});
			}
		}

		private static function rebuild() : void {
			var i : int;
			var m : Mesh;
			for (i = 0; i < _shipMeshs.length; i++) {
				m = _shipMeshs[i];
				m.moveTo(0, 0, 0);
				m.rotateTo(0, 0, 0);
				if (m.name == "ship_body_0") m.x = 70;
				if (m.name == "ship_body_2") m.x = -50;
				if (m.name == "ship_body_3") m.x = -100;
				if (m.name == "ship_wing") m.z = -45;
				if (m.name == "ship_wing_r") m.z = 45;
				if (m.name == "ship_wing_end") {
					m.z = -90;
					m.y = -32;
					m.rotationX = 25;
				}
				if (m.name == "ship_wing_end_r") {
					m.z = 90;
					m.y = -32;
					m.rotationX = -25;
				}
				if (m.name == "ship_cockpit_glass") {
					m.x = -33;
					m.y = 30;
				}
				if (m.name == "ship_cockpit") {
					m.x = -33;
					m.y = 30;
				}
			}
		}

		public static function reset() : void {
			_health = _maxHealth;
			Stat.setStat("shipHealth", _health);
			rebuild();
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
			dislocate();
		}
		/*private static function update(e : Event = null) : void {
		}*/
	}
}