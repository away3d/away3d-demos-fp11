/*

Basic Oimophysic physics 

Demonstrates:

How initialise and use oimophysic in away3d.

Code by LoTh
3dflashlo@gmail.com
http://3dflashlo.wordpress.com
Oimophysic by Saharan
http://el-ement.com

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
	import flash.text.TextField;

	import away3d.containers.*;
	import away3d.entities.*;
	import away3d.materials.*;
	import away3d.primitives.*;
	import away3d.utils.*;

	import physics.OimoPhysics;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.text.TextFormat;

	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	public class Demo_Physics extends Sprite {
		// engine variables
		private var _view : View3D;
		private var _text : TextField;
		// scene objects
		private var _plane : Mesh;
		private var _sphere : Mesh;
		private var _sphere2 : Mesh;

		/**
		 * Constructor
		 */
		public function Demo_Physics() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			initText();

			log("weclome");
			// setup the view
			_view = new View3D();
			addChild(_view);
			OimoPhysics.getInstance();

			OimoPhysics.addCube(1000, 100, 1000, 0, -100, 0);
			OimoPhysics.addSphere(150, 0, 500, 0, 10, 0.2, false);
			OimoPhysics.addSphere(50, 0, 1000, 0, 10, 0.2, false);

			// setup the camera
			_view.camera.z = -2000;
			_view.camera.y = 500;
			_view.camera.lookAt(new Vector3D());

			// setup the scene
			_plane = new Mesh(new CubeGeometry(1000, 100, 1000), new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, false, 0x888))));
			_view.scene.addChild(_plane);
			_plane.position = OimoPhysics.rigidPosition(0);

			_sphere = new Mesh(new SphereGeometry(150), new ColorMaterial(0xff0000));
			_view.scene.addChild(_sphere);

			_sphere2 = new Mesh(new SphereGeometry(50), new ColorMaterial(0xff0000));
			_view.scene.addChild(_sphere2);

			// setup the render loop
			addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}

		/**
		 * render loop
		 */
		private function _onEnterFrame(e : Event) : void {
			OimoPhysics.update();
			_plane.rotationY += 1;
			_sphere.position = OimoPhysics.rigidPosition(1);
			_sphere2.position = OimoPhysics.rigidPosition(2);

			log(OimoPhysics.info());
			_view.render();
		}

		/**
		 * stage listener for resize events
		 */
		private function onResize(event : Event = null) : void {
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}

		/**
		 * Initialise interface 
		 */
		private function initText() : void {
			_text = new TextField();
			var format : TextFormat = new TextFormat("Helvetica", 9, 0xdddddd);
			format.letterSpacing = 1;
			format.leftMargin = 5;
			format.leading = 1;
			_text.defaultTextFormat = format;
			_text.y = 5;
			_text.width = 300;
			_text.height = 250;
			_text.selectable = false;
			_text.mouseEnabled = true;
			_text.wordWrap = true;
			addChild(_text);
		}

		/**
		 * Display text
		 */
		private function log(t : String) : void {
			_text.htmlText = t;
		}
	}
}
