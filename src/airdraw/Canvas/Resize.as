package airdraw.Canvas 
{
	import airdraw.Frames.Layer;
	import airdraw.Frames.Layerpicker;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	/**
	 * Resize the canvas (all layers and the buffer)
	 * @author Matthew Hyndman
	 */
	public class Resize extends Undoable
	{
		private var wdiff:int;
		private var hdiff:int;
		private var newW:int;
		private var newH:int;
		private var oldLayers:Array; //of bitmapdata
		
		public function Resize(w:int,h:int) 
		{
			newW = w;
			newH = h;
			wdiff = newW - Canvas.singleton.buffer.bitmapData.width;
			hdiff = newH - Canvas.singleton.buffer.bitmapData.height;
			//undo the temp repositioning of canvas
			var c:Canvas = Canvas.singleton;
			c.x += wdiff / (2 / c.scaleX);
			c.y += hdiff / (2 / c.scaleX);
			c.w -= wdiff;
			c.h -= hdiff;
			//crop and recenter all of the layers and the buffer
			c.layers.x = c.layers.y = 0;
			if (c.layers.mask)
			{
				c.layers.removeChild(c.layers.mask);
				c.layers.mask = null;
			}
			super();
		}
		public override  function Do():void
		{
			//buffer is curently empty
			//but should update minibuffer as well
			var c:Canvas = Canvas.singleton;
			oldLayers = new Array();
			for (var i:int = 0; i < Layerpicker.singleton.layers.length; i++)
			{
				var l:Layer = Layerpicker.singleton.layers[i];
				var newbmp:BitmapData = new BitmapData(newW, newH, true, 0);
				var offset:Matrix = new Matrix();
				offset.translate((wdiff) / 2, (hdiff) / 2);
				newbmp.draw(l.layerbmp, offset);
				oldLayers.push(l.getBmpData());
				l.setBmpData(newbmp);
			}
			Layerpicker.singleton.minibuffer.bitmapData = c.buffer.bitmapData = new BitmapData(newW, newH, true, 0);
			Layerpicker.singleton.minibuffer.transform.matrix = Layerpicker.activelayer.preview.transform.matrix;
			c.x -= wdiff / (2 / c.scaleX);
			c.y -= hdiff / (2 / c.scaleX);
			c.w += wdiff;
			c.h += hdiff;
			c.drawBkg();
			c.drawOverlay();
			c.drawBorders();
		}
		public override function Undo():void
		{
			var c:Canvas = Canvas.singleton;
			c.x += wdiff / (2 / c.scaleX);
			c.y += hdiff / (2 / c.scaleX);
			c.w -= wdiff;
			c.h -= hdiff;
			c.drawBkg();
			c.drawOverlay();
			c.drawBorders();
			//undo layer + buffer changes
			for (var i:int = 0; i < Layerpicker.singleton.layers.length; i++)
			{
				var l:Layer = Layerpicker.singleton.layers[i];
				l.setBmpData(oldLayers[i]);
			}
			Layerpicker.singleton.minibuffer.bitmapData = c.buffer.bitmapData = new BitmapData(newW - wdiff, newH - hdiff, true, 0);
			Layerpicker.singleton.minibuffer.transform.matrix = Layerpicker.activelayer.preview.transform.matrix;			
		}
	}

}