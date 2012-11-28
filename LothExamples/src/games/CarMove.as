package games {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	public class CarMove extends Sprite {
		private static var _speed : Number = 0;
		private static var _speedMax : Number = 200;
		private static var _speedMaxReverse : Number = -4;
		private static var _speedAcceleration : Number = 0.8;//.15;
		private static var _groundFriction : Number = .95;
		private static var _steering : Number = 0;
		private static var _steeringMax : Number = 1;
		private static var _steeringAcceleration : Number = .05;
		private static var _steeringFriction : Number = .98;
		private static var _velocityX : Number = 0;
		private static var _velocityY : Number = 0;
		private static var _up : Boolean = false;
		private static var _down : Boolean = false;
		private static var _left : Boolean = false;
		private static var _right : Boolean = false;
		private static var _position : Vector3D = new Vector3D();
		private static var _angle : Number = 0;

		public function CarMove() {
		}

		/**
		 * Get setting
		 */
		static public function get position() : Vector3D {
			return _position;
		}

		static public function get angle() : Number {
			return _angle;
		}

		static public function get steering() : Number {
			return _steering;
		}

		static public function get speed() : Number {
			return _speed;
		}

		/**
		 * Set setting
		 */
		static public function up(v : Boolean) : void {
			_up = v;
		}

		static public function down(v : Boolean) : void {
			_down = v;
		}

		static public function left(v : Boolean) : void {
			_left = v;
		}

		static public function right(v : Boolean) : void {
			_right = v;
		}

		/**
		 * Listener on update
		 */
		static public function update(event : Event = null) : void {
			if (_up) {
				// check if below speedMax
				if (_speed < _speedMax) {
					// speed up
					_speed += _speedAcceleration;
					// check if above speedMax
					if (_speed > _speedMax) {
						// reset to speedMax
						_speed = _speedMax;
					}
				}
			}

			if (_down) {
				// check if below speedMaxReverse
				if (_speed > _speedMaxReverse) {
					// speed up (in reverse)
					_speed -= _speedAcceleration;
					// check if above speedMaxReverse
					if (_speed < _speedMaxReverse) {
						// reset to speedMaxReverse
						_speed = _speedMaxReverse;
					}
				}
			}

			if (_left) {
				// turn left
				_steering -= _steeringAcceleration;
				// check if above steeringMax
				if (_steering > _steeringMax) {
					// reset to steeringMax
					_steering = _steeringMax;
				}
			}

			if (_right) {
				// turn right
				_steering += _steeringAcceleration;
				// check if above steeringMax
				if (_steering < -_steeringMax) {
					// reset to steeringMax
					_steering = -_steeringMax;
				}
			}

			// friction
			_speed *= _groundFriction;

			// prevent drift
			if (_speed > 0 && _speed < 0.05) {
				_speed = 0;
			}

			// calculate velocity based on speed
			_velocityX = Math.sin(_angle * Math.PI / 180) * _speed;
			_velocityY = Math.cos(_angle * Math.PI / 180) * -_speed;

			// update position
			_position.x += _velocityX;
			_position.z -= _velocityY;

			// prevent steering drift (right)
			if (_steering > 0) {
				// check if steering value is really low, set to 0
				if (_steering < 0.05) {
					_steering = 0;
				}
			}
			// prevent steering drift (left) 
			else if (_steering < 0) {
				// check if steering value is really low, set to 0
				if (_steering > -0.05) {
					_steering = 0;
				}
			}

			// apply steering friction
			_steering = _steering * _steeringFriction;

			// make car go straight after driver stops turning
			_steering -= (_steering * 0.1);

			// rotate
			_angle += _steering * _speed;
		}
	}
}