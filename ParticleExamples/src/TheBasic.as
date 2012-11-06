package
{
	import away3d.animators.nodes.ParticleColorNode;
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.nodes.ParticleAccelerationNode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class TheBasic extends Sprite
	{
		

		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		

		public function TheBasic()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 2;
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
			var groundMaterial:ColorMaterial = new ColorMaterial();
			var ground:Mesh = new Mesh(new PlaneGeometry(2000, 2000), groundMaterial);
			_view.scene.addChild(ground);
		}
		
		private function initParticle():void
		{
			//create the original particle geometry
			var cube:Geometry = new CubeGeometry(10, 10, 10);
			
			//combine them into a list
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 2000; i++)
			{
				geometrySet.push(cube);
			}
			
			//generate the particle geometry
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet.loop = true;
			
			//add some animations which can control the particles:
			//the global animations can be set directly, because they influence all the particles with the same factor
			animationSet.addAnimation(new ParticleVelocityNode(ParticleVelocityNode.GLOBAL, new Vector3D(0, 200, 0)));
			animationSet.addAnimation(new ParticleAccelerationNode(ParticleAccelerationNode.GLOBAL, new Vector3D(0, -40, 0)));
			animationSet.addAnimation(new ParticleColorNode(ParticleColorNode.GLOBAL, true, false, true, false, new ColorTransform(1, 0, 0), new ColorTransform(0, 1, 1), 2));
			//no need to set the local animations here, because they influence all the particle with different factors.
			animationSet.addAnimation(new ParticlePositionNode(ParticlePositionNode.LOCAL));
			
			//set the initParticleFunc. It will be invoke for the local property initialization of every particle
			animationSet.initParticleFunc = initParticleParam;
			
			//create a mesh with material for particles
			var material:ColorMaterial = new ColorMaterial(0xffffff);
			var particleMesh:Mesh = new Mesh(particleGeometry, material);
			var animator:ParticleAnimator = new ParticleAnimator(animationSet);
			particleMesh.animator = animator;
			animator.start();
			
			_view.scene.addChild(particleMesh);
		}
		
		private function initParticleParam(param:ParticleParameter):void
		{
			//let all particle appear when time=0
			param.startTime = 0;
			//let all particle's life = 10s
			param.duration = 10;
			//calculate the original position of every particle. this value will be fetched by ParticleOffsetPositionLocalNode
			var percent:Number = param.index / param.total;
			var r:Number = percent * 1000;
			var x:Number = r*Math.cos(percent * Math.PI * 2 * 20);
			var z:Number = r*Math.sin(percent * Math.PI * 2 * 20);
			param[ParticlePositionNode.POSITION_VECTOR3D] = new Vector3D(x, 0, z);
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
