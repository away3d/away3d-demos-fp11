package games {
	import away3d.primitives.PlaneGeometry;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TextureMaterial;
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Vector3D;

	/**
	 * @author lo-th
	 */
	public class Player {
		private static var Singleton : Player;
		private static var _scale : Number;
		private static var _scene : Scene3D;
		private static var _player : ObjectContainer3D;
		private static var _position : Vector3D;

		/**
		 * Singleton enforcer
		 */
		public static function getInstance() : Player {
			if (Singleton == null) {
				Singleton = new Player();
			}
			return Singleton;
		}

		/**
		 * Get player position
		 */
		public static function get position() : Vector3D {
			return _position;
		}

		/**
		 * Set the player position
		 */
		static public function set position(v : Vector3D) : void {
			_position = v;
			_player.position = _position;
		}

		/**
		 * Set the away3d scene
		 */
		static public function set scene(Scene : Scene3D) : void {
			_scene = Scene;
		}

		/**
		 * Set the player scale
		 */
		static public function set scale(s : Number) : void {
			_scale = s;
			_player.scale(_scale);
		}

		/**
		 * Initialise Player content
		 */
		public static function initPlayer() : void {
			_player = new ObjectContainer3D();
			_player.addChild(createSprite3d());
			_scene.addChild(_player);
		}

		/**
		 * Add extra mesh to player
		 */
		public static function add(m : Mesh) : void {
			_player.addChild(m);
		}

		/**
		 * Remove extra mesh to player
		 */
		public static function remove(m : Mesh) : void {
			_player.removeChild(m);
		}

		/**
		 * Create sprite3d to control direction
		 */
		private static function createSprite3d() : Mesh {
			var material : TextureMaterial;
			var b : BitmapData = new BitmapData(128, 128, true, 0x00000000);
			var g : Shape = new Shape();
			g.graphics.lineStyle(10, 0x008800, 1);
			g.graphics.drawCircle(64, 64, 48);
			g.graphics.lineStyle(10, 0x00AA00, 1);
			g.graphics.moveTo(64, 10);
			g.graphics.lineTo(64, 50);
			g.graphics.endFill();
			b.draw(g);
			material = new TextureMaterial(Cast.bitmapTexture(b));
			material.alphaBlending = true;
			var s : Mesh = new Mesh(new PlaneGeometry(64, 64), material);
			s.rotationY = 180;
			s.castsShadows = false;
			return s;
		}
	}
}
