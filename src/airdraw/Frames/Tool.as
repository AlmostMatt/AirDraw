package airdraw.Frames 
{
	import airdraw.GUI.Button;
	import airdraw.GUI.IconButton;
	import com.adobe.images.BitString;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Tool extends IconButton
	{
		
		public var toolname:String;
		public static var SIZE:int = 32;
		public function Tool(x1:int,y1:int,type:String = BRUSH1) 
		{
			toolname = type;
			super(x1,y1,toolname, SIZE);
			
		}
		
	}

}