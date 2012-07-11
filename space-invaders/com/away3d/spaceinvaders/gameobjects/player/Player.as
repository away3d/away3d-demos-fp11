package com.away3d.spaceinvaders.gameobjects.player
{

	import away3d.cameras.Camera3D;

	import aze.motion.easing.Quart;
	import aze.motion.eaze;

	import com.away3d.spaceinvaders.gameobjects.GameObject;
	import com.away3d.spaceinvaders.utils.MathUtils;

	public class Player extends GameObject
	{
		private var _camera:Camera3D;

		public var shakeT:Number = 0;

		public function Player( camera:Camera3D ) {

			super();
			addChild( camera );

			_camera = camera;
		}

		override public function impact( hitter:GameObject ):void {
			shake();
		}

		private function onShakeUpdate():void {
			var shakeRange:Number = 50 * shakeT;
			_camera.x = MathUtils.rand( -shakeRange, shakeRange );
			_camera.y = MathUtils.rand( -shakeRange, shakeRange );
		}

		private function shake():void {
			shakeT = 1;
			eaze( this ).to( 0.5, { shakeT:0 } ).easing( Quart.easeOut ).onUpdate( onShakeUpdate ).onComplete( onShakeComplete );
		}

		private function onShakeComplete():void {
			_camera.x = 0;
			_camera.y = 0;
		}
	}
}
