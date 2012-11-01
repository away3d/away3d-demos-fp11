package
{
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.nodes.ParticleAccelerateGlobalNode;
	import away3d.animators.nodes.ParticleBillboardGlobalNode;
	import away3d.animators.nodes.ParticleOffsetPositionLocalNode;
	import away3d.animators.nodes.ParticleVelocityGlobalNode;
	import away3d.animators.nodes.ParticleVelocityLocalNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.utils.Cast;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class ShareGeometryInAnimationSets extends Sprite
	{
		[Embed(source="../embeds/water.png")]
		private var WaterImg:Class;
		
		[Embed(source="../embeds/light.png")]
		private var Light:Class;

		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		

		public function ShareGeometryInAnimationSets()
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
			var plane:Geometry = new PlaneGeometry(20, 20, 1, 1, false);
			
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 5000; i++)
			{
				geometrySet.push(plane);
			}
			
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			
			var animationSet1:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet1.loop = true;
			animationSet1.addAnimation(new ParticleBillboardGlobalNode());
			animationSet1.addAnimation(new ParticleVelocityLocalNode());
			animationSet1.addAnimation(new ParticleAccelerateGlobalNode(new Vector3D(0, -500, 0)));
			animationSet1.initParticleFunc = initParticleParam1;
			
			var material1:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(WaterImg));
			material1.alphaBlending = true;
			material1.blendMode = BlendMode.NORMAL;
			var particleMesh1:Mesh = new Mesh(particleGeometry, material1);
			var animator1:ParticleAnimator = new ParticleAnimator(animationSet1);
			particleMesh1.animator = animator1;
			particleMesh1.x = -300;
			animator1.start();
			_view.scene.addChild(particleMesh1);
			
			
			
			var animationSet2:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet2.loop = true;
			animationSet2.addAnimation(new ParticleBillboardGlobalNode());
			animationSet2.addAnimation(new ParticleVelocityGlobalNode(new Vector3D(0,700,0)));
			animationSet2.addAnimation(new ParticleOffsetPositionLocalNode());
			animationSet2.initParticleFunc = initParticleParam2;
			
			var material2:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(Light));
			material2.alphaBlending = true;
			material2.blendMode = BlendMode.ADD;
			var particleMesh2:Mesh = new Mesh(particleGeometry, material2);
			var animator2:ParticleAnimator = new ParticleAnimator(animationSet2);
			particleMesh2.animator = animator2;
			particleMesh2.x = 300;
			animator2.start();
			_view.scene.addChild(particleMesh2);
			
		}
		
		
		
		private function initParticleParam1(param:ParticleParameter):void
		{
			param.startTime = Math.random() * 3;
			param.duringTime = 3;
			var r:Number = 700;
			var r2:Number = Math.random() * 10;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.PI * 80 / 180 + Math.random() * Math.PI * 5 / 180;
			param[ParticleVelocityLocalNode.NAME] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.sin(degree2), r * Math.cos(degree1) * Math.cos(degree2));
		}
		
		private function initParticleParam2(param:ParticleParameter):void
		{
			param.startTime = Math.random() * 1;
			param.duringTime = 1;
			
			var degree:Number = Math.random() * Math.PI * 2;
			var cos:Number = Math.cos(degree);
			var sin:Number = Math.sin(degree);
			var r:Number = Math.random() * 100;
			param[ParticleOffsetPositionLocalNode.NAME] = new Vector3D(r * cos, 0, r * sin);
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
