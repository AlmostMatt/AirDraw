package airdraw.Canvas 
{
	import airdraw.Canvas.Manipulator.Selection;
	import airdraw.Frames.Colorpicker;
	import airdraw.Frames.Layer;
	import airdraw.Frames.Layerpicker;
	import airdraw.GUI.ButtonGroup;
	import airdraw.GUI.ButtonGroupEvent;
	import airdraw.GUI.Dialog;
	import airdraw.GUI.Frame;
	import airdraw.GUI.IconButton;
	import airdraw.Utils.Utils;
	import airdraw.Utils.V;
	import com.adobe.images.BitString;
	import com.adobe.images.PNGEncoder;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.PNGEncoderOptions;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;
	/**
	 * White rectangle with functions to draw with mouse. interacts with undoable actions and undolist.
	 * @author Matthew Hyndman
	 */
	public class Canvas extends Saveable
	{
		public var w:int;
		public var h:int;
		private var p1:Point;
		private var p2:Point;
		
		
		private var mode:String = "SKETCH";
		
		private var vReflect:Boolean = false;
		private var hReflect:Boolean = true;
		private var reflX:Sprite = new Sprite();
		private var reflY:Sprite = new Sprite();
		private var radialP:Sprite = new Sprite();
		private var radialParts:int = 1;
		
		//resize borders
		private var borderSize:int = 25;
		private var borderX1:Boolean = false;
		private var borderX2:Boolean = false;
		private var borderY1:Boolean = false;
		private var borderY2:Boolean = false;
		
		private var bkg:Sprite = new Sprite();
		public var layers:Sprite = new Sprite();
		public var buffer:Bitmap = new Bitmap();
		public var selectionBuffer:Bitmap = new Bitmap();
		
		public var tmp:Shape = new Shape();//buffer for the buffer
		private var overlay:Sprite = new Sprite();
		private var borders:Sprite = new Sprite();
		
		//reference to containing frame in order to resize / be resized / set caption
		//public var frame:Frame;
		
		//state logic
		private var tool:String;
		private var drawing:Boolean = false;
		private var resizing:Boolean = false;
		private var colorpicking:Boolean = false;
		private var borderhover:Boolean = false;
		private var selecting:Boolean = false;
		//slightly different for how it is set
		private var erasing:Boolean = false;
		
		public var selector:Selection;
		
		public static var singleton:Canvas;
		
		public function Canvas(x1:int,y1:int,w1:int,h1:int) 
		{
			singleton = this;
			//averafe e5 and f5 is maybe ec
			x = x1;
			y = y1;
			w = w1;
			h = h1;
			
			//overlay
			drawBkg();
			drawOverlay();
			
			//layers should always be below overlay
			addChild(bkg);
			addChild(layers);
			
			buffer.bitmapData = new BitmapData(w, h, true, 0);
			selectionBuffer.bitmapData = new BitmapData(w, h, true, 0);
			//layers.addChild(buffer);
			//layers.addChild(tmp);
			//tmp.visible = false;
			
			addChild(borders);
			addChild(overlay);
			
			addChild(selector = new Selection());
			
			addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			//stage.
			addEventListener(Event.ADDED_TO_STAGE,init);
			//addEventListener(ButtonGroupEvent.ON_SELECT, onButtonSelect);
			
			overlay.addChild(reflX);
			overlay.addChild(reflY);
			overlay.addChild(radialP);
		}
		private function init(e:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			//addEventListener(Event.ENTER_FRAME, onMouseMove);
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		public function copy(e:Event = null):void
		{
			Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, Layerpicker.activelayer.getBmpData());
		}
		public function paste(e:Event = null):void
		{
			/*
			Premultiplied alpha
			r(8bits) g(8bits) b(8bits) a(8bits)
			-> r2 = r * a/255 <= r is at most r
			-> g2 = g * a/255 <= g
			
			or
			
			instead of 3 x 8 bit = 24 bits, do 4 x 6 bit = 24 bit
			so some colors slightly rounded (either shift >> 2 or * largest 6 bit number / largest 8 bit number, should be the same)
			but it is possible to represent and extract this as a bitmap
			*/

			var bmpdata:Object = Clipboard.generalClipboard.getData(ClipboardFormats.BITMAP_FORMAT)
			if (bmpdata != null)
				if (bmpdata.width > w || bmpdata.height > h)
					new Dialog(stage, "Paste", "Image is larger than canvas.",
						["Expand Canvas", "Crop Image", "Shrink Image"],
						[function():void { new Paste(Layerpicker.activelayer, bmpdata as BitmapData, Paste.STRETCHCANVAS); }
						,function():void { new Paste(Layerpicker.activelayer, bmpdata as BitmapData, Paste.CROP);}
						, function():void { new Paste(Layerpicker.activelayer, bmpdata as BitmapData, Paste.SHRINKIMG);} ] );
				else
					new Paste(Layerpicker.activelayer,bmpdata as BitmapData);
		}
		public function clear():void
		{
			new ClearLayer(Layerpicker.activelayer);			
		}
		//toggle draw and eraser modes
		public function setErasing(b:Boolean):void
		{
			erasing = b;
		}
		//toggle reflection (lines of symmettry);
		public function setReflectH(b:Boolean):void
		{
			reflX.visible = b;
			hReflect = b;
		}
		public function setReflectV(b:Boolean):void
		{
			reflY.visible = b;
			vReflect = b;
		}
		public function setRadial(b:Boolean):void
		{
			radialP.visible = b;
			radialParts = b ? 8 : 1;
			drawOverlay();
		}
		/*
		public function setMode(newmode:String):void
		{
			if (newmode != "SKETCH")
			{
				layer2.alpha = 0.4;
				layer3.alpha = 1;
			}
			else if (newmode == "SKETCH")
			{
				layer2.alpha = 1;
				layer3.alpha = 0.15;
			}
			mode = newmode;
		}*/
		private function onScroll(e:MouseEvent):void
		{
			//move this so that the center is in the same spot
			//or so that the cursor is on the same spot
			//or so that whatever spot is in the center of the screen is unchanged
			var speed:Number = 0.02;
			var oldwidth:Number = width;
			var oldheight:Number = height;
			scaleX = scaleY = Math.min(20, Math.max(0.05, scaleX * (1 + e.delta * speed)));
			//if it gets larger move it left, if smaller move it right
			x = (stage.stageWidth - w*scaleX) / 2;
			y = (stage.stageHeight - h*scaleY) / 2;
			//x += (oldwidth - width) / 2;
			//y += (oldheight - height) / 2;
			//trace(oldwidth, width);
			drawOverlay();
		}
		private function onClick(e:MouseEvent):void
		{
			//if rightclick or edge click, start rotate
			//this.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			//addEventListener(Event.ENTER_FRAME, onMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);

			//don't draw or select while moving or resizing the selection
			//the children of the manip object are rotate and pan shapes
			if (e.target == selector.rot || e.target.parent == selector.manip1 || e.target.parent == selector.manip2)
				return;
			p1 = new Point(mouseX, mouseY);
			if (borderhover)
			{
				resizing = true;
			}
			else
			{
				tool = Layerpicker.activelayer.getToolName();
				if (erasing)
				{
					drawing = true;
					buffer.blendMode = BlendMode.ERASE;
					Layerpicker.singleton.minibuffer.blendMode = BlendMode.ERASE;
				} else if (tool == IconButton.COLORPICK) {
					var bmp:Bitmap = Layerpicker.activelayer.layerbmp;
					var col:uint = bmp.bitmapData.getPixel32(bmp.mouseX, bmp.mouseY);
					var a:Number = uint(((col & 0xff000000) >> 24) & 0xff) / 255;
					Layerpicker.activelayer.setColor(col,a);
					Colorpicker.singleton.setColor(col, a);
					colorpicking = true;
				} else if (tool == IconButton.SELECT) {
					selecting = true;
					p2 = p1;
					selector.startSelect(p1);
				} else 	{
					drawing = true;
					buffer.blendMode = BlendMode.NORMAL;
					Layerpicker.singleton.minibuffer.blendMode = BlendMode.NORMAL;
				}
			}
		}
		
		//check if the mouse is near a border of the canvas
		private function onMouseMove(e:Event):void
		{
			//hide all borders
			if (! resizing)
				borderX1 = borderX2 = borderY1 = borderY2 = false;
			//ignore border hover actions that occur while drawing
			if (!drawing && ! selecting)
			{
				//acceptable proximity to border doesn't scale with zoom, but mouseX does
				var close:Number = borderSize / (2*scaleX);
				
				if (mouseY > 0 && mouseY < h)
				{
					//x1
					if (Math.abs(mouseX + close) < close)
						borderX1= true;
					if (Math.abs(mouseX - w - close) < close)
						borderX2 = true;
				}
				if (mouseX > 0 && mouseX < w)
				{
					//y1
					if (Math.abs(mouseY + close) < close)
						borderY1 = true;
					if (Math.abs(mouseY - h - close) < close)
						borderY2 = true;
				}
			}
			//whether or not some border is being hovered over
			var b:Boolean = borderhover;
			borderhover = (borderX1 || borderX2 || borderY1 || borderY2);
			if (borderhover != b)
				drawBorders();
		}
		
		//an onEnter Frame event, used while cursor is down
		private function onMove(e:Event):void
		{
			//new mouse position. p1 is old mouse position.
			p2 = new Point(mouseX, mouseY);

			if ((p2.x == p1.x && p2.y == p1.y)) trace("mouse didnt move");
			if (colorpicking) {
				var bmp:Bitmap = Layerpicker.activelayer.layerbmp;
				var col:uint = bmp.bitmapData.getPixel32(bmp.mouseX, bmp.mouseY);
				var a:Number = uint(((col & 0xff000000) >> 24) & 0xff) / 255;
				Layerpicker.activelayer.setColor(col, a);
				Colorpicker.singleton.setColor(col, a);
			} else if (drawing && (p2.x != p1.x || p2.y != p1.y)) {
				var color:uint = Layerpicker.activelayer.getColor();
				var brushsize:uint = Layerpicker.activelayer.getBrush();
				var drawa:Number = Layerpicker.activelayer.getToolAlpha();
				//if (brushsize == 0)
					//tmp.graphics.lineStyle(1, color, 0.6 * drawa);
				//	tmp.graphics.lineStyle(1, color, drawa);
				//else if (brushsize == 30)
				//0.3*
				//else
					tmp.graphics.lineStyle(brushsize, color, drawa);
				//
				tmp.graphics.moveTo(p1.x, p1.y);
				tmp.graphics.lineTo((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
				//forced intermediary point
				tmp.graphics.moveTo((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
				tmp.graphics.lineTo(p2.x, p2.y);
				//buffer.bitmapData.draw(tmp,tmp.transform.matrix);
				buffer.bitmapData.draw(tmp);
				var m1:Matrix = new Matrix();
				var m2:Matrix = new Matrix();
				if (hReflect)
				{
					m1.scale( -1, 1);
					m1.translate(2*reflX.x, 0);
					buffer.bitmapData.draw(tmp,m1);
				}
				if (vReflect)
				{
					m2.scale( 1, -1);
					m2.translate(0, 2*reflY.y);
					buffer.bitmapData.draw(tmp, m2);
				}
				if (hReflect && vReflect)
				{
					m1.concat(m2);
					buffer.bitmapData.draw(tmp, m1);
				}
				if (radialParts > 1)
				{
					m2 = new Matrix();
					m2.rotate(Math.PI * 2 / radialParts);
					m1 = new Matrix();
					for (var i:int = 0; i < radialParts; i++)
					{
						m1.translate( -w / 2, -h / 2);
						m1.concat(m2);
						m1.translate(w / 2, h / 2);
						buffer.bitmapData.draw(tmp, m1);
					}
				}
				tmp.graphics.clear();
				/*//draw line
				var lines:Array = [[p1,p2]];
				//reflect lines
				if (vReflect)
				{
					var n:int = lines.length;
					//vertical reflect
					for (var i:uint = 0; i < n ; i++)
					{
						var a:Point = lines[i][0];
						var b:Point = lines[i][1];
						lines.push([new Point(a.x,h-a.y),new Point(b.x,h-b.y)])
					}
				}
				if (hReflect)
				{
					n = lines.length;
					//horizontal reflect
					for (i=0; i < n ; i++)
					{
						a = lines[i][0];
						b = lines[i][1];
						lines.push([new Point(w-a.x,a.y),new Point(w-b.x,b.y)])
					}
				}
				//draw lines
				for each (var line:Array in lines)
				{
					a = line[0];
					b = line[1];
					buffer.graphics.moveTo(a.x, a.y);
					buffer.graphics.lineTo(b.x, b.y);
				}*/
			} else if (resizing) {
				var dx:int = 0;
				var dy:int = 0;
				if (borderX1)
					dx = (p1.x - p2.x);
				if (borderX2)
					dx = (p2.x - p1.x);
				if (borderY1)
					dy = (p1.y - p2.y);
				if (borderY2)
					dy = (p2.y - p1.y);
				if (dx != 0 || dy != 0)
					resize(2 * dx, 2 * dy);
			} else if (selecting) {
				selector.setPoint2(p2);
			}
			
			//removeChild(bmp);
			//bmp = new Bitmap(myBmp);
			//addChild(bmp);

			
			p1 = new Point(mouseX,mouseY);
		}
		private function onRelease(e:MouseEvent):void
		{
			//for each undo need layer (sketch, line) and bitmap
			if (drawing) {
				new Draw(Layerpicker.activelayer, buffer);//this will also clear the buffer
				tmp.graphics.clear();
			} else if (resizing) {
				
				//undo the current position changes (so that it can be properly undone/redone)
				new Resize(w, h);
			} else if (selecting) {
				selector.endSelect(p2);
			}
			colorpicking = false;
			drawing = false;
			resizing = false;
			selecting = false;
			
			//this.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onRelease);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			//removeEventListener(Event.ENTER_FRAME, onMove);
		}
		
		public function exportPng(e:Event=null):void
		{
			filetype = Saveable.PNG;
			saveAs();
		}
		public function saveAdraw(e:Event = null):void
		{
			trace("Save pressed: debug");
			filetype = Saveable.ADRAW;
			save();
		}
		public function saveAsAdraw(e:Event = null):void
		{
			filetype = Saveable.ADRAW;
			saveAs();
		}
		public function importPng(e:Event=null):void
		{
			browseFiles("Import Image", [new FileFilter("Images .PNG","*" + Saveable.DOTPNG)]);
		}
		public function loadAdraw(e:Event=null):void
		{
			browseFiles("Open", [new FileFilter("Air Draw files .ADR", "*" + Saveable.DOTADRAW)]);
		}
		
		public function newCanvas(e:Event):void
		{
			//filename = nil
			//filetype = nil
		}
		
		protected override function toBytes(filetype:String):void
		{
			if (filetype == Saveable.PNG)
			{
				var pngSource:BitmapData = new BitmapData(this.w, this.h, true, 0);
				//draw the layers exactly as they currently are (alpha etc)
				pngSource.draw(layers);
				bytes = PNGEncoder.encode(pngSource);
			} else if (filetype == Saveable.ADRAW) {
				trace("Writing bytes");
				for each (var l:Layer in Layerpicker.singleton.layers)
				{
					//layer a1, layer a2, layer tool, layer color, layer size, layer data
					bytes.writeFloat(l.alpha1);
					bytes.writeFloat(l.alpha2);
					bytes.writeUTF(l.getToolName() );
					bytes.writeUnsignedInt(l.getColor() );
					var ba:ByteArray = PNGEncoder.encode(l.getBmpData());
					bytes.writeInt(ba.length);
					bytes.writeBytes(ba);
				}
				bytes.compress();				
			}
		}
		
		protected override function fromBytes(filetype:String):void
		{
			if (filetype == Saveable.PNG)
			{
				//a single blank layer
				Layerpicker.singleton.clearLayers();
				Layerpicker.singleton.addLayer();
				//setLayer(0);
				//setLayer(
				//Layerpicker.select(0);
				
				var imageLoader:Loader = new Loader();
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
				imageLoader.name = "Layer.0";
				var image:URLRequest = new URLRequest(filename);
				imageLoader.load(image);
			}
			else if (filetype == Saveable.ADRAW)
			{
				trace("Reading bytes");
				try { bytes.uncompress() } catch (e:Error) {
					trace(e.message);
					//have an error popup
					//clear all layers and create a new blank layer
					return;
				}
				var i:int = 0;
				Layerpicker.singleton.clearLayers();
				while (bytes.bytesAvailable > 0)
				{
					//layer a1, layer a2, layer tool, layer color, layer size, layer data
					var ba:ByteArray = new ByteArray();
					var a1:Number = bytes.readFloat();
					var a2:Number = bytes.readFloat();
					var tool:String = bytes.readUTF();
					var color:uint= bytes.readUnsignedInt();
					Layerpicker.singleton.addLayer(tool,color,a1,a2);
					var n:int = bytes.readInt();
					bytes.readBytes(ba, 0, n);
					//bytes is the result of png encoding
					imageLoader = new Loader();
					imageLoader.name = "Layer." + i;
					imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);
					imageLoader.loadBytes(ba);
					//bmpData = PNGEncoder.decode(
					//PNGEncoder.encode(l.getBmpData());					
					i++;
				}
				//Layerpicker.singleton.select(0);
			}
		}
		private function onLoad(e:Event):void
		{
			trace("loaded something");
			var img:Loader = (e.currentTarget.loader as Loader);
			var layernumber:int = int(img.name.split(".")[1]);
			trace(img.name, layernumber);
			Layerpicker.singleton.loadLayer(layernumber,img);
			//Layerpicker.activelayer.getBmpData().draw(img, img.transform.matrix);
		}
		private function resize(wdiff:int,hdiff:int):void
		{
			//a "min size"
			if (w + wdiff < 1)
				wdiff = 1 - w; //w + wdiff will be +1
			if (h + hdiff < 1)
				hdiff = 1 - h; //h + hdiff will be +1
			w = w + wdiff;
			h = h + hdiff;
			x = x - wdiff / (2 / scaleX);
			y = y - hdiff / (2 / scaleX);
			layers.x = layers.x + wdiff / 2;
			layers.y = layers.y + hdiff / 2;
			drawBkg();
			drawOverlay();
			drawBorders();
			//temp resize (mask) right now
			//and permanent resize (setBitmapData) on mouse release
			if (layers.mask)
				layers.removeChild(layers.mask);
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0xFF0000, 1);
			mask.graphics.drawRect(-layers.x, -layers.y, w, h);
			mask.graphics.endFill();
			layers.addChild(mask);
			layers.mask = mask;
			//buffer.mask = mask;
		}
		public function drawBkg():void
		{
			graphics.clear();
			graphics.beginFill(0xececec);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
		}
		//clear and redraw the overlay, grid etc
		public function drawOverlay():void
		{
			overlay.graphics.clear();
			//diagonals
			
			//circle
			var r2:Number = 0.9 * Math.min(w / 2, h / 2);
			overlay.graphics.lineStyle(1, 0x999999,0.6);
			overlay.graphics.drawCircle(w/2,h/2,r2)
			overlay.graphics.drawCircle(w/2,h/2,0.6 * Math.min(w/2,h/2))
			//grid
			var unit1:int = 48;
			var unit2:int = 12;
			var unit3:int = 3;
			//
			var unit:int = unit1;
			if (scaleX > 2) {
				unit = unit2;
			}
			var tiles:int = w / (2 * unit)
			for (var gx:int = -tiles; gx <= tiles; gx ++)
			{	
				var lw:Number = (gx % int(unit1 / unit) == 0) ? 1 : 0;
				overlay.graphics.lineStyle(lw, 0x999999,0.6);
				//columns
				overlay.graphics.moveTo(w/2 + gx * unit, 0);
				overlay.graphics.lineTo(w/2 + gx * unit, h);
			}
			tiles = h/(2*unit)
			for (var gy:int = -tiles; gy <= tiles; gy ++)
			{
				lw = (gy % int(unit1 / unit) == 0) ? 1 : 0;
				overlay.graphics.lineStyle(lw, 0x999999,0.6);
				//rows
				overlay.graphics.moveTo(0, h/2 + gy * unit);
				overlay.graphics.lineTo(w, h/2 + gy * unit);
			}
			
			//y overlay
			overlay.graphics.lineStyle(1, 0x00cc00,0.6);
			overlay.graphics.moveTo(w / 2, 0);
			overlay.graphics.lineTo(w / 2, h);
			//x overlay
			overlay.graphics.lineStyle(1, 0xcc0000,0.6);
			overlay.graphics.moveTo(0, h/2);
			overlay.graphics.lineTo(w, h / 2);
			//xy overlay
			overlay.graphics.lineStyle(1, 0x0000cc,0.6);
			overlay.graphics.moveTo(w/2 - Math.min(w,h)/2, h/2 - Math.min(w,h)/2);
			overlay.graphics.lineTo(w/2 + Math.min(w,h)/2, h/2 + Math.min(w,h)/2);
			overlay.graphics.moveTo(w/2 + Math.min(w,h)/2, h/2 - Math.min(w,h)/2);
			overlay.graphics.lineTo(w/2 - Math.min(w,h)/2, h/2 + Math.min(w,h)/2);
			
			//lines of symmetry
			radialP.x = reflX.x = w / 2;
			radialP.y = reflY.y = h / 2;
			reflX.graphics.clear();
			reflY.graphics.clear();
			radialP.graphics.clear();
			reflX.graphics.lineStyle(2, 0x000000, 0.6,true,"normal",CapsStyle.NONE);
			reflY.graphics.lineStyle(2, 0x000000, 0.6,true,"normal",CapsStyle.NONE);
			Utils.dottedLine(reflX.graphics, 0, 0, 0, h, 5, 8);
			Utils.dottedLine(reflY.graphics, 0, 0, w, 0,  5, 8);
			radialP.graphics.lineStyle(2, 0x000000,0.6);
			for (var i:int = 0; i < radialParts; i++)
			{
				var a:Number = (i+0.5) * 2 * Math.PI / radialParts;
				radialP.graphics.moveTo(0, 0);
				radialP.graphics.lineTo(r2 * Math.cos(a), r2 * Math.sin(a));
			}
		}
		//clear and redraw the borders (they change color when the cursor is above them)
		public function drawBorders():void
		{
			borders.graphics.clear();
			var bordercolor:uint = 0xcc0000;
			//size and alpha for Hovering
			var s:Number = (borderSize / scaleX) / 2;
			var a1:Number = 0.6;
			//size and alpha for notHovering
			var a2:Number = 0.2;
			//x1
			borders.graphics.lineStyle(2*s, bordercolor, borderX1 ? a1 : a2);
			borders.graphics.moveTo(-s, -s);
			borders.graphics.lineTo(-s, h+s);
			//x2
			borders.graphics.lineStyle(2*s, bordercolor, borderX2 ? a1 : a2);
			borders.graphics.moveTo(w+s, -s);
			borders.graphics.lineTo(w+s, h+s);
			//y1
			borders.graphics.lineStyle(2*s, bordercolor, borderY1 ? a1 : a2);
			borders.graphics.moveTo(-s, -s);
			borders.graphics.lineTo(w+s, -s);
			//y2
			borders.graphics.lineStyle(2*s, bordercolor, borderY2 ? a1 : a2);
			borders.graphics.moveTo(-s, h+s);
			borders.graphics.lineTo(w+s, h+s);
		}
	}

}