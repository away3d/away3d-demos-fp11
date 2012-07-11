package com.away3d.spaceinvaders.gameobjects.invaders
{

	import away3d.entities.Mesh;

	import flash.geom.Point;

	public class InvaderVO
	{
		public var meshFrame0:Mesh;
		public var meshFrame1:Mesh;
		public var definitionFrame0:Array;
		public var definitionFrame1:Array;
		public var cellsFrame0:Vector.<Point>;
		public var cellsFrame1:Vector.<Point>;

		public function InvaderVO() {
		}
	}
}
