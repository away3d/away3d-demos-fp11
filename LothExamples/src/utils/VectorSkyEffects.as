package utils
{
	import away3d.textures.BitmapCubeTexture;
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;
	
	
	public class VectorSkyEffects extends Sprite
	{
		/**
		 * create vector sky
		 */
		static public function vectorSky(zenithColor:uint, horizonColor:uint, nadirColor:uint, quality:uint = 8, bitmaps:Vector.<BitmapData>=null, blend:String="overlay"):BitmapCubeTexture
		{
			var xl:uint = 128 * quality;
			var pinch:uint = xl / 3.6;
			
			// sky color from bottom to top;
			var color:Vector.<uint> = Vector.<uint>([lighten(nadirColor, 50), darken(nadirColor, 25), darken(nadirColor, 5), horizonColor, horizonColor, horizonColor, zenithColor, darken(zenithColor, 25)]); // clear
			var side:BitmapData = new BitmapData(xl, xl, false, color[1]);
			var top:BitmapData = new BitmapData(xl, xl, false, color[6]);
			var floor:BitmapData = new BitmapData(xl, xl, false, color[1]);
			
			// side
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(xl, xl, -Math.PI / 2);
			var g:Shape = new Shape();
			g.graphics.beginGradientFill('linear', [color[1], color[2], color[3], color[4], color[5], color[6]], [1, 1, 1, 1, 1, 1], [90, 110, 120, 126, 160, 230], matrix);
			g.graphics.drawRect(0, 0, xl, xl);
			g.graphics.endFill();
			var displacement_map:DisplacementMapFilter = new DisplacementMapFilter(pinchMap(xl, xl), new Point(0, 0), 4, 2, 0, pinch, "clamp");
			g.filters = [displacement_map];
			side.draw(g);
			
			// top
			g = new Shape();
			matrix = new Matrix();
			matrix.createGradientBox(xl, xl, 0, 0, 0);
			g.graphics.beginGradientFill('radial', [color[7], color[6]], [1, 1], [0, 255], matrix);
			g.graphics.drawEllipse(0, 0, xl, xl);
			g.graphics.endFill();
			top.draw(g);
			
			// bottom
			g = new Shape();
			matrix = new Matrix();
			matrix.createGradientBox(xl, xl, 0, 0, 0);
			g.graphics.beginGradientFill('radial', [color[0], color[1]], [1, 1], [0, 255], matrix);
			g.graphics.drawEllipse(0, 0, xl, xl);
			g.graphics.endFill();
			floor.draw(g);
			
			var skyFinal:BitmapCubeTexture
			
			if (bitmaps!=null) {
				var s:Sprite
				var h:Bitmap
				var n:BitmapData
				var newMap:Vector.<BitmapData> = new Vector.<BitmapData>(6);
				var listing:Array = [2,5, 1, 0, 4, 3];
				
				for (var i:int = 0; i < 6;i++){
					s = new Sprite();
					h = new Bitmap(bitmaps[listing[i]]);
					newMap[i] = new BitmapData(1024, 1024, false, 0x00);
					
					if (i == 0 || i == 1 || i == 4 || i == 5) s.addChild(new Bitmap(side));
					else if (i == 2) s.addChild(new Bitmap(top));
					else  s.addChild(new Bitmap(floor));
					s.addChild(h);
					h.blendMode = blend;
					newMap[i].draw(s);
				}
				skyFinal = new BitmapCubeTexture(newMap[0], newMap[1], newMap[2], newMap[3], newMap[4], newMap[5]);
			}
			else {
				skyFinal = new BitmapCubeTexture(side, side, top, floor, side, side);
			}
			
			return skyFinal;
		}
		
		/**
		 * add sphericale distortion
		 */
		static private function pinchMap(w:uint, h:uint):BitmapData
		{
			var b:BitmapData = new BitmapData(w, h, false, 0x000000);
			var vx:uint = w >> 1;
			var vy:uint = h >> 1;
			
			for (var j:uint = 0; j < h; j++) {
				for (var i:uint = 0; i < w; i++) {
					var BCol:Number = 127 + (i - vx) / (vx) * 127 * (1 - Math.pow((j - vy) / (vy), 2));
					var GCol:Number = 127 + (j - vy) / (vy) * 127 * (1 - Math.pow((i - vx) / (vx), 2));
					b.setPixel(i, j, (GCol << 8) | BCol);
				}
			}
			
			return b;
		}
		
		/**
		 * lighten color
		 */
		static public function lighten(color:uint, percent:Number):Number
		{
			if (isNaN(percent) || percent <= 0)
				return color;
			
			if (percent >= 100)
				return 0xFFFFFF;
			
			var factor:Number = percent / 100;
			var channel:Number = factor*255;
			var rgb:Vector.<uint> = hexToRgb(color);
			factor = 1 - factor;
			
			return rgbToHex(channel + rgb[0]*factor, channel + rgb[1]*factor, channel + rgb[2]*factor);
		}
		
		/**
		 * darken color
		 */
		static public function darken(color:uint, percent:Number):uint
		{
			if (isNaN(percent) || percent <= 0)
				return color;
			
			if (percent >= 100)
				return 0x000000;
			
			var factor:Number = 1 - (percent / 100);
			var rgb:Vector.<uint> = hexToRgb(color);
			
			return rgbToHex(rgb[0]*factor, rgb[1]*factor, rgb[2]*factor);
		}
		
		/**
		 * conversion
		 */
		static public function rgbToHex(r:uint, g:uint, b:uint):Number
		{
			return (r << 16 | g << 8 | b);
		}
		
		static public function hexToRgb(color:uint):Vector.<uint>
		{
			return Vector.<uint>([(color & 0xff0000) >> 16, (color & 0x00ff00) >> 8, color & 0x0000ff]);
		}
	}
}