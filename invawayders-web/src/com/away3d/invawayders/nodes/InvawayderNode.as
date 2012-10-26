package com.away3d.invawayders.nodes
{
	import com.away3d.invawayders.components.DataModel;
	import com.away3d.invawayders.components.Invawayder;
	import com.away3d.invawayders.components.Motion3D;
	import com.away3d.invawayders.components.Transform3D;
	import net.richardlord.ash.core.Node;
	
	public class InvawayderNode extends Node
	{
		public var dataModel : DataModel;
		public var invawayder : Invawayder;
		public var transform : Transform3D;
		public var motion : Motion3D;
	}
}
