package utils {
	import awayphysics.collision.shapes.AWPCollisionShape;
	
	import AWPC_Run.CModule;
	import AWPC_Run.createHeightmapDataBufferInC;
	import AWPC_Run.removeHeightmapDataBufferInC;
	import AWPC_Run.createTerrainShapeInC;
	import AWPC_Run.disposeCollisionShapeInC;
	
	public class PerlinShape extends AWPCollisionShape {
		private var dataPtr:uint;
		private var dataLen:int;
		private var _v:Vector.<int>;
		
		/**
		 * create terrain with the heightmap data
		 */
		public function PerlinShape(sw:int, sh:int, lw:int, lh:int, maxHeight:int, heights:Vector.<Number>) {
			dataLen = heights.length; //sw * sh;
			dataPtr = createHeightmapDataBufferInC(dataLen);
			_v = Vector.<int>([sw, sh, lw, lh, maxHeight]);
			
			var data:Vector.<Number> = heights;
			
			for (var i:int = 0; i < dataLen; i++) {
				CModule.writeFloat(dataPtr + i * 4, data[i] / _scaling);
			}
			
			pointer = createTerrainShapeInC(dataPtr, _v[0], _v[1], _v[2] / _scaling, _v[3] / _scaling, 1, -_v[4] / _scaling, _v[4] / _scaling, 1);
			super(pointer, 10);
		}
		
		public function update(heights:Vector.<Number>, maxHeight:int = 0):void {
			if (maxHeight != 0)
				_v[4] = maxHeight;
			var data:Vector.<Number> = heights;
			for (var i:int = 0; i < dataLen; i++) {
				CModule.writeFloat(dataPtr + i * 4, data[i] / _scaling);
			}
			pointer = createTerrainShapeInC(dataPtr, _v[0], _v[1], _v[2] / _scaling, _v[3] / _scaling, 1, -_v[4] / _scaling, _v[4] / _scaling, 1);
		}
		
		override public function dispose():void {
			m_counter--;
			if (m_counter > 0) {
				return;
			} else {
				m_counter = 0;
			}
			if (!_cleanup) {
				_cleanup = true;
				removeHeightmapDataBufferInC(dataPtr);
				disposeCollisionShapeInC(pointer);
			}
		}
	
	}
}