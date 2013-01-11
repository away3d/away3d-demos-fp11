﻿package games.shooters {	import away3d.primitives.PlaneGeometry;	import away3d.utils.Cast;	import away3d.materials.TextureMaterial;	import away3d.primitives.CylinderGeometry;	import away3d.containers.Scene3D;	import away3d.entities.Mesh;	import flash.events.Event;	import flash.display.Sprite;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.media.SoundTransform ;	import flash.display.BitmapData;	import flash.geom.Vector3D;	/**	 * Bullet 	 * create, move and check collision with enemy	 */	public class Bullet extends Sprite {		private static var Singleton : Bullet;		[Embed(source="assets/sounds/Gun.mp3")]		public static var Shot : Class;		// the bullets will have a speed		public static var _speed : int;		private static var _sound : Sound;		private static var _channel : SoundChannel;		private static var _volume : SoundTransform;		private static var _scene : Scene3D;		private static var _bullets : Vector.<Mesh>;		private static var _bullet : Mesh;		private static var _viewLimit : int;		private static const ZONEHIT : int = 60;		private static var _isRun : Boolean;		/**		 * Singleton enforcer		 */		public static function getInstance() : Bullet {			if (Singleton == null) Singleton = new Bullet();			return Singleton;		}		static public function init(ViewLimit : int = 2000) : void {			_viewLimit = ViewLimit;			_volume = new SoundTransform();			_channel = new SoundChannel();			_volume.volume = .03;			_sound = new Shot();			_bullets = new Vector.<Mesh>();			// _bullets.fixed = true;			_speed = 100;			var material : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(4, 4, false, 0xffffff)));			var materialGlow : TextureMaterial = new TextureMaterial(Cast.bitmapTexture(Graph.BulletGlow(0xffffff)));			materialGlow.alphaBlending = true;			_bullet = new Mesh(new CylinderGeometry(5, 5, 20, 6, 1), material);			var g : Mesh = new Mesh(new PlaneGeometry(100, 100, 1, 1), materialGlow);			g.rotationX = 90;			_bullet.addChild(g);			_bullet.rotationZ = 90;			// separate enterframe			start();		}		public static function set scene(Scene : Scene3D) : void {			_scene = Scene;		}		public static function shot(p : Vector3D) : void {			_channel = _sound.play();			_channel.soundTransform = _volume;			var b : Mesh = Mesh(_bullet.clone());			b.position = p.add(new Vector3D(-130, 50, 0));			_scene.addChild(b);			// _bullets.push(b);			_bullets[_bullets.length] = b;			Stat.updateStat("shots", 1);		}		private static function update(e : Event = null) : void {			var i : uint, j : uint;			for ( i = 0;  i < _bullets.length; i++) {				_bullets[i].x -= _speed;				// destroy bullet if out of screen				if (_bullets[i].x < -_viewLimit) {					kill(i);					Stat.updateStat("misses", 1);					return;				}				// iterate through the enemy ship				for ( j = 0; j < Enemy.enemys.length; j++) {					// if this bullet is hitting any enemies					if (proximity(_bullets[i], Enemy.enemys[j])) {						// add damage to enemy ship						Enemy.takeDamage(j, 1);						// destroy bullet						kill(i);					}				}			}		}		private static function proximity(A : Mesh, B : Mesh) : Boolean {			var ax : int = ((A.x + _viewLimit) - (B.x + _viewLimit)) >> 0;			var ay : int = (A.y - B.y) >> 0;			if ( ax < ZONEHIT && ax > -ZONEHIT && ay < ZONEHIT && ay > -ZONEHIT) return true;			else return false;		}		private static function kill(n : uint) : void {			_bullets[n].removeChild(_bullets[n].getChildAt(0));			_scene.removeChild(_bullets[n]);			_bullets.splice(n, 1);		}		public static function pause() : void {			Singleton.removeEventListener(Event.ENTER_FRAME, update);			_isRun = false;		}		public static function start() : void {			if (_isRun) return;			Singleton.addEventListener(Event.ENTER_FRAME, update, false, 0, true);			_isRun = true;		}	}}