/*

   3D Still Life example in Away3d

   Demonstrates:

   How to use AWD smooth modelisation uv

   Code by loth
   3dflashlo@gmail.com
   http://3dflashlo.wordpress.com/

   This code is distributed under the MIT License

   Copyright (c) The Away Foundation http://www.theawayfoundation.org

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the “Software”), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.

 */

package {
	import away3d.containers.*;
	import away3d.controllers.HoverController;
	import away3d.core.base.SubGeometry;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.*;
	import away3d.textures.BitmapTexture;
	import away3d.utils.*;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.library.assets.AssetType;
	import away3d.library.AssetLibrary;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.materials.methods.*;
	import away3d.lights.shadowmaps.CascadeShadowMapper;
	import away3d.cameras.lenses.PerspectiveLens;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	[SWF(backgroundColor="#4a691d",frameRate="60")]
	
	public class Basic_StillLife extends Sprite {
		[Embed(source="/../embeds/stillLife.awd",mimeType="application/octet-stream")]
		public static var STILLLIFE:Class;
		
		//engine variables
		private var _view:View3D;
		private var _controller:HoverController;
		private var _sunLight:DirectionalLight;
		private var _pinLight:PointLight;
		private var _lightPicker:StaticLightPicker;
		private var _baseShadowMethod:DitheredShadowMapMethod;
		private var _cascadeMethod:CascadeShadowMapMethod;
		private var _cascadeShadowMapper:CascadeShadowMapper;
		private var _outlineMethod:OutlineMethod;
		private var _fogMethod:FogMethod;
		
		//scene objects
		private var _plane:Mesh;
		private var _fieldSubGeometry:SubGeometry;
		private var _tree:Mesh;
		
		//scene material
		private var _cupMaterial:TextureMultiPassMaterial;
		private var _appleMaterial:TextureMultiPassMaterial;
		private var _boxMaterial:TextureMultiPassMaterial;
		
		//mouse navigation 
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var _bgColor:uint = 0x4a691d;
		private var _center:Vector3D = new Vector3D(0, 10, 0);
		private var _azimuth:Number = 10;
		private var _altitude:Number = 20;
		
		/**
		 * Constructor
		 */
		public function Basic_StillLife() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//setup the view
			_view = new View3D();
			_view.backgroundColor = _bgColor;
			addChild(_view);
			
			//setup the camera
			_view.camera.lens = new PerspectiveLens(60);
			_view.camera.lens.near = 10;
			_view.camera.lens.far = 1000;
			
			//setup the camera controller
			_controller = new HoverController(_view.camera, null, 0, 2, 200, -5, 90);
			_controller.wrapPanAngle = true;
			_controller.autoUpdate = false;
			_controller.lookAtPosition = _center;
			
			//init light & Shadow
			_sunLight = new DirectionalLight();
			_sunLight.color = 0xFFFFEF;
			_sunLight.ambient = 0.5;
			_sunLight.diffuse = 1;
			_sunLight.specular = 1;
			_view.scene.addChild(_sunLight);
			
			_pinLight = new PointLight();
			_pinLight.color = 0x5555FF;
			_pinLight.ambient = 0.0;
			_pinLight.diffuse = 1;
			_pinLight.specular = 0.5;
			_pinLight.position = new Vector3D(-200, 0, 200);
			_view.scene.addChild(_pinLight);
			
			_lightPicker = new StaticLightPicker([_sunLight, _pinLight]);
			
			_cascadeShadowMapper = new CascadeShadowMapper(3);
			_cascadeShadowMapper.lightOffset = 2000;
			_sunLight.castsShadows = false;
			_sunLight.shadowMapper = _cascadeShadowMapper;
			_sunLight.shadowMapper.depthMapSize = 2048;
			_baseShadowMethod = new DitheredShadowMapMethod(_sunLight);
			_cascadeMethod = new CascadeShadowMapMethod(_baseShadowMethod);
			_cascadeMethod.epsilon = .0007;
			_cascadeMethod.alpha = 0.6;
			
			_fogMethod = new FogMethod(0, 500, _bgColor);
			_outlineMethod = new OutlineMethod(0x000000, 1, true, true);
			
			//init materials
			_cupMaterial = new TextureMultiPassMaterial(new BitmapTexture(cup()));
			_appleMaterial = new TextureMultiPassMaterial(new BitmapTexture(apple()));
			_boxMaterial = new TextureMultiPassMaterial(new BitmapTexture(desk()));
			
			_cupMaterial.lightPicker = _lightPicker;
			_appleMaterial.lightPicker = _lightPicker;
			_boxMaterial.lightPicker = _lightPicker;
			
			_cupMaterial.shadowMethod = _cascadeMethod;
			_appleMaterial.shadowMethod = _cascadeMethod;
			_boxMaterial.shadowMethod = _cascadeMethod;
			
			_cupMaterial.addMethod(_outlineMethod);
			_appleMaterial.addMethod(_outlineMethod);
			_boxMaterial.addMethod(_outlineMethod);
			
			_cupMaterial.addMethod(_fogMethod);
			_appleMaterial.addMethod(_fogMethod);
			_boxMaterial.addMethod(_fogMethod);
			
			// parse still life model
			parseTreeModel();
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			
			//mouse navigation
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.MOUSE_LEAVE, onMouseUp);
			stage.quality = "LOW";
			onResize();
		}
		
		/**
		 * parse tree model
		 */
		private function parseTreeModel():void {
			AssetLibrary.loadData(new STILLLIFE(), null, null, new AWD2Parser());
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}
		
		private function onResourceComplete(event:LoaderEvent):void {
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}
		
		private function onAssetComplete(event:AssetEvent):void {
			var m:Mesh;
			if (event.asset.assetType == AssetType.MESH) {
				m = event.asset as Mesh;
				_view.scene.addChild(m);
				if (m.name.substring(0, 5) == "apple") {
					m.material = _appleMaterial;
				}
				if (m.name == "cup") {
					m.material = _cupMaterial;
				}
				if (m.name == "box") {
					m.material = _boxMaterial;
				}
			}
		}
		
		/**
		 * render loop
		 */
		private function _onEnterFrame(e:Event):void {
			// light update
			_altitude += 0.1;
			if (_altitude >= 360)
				_altitude = .1;
			
			_sunLight.position = Orbit(_altitude, _azimuth, 2000).add(_center);
			_sunLight.lookAt(_center);
			// controller update
			if (_move) {
				_controller.panAngle = 0.3 * (stage.mouseX - _lastMouseX) + _lastPanAngle;
				_controller.tiltAngle = 0.3 * (stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
			_controller.lookAtPosition = _center;
			_controller.update();
			_view.render();
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void {
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
		
		/**
		 * stage listener for mouse navigation
		 */
		private function onMouseUp(event:Event):void {
			_move = false;
		
		}
		
		private function onMouseDown(event:MouseEvent):void {
			_lastPanAngle = _controller.panAngle;
			_lastTiltAngle = _controller.tiltAngle;
			_lastMouseX = stage.mouseX;
			_lastMouseY = stage.mouseY;
			_move = true;
		}
		
		private function onMouseWheel(ev:MouseEvent):void {
			_controller.distance -= ev.delta * 5;
			if (_controller.distance < 100)
				_controller.distance = 100;
			else if (_controller.distance > 2000)
				_controller.distance = 2000;
		}
		
		/**
		 * create bitmapData
		 */
		private function cup():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(32, 64, RadDeg(-90));
			s.graphics.beginGradientFill("linear", [0x89a04e, 0x4a691d, 0x89a04e], [1, 1, 1], [0x00, 0x80, 0xFF], m, "reflect");
			s.graphics.drawRect(0, 0, 64, 64);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(64, 64, false, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function apple():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(64, 32, RadDeg(90));
			s.graphics.beginGradientFill("linear", [0x46381e, 0xfad553, 0xd82102, 0xa43f11], [1, 1, 1, 1], [0x00, 0x30, 0xAA, 0xFF], m, "reflect");
			s.graphics.drawRect(0, 0, 64, 64);
			s.graphics.endFill();
			s.graphics.beginFill(0x8f4518);
			s.graphics.drawRect(0, 0, 13, 9);
			s.graphics.endFill();
			s.graphics.beginFill(0x46381e);
			s.graphics.drawRect(13, 0, 4, 4);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(64, 64, false, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function desk():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(64, 64, 0);
			s.graphics.beginGradientFill("linear", [0x8f4518, 0x4e2a08, 0x72300d], [1, 1, 1], [0x00, 0x80, 0xFF], m);
			s.graphics.drawRect(0, 0, 64, 64);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(64, 64, false, 0x00000000);
			b.draw(s);
			return b;
		}
		
		/**
		 * Math function
		 */
		private function Orbit(H:Number, V:Number, D:Number):Vector3D {
			var p:Vector3D = new Vector3D()
			var phi:Number = RadDeg(H);
			var theta:Number = RadDeg(V);
			p.x = (D * Math.sin(phi) * Math.cos(theta));
			p.z = (D * Math.sin(phi) * Math.sin(theta));
			p.y = (D * Math.cos(phi));
			return p;
		}
		
		private function RadDeg(d:Number):Number {
			return (d * (Math.PI / 180));
		}
	}
}
