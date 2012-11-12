package
{
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleBezierCurveNode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class AIRPlayer extends Sprite
	{
		[Embed(source="../embeds/air.png")]
		private var AIR_IMG:Class;
		[Embed(source="../embeds/player.png")]
		private var PLAYER_IMG:Class;
		
		private const SIZE:int = 3;
		private const TIME:int = 10000;
		
		private var _view:View3D;
		private var _cameraController:HoverController;
		
		private var _redSeparation:int;
		private var _whiteSeparation:int;
		private var _redTotal:int;
		private var _whiteTotal:int;
		
		private var _move:Boolean = false;
		private var _lastPanAngle:Number;
		private var _lastTiltAngle:Number;
		private var _lastMouseX:Number;
		private var _lastMouseY:Number;
		private var redData:Vector.<Vector3D>;
		private var whiteData:Vector.<Vector3D>;
		
		private var redAnimator:ParticleAnimator;
		private var whiteAnimator:ParticleAnimator;
		
		
		private var greenlight:PointLight;
		private var redlight:PointLight;
		private var lightpicker:StaticLightPicker;
		
		
		private var time:Number = 0;

		public function AIRPlayer()
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
					redAnimator.playbackSpeed = 0;
					whiteAnimator.playbackSpeed = 0;
					redAnimator.resetTime(0);
					whiteAnimator.resetTime(0);
					break;
				case 1:
					redAnimator.playbackSpeed = 1;
					whiteAnimator.playbackSpeed = 1;
					break;
				case 2:
					redAnimator.playbackSpeed = 0;
					redAnimator.resetTime( -TIME);
					whiteAnimator.playbackSpeed = 0;
					whiteAnimator.resetTime(-TIME);
					break;
				case 3:
					redAnimator.playbackSpeed = -1;
					whiteAnimator.playbackSpeed = -1;
					break;
			}
			state++;
			state %= 4;
		}
		
		private function initTextData():void
		{
			var bitmapData:BitmapData = new PLAYER_IMG().bitmapData;
			redData = new Vector.<Vector3D>;
			whiteData = new Vector.<Vector3D>;
			var depth:int = 1;
			
			var i:int;
			var j:int;
			var point:Vector3D;
			
			for (i = 0; i < bitmapData.width; i++)
			{
				for (j = 0; j < bitmapData.height; j++)
				{
					point = new Vector3D((i - bitmapData.width / 2) -100, ( -j + bitmapData.height / 2));
					point.scaleBy(SIZE);
					if (((bitmapData.getPixel(i, j) >> 8) & 0xff) <= 0xb0)
					{
						redData.push(point);
					}
					else
					{
						whiteData.push(point);
					}
				}
			}
			_redSeparation = redData.length;
			_whiteSeparation = whiteData.length;
			bitmapData = new AIR_IMG().bitmapData;
			
			for (i = 0; i < bitmapData.width; i++)
			{
				for (j = 0; j < bitmapData.height; j++)
				{
					point = new Vector3D((i - bitmapData.width / 2) +100, ( -j + bitmapData.height / 2));
					point.scaleBy(SIZE);
					if (((bitmapData.getPixel(i, j) >> 8) & 0xff) <= 0xb0)
					{
						redData.push(point);
					}
					else
					{
						whiteData.push(point);
					}
				}
			}
			_redTotal = redData.length;
			_whiteTotal = whiteData.length;
			
			trace(redData.length +whiteData.length);
		}
		
		private function initScene():void
		{
			greenlight = new PointLight();
			greenlight.color = 0x00ff00;
			greenlight.fallOff = 600;
			greenlight.radius = 100;
			greenlight.ambient = 0.6;
			greenlight.specular = 2;
			redlight = new PointLight();
			redlight.color = 0x0000ff;
			redlight.fallOff = 600;
			redlight.radius = 100;
			redlight.specular = 2;
			_view.scene.addChild(greenlight);
			_view.scene.addChild(redlight);
			lightpicker = new StaticLightPicker([greenlight, redlight]);
		}
		
		private function initParticle():void
		{
			//create the original particle geometry
			var cube:Geometry = new PlaneGeometry(SIZE, SIZE,1,1,false);
			
			//combine them into a list
			var i:int;
			var geometrySet1:Vector.<Geometry> = new Vector.<Geometry>;
			for (i = 0; i < _redTotal; i++)
			{
				geometrySet1.push(cube);
			}
			
			var geometrySet2:Vector.<Geometry> = new Vector.<Geometry>;
			for (i = 0; i < _whiteTotal; i++)
			{
				geometrySet2.push(cube);
			}
			
			var particleGeometry1:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet1);
			
			var particleGeometry2:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet2);
			
			var redAnimationSet:ParticleAnimationSet = new ParticleAnimationSet();
			redAnimationSet.hasDuration = true;
			redAnimationSet.addAnimation(new ParticleBezierCurveNode(ParticlePropertiesMode.LOCAL));
			redAnimationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL));
			
			redAnimationSet.initParticleFunc = initRedParticleParam;
			
			var redMaterial:ColorMaterial = new ColorMaterial(0xBE0E0E);
			redMaterial.alphaPremultiplied = true;
			redMaterial.bothSides = true;
			redMaterial.lightPicker = lightpicker;
			var redParticleMesh:Mesh = new Mesh(particleGeometry1, redMaterial);
			redAnimator = new ParticleAnimator(redAnimationSet);
			redParticleMesh.animator = redAnimator;
			redAnimator.start();
			_view.scene.addChild(redParticleMesh);
			
			
			
			var whiteAnimationSet:ParticleAnimationSet = new ParticleAnimationSet();
			whiteAnimationSet.hasDuration = false;
			whiteAnimationSet.addAnimation(new ParticleBezierCurveNode(ParticlePropertiesMode.LOCAL));
			whiteAnimationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL));
			whiteAnimationSet.initParticleFunc = initWhiteParticleParam;
			
			var whiteMaterial:ColorMaterial = new ColorMaterial(0xBEBEBE);
			whiteMaterial.alphaPremultiplied = true;
			whiteMaterial.bothSides = true;
			whiteMaterial.lightPicker = lightpicker;
			var whiteParticleMesh:Mesh = new Mesh(particleGeometry2, whiteMaterial);
			whiteAnimator = new ParticleAnimator(whiteAnimationSet);
			whiteParticleMesh.animator = whiteAnimator;
			whiteAnimator.start();
			_view.scene.addChild(whiteParticleMesh);
		}
		
		private function initRedParticleParam(param:ParticleProperties):void
		{
			param.startTime = 0;
			param.duration = TIME/1000 + Number.MIN_VALUE;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = 500;
			if (param.index < _redSeparation)
			{
				param[ParticleBezierCurveNode.BEZIER_END_VECTOR3D] = new Vector3D(200*SIZE, 0, 0);
			}
			else
			{
				param[ParticleBezierCurveNode.BEZIER_END_VECTOR3D] = new Vector3D(-200*SIZE, 0, 0);
			}
			
			param[ParticleBezierCurveNode.BEZIER_CONTROL_VECTOR3D] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), 2*r * Math.sin(degree2));
			param[ParticlePositionNode.POSITION_VECTOR3D] = redData[param.index];
		}
		
		
		private function initWhiteParticleParam(param:ParticleProperties):void
		{
			param.startTime = 0;
			param.duration = TIME/1000 + Number.MIN_VALUE;;
			var degree1:Number = Math.random() * Math.PI * 2;
			var degree2:Number = Math.random() * Math.PI * 2;
			var r:Number = 500;
			if (param.index < _whiteSeparation)
			{
				param[ParticleBezierCurveNode.BEZIER_END_VECTOR3D] = new Vector3D(200*SIZE, 0, 0);
			}
			else
			{
				param[ParticleBezierCurveNode.BEZIER_END_VECTOR3D] = new Vector3D(-200*SIZE, 0, 0);
			}
			param[ParticleBezierCurveNode.BEZIER_CONTROL_VECTOR3D] = new Vector3D(r * Math.sin(degree1) * Math.cos(degree2), r * Math.cos(degree1) * Math.cos(degree2), r * Math.sin(degree2));
			param[ParticlePositionNode.POSITION_VECTOR3D] = whiteData[param.index];
		}
		
		
		private function onEnterFrame(event:Event):void
		{
			if (_move)
			{
				_cameraController.panAngle = 0.3*(stage.mouseX - _lastMouseX) + _lastPanAngle;
				_cameraController.tiltAngle = 0.3*(stage.mouseY - _lastMouseY) + _lastTiltAngle;
			}
			time += 1 * Math.PI / 180;
			greenlight.x = Math.sin(time) * 600;
			greenlight.z = Math.cos(time) * 600;
			redlight.x = Math.sin(time+Math.PI) * 600;
			redlight.z = Math.cos(time+Math.PI) * 600;
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
