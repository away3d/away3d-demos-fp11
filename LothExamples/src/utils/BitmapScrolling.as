package utils {
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;

	public class BitmapScrolling {
		public var scrollingBitmap : BitmapData;
		private var canvas : Graphics;
		private var matrix : Matrix;
		private var _size : int;
		private var content : Sprite;
		private var bitmaper : BitmapData;

		public function BitmapScrolling(B : BitmapData) {
			_size = B.width;
			scrollingBitmap = B;
			init();
		}

		private function init(e : Event = null) : void {
			content = new Sprite();
			matrix = content.transform.matrix.clone();
			bitmaper = new BitmapData(_size, _size, false, 0x00);
			canvas = content.graphics;
			drawCanvas();
		}

		public function move(mx : int, my : int) : void {
			matrix.translate(mx, my);
			drawCanvas();
			if (dy > bitmaper.width * 10) dy = 0;
			if (dy < -bitmaper.width * 10) dy = 0;
			if (dx > bitmaper.width * 10) dx = 0;
			if (dx < -bitmaper.width * 10) dx = 0;
		}

		private function drawCanvas() : void {
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

		public function get dy() : Number {
			return matrix.ty;
		}

		public function set dy(value : Number) : void {
			matrix.ty = value;
			drawCanvas();
		}

		public function get dx() : Number {
			return matrix.tx;
		}

		public function set dx(value : Number) : void {
			matrix.tx = value;
			drawCanvas();
		}
	}
}