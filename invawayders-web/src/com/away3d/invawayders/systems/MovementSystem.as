package com.away3d.invawayders.systems
{
	import com.away3d.invawayders.*;
	import com.away3d.invawayders.components.*;
	import com.away3d.invawayders.nodes.*;
	
	import net.richardlord.ash.core.*;

	public class MovementSystem extends System
	{
		[Inject]
		public var creator : EntityCreator;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.MovementNode")]
		public var movementNodes : NodeList;

		override public function update( time : Number ) : void
		{
			var movementNode : MovementNode;
			var position : Transform3D;
			var motion : Motion3D;

			for ( movementNode = movementNodes.head; movementNode; movementNode = movementNode.next )
			{
				position = movementNode.position;
				motion = movementNode.motion;
				
				position.x += motion.velocity.x;
				position.y += motion.velocity.y;
				position.z += motion.velocity.z;
				
				//remove entities that stray outside the play area
				if (position.z < GameSettings.minZ || position.z > GameSettings.maxZ)
					creator.destroyEntity(movementNode.entity);
			}
		}
	}
}
