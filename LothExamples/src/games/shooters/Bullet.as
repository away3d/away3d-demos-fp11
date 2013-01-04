﻿/*This class draws bullets, moves them across stage, and checks to see if they hit any enemies */package games.shooters {	import away3d.materials.TextureMaterial;	import away3d.primitives.CylinderGeometry;	import away3d.containers.Scene3D;	import away3d.entities.Mesh;	import flash.events.Event;	import flash.display.Sprite;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.media.SoundTransform ;	import flash.geom.Vector3D;	public class Bullet extends Sprite {		private static var Singleton : Bullet;		[Embed(source="assets/sounds/Gun.mp3")]		public static var Shot : Class;		// the bullets will have a speed		public static var _speed : int;		private static var _sound : Sound;		private static var _channel : SoundChannel;		private static var _volume : SoundTransform;		private static var _scene : Scene3D;		private static var _bullets : Vector.<Mesh>;		private static var _bullet : Mesh;		private static var _viewLimit : int;		/**		 * Singleton enforcer		 */		public static function getInstance() : Bullet {			if (Singleton == null) Singleton = new Bullet();			return Singleton;		}		static public function init(material : TextureMaterial, ViewLimit : int = 2000) : void {			_viewLimit = ViewLimit;			_volume = new SoundTransform();			_channel = new SoundChannel();			_volume.volume = .03;			_sound = new Shot();			_bullets = new Vector.<Mesh>();			_speed = 100;			_bullet = new Mesh(new CylinderGeometry(5, 5, 20, 6, 1), material);			_bullet.rotationZ = 90;									// separate enterframe			Singleton.addEventListener(Event.ENTER_FRAME, update);		}		static public function set scene(Scene : Scene3D) : void {			_scene = Scene;		}		static public function shot(p : Vector3D) : void {			_channel = _sound.play();			_channel.soundTransform = _volume;			var b : Mesh = Mesh(_bullet.clone());			b.position = p.add(new Vector3D(130, 50, 0));			_scene.addChild(b);			_bullets.push(b);		}		// this logic will happen at frame rate		public static function update(e : Event = null) : void {			for (var i : int; i < _bullets.length; i++) {				_bullets[i].x -= _speed;				// kill bullet if out of screen				if (_bullets[i].x < -_viewLimit) kill(i);			}			/*			// add to the miss count			Game.main.updateStat("misses",1);			return;			}			// iterate through the enemy ship list, and see if this bullet is hitting any enemies			for(var i:int=0; i<EnemyShip.list.length; i++)			{			// if this bullet is hitting this enemy in the list			if(this.hitTestObject(EnemyShip.list[i].hitRect))			{			// have the hit enemy take damage			EnemyShip.list[i].takeDamage(1);			// kill the bullet			kill();								break;			}			}*/		}		private static function kill(n : uint) : void {			_scene.removeChild(_bullets[n]);			_bullets.splice(n, 1);		}	}}