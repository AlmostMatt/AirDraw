package airdraw.Canvas 
{
	import airdraw.Frames.Layer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	/**
	 * an undoable action to draw a sprite to a bitmap
	 * @author Matthew Hyndman
	 */
	public class Draw extends Undoable
	{
		private var bmp:BitmapData;
		private var layer:Layer;
		private var todraw:Bitmap;
		private var blendMode:String;
		
		//private var bmp2:BitmapData;
		//could optimize by only recording 1 bmp at a time being bitmap data at time of undo / do and take the buffer as a parameter
		public function Draw(drawlayer:Layer,buffer:Bitmap)//buffer:Sprite
		{
			layer = drawlayer;
			//todraw = new Sprite();
			//todraw.graphics.copyFrom(buffer.graphics);
			//buffer.graphics.clear();
			todraw = new Bitmap(buffer.bitmapData.clone());
			blendMode = buffer.blendMode;
			if (blendMode == "invert") blendMode = "erase";
			//todraw.blendMode = blendMode;
			buffer.bitmapData.fillRect(buffer.bitmapData.rect,0);
			super();
		}
		public override function Do():void
		{
			super.Do();
			//for future undo
			//might only need to be done once but not sure it matters much
			bmp = layer.getBmpData().clone();
			//layer.setBmpData(bmp);	
			
			//layer.layerbmp.blendMode = BlendMode.LAYER;
			layer.getBmpData().draw(todraw,null,null,blendMode);
		}
		public override function Undo():void
		{
			super.Undo();
			layer.setBmpData(bmp);	
		}
	}

}