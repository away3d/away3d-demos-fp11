package
{
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.nodes.ParticleBillboardGlobalNode;
	import away3d.animators.nodes.ParticleColorByLifeGlobalNode;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.animators.nodes.ParticleVelocityLocalNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.animators.states.ParticleFollowState;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.debug.AwayStats;
	import away3d.debug.WireframeAxesGrid;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.data.ParticleGeometryTransform;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.utils.Cast;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Vector3D;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class TrailExample extends Sprite
	{
		
		[Embed(source="../embeds/love_puke.png")]
		private var IMAGE:Class;
		
		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		
		private var followTrarget1:Object3D = new Object3D;
		private var followTrarget2:Object3D = new Object3D;
		private var factor:Number=0;

		public function TrailExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 2;
			addChild(_view);
			
			_cameraController = new HoverController(_view.camera, null, 45, 20, 1000, 5);
			
			addChild(new AwayStats(_view));
			_view.scene.addChild(new WireframeAxesGrid(10,1500));
			initParticle();
			
			//add listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function initParticle():void
		{
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(IMAGE));
			material.blendMode = BlendMode.ADD;
			
			var plane:Geometry = new PlaneGeometry(30, 30, 1, 1, false);
			
			
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>();
			var setTransforms:Vector.<ParticleGeometryTransform> = new Vector.<ParticleGeometryTransform>();
			var particleTransform:ParticleGeometryTransform;
			var uvTransform:Matrix;
			for (var i:int = 0; i < 1000; i++)
			{
				geometrySet.push(plane);
				particleTransform = new ParticleGeometryTransform();
				uvTransform = new Matrix();
				uvTransform.scale(0.5, 0.5);
				uvTransform.translate(int(Math.random() * 2) / 2, int(Math.random() * 2) / 2);
				particleTransform.UVTransform = uvTransform;
				setTransforms.push(particleTransform);
			}
			
			var geometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet, setTransforms);
			
			
			var animation:ParticleAnimationSet = new ParticleAnimationSet();
			animation.loop = true;
			animation.hasDuringTime = true;
			animation.hasSleepTime = true;
			
			animation.addAnimation(new ParticleBillboardGlobalNode());
			animation.addAnimation(new ParticleVelocityLocalNode());
			animation.addAnimation(new ParticleColorByLifeGlobalNode(new ColorTransform(), new ColorTransform(1, 1, 1, 0)));
			animation.addAnimation(new ParticleFollowNode(true, false));
			
			animation.initParticleFunc = initParticleParam;
			
			var particleMesh:Mesh = new Mesh(geometry, material);
			particleMesh.y = 300;
			var animator:ParticleAnimator = new ParticleAnimator(animation);
			particleMesh.animator = animator;
			animator.start();
			_view.scene.addChild(particleMesh);
			ParticleFollowState(animator.getAnimationStateByName(ParticleFollowNode.NAME)).followTarget = followTrarget1;
			
			var clone:Mesh = particleMesh.clone() as Mesh;
			clone.y = 300;
			animator = new ParticleAnimator(animation);
			clone.animator = animator;
			animator.start();
			_view.scene.addChild(clone);
			ParticleFollowState(animator.getAnimationStateByName(ParticleFollowNode.NAME)).followTarget = followTrarget2;
		}
		
		private function initParticleParam(param:ParticleParameter):void
		{
			param.startTime = Math.random()*4.1;
			param.duringTime = 4;
			param[ParticleVelocityLocalNode.NAME] = new Vector3D(Math.random() * 100 - 50, Math.random() * 100 - 200, Math.random() * 100 - 50);
		}
		

		private function onEnterFrame(event:Event):void
		{
			if (_move)
			{
				_cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle;
				_cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
			factor+=0.04;
			followTrarget1.x = Math.cos(factor) * 500;
			followTrarget1.z = Math.sin(factor) * 500;
			followTrarget2.x = Math.sin(factor) * 500;
			
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
