package
{
	import away3d.animators.data.ParticleParameter;
	import away3d.animators.nodes.ParticleBillboardGlobalNode;
	import away3d.animators.nodes.ParticleVelocityLocalNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.utils.Cast;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class PeformanceBenchmark extends Sprite
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
		
		private var particles:Vector.<Mesh> = new Vector.<Mesh>;
		private var _num:int;
		private var particleMesh:Mesh;
		private var animationSet:ParticleAnimationSet;
		
		
		private var input:TextField;

		public function PeformanceBenchmark()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 4;
			addChild(_view);
			
			_cameraController = new HoverController(_view.camera, null, 45, 20, 1000, 5);
			
			addChild(new AwayStats(_view));
			
			initParticle();
			
			//add listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			addInputText();
			input.text = "20";
			setParticles(20);
		}
		
		private function addInputText():void
		{
			input = new TextField();
			input.border = true;
			input.width = 50;
			input.height = 20;
			input.borderColor = 0xffff0000;
			input.textColor = 0xffff0000;
			input.backgroundColor = 0xffffff;
			input.background = true;
			input.type = TextFieldType.INPUT;
			input.y = 20;
			input.x = 350;
			addChild(input);
			var description:TextField = new TextField();
			description.x = input.x;
			description.y = 20;
			description.width = 0;
			description.height = 20;
			description.autoSize = TextFieldAutoSize.RIGHT;
			description.textColor = 0xffff0000;
			description.text = "input the number, then press the Enter:";
			addChild(description);
			description = new TextField();
			description.x = input.x + input.width + 2;
			description.y = 20;
			description.width = 0;
			description.height = 20;
			description.autoSize = TextFieldAutoSize.LEFT;
			description.textColor = 0xffff0000;
			description.text = "K";
			addChild(description);
			
			input.addEventListener(KeyboardEvent.KEY_UP, onKey);
		}
		
		private function onKey(e:KeyboardEvent):void
		{
			if (e.charCode == Keyboard.ENTER)
			{
				if (int(input.text) < 0)
					input.text = "0";
				setParticles(int(input.text));
			}
		}
		
		private function initParticle():void
		{
			var plane:Geometry = new PlaneGeometry(10, 10, 1, 1, false);
			
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 1000; i++)
			{
				geometrySet.push(plane);
			}
			var particleGeometry:Geometry = ParticleGeometryHelper.generateCompactGeometry(geometrySet);
			
			//create the particle animation set
			animationSet = new ParticleAnimationSet();
			animationSet.loop = true;
			
			animationSet.addAnimation(new ParticleBillboardGlobalNode());
			animationSet.addAnimation(new ParticleVelocityLocalNode());
			animationSet.initParticleFunc = initParticleParam;
			
			
			var material:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(ParticleImg));
			material.blendMode = BlendMode.ADD;
			particleMesh = new Mesh(particleGeometry, material);
		}
		
		private function initParticleParam(param:ParticleParameter):void
		{
			param.startTime = Math.random()*5;
			param.duringTime = 5;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = Math.random() * 50 + 400;
			param[ParticleVelocityLocalNode.NAME] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
		}
		
		
		private function setParticles(num:int):void
		{
			var i:int;
			for (i = 0; i < _num; i++)
			{
				_view.scene.removeChild(particles[i]);
			}
			
			particles.length = 0;
			particles.length = num;
			var animator:ParticleAnimator;
			for (i = 0; i < num; i++)
			{
				
				particles[i] = particleMesh.clone() as Mesh;
				particles[i].rotationY = Math.random()*Math.PI;
				animator = new ParticleAnimator(animationSet);
				particles[i].animator = animator;
				
				animator.start();
				animator.resetTime(-Math.random() * 5000);
				_view.scene.addChild(particles[i]);
			}
			_num = num;
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
