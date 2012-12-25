package utils {
	import flash.geom.Matrix;
	import flash.display.Shape;
	import flash.display.BitmapData;

	public class AutoMapPhysics {
		/**
		 * Simple eye bitmap texture
		 */
		static public function bitmapEyeBall() : BitmapData {
			var b : BitmapData = new BitmapData(256, 256, true, 0xAAFFFFFF);
			var c : Shape = new Shape();
			c.graphics.clear();
			c.graphics.beginFill(0xffffff, 0.7);
			c.graphics.drawRect(0, 0, 256, 256);
			c.graphics.endFill();
			c.graphics.lineStyle(5, 0x30AA70);
			c.graphics.beginFill(0x50cc90, 0.8);
			c.graphics.drawCircle(128, 128, 60);
			c.graphics.endFill();
			c.graphics.beginFill(0x000000, 0.8);
			c.graphics.drawCircle(128, 128, 20);
			c.graphics.endFill();
			c.graphics.lineStyle(0, 0xffffff, 0);
			c.graphics.beginFill(0xFFFFFF, 0.8);
			c.graphics.drawCircle(100, 100, 15);
			c.graphics.drawCircle(136, 136, 8);
			c.graphics.endFill();
			b.draw(c);
			c.graphics.clear();
			c = null;
			return b;
		}

		/**
		 * Simple dice bitmap texture
		 */
		static public function bitmapDice() : BitmapData {
			var color01 : uint = 0xEFEFEF;
			var color02 : uint = 0xAAAAAA;
			var b : BitmapData = new BitmapData(256, 256, true, color01);
			var c : Shape = new Shape();
			var m : Matrix;
			var dColor : Array = [color01, color02];
			var dRatio : Array = [0x33, 0x99];
			var dAlpha : Array = [0, 0.8];
			c.graphics.beginFill(color01, 0.8);
			c.graphics.drawRect(0, 0, 384, 256);

			c.graphics.lineStyle(6, color02, 0.8);
			m = new Matrix();
			m.createGradientBox(256, 256, 0, 0, 0);
			m.translate(-64, -64);
			c.graphics.beginGradientFill("radial", dColor, dAlpha, dRatio, m);
			c.graphics.drawRect(0, 0, 128, 128);
			m.translate(128, 0);
			c.graphics.beginGradientFill("radial", dColor, dAlpha, dRatio, m);
			c.graphics.drawRect(128, 0, 128, 128);
			m.translate(128, 0);
			c.graphics.beginGradientFill("radial", dColor, dAlpha, dRatio, m);
			c.graphics.drawRect(256, 0, 128, 128);
			m = new Matrix();
			m.createGradientBox(256, 256, 0, 0, 0);
			m.translate(-64, 64);
			c.graphics.beginGradientFill("radial", dColor, dAlpha, dRatio, m);
			c.graphics.drawRect(0, 128, 128, 128);
			m.translate(128, 0);
			c.graphics.beginGradientFill("radial", dColor, dAlpha, dRatio, m);
			c.graphics.drawRect(128, 128, 128, 128);
			m.translate(128, 0);
			c.graphics.beginGradientFill("radial", dColor, dAlpha, dRatio, m);
			c.graphics.drawRect(256, 128, 128, 128);
			c.graphics.endFill();
			// dice point
			c.graphics.lineStyle(6, color02, 0.3);
			c.graphics.beginFill(0xff0000, 0.8);
			c.graphics.drawCircle(64, 64, 16);
			c.graphics.beginFill(0x202020, 0.8);
			// 6
			c.graphics.drawCircle(160, 32, 10);
			c.graphics.drawCircle(160, 64, 10);
			c.graphics.drawCircle(160, 96, 10);
			c.graphics.drawCircle(224, 32, 10);
			c.graphics.drawCircle(224, 64, 10);
			c.graphics.drawCircle(224, 96, 10);
			// 2
			c.graphics.drawCircle(288, 32, 10);
			c.graphics.drawCircle(352, 96, 10);
			// 4
			c.graphics.drawCircle(32, 160, 10);
			c.graphics.drawCircle(32, 224, 10);
			c.graphics.drawCircle(96, 160, 10);
			c.graphics.drawCircle(96, 224, 10);
			// 5
			c.graphics.drawCircle(160, 160, 10);
			c.graphics.drawCircle(192, 192, 10);
			c.graphics.drawCircle(160, 224, 10);
			c.graphics.drawCircle(224, 160, 10);
			c.graphics.drawCircle(224, 224, 10);
			// 3
			c.graphics.drawCircle(288, 160, 10);
			c.graphics.drawCircle(320, 192, 10);
			c.graphics.drawCircle(352, 224, 10);

			m = new Matrix();
			m.scale(0.666, 1);
			b.draw(c, m);
			c.graphics.clear();
			m = null;
			c = null;
			return b;
		}
	}
}