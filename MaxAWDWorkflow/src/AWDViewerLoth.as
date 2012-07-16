package
{
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.transitions.*;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.library.*;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.net.*;
	import flash.text.*;
	import flash.ui.*;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="LOW")]
	
	public class AWDViewerLoth extends Sprite
	{
		
		private var modelTexture:BitmapTexture;
		private const DemoColor:Array = [0xffffff, 0x99AAff, 0x222233];
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var awayStats:AwayStats;
		
		//animation variables
		private var skeleton:Skeleton;
		private var animationSet:SkeletonAnimationSet;
		private var animator:SkeletonAnimator;
		private var breatheState:SkeletonAnimationState;
		private var walkState:SkeletonAnimationState;
		private var runState:SkeletonAnimationState;
		private var crossfadeTransition:CrossfadeStateTransition;
		private var isRunning:Boolean;
		private var isMoving:Boolean;
		private var movementDirection:Number;
		private var currentAnim:String;
		private var currentRotationInc:Number = 0;
		
		//animation constants
		private const ANIM_BREATHE:String = "Breathe";
		private const ANIM_WALK:String = "Walk";
		private const ANIM_RUN:String = "Run";
		private const XFADE_TIME:Number = 0.5;
		private const ROTATION_SPEED:Number = 3;
		private const RUN_SPEED:Number = 2;
		private const WALK_SPEED:Number = 1;
		private const BREATHE_SPEED:Number = 1;
		
		//light objects
		private var sunLight:DirectionalLight;
		private var skyLight:PointLight;
		private var lightPicker:StaticLightPicker;
		
		//material objects
		private var groundMaterial:ColorMaterial;
		
		//scene objects
		private var text:TextField;
		private var hero:Mesh;
		private var ground:Mesh;
		
		private var hoverController:HoverController;
		private var _prevMouseX:Number;
		private var _prevMouseY:Number;
		
		private var MESH_URL:String = "MaxAWDWorkflow.awd";
		private var TEXTURE_URL:String = "onkba_N.jpg";
		private var assetsThatAreloaded:int = 0;
		private var assetsToLoad:int = 2;
		
		/**
		 * Constructor
		 */
		public function AWDViewerLoth()
		{
			initEngine();
			initText();
			initLights();
			initLoading();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			scene = new Scene3D();
			
			camera = new Camera3D();
			camera.lens.far = 5000;
			camera.lens.near = 20;
			
			view = new View3D();
			view.backgroundColor = DemoColor[2];
			view.scene = scene;
			view.camera = camera;
			
			hoverController = new HoverController(camera);
			hoverController.tiltAngle = 0;
			hoverController.panAngle = 180;
			hoverController.minTiltAngle = -60;
			hoverController.maxTiltAngle = 60;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			
			addChild(view);
			
			awayStats = new AwayStats(view);
			addChild(awayStats);
			
			//create the ground plane
			groundMaterial = new ColorMaterial(0x333333);
			groundMaterial.addMethod(new FogMethod(1000, 3000, DemoColor[2]));
			groundMaterial.ambient = 0.25;
			ground = new Mesh(new PlaneGeometry(50000, 50000), groundMaterial);
			ground.geometry.scaleUV(50, 50);
			ground.y = -380;
			scene.addChild(ground);
		}
		
		/**
		 * Create an instructions overlay
		 */
		private function initText():void
		{
			text = new TextField();
			text.defaultTextFormat = new TextFormat("Verdana", 11, 0xFFFFFF);
			text.width = 240;
			text.height = 100;
			text.selectable = false;
			text.mouseEnabled = false;
			text.text = "Cursor keys / WSAD - move\n";
			text.appendText("SHIFT - hold down to run\n");
			
			text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			
			addChild(text);
		}
		
		private function showError(t:String):void
		{
			text.appendText(t);
			trace("ERROR: " + t);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			//create a light for shadows that mimics the sun's position in the skybox
			sunLight = new DirectionalLight(-1, -0.4, 1);
			sunLight.color = DemoColor[0];
			sunLight.castsShadows = true;
			sunLight.ambient = 1;
			sunLight.diffuse = 1;
			sunLight.specular = 1;
			scene.addChild(sunLight);
			
			//create a light for ambient effect that mimics the sky
			skyLight = new PointLight();
			skyLight.y = 500;
			skyLight.color = DemoColor[1];
			skyLight.diffuse = 1;
			skyLight.specular = 0.5;
			skyLight.radius = 2000;
			skyLight.fallOff = 2500;
			scene.addChild(skyLight);
			
			lightPicker = new StaticLightPicker([sunLight, skyLight]);
			
			// apply the lighting effects to the ground material
			groundMaterial.lightPicker = lightPicker;
			groundMaterial.shadowMethod = new DitheredShadowMapMethod(sunLight);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initLoading():void
		{
			AssetLibrary.enableParser(AWD2Parser);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			AssetLibrary.addEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
			AssetLibrary.load(new URLRequest(TEXTURE_URL));
			AssetLibrary.load(new URLRequest(MESH_URL));
		}
		
		protected function onLoadError(event:LoaderEvent):void
		{
			showError("Error loading: " + event.url);
		}
		
		/**
		 * Listener function for asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			// To not see these names output in the console, comment the
			// line below with two slash'es, just as you see on this line
			trace("Loaded " + event.asset.name + " Name: " + event.asset.name);
		}
		
		private function onResourceComplete(ev:LoaderEvent):void
		{
			assetsThatAreloaded++;
			// check to see if we have all we need
			if (assetsThatAreloaded == assetsToLoad) {
				setupScene();
			}
		}
		
		private function setupScene():void
		{
			// request all the things we loaded into the AssetLibrary
			skeleton = Skeleton(AssetLibrary.getAsset("Bone001"));
			breatheState = SkeletonAnimationState(AssetLibrary.getAsset("Breathe"));
			walkState = SkeletonAnimationState(AssetLibrary.getAsset("Walk"));
			runState = SkeletonAnimationState(AssetLibrary.getAsset("Run"));
			modelTexture = BitmapTexture(AssetLibrary.getAsset(TEXTURE_URL));
			hero = Mesh(AssetLibrary.getAsset("ONKBA-Corps-lnew"));
			
			// prepare the model's texture material
			var autoMap:Mapper = new Mapper(modelTexture.bitmapData);
			var specularMethod:FresnelSpecularMethod = new FresnelSpecularMethod();
			specularMethod.normalReflectance = .4;
			
			var material:TextureMaterial = new TextureMaterial(modelTexture);
			material.normalMap = new BitmapTexture(autoMap.bitdata[1]);
			material.specularMap = new BitmapTexture(autoMap.bitdata[2]);
			material.specularMethod = specularMethod;
			material.lightPicker = lightPicker;
			material.gloss = 40;
			material.specular = 0.5;
			material.ambientColor = 0xAAAAFF;
			material.ambient = 0.25;
			material.addMethod(new RimLightMethod(DemoColor[1], .4, 3, RimLightMethod.ADD));
			
			// put our hero center stage and assign our material object
			hero.scale(8);
			hero.material = material;
			hero.castsShadows = true;
			hero.z = 1000;
			hero.rotationY = -45;
			scene.addChild(hero);
			
			// Create an animation set object and add our state objects
			animationSet = new SkeletonAnimationSet(3);
			animationSet.addState(breatheState.name, breatheState);
			animationSet.addState(walkState.name, walkState);
			animationSet.addState(runState.name, runState);
			
			//couple our animation set with our skeleton and wrap in an animator object and apply to our mesh object
			animator = new SkeletonAnimator(animationSet, skeleton);
			hero.animator = animator;
			
			//create our crossfade transition object
			crossfadeTransition = new CrossfadeStateTransition(XFADE_TIME);
			
			if (animationSet.hasState("Breathe") && animationSet.hasState("Walk") && animationSet.hasState("Run")) {
				hoverController.lookAtObject = hero; // point the camera at the hero
				goToPauseState(); // starts the "breathe" animation
				initListeners(); // get ready for user input
			} else {
				showError("Animation error");
			}
		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			// start calling the
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			// Listen for key presses
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			// listen for the browser being resized
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		/**
		 * Key down listener for animation
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					isRunning = true;
					if (isMoving)
						updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
					updateMovement(movementDirection = 1);
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					updateMovement(movementDirection = -1);
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					currentRotationInc = -ROTATION_SPEED;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					currentRotationInc = ROTATION_SPEED;
					break;
			}
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					isRunning = false;
					if (isMoving)
						updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.DOWN:
				case Keyboard.S:
					goToPauseState();
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.RIGHT:
				case Keyboard.D:
					currentRotationInc = 0;
					break;
			}
		}
		
		private function updateMovement(dir:Number):void
		{
			isMoving = true;
			
			//update animator speed
			animator.playbackSpeed = dir * (isRunning ? RUN_SPEED : WALK_SPEED);
			
			//update animator sequence
			var anim:String = isRunning ? ANIM_RUN : ANIM_WALK;
			if (currentAnim == anim)
				return;
			
			currentAnim = anim;
			
			animator.play(currentAnim, crossfadeTransition);
		}
		
		private function goToPauseState():void
		{
			isMoving = false;
			
			//update animator speed
			animator.playbackSpeed = BREATHE_SPEED;
			
			//update animator sequence
			if (currentAnim == ANIM_BREATHE)
				return;
			
			currentAnim = ANIM_BREATHE;
			
			animator.play(currentAnim, crossfadeTransition);
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			//update character animation
			if (hero) hero.rotationY += currentRotationInc;
			
			skyLight.x = camera.x;
			skyLight.y = camera.y;
			skyLight.z = camera.z;
			view.render();
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			awayStats.x = stage.stageWidth - awayStats.width;
		}
		
		private function onStageMouseDown(ev:MouseEvent):void
		{
			_prevMouseX = ev.stageX;
			_prevMouseY = ev.stageY;
		}
		
		private function onStageMouseMove(ev:MouseEvent):void
		{
			if (ev.buttonDown) {
				hoverController.panAngle += (ev.stageX - _prevMouseX);
				hoverController.tiltAngle += (ev.stageY - _prevMouseY);
			}
			
			_prevMouseX = ev.stageX;
			_prevMouseY = ev.stageY;
		}
		
		private function onStageMouseWheel(ev:MouseEvent):void
		{
			hoverController.distance -= ev.delta * 5;
			
			if (hoverController.distance < 100)
				hoverController.distance = 100;
			else if (hoverController.distance > 2000)
				hoverController.distance = 2000;
		}
	}
}
