package utils {
	import flash.display.*;
	import flash.filters.*;
	import flash.geom.*;

	public class BitmapFilterEffects {
		[Embed(source="/../pb/Sharpen.pbj",mimeType="application/octet-stream")]
		public static var SharpenClass : Class;
		[Embed(source="/../pb/NormalMap.pbj",mimeType="application/octet-stream")]
		public static var NormalMapClass : Class;
		[Embed(source="/../pb/Outline.pbj",mimeType="application/octet-stream")]
		public static var OutlineClass : Class;
		// sharpen vars
		private static var _sharpenShader : Shader = new Shader(new SharpenClass());
		private static var _sharpenFilters : Array = [new ShaderFilter(_sharpenShader)];
		// normal map vars
		private static var _normalMapShader : Shader = new Shader(new NormalMapClass());
		private static var _normalMapFilters : Array = [new ShaderFilter(_normalMapShader)];
		// outline vars
		private static var _outlineShader : Shader = new Shader(new OutlineClass());
		private static var _outlineFilters : Array = [new ShaderFilter(_outlineShader)];

		static public function sharpen(sourceBitmap : BitmapData, amount : Number = 20, radius : Number = 0.1) : BitmapData {
			var returnBitmap : BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, sourceBitmap.transparent, 0x0);
			var shaderData : ShaderData = _sharpenShader.data;
			ShaderParameter(shaderData["amount"]).value = [amount];
			ShaderParameter(shaderData["radius"]).value = [radius];
			returnBitmap.applyFilter(sourceBitmap, sourceBitmap.rect, new Point(), _sharpenFilters[0]);
			return returnBitmap;
		}

		static public function normalMap(sourceBitmap : BitmapData, amount : Number = 10, soft_sobel : Number = 1, invert_red : Number = -1, invert_green : Number = -1) : BitmapData {
			var returnBitmap : BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, sourceBitmap.transparent, 0x0);
			var shaderData : ShaderData = _normalMapShader.data;
			ShaderParameter(shaderData["amount"]).value = [amount];
			ShaderParameter(shaderData["soft_sobel"]).value = [soft_sobel];
			ShaderParameter(shaderData["invert_red"]).value = [invert_red];
			ShaderParameter(shaderData["invert_green"]).value = [invert_green];
			returnBitmap.applyFilter(sourceBitmap, sourceBitmap.rect, new Point(), _normalMapFilters[0]);
			return returnBitmap;
		}

		static public function outline(sourceBitmap : BitmapData, dx : Number = 1, dy : Number = 0.15, color : uint = 0xFFFFFF, bgcolor : uint = 0x000000) : BitmapData {
			var returnBitmap : BitmapData = new BitmapData(sourceBitmap.width, sourceBitmap.height, sourceBitmap.transparent, 0x0);
			var shaderData : ShaderData = _outlineShader.data;
			ShaderParameter(shaderData["difference"]).value = [dx, dy];
			ShaderParameter(shaderData["color"]).value = [((color & 0xFF0000) >> 16) / 255, ((color & 0x00FF00) >> 8) / 255, (color & 0x0000FF) / 255, 1];
			ShaderParameter(shaderData["bgcolor"]).value = [((bgcolor & 0xFF0000) >> 16) / 255, ((bgcolor & 0x00FF00) >> 8) / 255, (bgcolor & 0x0000FF) / 255, 1];
			returnBitmap.applyFilter(sourceBitmap, sourceBitmap.rect, new Point(), _outlineFilters[0]);
			return returnBitmap;
		}
	}
}