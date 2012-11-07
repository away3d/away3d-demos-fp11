package com.away3d.invawayders.components
{
	import away3d.entities.*;
	
	import flash.geom.*;
	
	public class Explosion
	{
		public var currentFrame : uint;
		
		public var particleMeshes : Vector.<Mesh>;
		
		public var particlePositions:Vector.<Vector.<Vector3D>>;
		
		public var particleVelocities:Vector.<Vector.<Vector3D>>;
		
		public var particleRotationalVelocities:Vector.<Vector.<Vector3D>>;
		
		public function Explosion(particleMeshes : Vector.<Mesh>, particlePositions:Vector.<Vector.<Vector3D>>, particleVelocities:Vector.<Vector.<Vector3D>>, particleRotationalVelocities:Vector.<Vector.<Vector3D>>)
		{
			this.particleMeshes = particleMeshes;
			this.particlePositions = particlePositions;
			this.particleVelocities = particleVelocities;
			this.particleRotationalVelocities = particleRotationalVelocities;
		}
	}
}
