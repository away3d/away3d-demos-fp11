package com.away3d.spaceinvaders.utils
{

	public class MathUtils
	{
		public static function rand(min:Number, max:Number):Number {
		    return (max - min)*Math.random() + min;
		}
	}
}
