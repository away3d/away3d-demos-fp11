/*

RANDOM LAND

Demonstrates:

How to use the Loader3D object to load an embedded internal awd model.
How to create character interaction in physic world
How to set custom material on a model.

Code, model and map by LoTh
3dflashlo@gmail.com
http://3dflashlo.wordpress.com

This code is distributed under the MIT License

Copyright (c)

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
	import away3d.events.MouseEvent3D;
	import away3d.primitives.SphereGeometry;
	import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.methods.FogMethod;
	import away3d.controllers.HoverController;
	import away3d.core.pick.PickingColliderType;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.lights.DirectionalLight;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.utils.Cast;

	import flash.display.StageDisplayState;
	import flash.filters.DropShadowFilter;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.events.MouseEvent;
	import flash.text.GridFitType;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;

	import utils.AutoMapSky;
	import utils.LoaderPool;

	import com.bit101.components.Style;
	import com.bit101.components.PushButton;

	import games.Lander;

	[SWF(backgroundColor="#000000", frameRate="60")]
	public class Demo_Random_Land extends Sprite {
		private const MOUNTAIGN_TOP : Number = 2000;
		private const FARVIEW : Number = 128 * 100;
		private const FOGNEAR : Number = 0;
		// start colors
		private var groundColor : uint = 0x333338;
		private var fogColor : uint = 0x000000;
		private var skyColor : uint = 0x445465;
		private var sunColor : uint = 0xFFFFFF;
		// bitmaps
		private var _bitmapStrings : Vector.<String>;
		private var _bitmaps : Vector.<BitmapData>;
		// engine variables
		private var _view : View3D;
		private var _stats : AwayStats;
		private var _lightPicker : StaticLightPicker;
		private var _cameraController : HoverController;
		private var _night : Number = 100;
		// scene objects
		private var _lander : Lander;
		private var _ground : Mesh;
		private var _sunLight : DirectionalLight;
		private var _player : ObjectContainer3D;
		// materials
		private var _terrainMaterial : TextureMaterial;
		private var _waterMaterial : TextureMaterial;
		private var _boxMaterial : TextureMaterial;
		private var _materials : Vector.<TextureMaterial>;
		// methodes
		private var _shadowMethod : NearShadowMapMethod;
		private var _reflectionMethod : EnvMapMethod;
		private var _fresnelMethod : FresnelSpecularMethod;
		private var _waterMethod : SimpleWaterNormalMethod;
		private var _fogMethode : FogMethod;
		// navigation
		private var _prevMouseX : Number;
		private var _prevMouseY : Number;
		private var _mouseMove : Boolean;
		// demo testing
		private var _isIntro : Boolean = true;
		private var _isRotation : Boolean;
		private var _isRender : Boolean;
		// interface
		private var _text : TextField;
		private var _signature : Sprite;
		private var _capture : BitmapData;
		private var _topPause : Sprite;
		private var _menu : Sprite;

		/**
		 * Constructor
		 */
		public function Demo_Random_Land() {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}

		/**
		 * Global initialise function
		 */
		private function init(e : Event = null) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;

			initEngine();
			initText();
			initSetting();
			initLights();

			// kickoff asset loading
			_bitmapStrings = new Vector.<String>();
			_bitmapStrings.push("sky3/negy.jpg", "sky3/posy.jpg", "sky3/posx.jpg", "sky3/negz.jpg", "sky3/posz.jpg", "sky3/negx.jpg");
			_bitmapStrings.push("rock.jpg", "sand.jpg", "arid.jpg");
			_bitmapStrings.push("water_normals.jpg");

			LoaderPool.log = log;
			LoaderPool.loadBitmaps(_bitmapStrings, initAfterBitmapLoad);
			_bitmaps = LoaderPool.bitmaps;
		}

		/**
		 * Initialise the scene objects
		 */
		private function initAfterBitmapLoad() : void {
			// create material
			initMaterials();

			// create skybox
			randomSky();
			// reflection method
			_reflectionMethod = new EnvMapMethod(AutoMapSky.skyMap, 0.8);
			_waterMaterial.addMethod(_reflectionMethod);
			_boxMaterial.addMethod(_reflectionMethod);
			// create lander
			_lander = new Lander();
			_lander.scene = _view.scene;
			_lander.bitmaps = [_bitmaps[6], _bitmaps[7], _bitmaps[8]];
			_lander.initObjects(_terrainMaterial, FARVIEW * 2, MOUNTAIGN_TOP);
			// _lander.moveCenter(0.1, 0);
			// basic ground
			_ground = new Mesh(new PlaneGeometry(FARVIEW * 2, FARVIEW * 2), _waterMaterial);
			_ground.geometry.scaleUV(40, 40);
			_ground.mouseEnabled = true;
			_ground.pickingCollider = PickingColliderType.BOUNDS_ONLY;
			_ground.y = 100;
			// _ground.castsShadows = false;
			_view.scene.addChild(_ground);
			_ground.addEventListener(MouseEvent3D.MOUSE_UP, onGroundMouseOver);
			// _ground.addEventListener(MouseEvent3D.MOUSE_DOWN, onGroundMouseOver);
			_ground.addEventListener(MouseEvent3D.MOUSE_MOVE, onGroundMouseOver);
			initListeners();
			log(message());

			var spaceShip : Mesh = new Mesh(new SphereGeometry(60, 30, 20), _boxMaterial);
			var spaceShip2 : Mesh = new Mesh(new SphereGeometry(140, 30, 20), _boxMaterial);
			spaceShip2.scaleY = 0.25;
			spaceShip.y = 100;
			spaceShip2.y = 100;
			_player.addChild(spaceShip);
			_player.addChild(spaceShip2);
			spaceShip2.addEventListener(MouseEvent3D.MOUSE_DOWN, onShipMouseDown);
			spaceShip2.mouseEnabled = true;
			// load spaceship mesh
			// load("SpaceShip.awd"+ "?uniq=" + _id);
		}

		/**
		 * Initialise the engine
		 */
		private function initEngine() : void {
			// create the view
			_view = new View3D();
			addChild(_view);

			// create custom lens
			_view.camera.lens = new PerspectiveLens(80);
			_view.camera.lens.far = FARVIEW;
			_view.camera.lens.near = 1;
			_view.forceMouseMove = true;
			// setup controller to be used on the camera
			_cameraController = new HoverController(_view.camera, null, 22, 0, 1000, 10, 90);
			_cameraController.tiltAngle = 10;
			_cameraController.panAngle = 22;
			_cameraController.minTiltAngle = -10;
			_cameraController.maxTiltAngle = 60;
			_cameraController.autoUpdate = false;

			// setup the player container
			_player = new ObjectContainer3D();
			_view.scene.addChild(_player);

			// add stats
			addChild(_stats = new AwayStats(_view, false, true));
			_stats.x = stage.stageWidth - _stats.width - 5;
			_stats.alpha = 0.5;
			_stats.y = 2;

			stage.addEventListener(Event.RESIZE, onResize);
		}

		/**
		 * Initialise the lights
		 */
		private function initLights() : void {
			_sunLight = new DirectionalLight(0.1, -0.8, 0.3);
			_sunLight.color = sunColor;
			// _sunLight.ambientColor = 0x000000;
			_sunLight.ambient = 0;
			_sunLight.diffuse = 0;
			_sunLight.specular = 0;
			_sunLight.castsShadows = true;
			_sunLight.shadowMapper = new NearDirectionalShadowMapper(.4);
			_view.scene.addChild(_sunLight);

			// create light picker for materials
			_lightPicker = new StaticLightPicker([_sunLight]);
		}

		/**
		 * Create random sky 
		 */
		private function randomSky() : void {
			AutoMapSky.scene = _view.scene;
			if (_isIntro) AutoMapSky.randomSky([skyColor, fogColor, groundColor], _bitmaps, 8);
			else AutoMapSky.randomSky(null, _bitmaps, 8);
			_fogMethode.fogColor = AutoMapSky.fogColor;
		}

		/**
		 * Initialise the materials
		 */
		private function initMaterials() : void {
			_materials = new Vector.<TextureMaterial>();

			// water method
			_waterMethod = new SimpleWaterNormalMethod(Cast.bitmapTexture(_bitmaps[9]), Cast.bitmapTexture(_bitmaps[9]));
			// fresnelMethod
			_fresnelMethod = new FresnelSpecularMethod();
			_fresnelMethod.normalReflectance = 0.4;
			// fog method
			_fogMethode = new FogMethod(FOGNEAR, FARVIEW, fogColor);
			// shadow method
			_shadowMethod = new NearShadowMapMethod(new FilteredShadowMapMethod(_sunLight));
			_shadowMethod.epsilon = .0007;
			_shadowMethod.alpha = 0.25;

			// 0 _ water texture
			_waterMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, true, 0x22404060)));
			_waterMaterial.alphaBlending = true;
			_waterMaterial.repeat = true;
			_waterMaterial.gloss = 100;
			_waterMaterial.specular = 1;
			_waterMaterial.normalMethod = _waterMethod;
			_waterMaterial.specularMethod = _fresnelMethod;
			_materials[0] = _waterMaterial;

			// creat terrain material
			_terrainMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(128, 128, false, 0x00)));
			_terrainMaterial.gloss = 10;
			_terrainMaterial.specular = 0.2;
			_materials[1] = _terrainMaterial;

			// 1- simulation box
			_boxMaterial = new TextureMaterial(Cast.bitmapTexture(new BitmapData(64, 64, false, 0x999999)));
			_boxMaterial.gloss = 60;
			_boxMaterial.specular = 1;
			_materials[2] = _boxMaterial;

			// for all material
			for (var i : int; i < _materials.length; i++) {
				_materials[i].lightPicker = _lightPicker;
				_materials[i].shadowMethod = _shadowMethod;
				_terrainMaterial.addMethod(_fogMethode);
				_materials[i].ambient = 1;
			}
		}

		/**
		 * Render loop
		 */
		private function onEnterFrame(event : Event = null) : void {
			if (_night > 0) {
				_fogMethode.fogColor = AutoMapSky.darken(AutoMapSky.fogColor, _night);
				AutoMapSky.night(_night);
				_night -= 0.5;
			}
			if (_sunLight.ambient < 0.3)
				_sunLight.ambient += 0.005;
			if (_sunLight.diffuse < 1)
				_sunLight.diffuse += 0.005;
			if (_sunLight.specular < 1)
				_sunLight.specular += 0.005;
			if (_cameraController.distance > 1000)
				_cameraController.distance--;

			_lander.update();

			_player.y = _lander.getHeightAt(0, 0);
			_cameraController.lookAtPosition = new Vector3D(0, _player.y + 10, 0);
			_cameraController.update();

			// animate our lake material
			_waterMethod.water1OffsetX += .001;
			_waterMethod.water1OffsetY += .001;
			_waterMethod.water2OffsetX += .0007;
			_waterMethod.water2OffsetY += .0006;

			_view.render();
		}

		/**
		 * Initialise listener
		 */
		private function initListeners(e : Event = null) : void {
			if (_isIntro) _isIntro = false;
			_isRender = true;
			log(message());
			if (e != null) {
				removeGrayPauseEffect();
				stage.removeEventListener(MouseEvent.MOUSE_OVER, initListeners);
			}
			// add render loop
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			// add key listeners
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			// navigation
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}

		/**
		 * Remove listener
		 */
		private function stopListeners() : void {
			grayPauseEffect();
			_isRender = false;
			log("&#47;&#33;&#92; PAUSE");
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseLeave);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);

			// mouse come back
			stage.addEventListener(MouseEvent.MOUSE_OVER, initListeners);
		}

		/**
		 *  Function pause if leave stage
		 */
		private function grayPauseEffect() : void {
			if (_isIntro) return;
			_capture = new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x40000000);
			_topPause.graphics.beginBitmapFill(_capture, null, false, false);
			_topPause.graphics.drawRect(0, 0, stage.width, stage.height);
			_topPause.graphics.endFill();
		}

		/**
		 *  Function unpause if on stage
		 */
		private function removeGrayPauseEffect() : void {
			_topPause.graphics.clear();
			_capture = null;
		}

		/**
		 *  AWD asset complete event on loader
		 */
		/*private function onAssetComplete(event : AssetEvent) : void {
		}*/
		/**
		 *  AWD resource complete event on loader
		 */
		/*private function onResourceComplete(e : LoaderEvent) : void {
		}*/
		/**
		 * Key down listener
		 */
		private function onKeyDown(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					// isRunning = true;
					// if (isMoving) updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
					// fr
					// updateMovement(movementDirection = 1);
					// if (_physics){_physics.key_forward(true);}
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					// updateMovement(movementDirection = -1);
					// if (_physics){_physics.key_Reverse(true);}
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
					// fr
					// if (!isMoving)updateMovementSide(1);
					// if (_physics){_physics.key_Left(true);}
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					// if (!isMoving)updateMovementSide( -1);
					// if (_physics){_physics.key_Right(true);}
					break;
				case Keyboard.R:
					// reload();
					break;
				case Keyboard.B:
					// makeClone();
					break;
				case Keyboard.N:
					randomSky();
					break;
				case Keyboard.V:
					// initReflection();
					break;
				case Keyboard.U:
					// if(_physics) _physics.addDebug(_view);
					break;
				case Keyboard.P:
					// xRay();
					break;
				case Keyboard.O:
					// switchWeapon();
					break;
				case Keyboard.I:
					fullScreen();
					break;
				case Keyboard.C:
					// if (isCrouch) { isCrouch = false; _cameraHeight = 40; }
					// else {isCrouch = true; _cameraHeight = 15;}
					// stop();
					break;
				case Keyboard.SPACE:
					// if (!isJump) {
					// jumpUp();
					// if (_physics) { _physics.key_Jump(true); }
					// }
					break;
			}
		}

		/**
		 * Key up listener
		 */
		private function onKeyUp(event : KeyboardEvent) : void {
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					// isRunning = false;
					// if (isMoving)
					// updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.Z:
				// fr
				case Keyboard.DOWN:
				case Keyboard.S:
					// isMoving = false;
					// if (_physics) { _physics.key_forward(false); _physics.key_Reverse(false);  }
					// stop();
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.Q:
				// fr
				case Keyboard.RIGHT:
				case Keyboard.D:
					// isSideMove = false;
					// if (_physics) { _physics.key_Left(false); _physics.key_Right(false); }
					// stop();
					break;
				case Keyboard.SPACE:
					// isJump = false;;
					// if (_physics){_physics.key_Jump(false);}
					break;
			}
		}

		/**
		 * stage full screen
		 */
		private function fullScreen(e : Event = null) : void {
			if (stage.displayState == StageDisplayState.NORMAL) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			} else {
				stage.displayState = StageDisplayState.NORMAL;
			}
		}

		/**
		 * stage listener and mouse control
		 */
		private function onResize(event : Event = null) : void {
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_stats.x = stage.stageWidth - _stats.width;
			_signature.y = stage.stageHeight - _signature.height;
			_menu.y = stage.stageHeight;
			if (!_isRender)
				onEnterFrame();
		}

		private function onGroundMouseOver(e : MouseEvent3D) : void {
			if (_mouseMove)
				_lander.move(-((stage.stageWidth >> 1) - mouseX ) / (stage.stageWidth >> 1), -((stage.stageHeight >> 1) - mouseY) / (stage.stageHeight >> 1));
			else _lander.stop();
		}

		private function onShipMouseDown(e : MouseEvent3D) : void {
			_mouseMove = false;
			_isRotation = true;
		}

		private function onStageMouseDown(e : MouseEvent) : void {
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
			_mouseMove = true;
		}

		private function onStageMouseUp(e : Event) : void {
			_mouseMove = false;
			_isRotation = false;
		}

		private function onStageMouseLeave(e : Event) : void {
			_mouseMove = false;
			stopListeners();
		}

		private function onStageMouseMove(e : MouseEvent) : void {
			if (_isRotation) {
				_cameraController.panAngle += (e.stageX - _prevMouseX);
				_cameraController.tiltAngle += (e.stageY - _prevMouseY);
			}
			_prevMouseX = e.stageX;
			_prevMouseY = e.stageY;
		}

		/**
		 * mouseWheel listener
		 */
		private function onStageMouseWheel(e : MouseEvent) : void {
			_cameraController.distance -= e.delta * 5;

			if (_cameraController.distance < 50)
				_cameraController.distance = 50;
			else if (_cameraController.distance > 2000)
				_cameraController.distance = 2000;
		}

		/**
		 * Interface
		 */
		private function initSetting() : void {
			_menu = new Sprite();
			addChild(_menu);
			_menu.y = stage.stageHeight;
			Style.setStyle("dark");
			Style.DROPSHADOW = 0x000000;
			Style.BACKGROUND = 0x000000;
			Style.LABEL_TEXT = 0xffffff;
			Style.BUTTON_FACE = 0x060606;
			Style.BUTTON_DOWN = 0x995522;

			new PushButton(_menu, 180, -29, ">", showSetting).setSize(30, 30);
			new PushButton(_menu, 215, -29, "128", switch128).setSize(60, 30);
			new PushButton(_menu, 215 + 65, -29, "256", switch256).setSize(60, 30);
		}

		private function switch128(e : Event) : void {
			_lander.changeResolution(128);
		}

		private function switch256(e : Event) : void {
			_lander.changeResolution(256);
		}

		/**
		 * Create an instructions overlay
		 */
		private function initText() : void {
			_topPause = new Sprite();
			addChild(_topPause);

			_text = new TextField();
			var format : TextFormat = new TextFormat("Helvetica", 9, 0xdddddd, null, null, null, null, null, null, 5, null, null, 1);
			format.letterSpacing = 1;
			_text.defaultTextFormat = format;
			_text.antiAliasType = AntiAliasType.ADVANCED;
			_text.gridFitType = GridFitType.PIXEL;
			_text.y = 5;
			_text.width = 300;
			_text.height = 250;
			_text.wordWrap = true;
			_text.selectable = false;
			_text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			addChild(_text);
		}

		/**
		 * Welcome message
		 */
		private function message() : String {
			var mes : String = "Click on view for move\n";
			mes += "Click on ship for rotation\n";
			mes += "I - full screen\n";
			mes += "N - random sky\n";
			return mes;
		}

		/**
		 * Display text
		 */
		private function log(t : String) : void {
			_text.htmlText = t;
		}

		private function showSetting(e : MouseEvent) : void {
		}
	}
}