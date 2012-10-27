package com.away3d.invawayders.systems
{
	import com.away3d.invawayders.nodes.*;
	import com.away3d.invawayders.sounds.*;
	
	import net.richardlord.ash.core.*;
	
	public class SoundSystem extends System
	{
		[Inject]
		public var soundLibrary : SoundLibrary;
		
		[Inject(nodeType="com.away3d.invawayders.nodes.SoundNode")]
		public var nodes : NodeList;
		
		[PostConstruct]
		public function setUpListeners() : void
		{
			nodes.nodeAdded.add( addToNodes );
			nodes.nodeRemoved.add( removeFromNodes );
		}
		
		private function addToNodes( node : SoundNode ) : void
		{
			if (node.dataModel.subType.soundOnAdd)
				soundLibrary.playSound(node.dataModel.subType.soundOnAdd);
		}
		
		private function removeFromNodes( node : SoundNode ) : void
		{
			if (node.dataModel.subType.soundOnRemove)
				soundLibrary.playSound(node.dataModel.subType.soundOnRemove);
		}
	}
}
