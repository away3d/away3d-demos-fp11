package invaders.utils
{

	public class MathUtils
	{
		public static function rand(min:Number, max:Number):Number {
		    return (max - min)*Math.random() + min;
		}
	}
}
