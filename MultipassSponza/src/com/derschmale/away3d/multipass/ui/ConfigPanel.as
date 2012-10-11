package com.derschmale.away3d.multipass.ui
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HSlider;
	import com.bit101.components.NumericStepper;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class ConfigPanel extends Sprite
	{
		public static const NUM_CASCADES_CHANGED:String = "NumCascadesChanged";
		public static const METHOD_CHANGED:String = "MethodChanged";
		public static const DEPTH_MAP_CHANGED:String = "DepthMapChanged";
		public static const LIGHT_DIRECTION_CHANGED:String = "LightPositionChanged";

		[Embed(source="/../embeds/fonts/Uni0553.ttf", fontName="uni 05_53", advancedAntiAliasing="true", fontWeight="regular", fontStyle="normal", mimeType="application/x-font")]
		private static var UniFontAsset:Class;

		private var _uniFont : Font = new UniFontAsset();

		private var _numCascadeStepper:NumericStepper;
		private var _filterComboBox:ComboBox;
		private var _depthMapComboBox:ComboBox;
		private var _lightArcSlider:HSlider;
		private var _lightAzimuthSlider:HSlider;

		public function ConfigPanel()
		{
			init();
		}

		public function get filterMethod():String
		{
			return String(_filterComboBox.selectedItem);
		}

		public function get numCascades():int
		{
			return _numCascadeStepper.value;
		}

		public function get depthMapSize():int
		{
			return int(_depthMapComboBox.selectedItem);
		}

		private function init():void
		{
			initBackground();
			initNumCascades();
			initMethod();
			initDepthMapSize();
			initLightDirection();
		}

		private function initBackground():void
		{
			graphics.beginFill(0, .2);
			graphics.drawRect(0, 0, 250, 120);
			graphics.endFill();
		}

		private function initNumCascades():void
		{
			createLabel("Cascade levels:", 10);
			_numCascadeStepper = new NumericStepper(this, 150, 10, onNumCascadeChange);
			_numCascadeStepper.minimum = 1;
			_numCascadeStepper.maximum = 4;
			_numCascadeStepper.value = 3;
		}

		private function initMethod():void
		{
			createLabel("Filter method:", 30);
			_filterComboBox = new ComboBox(this, 130, 30, "", ["Unfiltered", "PCF", "Multiple taps", "Dithered"]);
			_filterComboBox.selectedIndex = 1;
			_filterComboBox.addEventListener(Event.SELECT, onFilterComboBoxChange);
		}

		private function initDepthMapSize():void
		{
			createLabel("Depth map size:", 50);
			_depthMapComboBox = new ComboBox(this, 130, 50, "", [512, 1024, 2048]);
			_depthMapComboBox.selectedIndex = 2;
			_depthMapComboBox.addEventListener(Event.SELECT, onDepthMapSizeChange);
		}

		private function initLightDirection():void
		{
			createLabel("Light direction:", 70);
			_lightArcSlider = new HSlider(this, 130, 77, onLightDirectionChange);
			_lightArcSlider.minimum = 0;
			_lightArcSlider.maximum = Math.PI*2;

			createLabel("Light height:", 90);
			_lightAzimuthSlider = new HSlider(this, 130, 97, onLightDirectionChange);
			_lightAzimuthSlider.minimum = 0;
			_lightAzimuthSlider.maximum = Math.PI/2;
		}

		private function onDepthMapSizeChange(event:Event):void
		{
			dispatchEvent(new Event(DEPTH_MAP_CHANGED));
		}

		private function createLabel(text : String, y:int):TextField
		{
			var label : TextField = new TextField();
			label.x = 10;
			label.y = y;
			label.embedFonts = true;
			label.selectable = false;
			label.antiAliasType = AntiAliasType.ADVANCED;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.defaultTextFormat = getTextFormat();
			label.text = text;
			addChild(label);
			return label;
		}

		private function getTextFormat():TextFormat
		{
			return new TextFormat(_uniFont.fontName, 11, 0xdddddd);
		}

		private function onNumCascadeChange(event:Event):void
		{
			dispatchEvent(new Event(NUM_CASCADES_CHANGED));
		}

		private function onFilterComboBoxChange(event:Event):void
		{
			dispatchEvent(new Event(METHOD_CHANGED));
		}

		private function onLightDirectionChange(event:Event):void
		{
			dispatchEvent(new Event(LIGHT_DIRECTION_CHANGED));
		}

		public function get lightAzimuth():Number
		{
			return Math.PI/2 - _lightAzimuthSlider.value;
		}

		public function get lightArc():Number
		{
			return _lightArcSlider.value;
		}

		public function setLightPosition(vector:Vector3D):void
		{
			_lightAzimuthSlider.value = Math.PI/2 - Math.acos(-vector.y/vector.length);
			_lightArcSlider.value = Math.atan2(vector.z, vector.x);
		}
	}
}
