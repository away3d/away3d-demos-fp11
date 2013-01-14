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
		private static var _wheelsMeshs : Vector.<Mesh>;
		private static var _axisMeshs : Vector.<Mesh>;
		// defines the current health of the ship
		private static var _life : int;
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
			_life = 3;
			_shipMeshs = shipParts;
			_wheelsMeshs = new Vector.<Mesh>(5, true);
			_axisMeshs = new Vector.<Mesh>(3, true);
			var m : Mesh, i : int, j : int;

			// add the reverse wing to ship
			for (i = 0; i < shipParts.length; i++) {
				if (shipParts[i].name == "ship_wing") {
					m = Mesh(shipParts[i].clone());
					m.name = "ship_wing_r";
					m.scaleZ = -1;
					_shipMeshs.push(m);
				}
				if (shipParts[i].name == "ship_wing_end") {
					m = Mesh(shipParts[i].clone());
					m.name = "ship_wing_end_r";
					m.scaleZ = -1;
					_shipMeshs.push(m);
				}
				// axe of wheels
				if (shipParts[i].name == "ship_axe_av") _axisMeshs[0] = shipParts[i];
				if (shipParts[i].name == "ship_axe_ar") {
					m = Mesh(shipParts[i].clone());
					m.name = "ship_axe_ar_r";
					_shipMeshs.push(m);
					_axisMeshs[1] = shipParts[i];
					_axisMeshs[2] = m;
				}
				// add all wheels
				if (shipParts[i].name == "ship_wheel") {
					shipParts[i].material = mat;
					for (j = 0; j < 5;++j) {
						m = Mesh(shipParts[i].clone());
						m.name = "ship_wheel_" + j;
						_wheelsMeshs[j] = m;
					}
				}
			}
			// place new wheels
			_wheelsMeshs[0].position = new Vector3D(-13, -14, 0);
			_wheelsMeshs[1].position = new Vector3D(0, -14, 6);
			_wheelsMeshs[2].position = new Vector3D(0, -14, -6);
			_wheelsMeshs[3].position = new Vector3D(0, -14, 6);
			_wheelsMeshs[4].position = new Vector3D(0, -14, -6);
			// add wheels to right axis
			_axisMeshs[0].addChild(_wheelsMeshs[0]);
			_axisMeshs[1].addChild(_wheelsMeshs[1]);
			_axisMeshs[1].addChild(_wheelsMeshs[2]);
			_axisMeshs[2].addChild(_wheelsMeshs[3]);
			_axisMeshs[2].addChild(_wheelsMeshs[4]);

			for (i = 0; i < _shipMeshs.length; i++) {
				m = _shipMeshs[i];
				if (m.name == "ship_cockpit_glass") m.material = mat2;
				else m.material = mat;
				if (m.name != "ship_wheel") container.addChild(m);
			}

			// finaly reposition all mesh
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
				velocity = new Vector3D(Math.random() * 300 - 150, -(Math.random() * 400 + 200), Math.random() * 300 - 150);
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
				if (m.name == "ship_axe_ar") m.position = new Vector3D(40, -30, 18);
				if (m.name == "ship_axe_ar_r") m.position = new Vector3D(40, -30, -18);
				if (m.name == "ship_axe_av") m.position = new Vector3D(-77, -30, 0);
				if (m.name == "ship_wing_end") {
					m.position = new Vector3D(0, -32, -90);
					m.rotationX = 25;
				}
				if (m.name == "ship_wing_end_r") {
					m.position = new Vector3D(0, -32, 90);
					m.rotationX = -25;
				}
				if (m.name == "ship_cockpit_glass") m.position = new Vector3D(-33, 30, 0);
				if (m.name == "ship_cockpit") m.position = new Vector3D(-33, 30, 0);
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