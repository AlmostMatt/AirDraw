package airdraw.Canvas 
{
	import airdraw.Frames.Layerpicker;
	import airdraw.Main;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class SwapLayers extends Undoable
	{
		private var A:int;
		private var B:int;
		private var layerpicker:Layerpicker;
		
		public function SwapLayers(lpicker:Layerpicker, i1:int, i2:int)
		{
			layerpicker = lpicker;
			A = Math.min(i1,i2);
			B = Math.max(i1,i2);
			super();
		}
		public override function Do():void
		{
			var b1:Sprite= layerpicker.bunches[A];
			var b2:Sprite = layerpicker.bunches[B];
			b1.y = b1.y - 65;
			b2.y = b2.y + 65;
			layerpicker.layerGroup.swap(A,B);
			var removed:Array = layerpicker.bunches.splice(A,1);
			layerpicker.bunches.splice(B, 0, removed[0]);
			removed = layerpicker.layers.splice(A, 1);
			layerpicker.layers.splice(B, 0, removed[0]);
			//if index == 0 or bunches.length -1 then enable/disable the up/down buttons
			
			//swap the "layer containers" which may also swap the buffers
			Canvas.singleton.layers.swapChildren(layerpicker.layers[A].layerbmp.parent, layerpicker.layers[B].layerbmp.parent)
		}
		public override function Undo():void
		{
			//this function is it's own inverse
			Do();
		}
		
	}

}