/* 
Framework Integration Example

Starling scene used in the framework integration examples.

Code by Greg Caldwell
greg@geepers.co.uk
http://www.geepers.co.uk

This code is distributed under the MIT License

Copyright (c)  

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

 */
package com.starling.rootsprites {

	import flash.display.Bitmap;
	import starling.display.Image;
	import starling.animation.Tween;

	import starling.core.Starling;
	import starling.extensions.ColorArgb;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import starling.display.Sprite;

	public class StarlingVortexSprite extends Sprite
	{
		// Space scene
		[Embed(source="../../../assets/skybox/space_posZ.jpg")]
		private var SpaceImage:Class;

		// Starling Particle assets
		[Embed(source="../../../assets/particles/Vortex1.pex", mimeType="application/octet-stream")]
		private static const VortexConfig:Class;
		
		[Embed(source = "../../../assets/particles/Vortex1.png")]
		private static const VortexParticle:Class;
		
		[Embed(source="../../../assets/particles/Spawn.pex", mimeType="application/octet-stream")]
		private static const SpawnConfig:Class;
		
		[Embed(source = "../../../assets/particles/Spawn.png")]
		private static const SpawnParticle:Class;
		
		[Embed(source="../../../assets/particles/Starfield.pex", mimeType="application/octet-stream")]
		private static const StarfieldConfig:Class;
		
		[Embed(source = "../../../assets/particles/Starfield.png")]
		private static const StarfieldParticle:Class;
		
		private static var _instance:StarlingVortexSprite;
		
		private var _starfieldParticles : PDParticleSystem;
		private var _vortexParticles : PDParticleSystem;
		private var _vortexContainer : Sprite;
		private var _spawnParticles : PDParticleSystem;
		private var _space : Image;
		private var _spaceScale : Number;
		private var _spaceContainer : Sprite;
		private var _lastOX : Number;
		private var _lastOY : Number;
		
		public static function getInstance():StarlingVortexSprite
		{
			return _instance;
		}

		public function StarlingVortexSprite()
		{
			_instance = this;
			
			var spaceBmp:Bitmap = new SpaceImage();
			_space = new Image(Texture.fromBitmap(spaceBmp));
			
			_spaceContainer = new Sprite();
			_spaceContainer.pivotX = spaceBmp.width >> 1;
			_spaceContainer.pivotY = spaceBmp.height >> 1;
			this.addChild(_spaceContainer);
			
			_spaceScale = getScaling();
			_spaceContainer.scaleX = _spaceContainer.scaleY = _spaceScale;
			_spaceContainer.addChild(_space);
			
			var psConfig:XML;
			var psTexture:Texture;

			_vortexContainer = new Sprite();
			this.addChild(_vortexContainer);

			// Add the star field particles
			psConfig = XML(new StarfieldConfig());
			psTexture = Texture.fromBitmap(new StarfieldParticle());
			_starfieldParticles = new PDParticleSystem(psConfig, psTexture);
			_starfieldParticles.emitterX = 0;
			_starfieldParticles.emitterY = 0;
			_vortexContainer.addChild(_starfieldParticles);
			
			Starling.juggler.add(_starfieldParticles);
			
			_starfieldParticles.start();
			
			psConfig = XML(new VortexConfig());
			psTexture = Texture.fromBitmap(new VortexParticle());
			_vortexParticles = new PDParticleSystem(psConfig, psTexture);
			_vortexParticles.emitterX = 0;
			_vortexParticles.emitterY = 0;
			_vortexContainer.addChild(_vortexParticles);

			Starling.juggler.add(_vortexParticles);
			
			_vortexParticles.start();
			
			psConfig = XML(new SpawnConfig());
			psTexture = Texture.fromBitmap(new SpawnParticle());

			_spawnParticles = new PDParticleSystem(psConfig, psTexture);
			_spawnParticles.emitterX = 0;
			_spawnParticles.emitterY = 0;
			_spawnParticles.emissionRate = 5000;
			_vortexContainer.addChild(_spawnParticles);

			Starling.juggler.add(_spawnParticles);
		}

		private function getScaling() : Number {
			var sW:Number = Starling.current.nativeStage.stageWidth / 1024;
			var sH:Number = Starling.current.nativeStage.stageHeight / 1024;
			return ((sW > sH) ? sW : sH) * 1.3;
		}
		
		public function updatePosition(oX:Number, oY:Number) : void {
			_vortexContainer.x = oX;
			_vortexContainer.y = oY;
			_spaceContainer.x = ((oX - _spaceContainer.pivotX) * 3) + _spaceContainer.pivotX; 
			_spaceContainer.y = ((oY - _spaceContainer.pivotY) * 3) + _spaceContainer.pivotY; 
			_starfieldParticles.gravityX = ((oX - _lastOX) * 150); 
			_starfieldParticles.gravityY = ((oY - _lastOY) * 150); 
			_lastOX = oX;
			_lastOY = oY;
		}

		public function spawn():void {
			_vortexParticles.endColor = new ColorArgb( Math.random(), Math.random(), Math.random() );
							
			_spawnParticles.start(0.1);
		}
	}
}
