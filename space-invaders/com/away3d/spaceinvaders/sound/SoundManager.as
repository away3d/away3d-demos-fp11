package com.away3d.spaceinvaders.sound
{

	import flash.media.Sound;

	public class SoundManager
	{
		private static var _initialized:Boolean;
		private static var _sounds:Object;

		private static function init():void {
			if( !_initialized ) {
				_sounds = new Object();
				_initialized = true;
			}
		}

		public static function registerSound( id:String, sound:Sound ):void {
			init();
			_sounds[ id ] = sound;
		}

		public static function playSound( id:String, loop:Boolean = false ):void {
			var sound:Sound = _sounds[ id ];
			sound.play();
		}

		public static function stopSound( id:String ):void {

		}
	}
}
