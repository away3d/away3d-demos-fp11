package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.core.base.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.lights.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.primitives.*;
	import away3d.tools.helpers.*;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class AdobeAway3D extends Sprite
	{
		[Embed(source="../embeds/text.png")]
		private var TEXT_IMG:Class;
		
		private const SIZE:int = 5;
		private const TIME:int = 10000;
		
		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var data:Vector.<Vector3D>;
		private var animator:ParticleAnimator;
		
		
		private var greenlight:PointLight;
		private var redlight:PointLight;
		private var lightpicker:StaticLightPicker;
		
		private var time:Number = 0;

		public function AdobeAway3D()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 2;
			addChild(_view);
			
			_cameraController = new HoverController(_view.camera, null, 180, 0, 1000, -90);
			
			addChild(new AwayStats(_view));
			initTextData();
			initScene();
			initParticle();
			
			//add listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			
			var timer:Timer = new Timer(TIME);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
			onTimer(null);
		}
		
		private var state:int;
		
		private function onTimer(e:Event):void
		{
			switch(state)
			{
				case 0:
					animator.playbackSpeed = 0;
					animator.resetTime(0);
					break;
				case 1:
					animator.playbackSpeed = 1;
					break;
				case 2:
					animator.playbackSpeed = -1;
					break;
			}
			state++;
			state %= 3;
		}
		
		private function initTextData():void
		{
			var bitmapData:BitmapData = new TEXT_IMG().bitmapData;
			data = new Vector.<Vector3D>;
			var depth:int = 8;
			
			for (var i:int = 0; i < bitmapData.width; i++)
			{
				for (var j:int = 0; j < bitmapData.height; j++)
				{
					if (bitmapData.getPixel(i, j) == 0x000000)
					{
						for (var k:int = 0; k < depth; k++)
						{
							var point:Vector3D = new Vector3D((i - bitmapData.width/2) , (-j+bitmapData.height/2), k);
							point.scaleBy(SIZE);
							data.push(point);
						}
					}
				}
				
			}
			trace(data.length);
		}
		
		private function initScene():void
		{
			greenlight = new PointLight();
			greenlight.color = 0x00ff00;
			greenlight.fallOff = 500;
			greenlight.radius = 100;
			greenlight.ambient = 0.5;
			greenlight.specular = 2;
			redlight = new PointLight();
			redlight.color = 0xff0000;
			redlight.fallOff = 500;
			redlight.radius = 100;
			redlight.specular = 2;
			_view.scene.addChild(greenlight);
			_view.scene.addChild(redlight);
			lightpicker = new StaticLightPicker([greenlight, redlight]);
		}
		
		private function initParticle():void
		{
			//create the original particle geometry
			var cube:Geometry = new CubeGeometry(SIZE, SIZE, SIZE);
			
			//combine them into a list
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < data.length; i++)
			{
				geometrySet.push(cube);
			}
			
			//generate the particle geometry
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet);
			
			//create the particle animation set
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet();
			animationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
			
			animationSet.initParticleFunc = initParticleParam;
			
			var material:ColorMaterial = new ColorMaterial(0xffffff);
			material.alphaPremultiplied = true;
			material.lightPicker = lightpicker;
			var particleMesh:Mesh = new Mesh(particleGeometry, material);
			animator = new ParticleAnimator(animationSet);
			particleMesh.animator = animator;
			animator.start();
			_view.scene.addChild(particleMesh);
		}
		
		private function initParticleParam(param:ParticleProperties):void
		{
			//let all particle appear when time=0
			param.startTime = 0;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = 30;
			param[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
			param[ParticlePositionNode.POSITION_VECTOR3D] = data[param.index];
		}
		
		
		private function onEnterFrame(event:Event):void
		{
			if (_move)
			{
				_cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle;
				_cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
			time += 1 * Math.PI / 180;
			greenlight.x = Math.sin(time) * 300;
			greenlight.z = Math.cos(time) * 300;
			redlight.x = Math.sin(time+Math.PI) * 300;
			redlight.z = Math.cos(time+Math.PI) * 300;
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
