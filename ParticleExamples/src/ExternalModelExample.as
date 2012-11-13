package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	import away3d.containers.*;
	import away3d.controllers.*;
	import away3d.core.base.*;
	import away3d.debug.*;
	import away3d.entities.*;
	import away3d.events.*;
	import away3d.library.assets.*;
	import away3d.lights.*;
	import away3d.loaders.*;
	import away3d.loaders.parsers.*;
	import away3d.materials.*;
	import away3d.materials.lightpickers.*;
	import away3d.materials.methods.*;
	import away3d.primitives.*;
	import away3d.textures.*;
	import away3d.tools.helpers.*;
	import away3d.tools.helpers.data.*;
	import away3d.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="60")]
	public class ExternalModelExample extends Sprite
	{
		[Embed(source="/../embeds/snow_diffuse.png")]
		private var SnowDiffuse:Class;
		
		
		[Embed(source="/../embeds/snow_normals.png")]
		private var SnowNormal:Class;
		
		
		[Embed(source="/../embeds/snow_specular.png")]
		private var SnowSpecular:Class;
		
		[Embed(source="../embeds/sky_posX.jpg")]
		private var PosX:Class;
		[Embed(source="../embeds/sky_negX.jpg")]
		private var NegX:Class;
		[Embed(source="../embeds/sky_posY.jpg")]
		private var PosY:Class;
		[Embed(source="../embeds/sky_negY.jpg")]
		private var NegY:Class;
		[Embed(source="../embeds/sky_posZ.jpg")]
		private var PosZ:Class;
		[Embed(source="../embeds/sky_negZ.jpg")]
		private var NegZ:Class;
		
		[Embed(source = "../embeds/snow.obj", mimeType = "application/octet-stream")]
		private var Snow:Class;
		
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
		private var lightPicker:StaticLightPicker;
		

		public function ExternalModelExample()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_view = new View3D();
			_view.antiAlias = 2;
			addChild(_view);
			
			_cameraController = new HoverController(_view.camera, null, 45, 20, 1000, 5);
			
			addChild(new AwayStats(_view));
			
			initScene();
			//initParticle();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
		}
		
		private function initScene():void
		{
			var sunLight:DirectionalLight = new DirectionalLight(-1, -0.4, 1);
			sunLight.color = 0xFFFFFF;
			sunLight.ambient = 1;
			sunLight.diffuse = 1;
			sunLight.specular = 1;
			_view.scene.addChild(sunLight);

			var skyLight:PointLight = new PointLight();
			skyLight.y = 500;
			skyLight.color = 0xFFFFFF;
			skyLight.diffuse = 1;
			skyLight.specular = 0.5;
			skyLight.radius = 2000;
			skyLight.fallOff = 2500;
			_view.scene.addChild(skyLight);
			
			lightPicker = new StaticLightPicker([sunLight,skyLight]);
			
			var loader:AssetLoader = new AssetLoader();
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader.loadData(new Snow(), '', null, null, new OBJParser());
			
			var groundMaterial:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(SnowDiffuse), true, true, true);
			groundMaterial.lightPicker = lightPicker;
			groundMaterial.specularMap = Cast.bitmapTexture(SnowSpecular);
			groundMaterial.normalMap = Cast.bitmapTexture(SnowNormal);
			groundMaterial.addMethod(new FogMethod(0, 3000, 0x5f5e6e));
			groundMaterial.ambient = 0.5;
			var ground:Mesh = new Mesh(new PlaneGeometry(50000, 50000), groundMaterial);
			ground.geometry.scaleUV(50, 50);
			_view.scene.addChild(ground);
			
			//create a skybox
			var cubeTexture:BitmapCubeTexture = new BitmapCubeTexture(Cast.bitmapData(PosX), Cast.bitmapData(NegX), Cast.bitmapData(PosY), Cast.bitmapData(NegY), Cast.bitmapData(PosZ), Cast.bitmapData(NegZ));
			var skyBox:SkyBox = new SkyBox(cubeTexture);
			_view.scene.addChild(skyBox);
		}
		
		private function onAssetComplete(e:AssetEvent):void
		{
			switch(e.asset.assetType)
			{
				case AssetType.GEOMETRY:
					initParticle(e.asset as Geometry);
					break;
			}
		}
		
		private function initParticle(externalGeometry:Geometry):void
		{
			
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			var transforms:Vector.<ParticleGeometryTransform> = new Vector.<ParticleGeometryTransform>();
			var scale:Number;
			var vertexTransform:Matrix3D;
			var particleTransform:ParticleGeometryTransform;
			for (var i:int = 0; i < 3000; i++)
			{
				geometrySet.push(externalGeometry);
				particleTransform = new ParticleGeometryTransform();
				scale = Math.random()  + 1;
				vertexTransform = new Matrix3D();
				vertexTransform.appendScale(scale, scale, scale);
				particleTransform.vertexTransform = vertexTransform;
				transforms.push(particleTransform);
			}
			
			var particleGeometry:Geometry = ParticleGeometryHelper.generateGeometry(geometrySet,transforms);
			
			
			var animationSet:ParticleAnimationSet = new ParticleAnimationSet(true, true);
			animationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.GLOBAL, new Vector3D(0, -100, 0)));
			animationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticleOscillatorNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.addAnimation(new ParticleRotationalVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));
			animationSet.initParticleFunc = initParticleParam;
			
			var material:ColorMaterial = new ColorMaterial();
			material.addMethod(new FogMethod(0, 5000, 0x5f5e6e));
			material.lightPicker = lightPicker;
			var particleMesh:Mesh = new Mesh(particleGeometry, material);
			var animator:ParticleAnimator = new ParticleAnimator(animationSet);
			particleMesh.animator = animator;
			animator.start();
			animator.resetTime(-10000);
			_view.scene.addChild(particleMesh);
			
		}
		
		
		
		private function initParticleParam(param:ParticleProperties):void
		{
			param.startTime = Math.random()*20;
			param.duration = 20;
			param[ParticleOscillatorNode.OSCILLATOR_VECTOR3D] = new Vector3D(Math.random() * 100 - 50, 0, Math.random() * 100 - 50, Math.random() * 2 + 3);
			param[ParticlePositionNode.POSITION_VECTOR3D] = new Vector3D(Math.random() * 10000 - 5000, 1200, Math.random() * 10000 - 5000);
			param[ParticleRotationalVelocityNode.ROTATIONALVELOCITY_VECTOR3D] = new Vector3D(Math.random(), Math.random(), Math.random(), Math.random() * 2 + 2);
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
