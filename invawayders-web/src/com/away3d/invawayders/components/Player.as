package com.away3d.invawayders.components
{
	import away3d.cameras.*;
	import away3d.entities.*;
	
	public class Player
	{
		public var fireTimer : Number = GameSettings.blasterFireRateMS;
		public var fireCounter : uint = 0;
		public var shakeCounter : uint = 0;
		public var camera : Camera3D;
		public var leftBlaster : Mesh;
		public var rightBlaster : Mesh;
		
		public function Player( camera : Camera3D, leftBlaster : Mesh, rightBlaster : Mesh )
		{
			this.camera = camera;
			this.leftBlaster = leftBlaster;
			this.rightBlaster = rightBlaster;
		}
	}
}
