package
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.materials.methods.CascadeShadowMapMethod;

	import com.derschmale.away3d.multipass.SceneBuilder;
	import com.derschmale.away3d.multipass.UpdateLoop;
	import com.derschmale.away3d.multipass.boot.Bootstrap;
	import com.derschmale.away3d.multipass.commands.InitMaterialsCommand;
	import com.derschmale.away3d.multipass.commands.RenderViewCommand;
	import com.derschmale.away3d.multipass.commands.UpdateCameraCommand;
	import com.derschmale.away3d.multipass.commands.UpdateSceneCommand;
	import com.derschmale.away3d.multipass.ui.ConfigMediator;
	import com.derschmale.away3d.multipass.ui.ConfigPanel;
	import com.derschmale.patterns.tasks.Task;

	import flash.display.Sprite;
	import flash.events.Event;

	[SWF(frameRate="60", backgroundColor="#000000")]
	[Frame(factoryClass="com.derschmale.away3d.multipass.Preloader")]
	public class Main extends Sprite
	{
		private var _bootstrap:Bootstrap;
		private var _view:View3D;
		private var _updateLoop:UpdateLoop;
		private var _sceneBuilder:SceneBuilder;
		private var _configPanel:ConfigPanel
		private var _configMediator:ConfigMediator;
		private var _cascadeMethod:CascadeShadowMapMethod;

		public function Main()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		public function get bootStrap():Task
		{
			_bootstrap ||= new Bootstrap();
			return _bootstrap;
		}

		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			init();
			stage.addEventListener(Event.RESIZE, onStageResize);
		}

		private function init():void
		{
			initScene();
			initStats();
			assignLights();
			initUI();
			initUpdateLoop();
			updateSize();
		}

		private function assignLights():void
		{
			var initMaterials:InitMaterialsCommand = new InitMaterialsCommand();
			initMaterials.materials = _bootstrap.materials;
			initMaterials.sceneBuilder = _sceneBuilder;
			initMaterials.execute();
			_cascadeMethod = initMaterials.cascadeMethod;
		}

		private function initScene():void
		{
			_sceneBuilder = new SceneBuilder();
			_view = _sceneBuilder.create(_bootstrap.loadedMeshes);
			addChild(_view);
		}

		private function initStats():void
		{
			addChild(new AwayStats(_view));
		}

		private function initUI():void
		{
			_configPanel = new ConfigPanel();
			_configMediator = new ConfigMediator(_configPanel, _sceneBuilder.directionalLight, _cascadeMethod);
			addChild(_configPanel);
		}

		private function initUpdateLoop():void
		{
			_updateLoop = new UpdateLoop(stage);
			_updateLoop.addCommand(new UpdateCameraCommand(_view.camera, stage));
			_updateLoop.addCommand(new UpdateSceneCommand(_sceneBuilder));
			_updateLoop.addCommand(new RenderViewCommand(_view));
			_updateLoop.start();
		}

		private function onStageResize(event:Event):void
		{
			updateSize();
		}

		private function updateSize():void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
			_configPanel.x = stage.stageWidth - _configPanel.width - 20;
			_configPanel.y = 20;
		}
	}
}
