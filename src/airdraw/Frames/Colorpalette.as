package airdraw.Frames 
{
	import airdraw.GUI.ButtonGroup;
	import airdraw.GUI.ColorButton;
	import airdraw.GUI.DisplayText;
	import airdraw.GUI.Frame;
	import airdraw.GUI.IconButton;
	import airdraw.Utils.Utils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Colorpalette extends Frame
	{
		private var colorGroup:ButtonGroup;
		private var rowsize:int = 20;
		private var numrows:int = 0;
		private var maxrows:int = 20;
		private var colorBmp:Bitmap;
		
		private var colors:Array = new Array();
		private var hues:Array = new Array();
		private var buttons:Array = new Array();
		private var addButton:ColorButton;
		
		public static var singleton:Colorpalette;
		
		public function Colorpalette(x1:int,y1:int,w1:int = 180,h1:int = 330) 
		{
			singleton = this;
			super(x1, y1, w1, h1, "Color Palette");
			var s:int = 25;
			
			colorBmp = new Bitmap(new BitmapData(w1 - rowsize - 15, maxrows * rowsize, true, 0));
			colorBmp.x = 10 + rowsize;
			colorBmp.y = 25 + 35;
			addChild(colorBmp);
			
			colorGroup = new ButtonGroup(ButtonGroup.COLORS);
			addChild(colorGroup);
			var colors:Array = [0x999999, 0xE7E72D, 0xFFD180, 0xDB2020, 0x6848B9, 0x4444ff, 0x4877B9, 0x004242, 0x68BF80, 0x0FB63E];
			
			addChild(new DisplayText(5, 30, "Add Color: ", 0xaaaaaa, 14, 100));
			addChild(addButton = new ColorButton(100 , 30, 25, 25, Layerpicker.activelayer.getColor(), function(col:uint):void { addRow(col) }));
			for (var i:int = 0; i < colors.length; i++) {
				addRow(colors[i]);
			}
			
			//add
			//colorBmp.addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(MouseEvent.MOUSE_DOWN, onClick);
		}
		
		private function onClick(e:MouseEvent):void
		{
			if (colorBmp.mouseX > 0 && colorBmp.mouseX < colorBmp.width && colorBmp.mouseY > 0 && colorBmp.mouseY < colorBmp.height)
			{
				var c:uint = colorBmp.bitmapData.getPixel32(colorBmp.mouseX, colorBmp.mouseY);
				//surely there is a better way to extract the alpha from this number
				// I had issues with it converting to an int and preceding the shifted number with ff ff ff, I don't know why.
				if (((uint(c & 0xff000000) >> 24) & 0xff) < 0xff)
					return;
				//remove the alpha info now
				c = colorBmp.bitmapData.getPixel(colorBmp.mouseX, colorBmp.mouseY);
				Layerpicker.activelayer.setColor(c);
				Colorpicker.singleton.setColor(c);
				addEventListener(MouseEvent.MOUSE_MOVE, onMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
			}			
		}
		
		private function onMove(e:MouseEvent):void
		{
			var c:uint = colorBmp.bitmapData.getPixel32(colorBmp.mouseX, colorBmp.mouseY);
			if (((uint(c & 0xff000000) >> 24) & 0xff) < 0xff)
				return;
			c = colorBmp.bitmapData.getPixel(colorBmp.mouseX, colorBmp.mouseY);
			//trace("clicked",c.toString(16));
			Layerpicker.activelayer.setColor(c);
			Colorpicker.singleton.setColor(c);
		}
		
		private function onRelease(e:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onRelease);			
		}
		
		public function setColor(col:uint):void
		{
			addButton.setColor(col);
		}
		
		public function clearRow(i:int):void
		{
			numrows--;
			removeChild(buttons[numrows-1]);
			buttons.splice(numrows-1,1);
			colors.splice(i, 1);
			hues.splice(i, 1);
			//get pixels below the row
			var w:int = colorBmp.bitmapData.width;
			var pixels:ByteArray = colorBmp.bitmapData.getPixels(new Rectangle(0, (i + 1) * rowsize, w, (maxrows - i - 1) * rowsize));
			pixels.position = 0;
			//and move them up
			colorBmp.bitmapData.setPixels(new Rectangle(0, i * rowsize, w, (maxrows - i - 1) * rowsize),pixels);
		}
		
		public function addRow(col:uint):void
		{
			//check if hue already exists
			if (numrows > 0)
				buttons.push(addChild(new IconButton(5 , colorBmp.y + rowsize * numrows, IconButton.DELETE, rowsize, clearRow, numrows)));
			numrows++;
			
			//assume colors is sorted by hue so far.
			//and a corresponding hue array exists
			var hsv:Array = Utils.getHSV(col);
			var sortby:Number = hsv[0] * hsv[1];
			for (var n:int = 0; n < colors.length; n++)
			{
				if (hues[n] > sortby)
					break;
			}
			//colors.push(col);
			colors.splice(n, 0, col);
			hues.splice(n, 0, sortby);
			//get pixels for all later rows
			var w:int = colorBmp.bitmapData.width;
			var pixels:ByteArray = colorBmp.bitmapData.getPixels(new Rectangle(0, n * rowsize, w, (maxrows - n - 1) * rowsize));
			pixels.position = 0;
			//and move them down
			colorBmp.bitmapData.setPixels(new Rectangle(0, (n + 1) * rowsize, w, (maxrows - n - 1) * rowsize),pixels);
			
			
			//the graphics object on which to draw the gradient that will be rendered to the bitmapData
			var tmp:Shape = new Shape();
			//size of the desired color, non gradient component
			var s:int = 30;
			//var hsv:Array = Utils.getHSV(col);
			
			var c1:uint = Utils.hsvColor(hsv[0], hsv[1], 0);
			var c2:uint = Utils.hsvColor(hsv[0], hsv[1], 1);//gradient to white
			
			w = colorBmp.bitmapData.width-s;
			var x0:int = 0;
			var x1:int = Math.ceil(w * hsv[2]);
			//x1 = w/2
			var x2:int = x1 + s;
			var x3:int = w + s;
			
			var method:int = 2;
			
			//could do this as one gradient with different ratios values
			switch (method)
			{
				//black to maxValue-color to white, with color position based on saturation
				case 1:
					var matrix:Matrix = new Matrix();
					matrix.createGradientBox(x3 - x0, rowsize);
					tmp.graphics.beginGradientFill(GradientType.LINEAR,[0x000000,c2,0xffffff],[1,1,1],[0,255 * (1 - 0.5*hsv[1]),255],matrix);
					tmp.graphics.drawRect(x0, n * rowsize, x3-x0, rowsize);
					tmp.graphics.endFill();
					colorBmp.bitmapData.draw(tmp);
					break;
				case 2:
					//draw black to color to maxValue color to white
					if (hsv[2] > 0)
					{
						matrix = new Matrix();
						matrix.createGradientBox(x1 - x0, rowsize);
						tmp.graphics.beginGradientFill(GradientType.LINEAR,[c1,col],[1,1],[0,255],matrix);
						tmp.graphics.drawRect(x0, n * rowsize, x1-x0, rowsize);
						tmp.graphics.endFill();
						colorBmp.bitmapData.draw(tmp);
					}
					//draw color
					colorBmp.bitmapData.fillRect(new Rectangle(x1, n * rowsize, x2 - x1, rowsize), 0xff000000 | col);
					//draw color to brighest variation
					if (true)//hsv[2] < 1)
					{
						matrix = new Matrix();
						matrix.createGradientBox(x3 - x2, rowsize, 0, x2, n * rowsize);
						//1 - satDiff / (abs(satDiff) + abs(valueDiff))
						tmp.graphics.beginGradientFill(GradientType.LINEAR,[col,c2,0xffffff],[1,1,1],[0,255 * 1-hsv[1]/(hsv[1]+1-hsv[2]),255],matrix);
						tmp.graphics.drawRect(x2, n * rowsize, x3-x2, rowsize);
						tmp.graphics.endFill();
						colorBmp.bitmapData.draw(tmp);
						//colorBmp.bitmapData.fillRect(new Rectangle(w * hsv[2] + s, n * rowsize, w * (1 - hsv[2]), rowsize), c2);
					}
					//outline color
					//hsv[2] > 0.5 ? 0x000000 : 0xffffff
					//var v:uint = 255 * hsv[2];
					//var c:uint = Utils.rgbColor(v, v, v);
					tmp.graphics.clear();
					//var invC:uint = Utils.hsvColor((180+hsv[0])%360, 1, 1);
					var invC:uint = Utils.hsvColor(hsv[0], hsv[1]*0.8, 0.5 + hsv[2]/2);
					tmp.graphics.lineStyle(2, invC);// x1 > w / 2 ? 0x333333 : 0xcccccc);
					tmp.graphics.drawRect(x1, n * rowsize+1, x2 - x1, rowsize-3);
					tmp.graphics.lineStyle();
					colorBmp.bitmapData.draw(tmp);
					break;
				case 3:
					//step based
					//width steps 1 to round(position/stepsize) being black to color and remaining steps color to maxvalue color to white
					tmp.graphics.clear();
					var steps:int = 4;
					w = colorBmp.width;// hsv[2];
					for (var i:int = 0; i < steps; i++)
					{
						x1 = Math.floor( (w) * i / steps);
						x2 = Math.floor( (w) * (i + 1) / steps);
						var ci:uint = Utils.hsvColor(hsv[0], hsv[1], (i+1) / (steps+1));
						//tmp.graphics.lineStyle(1, 0xffffff);
						tmp.graphics.beginFill(ci);
						tmp.graphics.drawRect(x1, n * rowsize, x2 - x1, rowsize);
						tmp.graphics.endFill();
					}
					colorBmp.bitmapData.draw(tmp);
					break;
			}
		}
	}

}