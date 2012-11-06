package
{
	import away3d.utils.Cast;
	import away3d.materials.TextureMaterial;
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.nodes.ParticleColorNode;
	import away3d.animators.nodes.ParticleScaleNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class CloneExample extends Sprite
	{
		
[Embed(source="../embeds/blue.png")]
		private var ParticleImg:Class;
		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var particleAnimators:Vector.<ParticleAnimator> = new Vector.<ParticleAnimator>;
		private var timer:Timer;

		public function CloneExample()
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
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function initScene():void
		{
			var groundMaterial:ColorMaterial = new ColorMaterial(0x222222);
			var ground:Mesh = new Mesh(new PlaneGeometry(2000, 2000), groundMaterial);
			_view.scene.addChild(ground);
		}
		
		private function initParticle():void
		{
			//create the original particle geometry
			var plane:Geometry = new PlaneGeometry(10, 10, 1, 1, false);
			
			//combine them into a list
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 500; i++)
			{
				geometrySet.push(plane);
			}
			
			//generate the particle geometry
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet.loop = true;
			
			//add some animations which can control the particles:
			//the global animations can be set directly, because they influence all the particles with the same factor
			animationSet.addAnimation(new ParticleBillboardNode());
			animationSet.addAnimation(new ParticleScaleNode(ParticleScaleNode.GLOBAL, false, false, 2.5, 0.5));
			animationSet.addAnimation(new ParticleVelocityNode(ParticleVelocityNode.GLOBAL, new Vector3D(0, 80, 0)));
			animationSet.addAnimation(new ParticleColorNode(ParticleColorNode.GLOBAL, true, true, false, false, new ColorTransform(0, 0, 0, 1, 0xFF, 0x33, 0x01), new ColorTransform(0, 0, 0, 1, 0x99)));
			//no need to set the local animations here, because they influence all the particle with different factors.
			animationSet.addAnimation(new ParticleVelocityNode(ParticleVelocityNode.LOCAL));
			
			//set the initParticleFunc. It will be invoke for the local property initialization of every particle
			animationSet.initParticleFunc = initParticleParam;
			
			//create a mesh with material for particles
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(ParticleImg));
			material.blendMode = BlendMode.ADD;
			var particleMesh:Mesh = new Mesh(particleGeometry, material);
			
			var animator:ParticleAnimator;
			
			//clone them. reuse the animationSet and particleGeometry
			for (var j:int = 0; j < 10; j++)
			{
				var degree:Number = j / 10 * Math.PI * 2;
				var clone:Mesh = particleMesh.clone() as Mesh;
				animator = new ParticleAnimator(animationSet);
				clone.animator = animator;
				clone.x = Math.sin(degree) * 400;
				clone.z = Math.cos(degree) * 400;
				clone.y = 20;
				particleAnimators.push(animator);
				_view.scene.addChild(clone);
			}
			
			animator = new ParticleAnimator(animationSet);
			particleMesh.animator = animator;
			particleMesh.y = 20;
			particleAnimators.push(animator);
			_view.scene.addChild(particleMesh);
			
			timer = new Timer(1000, particleAnimators.length);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(e:TimerEvent):void
		{
			particleAnimators[timer.currentCount-1].start();
		}
		
		private function initParticleParam(param:ParticleParameter):void
		{
			param.startTime = Math.random()*5;
			param.duration = Math.random() * 4 + 0.1;
			
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = 15;
			param[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
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
