/*

   3D SpaceMan example in Away3d

   Demonstrates:

   How to use AWD animation
   How to add multy mesh to same animator
   How to link mesh to bones structur

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
	import away3d.tools.helpers.MeshHelper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.animators.data.Skeleton;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.nodes.SkeletonClipNode;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	[SWF(backgroundColor="#4a69ff",frameRate="60")]
	
	public class Basic_MultySqueleton extends Sprite {
		[Embed(source="/../embeds/man.awd",mimeType="application/octet-stream")]
		public static var MAN:Class;
		
		//engine variables
		private var _view:View3D;
		private var _controller:HoverController;
		private var _sunLight:DirectionalLight;
		private var _pinLight:PointLight;
		private var _lightPicker:StaticLightPicker;
		private var _shadowMapMethod:FilteredShadowMapMethod;
		private var _outlineMethod:OutlineMethod;
		private var _outlineMethod2:OutlineMethod;
		private var _fogMethod:FogMethod;
		private var _fogMethod2:FogMethod;
		
		//scene objects
		private var _plane:Mesh;
		private var _man:Mesh;
		private var _spaceSuit:Mesh;
		private var _helmet:Mesh;
		private var _backSphere:Mesh;
		private const _bipedMeshs:Vector.<Mesh> = new Vector.<Mesh>;
		
		//animations
		private var _squeleton:Skeleton;
		private var _animationSet:SkeletonAnimationSet;
		private var _animator:SkeletonAnimator;
		private const AnimName:Array = ["Breathe", "Walk", "Run", "Sit"];
		
		//scene material
		private var _manMaterial:TextureMaterial;
		private var _spaceMaterial:TextureMaterial;
		private var _helmetMaterial:TextureMaterial;
		private var _groundMaterial:TextureMaterial
		private var _rightMaterial:TextureMaterial;
		private var _leftMaterial:TextureMaterial;
		private var _midMaterial:TextureMaterial;
		private var _backgroundMaterial:TextureMaterial;
		
		//mouse navigation 
		private var _move:Boolean = false;
		private const _mouseNav:Vector.<Number> = Vector.<Number>([0, 0, 0, 0, 50, 300]);
		private var _center:Vector3D = new Vector3D(0, 40, 0);
		
		private var _bgColor:uint = 0x4a69ff;
		private var _azimuth:Number = 45;
		private var _altitude:Number = -90;
		private var _isWithBiped:Boolean = true;
		
		/**
		 * Constructor
		 */
		public function Basic_MultySqueleton() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//setup the view
			_view = new View3D();
			_view.backgroundColor = _bgColor;
			_view.antiAlias = 8;
			addChild(_view);
			
			//setup the camera
			_view.camera.lens = new PerspectiveLens(60);
			_view.camera.lens.near = 10;
			_view.camera.lens.far = 1000;
			
			//setup the camera controller
			_controller = new HoverController(_view.camera, null, 140, 5, 100, -5, 90);
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
			_pinLight.color = 0x4b61ff;
			_pinLight.ambient = 0;
			_pinLight.diffuse = 0.5;
			_pinLight.specular = 0.5;
			_pinLight.position = new Vector3D(-100, 100, -200);
			_view.scene.addChild(_pinLight);
			
			_lightPicker = new StaticLightPicker([_sunLight, _pinLight]);
			
			//setup methods
			_shadowMapMethod = new FilteredShadowMapMethod(_sunLight);
			_fogMethod = new FogMethod(10, 600, _bgColor);
			_fogMethod2 = new FogMethod(0, 300, 0xffffff);
			_outlineMethod = new OutlineMethod(0x000000, 0.5, true, false);
			_outlineMethod2 = new OutlineMethod(0x000000, 0.5, true, false);
			
			//init materials
			_manMaterial = new TextureMaterial(new BitmapTexture(manMap()));
			_spaceMaterial = new TextureMaterial(new BitmapTexture(spaceMap()));
			_helmetMaterial = new TextureMaterial(new BitmapTexture(spaceMap()));
			_rightMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0x33ff33)));
			_leftMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0x3333ff)));
			_midMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0xffff33)));
			_backgroundMaterial = new TextureMaterial(new BitmapTexture(background()));
			_groundMaterial = new TextureMaterial(new BitmapTexture(new BitmapData(64, 64, false, 0xffffff)));
			_groundMaterial.blendMode = "multiply";
			_groundMaterial.ambient = 1.5;
			_groundMaterial.specular = 0;
			
			_manMaterial.lightPicker = _lightPicker;
			_spaceMaterial.lightPicker = _lightPicker;
			_helmetMaterial.lightPicker = _lightPicker;
			_rightMaterial.lightPicker = _lightPicker;
			_leftMaterial.lightPicker = _lightPicker;
			_midMaterial.lightPicker = _lightPicker;
			_groundMaterial.lightPicker = _lightPicker;
			
			_manMaterial.shadowMethod = _shadowMapMethod;
			_spaceMaterial.shadowMethod = _shadowMapMethod;
			_helmetMaterial.shadowMethod = _shadowMapMethod;
			_rightMaterial.shadowMethod = _shadowMapMethod;
			_leftMaterial.shadowMethod = _shadowMapMethod;
			_midMaterial.shadowMethod = _shadowMapMethod;
			_groundMaterial.shadowMethod = _shadowMapMethod;
			
			_manMaterial.addMethod(_outlineMethod);
			_manMaterial.alphaBlending = true;
			
			_spaceMaterial.addMethod(_outlineMethod);
			_spaceMaterial.alphaBlending = true;
			
			_helmetMaterial.addMethod(_outlineMethod2);
			_helmetMaterial.alphaBlending = true;
			
			_manMaterial.addMethod(_fogMethod);
			_spaceMaterial.addMethod(_fogMethod);
			_helmetMaterial.addMethod(_fogMethod);
			_rightMaterial.addMethod(_fogMethod);
			_leftMaterial.addMethod(_fogMethod);
			_midMaterial.addMethod(_fogMethod);
			_groundMaterial.addMethod(_fogMethod2);
			
			_helmetMaterial.gloss = 120;
			_manMaterial.gloss = 60;
			_spaceMaterial.gloss = 10;
			
			//create background invers sphere
			_backSphere = new Mesh(new SphereGeometry(400, 20, 16), _backgroundMaterial);
			_backSphere.geometry.convertToSeparateBuffers();
			MeshHelper.invertFaces(_backSphere);
			_backSphere.castsShadows = false;
			_view.scene.addChild(_backSphere);
			_backSphere.rotationZ = -7;
			
			//parse model
			parseManModel();
			
			_plane = new Mesh(new PlaneGeometry(500, 500), _groundMaterial), _view.scene.addChild(_plane);
			_plane.castsShadows = false;
			_plane.y = -3;
			
			//setup the render loop
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			
			//setup mouse navigation
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
		private function parseManModel():void {
			AssetLibrary.loadData(new MAN(), null, null, new AWD2Parser());
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
		}
		
		private function onResourceComplete(event:LoaderEvent):void {
			AssetLibrary.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			
			//add the man model
			_view.scene.addChild(_man);
			_animator = new SkeletonAnimator(_animationSet, _squeleton);
			_man.animator = _animator;
			_animator.play(AnimName[1]);
			_animator.playbackSpeed = 0.2;
			
			//add space suit model with same animator
			//in 3dsmax make a copy of man with skin and apply push modifier
			_view.scene.addChild(_spaceSuit);
			_spaceSuit.animator = _animator;
			
			_view.scene.addChild(_helmet);
			
			//add the 3dsmax biped mesh just for test
			for (var i:uint; i < _bipedMeshs.length; ++i) {
				if (i > 0) {
					if (i == 4)
						_bipedMeshs[i].visible = false;
					if (i != 3 && i != 4 && i != 6 && i != 12 && i != 8)
						_view.scene.addChild(_bipedMeshs[i])
				}
			}
		
		}
		
		/**
		 * move biped mesh to follow bones
		 */
		public function updateMeshBone():void {
			if (_animator && _animator.globalPose.numJointPoses == 16) {
				
				_helmet.transform = _animator.globalPose.jointPoses[15].toMatrix3D();
				
				if (_isWithBiped) {
					// pelvis
					_bipedMeshs[1].transform = _animator.globalPose.jointPoses[0].toMatrix3D();
					_bipedMeshs[1].roll(-90);
					// pelvis
					_bipedMeshs[2].transform = _animator.globalPose.jointPoses[1].toMatrix3D();
					//leg L
					_bipedMeshs[19].transform = _animator.globalPose.jointPoses[2].toMatrix3D();
					_bipedMeshs[20].transform = _animator.globalPose.jointPoses[3].toMatrix3D();
					_bipedMeshs[21].transform = _animator.globalPose.jointPoses[4].toMatrix3D();
					_bipedMeshs[21].yaw(60);
					// leg R
					_bipedMeshs[16].transform = _animator.globalPose.jointPoses[5].toMatrix3D();
					_bipedMeshs[17].transform = _animator.globalPose.jointPoses[6].toMatrix3D();
					_bipedMeshs[18].transform = _animator.globalPose.jointPoses[7].toMatrix3D();
					_bipedMeshs[18].yaw(60);
					// shest
					_bipedMeshs[5].transform = _animator.globalPose.jointPoses[8].toMatrix3D();
					// arm R
					_bipedMeshs[9].transform = _animator.globalPose.jointPoses[9].toMatrix3D();
					_bipedMeshs[10].transform = _animator.globalPose.jointPoses[10].toMatrix3D();
					_bipedMeshs[11].transform = _animator.globalPose.jointPoses[11].toMatrix3D();
					//arm L
					_bipedMeshs[13].transform = _animator.globalPose.jointPoses[12].toMatrix3D();
					_bipedMeshs[14].transform = _animator.globalPose.jointPoses[13].toMatrix3D();
					_bipedMeshs[15].transform = _animator.globalPose.jointPoses[14].toMatrix3D();
					//head 
					_bipedMeshs[7].transform = _animator.globalPose.jointPoses[15].toMatrix3D();
				}
			}
		}
		
		private function onAssetComplete(event:AssetEvent):void {
			var m:Mesh;
			if (event.asset.assetType == AssetType.MESH) {
				m = event.asset as Mesh;
				if (m.name == "man_mid") {
					m.material = _manMaterial;
					_man = m;
				} else if (m.name == "space_suit") {
					m.material = _spaceMaterial;
					_spaceSuit = m;
				} else if (m.name == "helmet") {
					m.material = _helmetMaterial;
					_helmet = m;
				} else {
					if (m.name.substring(7, 8) == "R") {
						m.material = _rightMaterial;
					} else if (m.name.substring(7, 8) == "L") {
						m.material = _leftMaterial;
					} else {
						m.material = _midMaterial;
					}
					//remove biped part than not linked with bone
					if (m.name.substring(9) != "Toe0" && m.name.substring(9) != "Finger0")
						_bipedMeshs.push(m);
				}
				
			} else if (event.asset.assetType == AssetType.SKELETON) {
				_squeleton = event.asset as Skeleton;
				_animationSet = new SkeletonAnimationSet(3);
			} else if (event.asset.assetType == AssetType.ANIMATION_NODE) {
				_animationSet.addAnimation(event.asset as SkeletonClipNode);
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
			
			updateMeshBone();
			
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
		 * create bitmapData
		 */
		private function manMap():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(64, 32, RadDeg(90));
			s.graphics.beginGradientFill("linear", [0x46381e, 0xfad553, 0xd82102, 0xa43f11], [0.3, 0.6, 0.9, 0.5], [0x00, 0x30, 0xAA, 0xFF], m, "reflect");
			s.graphics.drawRect(0, 0, 64, 64);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(64, 64, true, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function spaceMap():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(64, 32, RadDeg(90));
			s.graphics.beginGradientFill("linear", [0x505050, 0x606060, 0x808080, 0xcccccc], [0.3, 0.6, 0.9, 0.5], [0x00, 0x30, 0xAA, 0xFF], m, "reflect");
			s.graphics.drawRect(0, 0, 64, 64);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(64, 64, true, 0x00000000);
			b.draw(s);
			return b;
		}
		
		private function background():BitmapData {
			var s:Sprite = new Sprite();
			var m:Matrix = new Matrix();
			m.createGradientBox(512, 512, RadDeg(-90));
			s.graphics.beginGradientFill("linear", [0x1c2060, 0x2a3a80, 0x3c4fff, 0x4f61ff], [1, 1, 1, 1], [0x30, 0x90, 0xAA, 0xFF], m);
			s.graphics.drawRect(0, 0, 512, 512);
			s.graphics.endFill();
			var b:BitmapData = new BitmapData(512, 512, false, 0x00000000);
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
