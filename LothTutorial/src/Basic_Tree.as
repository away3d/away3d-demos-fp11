/*

   3D forest example in Away3d

   Demonstrates:

   How to use AWD link for easy import
   How to create layered terrain on fly

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
	import away3d.lights.DirectionalLight;
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
	import flash.filters.BlurFilter;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	[SWF(backgroundColor="#7eace7",frameRate="60")]
	
	public class Basic_Tree extends Sprite {
		//tree object
		[Embed(source="/../embeds/tree.awd",mimeType="application/octet-stream")]
		public static var TREE:Class;
		
		//engine variables
		private var _view:View3D;
		private var _controller:HoverController;
		private var _sunLight:DirectionalLight;
		private var _lightPicker:StaticLightPicker;
		
		//scene methode
		private var _baseShadowMethod:DitheredShadowMapMethod;
		private var _cascadeMethod:CascadeShadowMapMethod;
		private var _cascadeShadowMapper:CascadeShadowMapper;
		private var _terrainMethode:TerrainDiffuseMethod;
		private var _specularMethod:FresnelSpecularMethod;
		private var _outlineMethod:OutlineMethod;
		private var _fog:FogMethod;
		
		//scene objects
		private var _plane:Mesh;
		private var _planeMask:Mesh;
		private var _fieldSubGeometry:SubGeometry;
		private var _tree:Mesh;
		
		//scene material
		private var _groundMaterial:TextureMultiPassMaterial;
		private var _trunkMaterial:TextureMultiPassMaterial;
		private var _leaveMaterial:TextureMultiPassMaterial;
		private var _flowerMaterial:TextureMultiPassMaterial;
		private var _maskMaterial:TextureMaterial;
		
		//mouse navigation 
		private var _move:Boolean = false;
		private const _mouseNav:Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 50, 1000]);
		
		private var _bgColor:uint = 0x527096; //7eace7;
		private var _center:Vector3D = new Vector3D(0, 50, 0);
		private var _azimuth:Number = 10;
		private var _altitude:Number = 20;
		
		//field variable
		private var _terrainResolution:int = 128;
		private var _terrainHeight:int = 300;
		private var _terrainDistance:int = 1000;
		private var _bump:BitmapData;
		private const _textures:Vector.<BitmapTexture> = new Vector.<BitmapTexture>();
		
		/**
		 * Constructor
		 */
		public function Basic_Tree() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//setup the view
			_view = new View3D();
			_view.backgroundColor = _bgColor;
			_view.antiAlias = 8;
			addChild(_view);
			
			//setup the camera
			_view.camera.lens = new PerspectiveLens(70);
			_view.camera.lens.near = 10;
			_view.camera.lens.far = 2000;
			
			//setup the camera controller
			_controller = new HoverController(_view.camera, null, 0, 3, 800, -5, 90);
			_controller.wrapPanAngle = true;
			_controller.autoUpdate = false;
			_controller.lookAtPosition = _center;
			
			//init light & Shadow
			_sunLight = new DirectionalLight();
			_sunLight.color = 0xFFFFEF;
			_sunLight.ambient = 0.8;
			_sunLight.diffuse = 1;
			_sunLight.specular = 1;
			_view.scene.addChild(_sunLight);
			_lightPicker = new StaticLightPicker([_sunLight]);
			
			_cascadeShadowMapper = new CascadeShadowMapper(3);
			_cascadeShadowMapper.lightOffset = 20000;
			_sunLight.castsShadows = false;
			_sunLight.shadowMapper = _cascadeShadowMapper;
			_sunLight.shadowMapper.depthMapSize = 2048;
			_baseShadowMethod = new DitheredShadowMapMethod(_sunLight);
			_cascadeMethod = new CascadeShadowMapMethod(_baseShadowMethod);
			_cascadeMethod.epsilon = .0007;
			_cascadeMethod.alpha = 0.6;
			
			_fog = new FogMethod(300, 1500, _bgColor);
			_outlineMethod = new OutlineMethod(0x2c2421, 2, true, false);
			
			//ground noise
			_bump = new BitmapData(_terrainResolution, _terrainResolution, false, 0xffffff);
			//init materials
			_groundMaterial = new TextureMultiPassMaterial(new BitmapTexture(_bump));
			_trunkMaterial = new TextureMultiPassMaterial(new BitmapTexture(trunk()));
			_leaveMaterial = new TextureMultiPassMaterial(new BitmapTexture(leave()));
			_leaveMaterial.alphaThreshold = 0.5;
			_flowerMaterial = new TextureMultiPassMaterial(new BitmapTexture(flower()));
			_flowerMaterial.alphaThreshold = 0.5;
			
			_maskMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0x354961)));
			
			_groundMaterial.lightPicker = _lightPicker;
			_trunkMaterial.lightPicker = _lightPicker;
			_leaveMaterial.lightPicker = _lightPicker;
			_flowerMaterial.lightPicker = _lightPicker;
			
			_groundMaterial.shadowMethod = _cascadeMethod;
			_trunkMaterial.shadowMethod = _cascadeMethod;
			_leaveMaterial.shadowMethod = _cascadeMethod;
			_flowerMaterial.shadowMethod = _cascadeMethod;
			
			_groundMaterial.addMethod(_outlineMethod);
			
			_groundMaterial.addMethod(_fog);
			_trunkMaterial.addMethod(_fog);
			_leaveMaterial.addMethod(_fog);
			_flowerMaterial.addMethod(_fog);
			_maskMaterial.addMethod(_fog);
			
			_specularMethod = new FresnelSpecularMethod();
			_specularMethod.normalReflectance = 0.2;
			_groundMaterial.specularMethod = _specularMethod;
			_groundMaterial.gloss = 60;
			//setup the scene
			_plane = new Mesh(new PlaneGeometry(_terrainDistance, _terrainDistance, _terrainResolution - 1, _terrainResolution - 1), _groundMaterial);
			_plane.geometry.convertToSeparateBuffers();
			// _plane.castsShadows = false;
			_view.scene.addChild(_plane);
			// get the field sugGeometry referency
			_fieldSubGeometry = _plane.geometry.subGeometries[0] as SubGeometry;
			_fieldSubGeometry.autoDeriveVertexNormals = true;
			_fieldSubGeometry.autoDeriveVertexTangents = true;
			
			_planeMask = new Mesh(new PlaneGeometry(_terrainDistance * 2, _terrainDistance * 2), _maskMaterial);
			_view.scene.addChild(_planeMask);
			_planeMask.y = 2;
			_planeMask.castsShadows = false;
			//create terrain noise
			updateFieldGeometry();
			//get center of camera
			_center.y = getHeightAt() + 50;
			
			//parse tree model
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
			AssetLibrary.loadData(new TREE(), null, null, new AWD2Parser());
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}
		
		private function onResourceComplete(event:LoaderEvent):void {
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			initTreeModel();
		}
		
		private function onAssetComplete(event:AssetEvent):void {
			var m:Mesh;
			if (event.asset.assetType == AssetType.MESH) {
				m = event.asset as Mesh;
				if (m.name == "Foliage001") {
					m.material = _trunkMaterial;
					m.geometry.scaleUV(2, 10);
					_tree = m;
				}
				if (m.name == "Foliage002") {
					m.material = _leaveMaterial;
				}
				if (m.name == "Foliage003") {
					m.material = _flowerMaterial;
				}
			}
		}
		
		/**
		 * init tree model
		 */
		private function initTreeModel():void {
			//_view.scene.addChild(_tree);
			// create some clones
			var m:Mesh;
			var x:int, y:int, z:int;
			for (var i:uint; i < 30; ++i) {
				m = _tree.clone() as Mesh;
				m.scale(0.3 + Math.random() * 0.8);
				
				x = -(_terrainDistance / 2) + (Math.random() * _terrainDistance);
				z = -(_terrainDistance / 2) + (Math.random() * _terrainDistance);
				y = getHeightAt(x, z) - 20;
				while (y < 50) {
					x = -(_terrainDistance / 2) + (Math.random() * _terrainDistance);
					z = -(_terrainDistance / 2) + (Math.random() * _terrainDistance);
					y = getHeightAt(x, z) - 20;
					
					m.position = new Vector3D(x, y, z);
					m.rotationX = Math.random() * 5;
					m.rotationZ = Math.random() * 5;
					m.rotationY = Math.random() * 360;
					_view.scene.addChild(m);
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
				_controller.panAngle = 0.3 * (stage.mouseX - _mouseNav[0]) + _mouseNav[2];
				_controller.tiltAngle = 0.3 * (stage.mouseY - _mouseNav[1]) + _mouseNav[3];
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
			_mouseNav[0] = stage.mouseX;
			_mouseNav[1] = stage.mouseY;
			_mouseNav[2] = _controller.panAngle;
			_mouseNav[3] = _controller.tiltAngle;
			_move = true;
		}
		
		private function onMouseWheel(ev:MouseEvent):void {
			_controller.distance -= ev.delta * 5;
			if (_controller.distance < _mouseNav[4])
				_controller.distance = _mouseNav[4];
			else if (_controller.distance > _mouseNav[5])
				_controller.distance = _mouseNav[5];
		}
		
		/**
		 * create noise terrain
		 */
		private function updateFieldGeometry():void {
			_bump.lock();
			_bump.perlinNoise(_terrainResolution * 0.12, _terrainResolution * 0.12, 1, int(Math.random() * 0xffffffff), false, true, 7, true, [new Point(0, 0)]);
			_bump.draw(islandMapCache());
			_bump.unlock();
			var i:uint, px:uint, c:uint;
			var v:Vector.<Number> = _fieldSubGeometry.vertexData;
			var l:uint = v.length;
			for (i = 1; i < l; i += 3, ++c) {
				px = _bump.getPixel(c % _terrainResolution, _terrainResolution - (c / _terrainResolution));
				// Displace y position by the range
				v[i] = (_terrainHeight * px / 0xffffff);
			}
			// update plane geometry
			_fieldSubGeometry.updateVertexData(v);
			// update plane texture
			//BitmapTexture(TextureMultiPassMaterial(_groundMaterial).texture).invalidateContent();
			// material method
			_textures[0] = new BitmapTexture(new BitmapData(64, 64, false, 0x5b4237));
			_textures[1] = new BitmapTexture(new BitmapData(64, 64, false, 0xb99c56));
			_textures[2] = new BitmapTexture(new BitmapData(64, 64, false, _bgColor));
			_textures[3] = new BitmapTexture(layerTerrainBitmap(_bump));
			
			_terrainMethode = new TerrainDiffuseMethod([_textures[0], _textures[1], _textures[2]], _textures[3], [1, 10, 10, 10]);
			_groundMaterial.diffuseMethod = _terrainMethode;
		}
		
		/**
		 * get height possition on terrain
		 */
		private function getHeightAt(x:Number = 0, z:Number = 0):Number {
			var col:int = _bump.getPixel((x / _terrainDistance + .5) * (_terrainResolution + 1), (-z / _terrainDistance + .5) * (_terrainResolution + 1)) & 0xffffff;
			return int(_terrainHeight * col / 0xffffff);
		}
		
		/**
		 * create bitmapData
		 */
		private function trunk():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(32, 64, 0);
			s.graphics.beginGradientFill("linear", [0x32321d, 0x51523a, 0x7d7d64], [1, 1, 1], [0x00, 0x80, 0xFF], m, "reflect");
			s.graphics.drawRect(0, 0, 64, 64);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(64, 64, false, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function leave():BitmapData {
			var s:Sprite = new Sprite();
			var j:Sprite;
			var m:Matrix = new Matrix();
			m.createGradientBox(30, 60, -Math.PI / 2);
			for (var i:uint; i < 2; ++i) {
				j = new Sprite();
				j.graphics.beginGradientFill("linear", [0xd7d82b, 0x929624, 0x938f25], [1, 1, 1], [0x30, 0xbb, 0xFF], m);
				j.graphics.drawEllipse(0, 8 + (i * 10), 30 - (i * 10), 58 - (i * 10));
				j.graphics.endFill();
				j.rotation = -25 - 30 * i;
				s.addChild(j);
			}
			var b:BitmapData = new BitmapData(64, 64, true, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function flower():BitmapData {
			var j:Sprite;
			var m:Matrix = new Matrix();
			m.createGradientBox(20, 30, -Math.PI / 2);
			var s:Sprite = new Sprite();
			var js:Sprite;
			for (var i:uint; i < 5; ++i) {
				j = new Sprite();
				j.graphics.beginGradientFill("linear", [0xffffff, 0xfe9ec6, 0xb70616], [1, 1, 1], [0x00, 0xAA, 0xFF], m);
				j.graphics.drawEllipse(-10, 0, 20, 30);
				j.graphics.endFill();
				j.x = j.y = 32
				j.rotation = i * (70 + Math.random() * 2);
				s.addChild(j);
			}
			var b:BitmapData = new BitmapData(64, 64, true, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function islandMapCache():BitmapData {
			var groundAdd:BitmapData = new BitmapData(_terrainResolution, _terrainResolution, true, 0x000000);
			var g:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(_terrainResolution, _terrainResolution);
			g.graphics.beginGradientFill("radial", [0x000000, 0x000000, 0x000000, 0x000000], [0, 0.2, 0.5, 1], [0x00, 0x99, 0xAA, 0xEF], m);
			g.graphics.drawRect(0, 0, _terrainResolution, _terrainResolution);
			groundAdd.draw(g);
			g.graphics.clear();
			return groundAdd;
		}
		
		private function layerTerrainBitmap(B:BitmapData):BitmapData {
			var layerTop:Array = [0x555555, 0x161616]
			var layer00:BitmapData = new BitmapData(_terrainResolution, _terrainResolution, false, 0x000000);
			var layer01:BitmapData = new BitmapData(_terrainResolution, _terrainResolution, true, 0x000000);
			var layer02:BitmapData = new BitmapData(_terrainResolution, _terrainResolution, true, 0x000000);
			var rect:Rectangle = B.rect;
			var p:Point = new Point();
			// red _ top
			layer00 = B.clone();
			layer00.colorTransform(rect, new ColorTransform(1, 0, 0, 1, 255, 0, 0, 0));
			// green _ mid
			layer01.threshold(B, rect, p, ">", 0xFF000000 + layerTop[0], 0x0000000, 0xFFFFFFFF, true);
			layer01.colorTransform(rect, new ColorTransform(0, 1, 0, 1, 0, 255, 0, 0));
			layer01.applyFilter(layer01, rect, p, new BlurFilter(12, 12, 2));
			// blue _ bottom
			layer02.threshold(B, rect, p, ">", 0xFF000000 + layerTop[1], 0x0000000, 0xFFFFFFFF, true);
			layer02.colorTransform(rect, new ColorTransform(0, 0, 1, 1, 0, 0, 255, 0));
			layer02.applyFilter(layer02, rect, p, new BlurFilter(6, 6, 2));
			
			// copy chanel from other layer to base layer
			layer00.draw(layer01);
			layer00.draw(layer02);
			layer01.dispose();
			layer02.dispose();
			return layer00;
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
