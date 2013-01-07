package games.shooters {
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;

	/**
	 * Graph 
	 * simple graphics methode for texture
	 */
	public class Graph {
		public static function BulletGlow(color : uint = 0x3366FF) : BitmapData {
			var b : BitmapData = new BitmapData(64, 64, true, 0x00000000);
			var c : Shape = new Shape();
			var m : Matrix = new Matrix();
			m.createGradientBox(64, 64, 0, 0, 0);
			c.graphics.beginGradientFill("radial", [color, color], [0x11, 0x00], [0x00, 0xff], m);
			c.graphics.drawRect(0, 0, 64, 64);
			c.graphics.endFill();
			b.draw(c);
			return b;
		}
	}
}