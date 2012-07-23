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

	import starling.core.Starling;
	import starling.extensions.PDParticleSystem;
	import starling.textures.Texture;
	import starling.display.Sprite;

	public class StarlingExplosionSprite extends Sprite
	{
		// Starling Explosion Particle assets
		[Embed(source="../../../assets/particles/Explosion.pex", mimeType="application/octet-stream")]
		private static const ExplosionConfig:Class;
		
		[Embed(source = "../../../assets/particles/Explosion.png")]
		private static const ExplosionParticle:Class;
		
		private static var _instance:StarlingExplosionSprite;
		
		private var explosionParticles : PDParticleSystem;
		private var explosionContainer : Sprite;
		
		public static function getInstance():StarlingExplosionSprite
		{
			return _instance;
		}

		public function StarlingExplosionSprite()
		{
			_instance = this;
			
			explosionContainer = new Sprite();
			this.addChild(explosionContainer);
			
			var psConfig:XML = XML(new ExplosionConfig());
			var psTexture:Texture = Texture.fromBitmap(new ExplosionParticle());
			
			explosionParticles = new PDParticleSystem(psConfig, psTexture);
			explosionParticles.emitterX = 0;
			explosionParticles.emitterY = 0;
			explosionParticles.emissionRate = 1000;
			explosionContainer.addChild(explosionParticles);

			Starling.juggler.add(explosionParticles);
		}

		public function explode(oX:Number, oY:Number, size:Number) : void {
			explosionContainer.x = oX;
			explosionContainer.y = oY;
			explosionContainer.scaleX = explosionContainer.scaleY = (size<0 ? 0 : size);
			explosionParticles.start(0.1);
		}
	}
}
