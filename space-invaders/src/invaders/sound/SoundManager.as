package invaders.sound
{

	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;


	public class SoundManager
	{
		private static var _initialized:Boolean;
		private static var _sounds:Object;

		public static function registerSounds():void {
			registerSound( Sounds.PLAYER_FIRE, new SoundShoot() );
			registerSound( Sounds.INVADER_DEATH, new SoundInvaderDeath() );
			registerSound( Sounds.EXPLOSION_SOFT, new SoundExplosionSoft() );
			registerSound( Sounds.EXPLOSION_STRONG, new SoundExplosionStrong() );
			registerSound( Sounds.MOTHERSHIP, new SoundMothership() );
			registerSound( Sounds.INVADER_FIRE, new SoundPlayerFire() );
			registerSound( Sounds.THUCK, new SoundThuck() );
			registerSound( Sounds.UFO, new SoundUfo() );
			registerSound( Sounds.BOING, new SoundBoing() );
		}

		private static function init():void {
			if( !_initialized ) {
				_sounds = new Object();
				_initialized = true;
			}
		}

		private static function registerSound( id:String, sound:Sound ):void {
			init();
			_sounds[ id ] = sound;
		}

		public static function playSound( id:String, volume:Number = 1 ):void {
			if( !GameSettings.useSound ) return;
			var sound:Sound = _sounds[ id ] as Sound;
			var channel:SoundChannel = sound.play();
			channel.soundTransform = new SoundTransform( volume );
		}
	}
}
