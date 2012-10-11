package com.derschmale.away3d.multipass.ui
{
	import away3d.lights.DirectionalLight;
	import away3d.lights.shadowmaps.CascadeShadowMapper;
	import away3d.materials.methods.CascadeShadowMapMethod;
	import away3d.materials.methods.DitheredShadowMapMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.HardShadowMapMethod;
	import away3d.materials.methods.SimpleShadowMapMethodBase;
	import away3d.materials.methods.SoftShadowMapMethod;

	import flash.events.Event;
	import flash.geom.Vector3D;

	public class ConfigMediator
	{
		private var _panel:ConfigPanel;
		private var _light:DirectionalLight;
		private var _shadowMapper:CascadeShadowMapper;
		private var _cascadeMethod:CascadeShadowMapMethod;

		public function ConfigMediator(panel : ConfigPanel, light : DirectionalLight, cascadeMethod : CascadeShadowMapMethod)
		{
			_panel = panel;
			_light = light;
			_shadowMapper = CascadeShadowMapper(_light.shadowMapper);
			_cascadeMethod = cascadeMethod;
			_panel.setLightPosition(_light.direction);
			initListeners();
		}

		private function initListeners():void
		{
			_panel.addEventListener(ConfigPanel.NUM_CASCADES_CHANGED, onNumCascadesChanged);
			_panel.addEventListener(ConfigPanel.METHOD_CHANGED, onMethodChanged);
			_panel.addEventListener(ConfigPanel.DEPTH_MAP_CHANGED, onDepthMapChanged);
			_panel.addEventListener(ConfigPanel.LIGHT_DIRECTION_CHANGED, onLightDirChanged);
		}

		private function onNumCascadesChanged(event:Event):void
		{
			_shadowMapper.numCascades = _panel.numCascades;
		}

		private function onMethodChanged(event:Event):void
		{
			_cascadeMethod.baseMethod = getShadowMethod();
		}

		private function getShadowMethod():SimpleShadowMapMethodBase
		{
			switch(_panel.filterMethod) {
				case "Unfiltered":
					return new HardShadowMapMethod(_light);
					break;
				case "Multiple taps":
					return new SoftShadowMapMethod(_light);
					break;
				case "PCF":
					return new FilteredShadowMapMethod(_light);
					break;
				case "Dithered":
					return new DitheredShadowMapMethod(_light);
					break;
			}
			return null;
		}

		private function onDepthMapChanged(event:Event):void
		{
			_shadowMapper.depthMapSize = _panel.depthMapSize;
		}

		private function onLightDirChanged(event:Event):void
		{
			var azimuth : Number = _panel.lightAzimuth;
			var arc : Number = _panel.lightArc;
			_light.direction = new Vector3D(
					Math.sin(azimuth)*Math.cos(arc),
					-Math.cos(azimuth),
					Math.sin(azimuth)*Math.sin(arc)
			);
		}
	}
}
