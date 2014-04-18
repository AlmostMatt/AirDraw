package airdraw.GUI 
{
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class ToggleButton extends IconButton 
	{
		private var toggled:Boolean = false;
		private var icon1:Bitmap;
		private var icon2:Bitmap;
		
		public function ToggleButton(x1:int,y1:int,iconname1:String,iconname2:String,size:int,onclick:Function=null,v:*=null) 
		{	
			icon1 = getIcon(iconname1);
			icon2 = getIcon(iconname2);
			
			super(x1, y1, iconname1, size, onclick, v);
			
			callback(false);
		}
		override public function select():void 
		{
			toggled = !toggled;
			if (toggled)
				icon.bitmapData = icon2.bitmapData;
			else
				icon.bitmapData = icon1.bitmapData;
			//ignore the previous button value
			value = toggled;
			//if (callback ~ = null)
			//	callback(toggled);
			super.select();
		}
	}

}