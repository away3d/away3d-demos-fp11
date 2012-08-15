package invawayders.data
{
	import flash.geom.*;
	
	/**
	 * 
	 */
	public class OctopusInvaderData extends InvaderData
	{
		public function OctopusInvaderData(id:uint)
		{
			this.id = id;
			
			cellDefinition = Vector.<Vector.<uint>>([
				Vector.<uint>([
					0, 0, 0, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 1, 1, 0, 0,
					0, 1, 1, 1, 1, 1, 1, 0,
					1, 1, 0, 1, 1, 0, 1, 1,
					1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 1, 0, 0, 1, 0, 0,
					0, 1, 0, 1, 1, 0, 1, 0,
					1, 0, 1, 0, 0, 1, 0, 1
				]),
				Vector.<uint>([
					0, 0, 0, 1, 1, 0, 0, 0,
					0, 0, 1, 1, 1, 1, 0, 0,
					0, 1, 1, 1, 1, 1, 1, 0,
					1, 1, 0, 1, 1, 0, 1, 1,
					1, 1, 1, 1, 1, 1, 1, 1,
					0, 0, 1, 0, 0, 1, 0, 0,
					0, 1, 0, 0, 0, 0, 1, 0,
					0, 0, 1, 0, 0, 1, 0, 0
				])
			]);
			
			dimensions = new Point( 8, 8 );
			
			life = 1;
			
			spawnRate = 20000;
			
			fireRate = 1000;
			
			panAmplitude = 500;
			
			speed = 25;
			
			scale = 1;
			
			score = 100;
		}
	}
}
