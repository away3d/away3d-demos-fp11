package
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleColorNode;
	import away3d.core.base.ParticleGeometry;
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.nodes.ParticleRotationalVelocityNode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.primitives.ConeGeometry;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.TorusGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class ParticleWithLight extends Sprite
	{
		

		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var lightPicker:StaticLightPicker;
		private var light:DirectionalLight;
		

		public function ParticleWithLight()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 2;
			//setup the camera for optimal shadow rendering
			_view.camera.lens.far = 2500;
			addChild(_view);
			
			_cameraController = new HoverController(_view.camera, null, 45, 20, 1000, 5);
			
			addChild(new AwayStats(_view));
			
			initScene();
			initParticle();
			
			//add listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function initScene():void
		{
			light = new DirectionalLight();
			light.ambient = 0.3;
			light.specular = 2;
			_view.scene.addChild(light);
			lightPicker = new StaticLightPicker([light]);
			
			var groundMaterial:ColorMaterial = new ColorMaterial();
			groundMaterial.shadowMethod = new HardShadowMapMethod(light);
			groundMaterial.lightPicker = lightPicker;
			var ground:Mesh = new Mesh(new PlaneGeometry(2000, 2000), groundMaterial);
			_view.scene.addChild(ground);
		}
		
		private function initParticle():void
		{
			//create the original particle geometry
			var cube:Geometry = new CubeGeometry(20, 20, 20);
			var sphere:Geometry = new SphereGeometry(20, 8, 8);
			var cylinder:Geometry = new CylinderGeometry(0, 40, 60);
			var cone:Geometry = new ConeGeometry(20, 60);
			var torus:Geometry = new TorusGeometry(30, 10);
			var cross:Geometry = new CubeGeometry(50, 10, 10);
			var crossTemp:Geometry=new CubeGeometry(10, 50, 10);
			cross.addSubGeometry(crossTemp.subGeometries[0]);
			
			//var list:Array = [cube, sphere, cylinder, cone, torus, crossTemp];
			var list:Array = [cube, sphere, cylinder, cone, torus, cross];
			var len:int = list.length;
			//combine them into a list
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 500; i++)
			{
				geometrySet.push(list[int(Math.random() * len)]);
			}
			
			//generate the particle geometry
			var particleGeometry:ParticleGeometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet(true, true);
			
			//add some animations which can control the particles:
			//the global animations can be set directly, because they influence all the particles with the same factor
			animationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.GLOBAL, new Vector3D(0, 100, 0)));
			animationSet.addAnimation(new ParticleColorNode(ParticlePropertiesMode.GLOBAL, true, false, true, false, new ColorTransform(1, 0, 0), new ColorTransform(0, 0, 1), 4));
			//no need to set the local animations here, because they influence all the particle with different factors.
			animationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticleRotationalVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			
			//set the initParticleFunc. It will be invoke for the local property initialization of every particle
			animationSet.initParticleFunc = initParticleParam;
			
			//create a mesh with material for particles
			var material:ColorMaterial = new ColorMaterial(0xcccc88);
			material.lightPicker = lightPicker;
			material.shadowMethod = new HardShadowMapMethod(light);
			var particleMesh:Mesh = new Mesh(particleGeometry, material);
			var animator:ParticleAnimator = new ParticleAnimator(animationSet);
			particleMesh.animator = animator;
			animator.start();
			
			_view.scene.addChild(particleMesh);
		}
		
		private function initParticleParam(param:ParticleProperties):void
		{
			param.startTime = Math.random() * 5;
			param.duration = Math.random() * 2 + 3;
			param[ParticlePositionNode.POSITION_VECTOR3D] = new Vector3D(Math.random() * 2000 - 1000, 0, Math.random() * 2000 - 1000);
			param[ParticleRotationalVelocityNode.ROTATIONALVELOCITY_VECTOR3D] = new Vector3D(0, 1, 0, Math.random() + 1);
			
		}
		

		private function onEnterFrame(event:Event):void
		{
			if (_move)
			{
				_cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle;
				_cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
			_view.render();
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			_lastPanAngle = _cameraController.panAngle;
			_lastTiltAngle = _cameraController.tiltAngle;
			_lastMouseX = stage.mouseX;
			_lastMouseY = stage.mouseY;
			_move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onMouseUp(event:MouseEvent):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onStageMouseLeave(event:Event):void
		{
			_move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		private function onResize(event:Event = null):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
	}
}
