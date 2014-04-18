package airdraw.Canvas 
{
	import airdraw.Frames.Layer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	/**
	 * Paste a bmp onto current layer
	 * @author Matthew Hyndman
	 */
	public class Paste extends Undoable
	{
		public static const CROP:String = "CROP";
		public static const SHRINKIMG:String = "SHRINK";
		public static const STRETCHCANVAS:String = "STRETCHCANVAS";
		
		private var bmp:BitmapData;
		private var layer:Layer;
		private var todraw:Bitmap;
		public function Paste(drawlayer:Layer,buffer:BitmapData,mode:String=Paste.CROP) 
		{
			//canvas size
			var w:int = drawlayer.getBmpData().width;
			var h:int = drawlayer.getBmpData().height;
			
			layer = drawlayer;
			todraw = new Bitmap(buffer);
			switch (mode)
			{
				case CROP:
					todraw.x = (w - buffer.width) / 2;
					todraw.y = (h - buffer.height) / 2;
					break;
				case SHRINKIMG:
					todraw.scaleX = todraw.scaleY = Math.min(1, w/ buffer.width, h / buffer.height);
					todraw.x = (w - todraw.width) / 2;
					todraw.y = (h - todraw.height) / 2;
					break;
				case STRETCHCANVAS:
					//resize canvas
					todraw.x = (w - buffer.width) / 2;
					todraw.y = (h - buffer.height) / 2;
					break;
			}
			//center it
			super();
		}
		public override function Do():void
		{
			super.Do();
			//for future undo
			//might only need to be done once but not sure it matters much
			bmp = layer.getBmpData().clone();
			//layer.setBmpData(bmp);	
			layer.getBmpData().draw(todraw,todraw.transform.matrix);
		}
		public override function Undo():void
		{
			super.Undo();
			layer.setBmpData(bmp);	
		}
	}

}