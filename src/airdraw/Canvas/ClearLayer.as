package airdraw.Canvas 
{
	import airdraw.Frames.Layer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	/**
	 * an undoable action to clear a bitmap
	 * @author Matthew Hyndman
	 */
	public class ClearLayer extends Undoable
	{
		private var bmp:BitmapData;
		private var layer:Layer;
		public function ClearLayer(clearlayer:Layer) 
		{
			layer = clearlayer;
			super();
		}
		public override function Do():void
		{
			//for future undo
			//might only need to be done once but not sure it matters much
			//newBitmap(w,h) might be faster than copy and clear
			bmp = layer.getBmpData().clone();
			layer.getBmpData().fillRect(layer.getBmpData().rect,0x00000000)
		}
		public override function Undo():void
		{
			//layer
			layer.setBmpData(bmp);
		}
		
	}

}