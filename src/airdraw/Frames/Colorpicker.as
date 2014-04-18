package airdraw.Frames 
{
	import airdraw.GUI.DisplayText;
	import airdraw.GUI.Frame;
	import airdraw.GUI.Slider;
	import airdraw.Utils.Utils;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Colorpicker extends Frame
	{
		private var r:uint = 0;
		private var g:uint = 0;
		private var b:uint = 0;
		private var h:uint = 0;
		private var s:Number = 0;
		private var v:Number = 0;
		private var a:Number = 1;
		
		private var color:uint = 0x000000;
		
		private var preview:Sprite;
		private var sliders:Array = new Array();
		
		private var hextext:DisplayText;
		private var rgbtext:DisplayText;
		
		public static var singleton:Colorpicker; //reference to the instance when it is created
		
		public function Colorpicker(x1:int,y1:int,w1:int = 170,h1:int = 300) 
		{
			singleton = this;
			super(x1, y1, w1, h1, "Color Picker");
			var y:int = 25 + 10;
			addChild(new DisplayText(10, y, "R", 0xAAAAAA, 12, w1));
			sliders.push(addChild(new Slider(30, y, 100, 12, getR )));
			y += 20;
			addChild(new DisplayText(10, y, "G", 0xAAAAAA, 12, w1));
			sliders.push(addChild(new Slider(30, y, 100, 12, getG )));
			y += 20;
			addChild(new DisplayText(10, y, "B", 0xAAAAAA, 12, w1));
			sliders.push(addChild(new Slider(30, y, 100, 12, getB )));
			
			y += 40
			addChild(new DisplayText(10, y, "H", 0xAAAAAA, 12, w1));
			sliders.push(addChild(new Slider(30, y, 100, 12, getH )));
			y += 20;
			addChild(new DisplayText(10, y, "S", 0xAAAAAA, 12, w1));
			sliders.push(addChild(new Slider(30, y, 100, 12, getS )));
			y += 20;
			addChild(new DisplayText(10, y, "V", 0xAAAAAA, 12, w1));
			sliders.push(addChild(new Slider(30, y, 100, 12, getV )));
			
			y += 30;
			addChild(new DisplayText(10, y, "Preview:", 0xAAAAAA, 12, w1));
			preview = new Sprite();
			preview.x = 110, preview.y = y + 18
			addChild(preview);


			y += 50;

			addChild(new DisplayText(10, y, "A", 0xAAAAAA, 12, w1));
			sliders.push(addChild(new Slider(30, y, 100, 12, getA )));

			y += 20;
			
			hextext = new DisplayText(10, y, "hex", 0xAAAAAA, 12, w1,"LEFT","Century Gothic",true);
			rgbtext = new DisplayText(10, y + 16, "rgb", 0xAAAAAA, 12, w1,"LEFT","Century Gothic",true);
			addChild(hextext);
			addChild(rgbtext);
			
			setColor(Layerpicker.activelayer.getColor(),Layerpicker.activelayer.getToolAlpha());
			//drawColor();			
		}
		
		//get color, called by slider, updates preview
		private function getR(v:Number):void
		{
			r = int(255 * v);
			rgbColor();
		}
		private function getG(v:Number):void
		{
			g = int(255 * v);
			rgbColor();
		}
		private function getB(v:Number):void
		{
			b = int(255 * v);
			rgbColor();
		}
		private function getH(v2:Number):void
		{
			h = 360 * v2;
			hsvColor();
		}
		private function getS(v2:Number):void
		{
			s = v2;
			hsvColor();
		}
		private function getV(v2:Number):void
		{
			v = v2;
			hsvColor();
		}
		private function getA(v:Number):void
		{
			a = v;
			//a = int(v*255);
			drawColor();
		}
		//set h s v based on r g b
		private function rgbColor():void
		{
			//trace("rgb", r, g, b);
			var hsv:Array = Utils.rgb2hsv(r, g, b);
			h = hsv[0];
			s = hsv[1];
			v = hsv[2];
			//trace("to hsv", h, s, v);
			//prevent callbacks from occuring to avoid infinite recursion of rgb -> hsv -> rgb -> hsv ..
			sliders[3].setValue(h / 360,false);
			sliders[4].setValue(s,false);
			sliders[5].setValue(v,false);
			//
			color = Utils.rgbColor(r,g,b);
			drawColor();
		}
		//set r g b based on hsv
		private function hsvColor():void
		{
			//trace("hsv", h, s, v);	
			var rgb:Array = Utils.hsv2rgb(h, s, v);
			r = rgb[0];
			g = rgb[1];
			b = rgb[2];
			//trace("to rgb", r, g, b);
			//
			sliders[0].setValue(r / 255,false);
			sliders[1].setValue(g / 255,false);
			sliders[2].setValue(b / 255,false);
			//
			color = Utils.rgbColor(r,g,b);
			drawColor();
		}
		private function drawColor():void
		{
			//0 pad the hex representation in case red is 0 or < 10
			var hexstr:String = color.toString(16);
			while (hexstr.length < 6)
				hexstr = "0" + hexstr;				
			hextext.setText("Hex:   0x" + hexstr);
			rgbtext.setText("RGB:   { " + r + ", " + g + ", " + b+" }");
			
			preview.graphics.clear();
			//trace(a / 255);
			preview.graphics.beginFill(color,a);
			preview.graphics.drawRect(-20, -20, 40, 40);
			preview.graphics.endFill();
			
			Layerpicker.activelayer.setColor(color,a);
			if (Colorpalette.singleton)
				Colorpalette.singleton.setColor(color);
		}
		//called on init and on layer select, possibly also on color picker tool
		//-1 alpha parameter means "do not change"
		public function setColor(c:uint,newa:Number=-1):void
		{
			color = c;
			//a = ((color & 0xff000000) >> 24) && 0xff;
			//trace(a);
			r = (color & 0xff0000) >> 16;
			g = (color & 0x00ff00) >> 8;
			b = color & 0xff;
			//trace(color,r,g,b);
			sliders[0].setValue(r / 255, false);
			sliders[1].setValue(g / 255, false);
			sliders[2].setValue(b / 255, false);
			
			//alpha slider
			if (newa != -1)
			{
				a = newa
				sliders[6].setValue(newa, false);
			}	
			rgbColor();
		}
	}

}