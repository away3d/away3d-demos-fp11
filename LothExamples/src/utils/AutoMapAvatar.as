package utils {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;

	[SWF(width="512",height="512")]
	public class AutoMapAvatar extends Sprite {
		public static var map : BitmapData;
		private static var preview : Sprite;
		private static var layer : Vector.<Sprite>;
		private static var skincolor : Array = [0xFFF3E3, 0xFFE5CD, 0x7C4540, 0xFFCCA9, 0x83584A, 0xFFD59B];
		private static var shirtcolor : Array = [0x58595A, 0x456150, 0x49768F, 0x614D4F, 0x625159, 0x494344];
		private static var trousorscolor : Array = [0x9A7F60, 0x4B4743, 0x81494A, 0x6D7881, 0x5E5E41, 0x494344];

		public function AutoMapAvatar() {
			// juste for preview no need in demo
			preview = new Sprite();
			addChild(preview);
			preview.addEventListener(MouseEvent.CLICK, draw);
			preview.buttonMode = true;
			draw();
		}

		/**
		 * Draw preview
		 */
		private function draw(e : MouseEvent = null) : void {
			preview.graphics.clear();
			preview.graphics.beginBitmapFill(avatarBitmap());
			preview.graphics.drawRect(0, 0, 512, 512);
			preview.graphics.endFill();
		}

		/**
		 * Avatar vector map
		 */
		static public function avatarBitmap() : BitmapData {
			var uni : Boolean = true;
			var nakedLeg : Boolean = false;
			var nakedNeck : Boolean = false;
			var nakedFoot : Boolean = true;
			var s : Sprite = new Sprite();
			var cSkin : uint = skincolor[uint(Math.random() * skincolor.length)];
			var cShirt : uint = shirtcolor[uint(Math.random() * shirtcolor.length)];
			var cTrousor : uint;
			if (uni)
				cTrousor = cShirt;
			else
				cTrousor = trousorscolor[uint(Math.random() * trousorscolor.length)];

			map = new BitmapData(512, 512, false, 0x00ff00);
			layer = new Vector.<Sprite>(3);
			// /0xE8593A
			// tint line layer
			s.graphics.clear();
			s.graphics.beginFill(cSkin);
			// skin
			s.graphics.drawRect(0, 0, 512, 160);
			if (nakedNeck) s.graphics.beginFill(cSkin);
			else s.graphics.beginFill(cShirt);
			s.graphics.drawRect(0, 160, 512, 20);

			s.graphics.beginFill(cShirt);
			// shirt
			s.graphics.drawRect(0, 180, 512, 144);
			// neckstyle
			s.graphics.beginFill(cTrousor);
			// trousor
			s.graphics.drawRect(0, 324, 512, 148);
			if (nakedFoot) s.graphics.beginFill(cSkin);
			else s.graphics.beginFill(0x1A130F);
			// shoes
			s.graphics.drawRect(0, 472, 512, 40);
			s.graphics.endFill();
			if (nakedLeg) {
				s.graphics.beginFill(cSkin);
				// extra woman leg
				s.graphics.drawRect(256, 379, 185, 93);
				s.graphics.endFill();
			}

			layer[0] = s;
			map.draw(s);
			// deco line layer
			s.graphics.clear();
			s.graphics.beginFill(0x121212);
			// eye
			s.graphics.drawEllipse(216, 77, 22, 8);
			s.graphics.drawEllipse(275, 77, 22, 8);
			s.graphics.endFill();
			s.graphics.beginFill(0xeaeaea);
			s.graphics.drawEllipse(216, 78, 22, 7);
			s.graphics.drawEllipse(275, 78, 22, 7);
			s.graphics.endFill();
			s.graphics.beginFill(0x603310);
			// eye color
			s.graphics.drawEllipse(223, 77, 8, 8);
			s.graphics.drawEllipse(282, 77, 8, 8);
			s.graphics.endFill();
			s.graphics.beginFill(0x121212);
			s.graphics.drawEllipse(225, 79, 4, 4);
			// eye
			s.graphics.drawEllipse(284, 79, 4, 4);
			// eye
			s.graphics.endFill();
			s.graphics.beginFill(0x121212, 0.3);
			// mouth
			s.graphics.drawEllipse(236, 118, 40, 5);
			s.graphics.endFill();
			layer[0] = s;
			map.draw(s);
			// -----------------------------black line layer
			s.graphics.clear();
			s.graphics.beginFill(0x2D2825);
			s.graphics.drawRect(0, 319, 512, 5);
			s.graphics.endFill();
			layer[0] = s;
			map.draw(s);

			return map;
		}
	}
}