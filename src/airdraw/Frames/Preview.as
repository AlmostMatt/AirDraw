package airdraw.Frames 
{
	import airdraw.GUI.Frame;
	import airdraw.Main;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import airdraw.Canvas.Canvas;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Preview extends Frame
	{
		private var prev:Bitmap;
		public function Preview(x1:int,y1:int,w1:int = 128,h1:int = 128+25) 
		{
			super(x1, y1, w1, h1, "Preview", false);
			var wh:Rectangle = Layerpicker.activelayer.getBmpData().rect;
			prev = new Bitmap(new BitmapData(wh.width,wh.height,true,0));
			addChild(prev);
			prev.y = 25;
			//center this
			prev.scaleX = prev.scaleY = Math.min(w1 / prev.bitmapData.width, (h1-25) / prev.bitmapData.height);
			
			addEventListener(Event.ENTER_FRAME, draw);
		}
		//draw every frame for now, could probably be optimized
		public function draw(e:Event):void
		{
			//clear it
			prev.bitmapData.fillRect(prev.bitmapData.rect, 0);
			//and then draw layers and buffer
			//prev.bitmapData.draw(Canvas.singleton.layers);
			for each (var l:Layer in Layerpicker.singleton.layers)
			{
				//want to draw each layer with alpha1 instead of alpha2
				//drawing with alpha 1 is also ok
				//prev.bitmapData.draw(l.getBmpData());
				prev.bitmapData.draw(l.layerbmp.parent);// , null, null, BlendMode.LAYER);
			}
			//prev.bitmapData.draw(Canvas.singleton.buffer);
		}
	}

}