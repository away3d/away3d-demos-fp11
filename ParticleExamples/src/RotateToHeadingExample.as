package
{
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.animators.nodes.ParticleOrbitNode;
	import away3d.animators.nodes.ParticleRotateToHeadingNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.debug.WireframeAxesGrid;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.data.ParticleGeometryTransform;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class RotateToHeadingExample extends Sprite
	{
		

		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		

		public function RotateToHeadingExample()
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
			_view.scene.addChild(new WireframeAxesGrid(10, 1000));
		}
		
		private function initParticle():void
		{
			//explosion1
			var cube:Geometry = new CubeGeometry(50, 4, 4);
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			var i:int;
			for (i = 0; i < 400; i++)
			{
				geometrySet.push(cube);
			}
			var particleCubeGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			var animationSet1:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet1.loop = true;
			animationSet1.hasDelay = true;

			animationSet1.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL));
			animationSet1.addAnimation(new ParticleRotateToHeadingNode());
			animationSet1.initParticleFunc = initParticleParamForExplosion;
			var material1:ColorMaterial = new ColorMaterial(0xffff10, 0.3);
			material1.blendMode = BlendMode.ADD;
			var particleMesh1:Mesh = new Mesh(particleCubeGeometry, material1);
			var animator1:ParticleAnimator = new ParticleAnimator(animationSet1);
			particleMesh1.animator = animator1;
			particleMesh1.x = -300;
			animator1.start();
			_view.scene.addChild(particleMesh1);
			
			//explosion2
			var plane:Geometry = new PlaneGeometry(50, 4, 1, 1, false);
			geometrySet = new Vector.<Geometry>;
			for (i = 0; i < 400; i++)
			{
				geometrySet.push(plane);
			}
			var particlePlaneGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			var material2:ColorMaterial = new ColorMaterial(0xff10ff, 0.3);
			material2.blendMode = BlendMode.ADD;
			var particleMesh2:Mesh = new Mesh(particlePlaneGeometry, material2);
			
			var animationSet2:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet2.loop = true;
			animationSet2.hasDelay = true;
			
			animationSet2.addAnimation(new ParticleBillboardNode());
			animationSet2.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL));
			animationSet2.addAnimation(new ParticleRotateToHeadingNode());
			animationSet2.initParticleFunc = initParticleParamForExplosion;
			var animator2:ParticleAnimator = new ParticleAnimator(animationSet2);
			particleMesh2.animator = animator2;
			particleMesh2.x = 300;
			animator2.start();
			_view.scene.addChild(particleMesh2);
			
			//orbit
			var cylinder:Geometry = new CylinderGeometry(5, 0, 50);
			var transfrom:Matrix3D = new Matrix3D;
			transfrom.appendRotation(90, Vector3D.Z_AXIS);
			geometrySet = new Vector.<Geometry>;
			var particleTransforms:Vector.<ParticleGeometryTransform> = new Vector.<ParticleGeometryTransform>;
			var particleTransform:ParticleGeometryTransform = new ParticleGeometryTransform();
			particleTransform.vertexTransform = transfrom;
			for (i = 0; i < 60; i++)
			{
				geometrySet.push(cylinder);
				particleTransforms.push(particleTransform);
			}
			
			var particleCylinderGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet,particleTransforms);
			
			var material3:ColorMaterial = new ColorMaterial(0xff0000);
			var particleMesh3:Mesh = new Mesh(particleCylinderGeometry, material3);
			
			var animationSet3:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet3.loop = true;
			
			animationSet3.addAnimation(new ParticleOrbitNode(ParticlePropertiesMode.GLOBAL, true, true, false, 150, 2, 0, new Vector3D(90, 0, 0)));
			animationSet3.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.GLOBAL, new Vector3D(0, 50, 0)));
			animationSet3.addAnimation(new ParticleRotateToHeadingNode());
			animationSet3.initParticleFunc = initParticleParamForOrbit;
			var animator3:ParticleAnimator = new ParticleAnimator(animationSet3);
			particleMesh3.animator = animator3;
			animator3.start();
			_view.scene.addChild(particleMesh3);
			
			
		}
		
		private function initParticleParamForExplosion(param:ParticleProperties):void
		{
			param.startTime = 0;
			param.duration = 0.3;
			param.delay = 1;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = 1000;
			param[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
		}
		
		private function initParticleParamForOrbit(param:ParticleProperties):void
		{
			param.startTime = 10 * param.index / param.total;
			param.duration = 10;
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
