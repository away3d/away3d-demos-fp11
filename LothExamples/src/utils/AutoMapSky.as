package utils {
	import away3d.containers.Scene3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.primitives.SkyBox;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;

	[SWF(width="256",height="768")]
	public class AutoMapSky extends Sprite {
		private static var _sky : SkyBox;
		private static var _scene : Scene3D;
		private static var _skyMap : BitmapCubeTexture;
		private static var _skyTextureBitmaps : Vector.<BitmapData>;
		private static var _skyBitmaps : Vector.<BitmapData>;
		private static var _blendmodes : Array = ["add", "darken", "hardlight", "lighten", "multiply", "overlay", "screen", "subtract"];
		private static var _skyColor : uint = 0x333338;
		private static var _fogColor : uint = 0x333338;
		private static var _groundColor : uint = 0x445465;
		private static var _top : BitmapData;
		private static var _floor : BitmapData;
		private static var _side : BitmapData;
		private static var _bigCube : Mesh;
		private static var _bigCubeMat : ColorMaterial;
		private var _preview : Sprite;

		public function AutoMapSky() {
			// juste for preview no need in demo
			_preview = new Sprite();
			addChild(_preview);
			_preview.addEventListener(MouseEvent.CLICK, draw);
			_preview.buttonMode = true;
			draw();
		}

		/**
		 * Create preview
		 */
		private function draw(e : MouseEvent = null) : void {
			var s : Vector.<BitmapData> = new Vector.<BitmapData>(3);
			s[0] = _side;
			s[1] = _top;
			s[2] = _floor;
			_preview.graphics.clear();
			_preview.graphics.beginBitmapFill(s[1]);
			_preview.graphics.drawRect(0, 0, 256, 256);
			_preview.graphics.endFill();
			_preview.graphics.beginBitmapFill(s[0]);
			_preview.graphics.drawRect(0, 256, 256, 256);
			_preview.graphics.endFill();
			_preview.graphics.beginBitmapFill(s[2]);
			_preview.graphics.drawRect(0, 512, 256, 256);
			_preview.graphics.endFill();
		}

		static public function get skyMap() : BitmapCubeTexture {
			return _skyMap;
		}

		static public function get fogColor() : uint {
			return _fogColor;
		}

		static public function set scene(s : Scene3D) : void {
			_scene = s;
		}

		/**
		 * Create new random sky
		 */
		static public function randomSky(colors : Array = null, Bitmaps : Vector.<BitmapData>=null, Quality : uint = 8, Blend : String = "overlay") : void {
			var i : uint = 0;
			var blend : String = Blend;
			_skyTextureBitmaps = new Vector.<BitmapData>(6);
			if (colors == null) {
				_skyColor = 0xFFFFFF * Math.random();
				_fogColor = 0xFFFFFF * Math.random();
				_groundColor = 0xFFFFFF * Math.random();
				blend = _blendmodes[uint(Math.random() * _blendmodes.length)];
			} else {
				_skyColor = colors[0];
				_fogColor = colors[1];
				_groundColor = colors[2];
			}
			// add real sky bitmap
			if (_skyBitmaps == null && Bitmaps != null) {
				_skyBitmaps = new Vector.<BitmapData>(6);
				for (i = 0; i < 6; i++) {
					_skyBitmaps[i] = Bitmaps[i];
				}
			}
			if (_sky) {
				_scene.removeChild(_sky);
				_sky.dispose();
			}

			_skyMap = vectorSky(_skyColor, _fogColor, _groundColor, Quality, _skyBitmaps, blend);
			_sky = new SkyBox(_skyMap);
			_scene.addChild(_sky);
		}

		/**
		 * Create Sky vector map
		 */
		static public function vectorSky(zenithColor : uint, horizonColor : uint, nadirColor : uint, quality : uint = 8, bitmaps : Vector.<BitmapData> = null, blend : String = "overlay") : BitmapCubeTexture {
			var xl : uint = 128 * quality;
			var pinch : uint = xl / 3.6;

			// sky color from bottom to top;
			var color : Vector.<uint> = Vector.<uint>([lighten(nadirColor, 50), darken(nadirColor, 25), darken(nadirColor, 5), horizonColor, horizonColor, horizonColor, zenithColor, darken(zenithColor, 25)]);
			// clear
			_side = new BitmapData(xl, xl, false, color[1]);
			_top = new BitmapData(xl, xl, false, color[6]);
			_floor = new BitmapData(xl, xl, false, color[1]);

			// side
			var matrix : Matrix = new Matrix();
			matrix.createGradientBox(xl, xl, -Math.PI / 2);
			var g : Shape = new Shape();
			g.graphics.beginGradientFill('linear', [color[1], color[2], color[3], color[4], color[5], color[6]], [1, 1, 1, 1, 1, 1], [90, 110, 120, 126, 160, 230], matrix);
			g.graphics.drawRect(0, 0, xl, xl);
			g.graphics.endFill();
			var displacement_map : DisplacementMapFilter = new DisplacementMapFilter(pinchMap(xl, xl), new Point(0, 0), 4, 2, 0, pinch, "clamp");
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

			var skyFinal : BitmapCubeTexture;

			if (bitmaps != null) {
				var s : Sprite;
				var h : Bitmap;
				var newMap : Vector.<BitmapData> = new Vector.<BitmapData>(6);
				var listing : Array = [2, 5, 1, 0, 4, 3];

				for (var i : int = 0; i < 6; i++) {
					s = new Sprite();
					h = new Bitmap(bitmaps[listing[i]]);
					newMap[i] = new BitmapData(xl, xl, false, 0x00);

					if (i == 0 || i == 1 || i == 4 || i == 5)
						s.addChild(new Bitmap(_side));
					else if (i == 2)
						s.addChild(new Bitmap(_top));
					else
						s.addChild(new Bitmap(_floor));
					s.addChild(h);
					h.blendMode = blend;
					newMap[i].draw(s);
					_skyTextureBitmaps[i] = newMap[i];
				}
				skyFinal = new BitmapCubeTexture(newMap[0], newMap[1], newMap[2], newMap[3], newMap[4], newMap[5]);
			} else {
				skyFinal = new BitmapCubeTexture(_side, _side, _top, _floor, _side, _side);
			}

			return skyFinal;
		}

		public static function night(value : Number = 100) : void {
			if (_bigCubeMat == null) {
				_bigCubeMat = new ColorMaterial(0x000000, 1);
				_bigCubeMat.bothSides = true;
				_bigCube = new Mesh(new CubeGeometry(20000, 20000, 20000), _bigCubeMat);
				_bigCube.castsShadows = false;
				_scene.addChild(_bigCube);
			} else if (_bigCubeMat.alpha == 0) {
				_scene.removeChild(_bigCube);
				_bigCube.dispose();
				_bigCubeMat = null;
			} else {
				_bigCubeMat.alpha = value / 100;
				_bigCube.material = _bigCubeMat;
			}
		}

		/**
		 * sets Brightneww value available are -100 ~ 100 @default is 0
		 * @param       value:int   contrast value
		 * @return      ColorMatrixFilter
		 */
		public static function setBrightness(value : Number) : ColorMatrixFilter {
			value = value * (255 / 250);
			var m : Array = new Array();
			m = m.concat([1, 0, 0, 0, value]);
			m = m.concat([0, 1, 0, 0, value]);
			m = m.concat([0, 0, 1, 0, value]);
			m = m.concat([0, 0, 0, 1, 0]);
			return new ColorMatrixFilter(m);
		}

		/**
		 * add sphericale distortion for side
		 */
		static private function pinchMap(w : uint, h : uint) : BitmapData {
			var b : BitmapData = new BitmapData(w, h, false, 0x000000);
			var vx : uint = w >> 1;
			var vy : uint = h >> 1;
			for (var j : uint = 0; j < h; j++) {
				for (var i : uint = 0; i < w; i++) {
					var BCol : Number = 127 + (i - vx) / (vx) * 127 * (1 - Math.pow((j - vy) / (vy), 2));
					var GCol : Number = 127 + (j - vy) / (vy) * 127 * (1 - Math.pow((i - vx) / (vx), 2));
					b.setPixel(i, j, (GCol << 8) | BCol);
				}
			}
			return b;
		}

		/**
		 * lighten color
		 */
		static public function lighten(color : uint, percent : Number) : Number {
			if (isNaN(percent) || percent <= 0) return color;
			if (percent >= 100) return 0xFFFFFF;
			var factor : Number = percent / 100;
			var channel : Number = factor * 255;
			var rgb : Vector.<uint> = hexToRgb(color);
			factor = 1 - factor;
			return rgbToHex(channel + rgb[0] * factor, channel + rgb[1] * factor, channel + rgb[2] * factor);
		}

		/**
		 * darken color
		 */
		static public function darken(color : uint, percent : Number) : uint {
			if (isNaN(percent) || percent <= 0) return color;
			if (percent >= 100) return 0x000000;
			var factor : Number = 1 - (percent / 100);
			var rgb : Vector.<uint> = hexToRgb(color);
			return rgbToHex(rgb[0] * factor, rgb[1] * factor, rgb[2] * factor);
		}

		/**
		 * conversion
		 */
		static public function rgbToHex(r : uint, g : uint, b : uint) : Number {
			return (r << 16 | g << 8 | b);
		}

		static public function hexToRgb(color : uint) : Vector.<uint> {
			return Vector.<uint>([(color & 0xff0000) >> 16, (color & 0x00ff00) >> 8, color & 0x0000ff]);
		}

		public function randColor() : uint {
			return uint(Math.random() * 0xffffff);
		}
	}
}