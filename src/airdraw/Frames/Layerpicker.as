package airdraw.Frames 
{
	import air.update.logging.Level;
	import airdraw.Canvas.Canvas;
	import airdraw.Canvas.RemoveLayer;
	import airdraw.Canvas.SwapLayers;
	import airdraw.GUI.Button;
	import airdraw.GUI.ButtonGroup;
	import airdraw.GUI.ButtonGroupEvent;
	import airdraw.GUI.DisplayText;
	import airdraw.GUI.Frame;
	import airdraw.GUI.IconButton;
	import airdraw.GUI.Slider;
	import airdraw.Main;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Layerpicker extends Frame
	{
		public static var activelayer:Layer;
		public static var activegroup:Sprite;
		
		// these are managed simultaneously, so adding to one should also add to the other
		public var layers:Array = new Array();
		public var bunches:Array = new Array();
		
		public var layerGroup:ButtonGroup;
		public static var singleton:Layerpicker;
		
		public var minibuffer:Bitmap;
		
		public function Layerpicker(x1:int,y1:int,w1:int = 150,h1:int = 330) 
		{
			singleton = this;
			super(x1, y1, w1, h1, "Layers",true);

			minibuffer = new Bitmap(Canvas.singleton.buffer.bitmapData);
			addChild(minibuffer);

			layerGroup = new ButtonGroup(ButtonGroup.LAYERS);
			//addChild(layerGroup);
			
			
			addChild(new DisplayText(5, 30, "Add Layer: ", 0xaaaaaa, 14, 100));
			addChild(new IconButton(100, 25 + 5, IconButton.PLUS, 25, function (v:Number):void { addLayer()}));
			
			addLayer(IconButton.PENCIL, 0x000064);
			addLayer(IconButton.BRUSH1,0x990000);
			layerGroup.addEventListener(ButtonGroupEvent.ON_SELECT, pickLayer);
			layerGroup.select(0);
			//activelayer = layers[0];
		}
		//i is index of layer
		//need to remove layer/bunch, shift previous layers, and be undoable (and not break other removeLayer buttons)
		//and select a different layer
		//in fact, selectLayer should alse be undoable if it is done manually
		//also prevent removal of last layer
		private function removeLayer(bunch:Sprite):void
		{
			if (bunches.length > 1)
			{
				new RemoveLayer(this,bunch);
			}
		}
		private function moveUp(bunch:Sprite):void
		{	//decrease y and increase index
			var index:int = -1;
			for (var i:int = 0; i < bunches.length; i++)
			{
				if (bunch == bunches[i])
					index = i;
			}
			if (index < bunches.length - 1) {
				new SwapLayers(this, index, index + 1);
			}
		}
		private function moveDown(bunch:Sprite):void
		{ 	//increase y and decrease index
			var index:int = -1;
			for (var i:int = 0; i < bunches.length; i++)
			{
				if (bunch == bunches[i])
					index = i;
			}
			if (index > 0) {
				new SwapLayers(this, index, index - 1);
			}
		}
		
		public function addLayer(tool:String=IconButton.BRUSH2,color:uint=0x000000, a1:Number = 1, a2:Number = 0.4 ):Layer
		{
			var canvas:Canvas = Canvas.singleton;
			var layerbmp:Bitmap = new Bitmap(new BitmapData(canvas.w, canvas.h, true, 0x00000000));
			var layer:Layer = new Layer(5, 0, layerbmp, tool, color);
			
			var bunch:Sprite = new Sprite();
			bunch.y = 25 + 35;
			addChild(bunch);
			//shift old layers to make room for this one (sliders, buttons, etc)
			for each (var o:Sprite in bunches)
				o.y = o.y + 65
			//I want it to be part of the group but not added to the layergroup display object
			layerGroup.add(layer);
			layerGroup.removeChild(layer);
			bunch.addChild(layer);
			
			var s:int = 20;
			//bunches.length will be index of bunches and index of layers
			 //can't use index because it is likely to change when other layers are removed/moved
			bunch.addChild(new IconButton(90, 0, IconButton.UP, s, moveUp, bunch));
			bunch.addChild(new IconButton(90, s, IconButton.DELETE, s, removeLayer, bunch));
			bunch.addChild(new IconButton(90, 2*s, IconButton.DOWN, s, moveDown, bunch));
			layer.slider1 = bunch.addChild(new Slider(120, 2, 10, 56, layer.setAlpha1, a1));
			layer.slider2 = bunch.addChild(new Slider(135, 2, 10, 56, layer.setAlpha2, a2));
			layer.alpha1 = a1;
			layer.alpha2 = a2;
			//i--;
			bunches.push(bunch);
			layers.push(layer);
			
			//a "container" for layer + buffer + selection
			//container has the "layer" blendmode and layer's alpha
			var layergrp:Sprite = new Sprite();
			layergrp.blendMode = BlendMode.LAYER; //allows for proper alpha blending and enables erasing
			layergrp.addChild(layerbmp);
			canvas.layers.addChild(layergrp);
			layer.select();
			return layer;
			//
		}
		
		//clears all layers, should be followed with a call to newLayer() or odd behaviour will occur with activelayer = nil
		//maybe use activelayer.tool for the new layer tool
		public function clearLayers(newlayers:int=1):void
		{
			//remove objects associated with each layer from the scene
			for (var i:int = 0; i < layers.length; i++ )
			{
				removeChild(bunches[i]);
				Canvas.singleton.layers.removeChild(layers[i].layerbmp.parent);
			}
			//new layergroup (so it doesn't have references to old buttons)
			layerGroup.removeEventListener(ButtonGroupEvent.ON_SELECT, pickLayer);
			layerGroup = new ButtonGroup(ButtonGroup.LAYERS);
			layerGroup.addEventListener(ButtonGroupEvent.ON_SELECT, pickLayer);
			
			bunches = [];
			layers = [];
			//layerGroup.select(0);			
		}
		//creates a new layer and draws a display object to it
		public function loadLayer(n:int, img:DisplayObject):void
		{
			var layer:Layer = layers[n];
			//if (layers.length < n + 1)
			//	layer = addLayer();
			//else
			//{
			//	layer = layers[n];
				//clear layer
			//}
			layer.layerbmp.bitmapData.draw(img);
		}
		
		private function pickLayer(e:ButtonGroupEvent):void
		{
			//e.value is the layer bmp
			//e.button is a Layer object
			var c:Canvas = Canvas.singleton;
			
			activelayer = (e.button as Layer);
			if (Colorpicker.singleton)
				Colorpicker.singleton.setColor(activelayer.getColor(),activelayer.getToolAlpha());
			if (Toolpicker.singleton)
				Toolpicker.singleton.setTool(activelayer.getToolName());
			
			var index:int = 0;
			for (var i:int = 0; i < layers.length; i++)
			{
				if (layers[i] == activelayer)
					index = i;
			}
			//move buffer
			//c.layers.removeChild(c.buffer);
			//get the layergroup object
			activegroup = (c.layers.getChildAt(index) as Sprite);
			activegroup.addChild(c.buffer);
			activegroup.addChild(c.selectionBuffer);
			//.addChildAt(c.buffer, index + 1);
			activegroup.alpha = activelayer.alpha1;
			
			activelayer.addChild(minibuffer);
			minibuffer.transform.matrix = activelayer.preview.transform.matrix;
			//Canvas.singleton.setLayer(e.value);
			//activelayer.deselect();
			//move buffer
			//Canvas.singleton.layers.removeChild(Canvas.singleton.buffer);
			//Canvas.singleton.activelayer = e.value; //bmp object
			//activelayer.select();
		}
	}

}