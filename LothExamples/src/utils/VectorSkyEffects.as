package utils
{
	import away3d.textures.BitmapCubeTexture;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	[SWF(width="256",height="768")]
	
	public class VectorSkyEffects extends Sprite
	{
		private static var _top:BitmapData;
		private static var _floor:BitmapData;
		private static var _side:BitmapData;
		private var preview:Sprite;
		
		public function VectorSkyEffects()
		{
			// juste for preview no need in demo
			preview = new Sprite();
			addChild(preview);
			preview.addEventListener(MouseEvent.CLICK, draw);
			preview.buttonMode = true;
			draw();
		}
		
		private function draw(e:MouseEvent = null):void
		{
			var skyTest:BitmapCubeTexture = vectorSky(randColor(), randColor(), randColor(), 2);
			var s:Vector.<BitmapData> = new Vector.<BitmapData>(3);
			s[0] = _side;
			s[1] = _top;
			s[2] = _floor;
			preview.graphics.clear();
			preview.graphics.beginBitmapFill(s[1]);
			preview.graphics.drawRect(0, 0, 256, 256);
			preview.graphics.endFill();
			preview.graphics.beginBitmapFill(s[0]);
			preview.graphics.drawRect(0, 256, 256, 256);
			preview.graphics.endFill();
			preview.graphics.beginBitmapFill(s[2]);
			preview.graphics.drawRect(0, 512, 256, 256);
			preview.graphics.endFill();
		}
		
		//-------------------------------------------------------------------------------
		//       SKY VECTOR MAP
		//-------------------------------------------------------------------------------
		
		static public function vectorSky(zenithColor:uint, horizonColor:uint, nadirColor:uint, quality:uint = 8, bitmaps:Vector.<BitmapData> = null, blend:String = "overlay"):BitmapCubeTexture
		{
			var xl:uint = 128 * quality;
			var pinch:uint = xl / 3.6;
			
			// sky color from bottom to top;
			var color:Vector.<uint> = Vector.<uint>([lighten(nadirColor, 50), darken(nadirColor, 25), darken(nadirColor, 5), horizonColor, horizonColor, horizonColor, zenithColor, darken(zenithColor, 25)]); // clear
			_side = new BitmapData(xl, xl, false, color[1]);
			_top = new BitmapData(xl, xl, false, color[6]);
			_floor = new BitmapData(xl, xl, false, color[1]);
			
			// side
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(xl, xl, -Math.PI / 2);
			var g:Shape = new Shape();
			g.graphics.beginGradientFill('linear', [color[1], color[2], color[3], color[4], color[5], color[6]], [1, 1, 1, 1, 1, 1], [90, 110, 120, 126, 160, 230], matrix);
			g.graphics.drawRect(0, 0, xl, xl);
			g.graphics.endFill();
			var displacement_map:DisplacementMapFilter = new DisplacementMapFilter(pinchMap(xl, xl), new Point(0, 0), 4, 2, 0, pinch, "clamp");
			g.filters = [displacement_map];
			_side.draw(g);
			
			// top
			g = new Shape();
			matrix = new Matrix();
			matrix.createGradientBox(xl, xl, 0, 0, 0);
			g.graphics.beginGradientFill('radial', [color[7], color[6]], [1, 1], [0, 255], matrix);
			g.graphics.drawEllipse(0, 0, xl, xl);
			g.graphics.endFill();
			_top.draw(g);
			
			// bottom
			g = new Shape();
			matrix = new Matrix();
			matrix.createGradientBox(xl, xl, 0, 0, 0);
			g.graphics.beginGradientFill('radial', [color[0], color[1]], [1, 1], [0, 255], matrix);
			g.graphics.drawEllipse(0, 0, xl, xl);
			g.graphics.endFill();
			_floor.draw(g);
			
			var skyFinal:BitmapCubeTexture
			
			if (bitmaps != null)
			{
				var s:Sprite
				var h:Bitmap
				var n:BitmapData
				var newMap:Vector.<BitmapData> = new Vector.<BitmapData>(6);
				var listing:Array = [2, 5, 1, 0, 4, 3];
				
				for (var i:int = 0; i < 6; i++)
				{
					s = new Sprite();
					h = new Bitmap(bitmaps[listing[i]]);
					newMap[i] = new BitmapData(1024, 1024, false, 0x00);
					
					if (i == 0 || i == 1 || i == 4 || i == 5)
						s.addChild(new Bitmap(_side));
					else if (i == 2)
						s.addChild(new Bitmap(_top));
					else
						s.addChild(new Bitmap(_floor));
					s.addChild(h);
					h.blendMode = blend;
					newMap[i].draw(s);
				}
				skyFinal = new BitmapCubeTexture(newMap[0], newMap[1], newMap[2], newMap[3], newMap[4], newMap[5]);
			}
			else
			{
				skyFinal = new BitmapCubeTexture(_side, _side, _top, _floor, _side, _side);
			}
			
			return skyFinal;
		}
		
		/**
		 * add sphericale distortion for side
		 */
		static private function pinchMap(w:uint, h:uint):BitmapData
		{
			var b:BitmapData = new BitmapData(w, h, false, 0x000000);
			var vx:uint = w >> 1;
			var vy:uint = h >> 1;
			
			for (var j:uint = 0; j < h; j++)
			{
				for (var i:uint = 0; i < w; i++)
				{
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
			var channel:Number = factor * 255;
			var rgb:Vector.<uint> = hexToRgb(color);
			factor = 1 - factor;
			
			return rgbToHex(channel + rgb[0] * factor, channel + rgb[1] * factor, channel + rgb[2] * factor);
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
			
			return rgbToHex(rgb[0] * factor, rgb[1] * factor, rgb[2] * factor);
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
		
		public function randColor():uint
		{
			return uint(Math.random() * 0xffffff);
		}
	}
}