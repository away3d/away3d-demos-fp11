package utils {
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;

	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.LoaderInfo;
	import flash.events.ProgressEvent;
	import flash.net.URLLoaderDataFormat;

	/**
	 * Loader Pool
	 * load binary file
	 * @author Loth 2012
	 */
	public class LoaderPool extends Sprite {
		private static const ASSETS_ROOT : String = "assets/";
		private static var _num : uint = 0;
		private static var _log : Function = null;
		private static var _currentLoadFile : String;
		private static var _finalFunction : Function;
		private static var _onAssetComplete : Function;
		private static var _onResourceComplete : Function;
		private static var _bitmapStrings : Vector.<String>;
		private static var _bitmaps : Vector.<BitmapData>;

		public function LoaderPool() {
		}

		/**
		 * Load bitmaps pool
		 */
		static public function loadBitmaps(BitmapNames : Vector.<String>, FinalFunction : Function = null) : void {
			_num = 0;
			_bitmapStrings = BitmapNames;
			_finalFunction = FinalFunction;
			_bitmaps = new Vector.<BitmapData>(_bitmapStrings.length);
			load(_bitmapStrings[_num]);
		}

		/**
		 * Load awd object
		 */
		static public function loadObject(Name : String, OnAssetComplete : Function = null, OnResourceComplete : Function = null) : void {
			_onAssetComplete = OnAssetComplete;
			_onResourceComplete = OnResourceComplete;
			_bitmaps = new Vector.<BitmapData>(_bitmapStrings.length);
			load(Name);
		}

		/**
		 * Set the text out function from stage
		 */
		static public function set log(v : Function) : void {
			_log = v;
		}

		/**
		 * Get final bitmaps
		 */
		static public function get bitmaps() : Vector.<BitmapData> {
			return _bitmaps;
		}

		/**
		 * Globale function loader binary files
		 */
		static private function load(url : String) : void {
			_currentLoadFile = url;
			var loader : URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			switch (url.substring(url.length - 3)) {
				case "AWD":
				case "awd":
					loader.addEventListener(Event.COMPLETE, parseAWD, false, 0, true);
					break;
				case "png":
				case "jpg":
					loader.addEventListener(Event.COMPLETE, parseBitmap, false, 0, true);
					break;
			}
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorImage, false, 0, true);
			loader.addEventListener(ProgressEvent.PROGRESS, loadProgress, false, 0, true);
			loader.load(new URLRequest(ASSETS_ROOT + url));
		}

		/**
		 * Listener function error event on loader
		 */
		static private function onErrorImage(e : ErrorEvent) : void {
			if (_log != null) _log(e.text.toUpperCase() + " on " + _currentLoadFile);
		}

		/**
		 * Listener function progress event on loader
		 */
		static private function loadProgress(e : ProgressEvent) : void {
			var P : int = int(e.bytesLoaded / e.bytesTotal * 100);
			if (_log != null) _log('LOAD | ' + _currentLoadFile + ' | ' + P + ' % | ' + int((e.bytesLoaded / 1024) << 0) + ' ko');
		}

		/**
		 * Listener function for bitmap asset event on loader
		 */
		static private function parseBitmap(e : Event) : void {
			var urlLoader : URLLoader = URLLoader(e.target);
			var loader : Loader = new Loader();
			loader.loadBytes(urlLoader.data);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onBitmapComplete, false, 0, true);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			urlLoader.removeEventListener(Event.COMPLETE, parseBitmap);
			urlLoader = null;
		}

		/**
		 * Listener function for bitmap asset complete event on loader
		 */
		static private function onBitmapComplete(e : Event) : void {
			var loader : Loader = LoaderInfo(e.target).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onBitmapComplete);
			_bitmaps[_num] = Bitmap(loader.contentLoaderInfo.content).bitmapData;
			loader.unload();
			loader = null;
			_num++;
			if (_num < _bitmapStrings.length) load(_bitmapStrings[_num]);
			else {
				if (_log != null) _log("end");
				if (_finalFunction != null) _finalFunction();
			}
		}

		/**
		 * Listener function for awd asset event on loader
		 */
		static private function parseAWD(e : Event) : void {
			var urlLoader : URLLoader = e.target as URLLoader;
			var loader3d : Loader3D = new Loader3D(false);
			loader3d.addEventListener(AssetEvent.ASSET_COMPLETE, _onAssetComplete, false, 0, true);
			loader3d.addEventListener(LoaderEvent.RESOURCE_COMPLETE, _onResourceComplete, false, 0, true);
			loader3d.loadData(urlLoader.data, null, null, new AWD2Parser());
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorImage);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorImage);
			urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadProgress);
			urlLoader.removeEventListener(Event.COMPLETE, parseAWD);
			urlLoader = null;
		}
	}
}