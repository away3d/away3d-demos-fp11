package utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.geom.ColorTransform;
	import flash.display.BitmapDataChannel;
	
	public class BitmapMapper extends Sprite
	{
		private var move:Boolean;
		
		private static var _ground:BitmapData;
		
		private static var _position:Vector3D;
		private static var _ease:Vector3D;
		private static var _size:uint = 128;
		private static var _sizePreview:uint = 512;
		private static var _height:uint = 1300;
		private static var _seed:uint = 1973;
		
		private static var _fractal:Boolean = true;
		private static var _numOctaves:uint = 2;
		private static var _complex:Number = 0.2;
		private static var _offsets:Array = [];
		private static var _maxSpeed:Number = 2;
		private static var _matrix:Matrix;
		private static var _pointTest:Vector.<Point>;
		private static var _centerColor:Vector.<uint>;
		
		public function BitmapMapper(quality:uint = 1, height:Number = 1300)
		{
			_size = 128 * quality;
			_height = height;
			_pointTest = new Vector.<Point>(4);
			_centerColor = new Vector.<uint>(4);
			_ease = new Vector3D();
			
			for (var i:uint = 0; i < _numOctaves; i++)
			{
				_offsets[i] = new Point(0, 0);
			}
			
			_matrix = new Matrix();
			
			if (_size == 128)
				_matrix.scale(4, 4);
			else if (_size == 256)
				_matrix.scale(2, 2);
			else if (_size == 64)
				_matrix.scale(8, 8);
			
			var middle:uint = _size >> 1;
			
			for (i = 0; i < 4; i++)
			{
				if (i == 0)
					_pointTest[0] = new Point(middle - 1, middle - 1);
				else if (i == 1)
					_pointTest[1] = new Point(middle, middle - 1);
				else if (i == 2)
					_pointTest[2] = new Point(middle - 1, middle);
				else
					_pointTest[3] = new Point(middle, middle);
				
				_centerColor[i] = 0;
			}
			
			_ground = new BitmapData(_size, _size, false);
			draw();
		}
		
		public static function get ground():BitmapData
		{
			return _ground;
		}
		
		public function update(e:Event):void
		{
		
		}
		
		private function draw():void
		{
			_ground.perlinNoise(_size * _complex, _size * _complex, _numOctaves, _seed, false, _fractal, 0 | 1 | 2, true, _offsets);
			_ground.applyFilter(ground, ground.rect, new Point(), setContrast(100));
			
			_centerColor[0] = ground.getPixel(_pointTest[0].x, _pointTest[0].y);
			_centerColor[1] = ground.getPixel(_pointTest[1].x, _pointTest[1].y);
			_centerColor[2] = ground.getPixel(_pointTest[2].x, _pointTest[2].y);
			_centerColor[3] = ground.getPixel(_pointTest[3].x, _pointTest[3].y);
		
			// preview
		/*
		   _content.graphics.clear();
		   _content.graphics.beginBitmapFill(ground, _matrix, false, false);
		   _content.graphics.drawEllipse(0, 0, 512, 512);
		   _content.graphics.endFill();
		
		   // deco
		   _content.graphics.lineStyle(0, 0x000000, 0.3);
		   _content.graphics.drawRect(252, 252, 8, 8);
		   _content.graphics.endFill();
		
		   _content.graphics.lineStyle(0, 0x000000, 0.1);
		   _content.graphics.moveTo(256, 0);
		   _content.graphics.lineTo(256, 512);
		   _content.graphics.endFill();
		
		   _content.graphics.lineStyle(0, 0x000000, 0.1);
		   _content.graphics.moveTo(0, 256);
		   _content.graphics.lineTo(512, 256);
		   _content.graphics.endFill();
		
		   _content.graphics.lineStyle(20, 0x000000, 0.3);
		   _content.graphics.drawEllipse(6, 6, 500, 500);
		   _content.graphics.endFill();
		
		   _content.graphics.lineStyle(10, 0x000000, 0.75);
		   _content.graphics.drawEllipse(3, 3, 506, 506);
		   _content.graphics.endFill();
		 */
		}
		
		/*public function move(e:Event):void
		   {
		
		   }
		
		   public static function move22(e:Event):void
		   {
		
		 }*/
         
        //-------------------------------------------------------------------------------
		//
		//      MATH TOOL
		//
		//-------------------------------------------------------------------------------
        private function velocity(angle:Number):Vector3D {
            return new Vector3D( Math.cos(radDeg(angle)), 0, Math.sin(radDeg(angle)));
        }
        
		private function degRad(r:Number):Number { return(r * (180 / Math.PI)) }
        private function radDeg(d:Number):Number { return(d * (Math.PI / 180)) }
        
		//-------------------------------------------------------------------------------
		//
		//       COLOR MATRIX FILTER
		//
		//-------------------------------------------------------------------------------
		
		/**
		 * sets grayscale effect
		 * @return      ColorMatrixFilter
		 */
		public static function grayScale():ColorMatrixFilter
		{
			var elements:Array = [0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0];
			return new ColorMatrixFilter(elements);
		}
		
		/**
		 * sets Brightneww value available are -100 ~ 100 @default is 0
		 * @param       value:int   contrast value
		 * @return      ColorMatrixFilter
		 */
		public static function setBrightness(value:Number):ColorMatrixFilter
		{
			value = value * (255 / 250);
			var m:Array = new Array();
			m = m.concat([1, 0, 0, 0, value]); // red
			m = m.concat([0, 1, 0, 0, value]); // green
			m = m.concat([0, 0, 1, 0, value]); // blue
			m = m.concat([0, 0, 0, 1, 0]); // alpha
			return new ColorMatrixFilter(m);
		}
		
		/**
		 * sets contrast value available are -100 ~ 100 @default is 0
		 * @param       value:int   contrast value
		 * @return      ColorMatrixFilter
		 */
		public static function setContrast(value:Number):ColorMatrixFilter
		{
			value /= 100;
			var s:Number = value + 1;
			var o:Number = 128 * (1 - s);
			var m:Array = new Array();
			m = m.concat([s, 0, 0, 0, o]); // red
			m = m.concat([0, s, 0, 0, o]); // green
			m = m.concat([0, 0, s, 0, o]); // blue
			m = m.concat([0, 0, 0, 1, 0]); // alpha
			return new ColorMatrixFilter(m);
		}
		
		/**
		 * sets saturation value available are -100 ~ 100 @default is 0
		 * @param       value:int   saturation value
		 * @return      ColorMatrixFilter
		 */
		public static function setSaturation(value:Number):ColorMatrixFilter
		{
			const lumaR:Number = 0.212671;
			const lumaG:Number = 0.71516;
			const lumaB:Number = 0.072169;
			var v:Number = (value / 100) + 1;
			var i:Number = (1 - v);
			var r:Number = (i * lumaR);
			var g:Number = (i * lumaG);
			var b:Number = (i * lumaB);
			var m:Array = new Array();
			m = m.concat([(r + v), g, b, 0, 0]); // red
			m = m.concat([r, (g + v), b, 0, 0]); // green
			m = m.concat([r, g, (b + v), 0, 0]); // blue
			m = m.concat([0, 0, 0, 1, 0]); // alpha
			return new ColorMatrixFilter(m);
		}
	}
}