package
{
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.animators.nodes.ParticleSpriteSheetNode;
	import away3d.animators.nodes.ParticleVelocityNode;
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
	public class SpriteSheetExample extends Sprite
	{
		
		[Embed(source="/../embeds/LightningBall.png")]
		private var Spritesheet:Class;
		
		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		

		public function SpriteSheetExample()
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
			//_view.scene.addChild(ground);
		}
		
		private function initParticle():void
		{
			var plane:Geometry = new PlaneGeometry(100, 100, 1, 1, false);
			
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 400; i++)
			{
				geometrySet.push(plane);
			}
			
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet.loop = true;
			animationSet.hasDelay = true;
			
			animationSet.addAnimation(new ParticleBillboardNode());;
			animationSet.addAnimation(new ParticleVelocityNode(ParticleVelocityNode.LOCAL));
			animationSet.addAnimation(new ParticleSpriteSheetNode(ParticleSpriteSheetNode.GLOBAL, 3, 2, 0, 1));
			
			animationSet.initParticleFunc = initParticleParam;
			
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(Spritesheet));
			material.blendMode = BlendMode.ADD;
			material.repeat = true;
			var particleMesh:Mesh = new Mesh(particleGeometry, material);
			var animator:ParticleAnimator = new ParticleAnimator(animationSet);
			particleMesh.animator = animator;
			animator.start();
			
			_view.scene.addChild(particleMesh);
		}
		
		private function initParticleParam(param:ParticleParameter):void
		{
			param.startTime = Math.random()*1;
			param.duration = 6;
			param.delay = 4;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = 100;
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
