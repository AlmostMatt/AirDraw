package airdraw.Utils 
{
	import flash.geom.Point;
	/**
	 * minimal vector math library (shorthand mostly)
	 * consider extending point class rather than creating a static utility class
	 * @author Matthew Hyndman
	 */
	public class V 
	{		
		public static function avg(p1:Point, p2:Point):Point
		{
			return new Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
		}
		public static function dist(p1:Point, p2:Point):Number
		{
			return Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2));
		}
	}

}