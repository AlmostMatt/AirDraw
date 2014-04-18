package airdraw.GUI 
{
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class TextButton extends Button 
	{
		
		public function TextButton(str:String,x1:int,y1:int) 
		{
			var textob:DisplayText = new DisplayText(5, 2, str, 0xaaaaaa, 16, 0, "WIDTH");
			addChild(textob);
			super(x1, y1, textob.width + 10, textob.height);
		}
		
	}

}