package utils {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;

	public class BitmapScrolling {
		public var scrollingBitmap : BitmapData;
		protected var _parallaxAmount : Number = 2;
		// 1;
		protected var graphPaperBmp : BitmapData;
		protected var canvas : Graphics;
		protected var matrix : Matrix;
		protected var _size : int;
		protected var content : Sprite;
		private var bitmaper : BitmapData;

		public function BitmapScrolling(B : BitmapData) {
			_size = B.width;
			scrollingBitmap = B;
			init();
		}

		protected function init(e : Event = null) : void {
			content = new Sprite();
			matrix = content.transform.matrix.clone();
			bitmaper = new BitmapData(_size, _size, false, 0x00);
			canvas = content.graphics;
			drawCanvas();
		}

		protected function handleResize(e : Event) : void {
			drawCanvas();
		}

		public function move(dx : Number, dy : Number) : void {
			matrix.translate(dx, dy);
			// bitmaper.draw(scrollingBitmap.clone(), matrix);
			drawCanvas();
		}

		public function get dy() : Number {
			return matrix.ty;
		}

		public function set dy(value : Number) : void {
			matrix.ty = value * _parallaxAmount;
			drawCanvas();
		}

		protected function drawCanvas() : void {
			canvas.clear();
			canvas.beginBitmapFill(scrollingBitmap, matrix, true, false);
			canvas.drawRect(0, 0, _size, _size);
		}

		public function getMap() : BitmapData {
			bitmaper.unlock();
			bitmaper.draw(content, null, null, null, null, true);
			bitmaper.lock();
			canvas.clear();
			return bitmaper;
		}

		public function get dx() : Number {
			return matrix.tx;
		}

		public function set dx(value : Number) : void {
			matrix.tx = value * _parallaxAmount;
			drawCanvas();
		}

		public function get parallaxAmount() : Number {
			return _parallaxAmount;
		}

		public function set parallaxAmount(value : Number) : void {
			_parallaxAmount = value;
		}
	}
}