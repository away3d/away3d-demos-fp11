package com.away3d.spaceinvaders
{

	import com.away3d.spaceinvaders.input.AccelerometerInput;
	import com.away3d.spaceinvaders.input.InputBase;
	import com.away3d.spaceinvaders.input.MouseInput;
	import com.away3d.spaceinvaders.input.TouchInput;
	import com.away3d.spaceinvaders.sound.SoundManager;
	import com.away3d.spaceinvaders.sound.Sounds;
	import com.away3d.spaceinvaders.utils.PlatformUtil;
	import com.away3d.spaceinvaders.views.InvaderScene;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.sensors.Accelerometer;

	public class Main extends Sprite
	{
		private var _invaderScene:InvaderScene;
		private var _input:InputBase;

		public function Main() {
			initStage();
			initScene();
			initSound();
			initInput();
			addEventListener( Event.ENTER_FRAME, enterframeHandler );
		}

		private function initInput():void {
			_input = PlatformUtil.isRunningOnMobile() ?
					GameSettings.useAccelerometer && Accelerometer.isSupported ? new AccelerometerInput( _invaderScene ) : new TouchInput( _invaderScene )
					: new MouseInput( _invaderScene );
			addChild( _input );
		}

		private function initSound():void {
			SoundManager.registerSound( Sounds.PLAYER_FIRE, new SoundPlayerFire() );
			SoundManager.registerSound( Sounds.INVADER_DEATH, new SoundInvaderDeath() );
			SoundManager.registerSound( Sounds.EXPLOSION_SOFT, new SoundExplosionSoft() );
			SoundManager.registerSound( Sounds.EXPLOSION_STRONG, new SoundExplosionStrong() );
			SoundManager.registerSound( Sounds.MOTHERSHIP, new SoundMothership() );
			SoundManager.registerSound( Sounds.BOING, new SoundFast() );
		}

		private function initStage():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.frameRate = 30;
		}

		private function initScene():void {
			_invaderScene = new InvaderScene();
			addChild( _invaderScene );
		}

		private function enterframeHandler( event:Event ):void {
			_input.update();
			_invaderScene.update();
		}
	}
}
