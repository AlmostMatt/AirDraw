package airdraw.Canvas 
{
	import adobe.utils.CustomActions;
	import airdraw.Frames.Layer;
	import airdraw.Frames.Layerpicker;
	import airdraw.GUI.Button;
	import airdraw.Main;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	/**
	 * delete a layer (and restore it)
	 * @author Matthew Hyndman
	 */
	public class RemoveLayer extends Undoable
	{
		//info needed to remove
		private var index:int = -1;
		private var lpicker:Layerpicker;
		//info needed to restore
		private var wasselected:Boolean;
		private var b:Button;
		private var v:*;
		private var lremoved:Layer;
		private var bremoved:Sprite;
		
		public function RemoveLayer(layerpicker:Layerpicker,bunch:Sprite) 
		{	
			lpicker = layerpicker;
			//find the index
			for (var i:int = 0; i < layerpicker.bunches.length; i++)
			{
				if (bunch == lpicker.bunches[i]) {
					index = i;
				}
			}
			super();
		}
		public override function Do():void
		{
			for (var i:int = 0; i < index; i++)
				lpicker.bunches[i].y = lpicker.bunches[i].y - 65;
			//remove bunch and canvas layer
			lpicker.removeChild(lpicker.bunches[index]);
			//layer bitmap is child of layergrp sprite which should be removed from the canvas layers object
			Canvas.singleton.layers.removeChild(lpicker.layers[index].layerbmp.parent)
			//manage arrays
			var removed:Array = lpicker.bunches.splice(index, 1);
			bremoved = removed[0];
			removed = lpicker.layers.splice(index, 1);
			lremoved = removed[0];
			b = lpicker.layerGroup.getButton(index);
			v = lpicker.layerGroup.getValue(index);
			wasselected = lpicker.layerGroup.remove(index);
		}
		//restoring active layer works np, restoring inactive layer results in :
		//activelayer = incorrect layer
		//somehow they both seem to have the same index
		//and the restored layer doesnt deselect the other one or itself when it is selected
		//they are "Equal" somehow??
		//two of the same button
		public override function Undo():void
		{
			for (var i:int = 0; i < index; i++)
				lpicker.bunches[i].y = lpicker.bunches[i].y + 65;
			//remove bunch and canvas layer
			lpicker.addChild(bremoved);
			//bremoved.removeChild(b);
			Canvas.singleton.layers.addChildAt(lremoved.layerbmp.parent, index);
			//manage arrays
			lpicker.bunches.splice(index, 0, bremoved);
			lpicker.layers.splice(index, 0, lremoved);
			lpicker.layerGroup.addAt(b,v,index,wasselected);
		}
	}

}