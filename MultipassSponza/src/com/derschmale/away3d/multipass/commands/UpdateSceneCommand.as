package com.derschmale.away3d.multipass.commands
{
	import away3d.cameras.Camera3D;
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.lights.PointLight;

	import com.derschmale.away3d.multipass.SceneBuilder;
	import com.derschmale.patterns.commands.Command;

	public class UpdateSceneCommand implements Command
	{
		private var _sceneBuilder:SceneBuilder;

		public function UpdateSceneCommand(sceneBuilder : SceneBuilder)
		{
			_sceneBuilder = sceneBuilder;
		}

		public function execute():void
		{
			var pointLights : Vector.<PointLight> = _sceneBuilder.flameLights;
			var flames : Vector.<Mesh> = _sceneBuilder.flameMeshes;
			var len : int = flames.length;
			var camera : Camera3D = _sceneBuilder.view.camera;

			for (var i : int = 0; i < len; ++i) {
				var pointLight : PointLight = pointLights[i];
				pointLight.fallOff = 380+Math.random()*20;
				pointLight.radius = 200+Math.random()*30;
				pointLight.diffuse = .9+Math.random()*.1;
				var flame : Mesh = flames[i];
				var subMesh : SubMesh = flame.subMeshes[0];
				subMesh.offsetU += 1/16;
				if (subMesh.offsetU >= 1)
					subMesh.offsetU = 0;
				flame.rotationY = Math.atan2(flame.x - camera.x, flame.z - camera.z)*180/Math.PI;
			}
		}
	}
}
