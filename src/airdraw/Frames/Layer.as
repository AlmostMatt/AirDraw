package airdraw.Frames 
{
	import airdraw.Canvas.Canvas;
	import airdraw.GUI.Button;
	import airdraw.GUI.IconButton;
	import airdraw.GUI.Slider;
	import com.adobe.images.BitString;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Layer extends Button
	{
		private var toolType:String;
		private var toolIcon:Bitmap;
		private var color:Bitmap;
		
		public var preview:Bitmap; //a copy of the canvas layer object for button preview
		public var layerbmp:Bitmap; //the layer bitmap object on the canvas
		
		//alpha of the layer
		public var alpha1:Number = 1; //these values will be replaced by the addlayer() function
		public var alpha2:Number = 1;
		
		//alpha of the draw tool associated with the layer
		private var toolAlpha:Number = 1;
		
		public var slider1:DisplayObject;
		public var slider2:DisplayObject;
		
		//	ACTIVECOLOR = 0xcccccc;
		//	HOVERCOLOR = 0xffffff;
		//	NORMALCOLOR = 0x888888;
			
		public function Layer(x1:int, y1:int, bmp:Bitmap, toolT:String, toolColor:uint = 0xcc44ff) 
		{	
			var s:int = 20;
			super(x1, y1, 80,60);
			//var h:int = 60;
			//var w:int = Canvas.singleton.w * h / Canvas.singleton.h; 
			
			layerbmp = bmp;
			preview = new Bitmap(bmp.bitmapData);// bmp.bitmapData);
			setBmpData(bmp.bitmapData);
			
			toolIcon = new Bitmap(new BitmapData(Tool.SIZE, Tool.SIZE, true));
			toolIcon.scaleX = toolIcon.scaleY = s / Tool.SIZE;
			//toolIcon.x = s;
			toolIcon.y = h - s;
			//default color
			color = new Bitmap(new BitmapData(Tool.SIZE, Tool.SIZE, false, toolColor));
			color.y = h - s;
			color.scaleX = color.scaleY = s / Tool.SIZE;
			
			addChild(preview);
			addChild(color);
			addChild(toolIcon);
			
			//default tool
			setTool(IconButton.getIcon(toolT),toolT);
		}
		
		public function setColor(c:uint,a:Number=-1):void
		{
			//color.bitmapData.fillRect(color.bitmapData.rect, (a << 24) | c );
			if (a != -1)
			{
				color.alpha = a;
				toolAlpha = a;
			}
			color.bitmapData.fillRect(color.bitmapData.rect, (255 << 24) | c );
		}
		public function getColor():uint
		{
			return color.bitmapData.getPixel(1,1); //assuming solid color rect of at least 1x1
		}
		public function getToolAlpha():Number
		{
			return toolAlpha;
		}
		public function getToolName():String
		{
			return toolType;
		}
		public function getBrush():uint
		{
			switch (toolType)
			{
				case IconButton.PENCIL:
					return 1;
				case IconButton.PEN:
					return 4;
				case IconButton.BRUSH1:
					return 10;
				case IconButton.BRUSH2:
					return 30;
				case IconButton.WARN:
					return 10;
				default:
					return 1;
			}
		}
		public function setTool(t:Bitmap,toolT:String):void
		{
			toolType = toolT;
			var s:int = 20;
			toolIcon.bitmapData = t.bitmapData;
			toolIcon.scaleX = toolIcon.scaleY = Math.min(s / t.bitmapData.width, s / t.bitmapData.height);
		}
		/*public function updatePreview(b:Bitmap):void
		{
			preview.bitmapData = b.bitmapData;
			//fit it in the button
			preview.scaleX = preview.scaleY = Math.min(w / b.bitmapData.width, h / b.bitmapData.height);
		}*/
		public function getBmpData():BitmapData
		{
			return layerbmp.bitmapData;
		}
		public function setBmpData(bmpData:BitmapData):void
		{
			layerbmp.bitmapData = bmpData;
			preview.bitmapData = bmpData;
			preview.scaleX = preview.scaleY = Math.min(w / bmpData.width, h / bmpData.height);
			preview.x = (w-preview.width)/2
			preview.y = (h-preview.height)/2
		}
		public function setAlpha1(v:Number):void
		{
			alpha1 = v;
			if (Layerpicker.activelayer == this)
				layerbmp.parent.alpha = alpha1;
			//{
				//this.layerbmp.alpha = alpha1;
				//Canvas.singleton.buffer.alpha = alpha1;
			//}
		}
		public function setAlpha2(v:Number):void
		{
			alpha2 = v;
			if (Layerpicker.activelayer != this)
				layerbmp.parent.alpha = alpha2;
				//this.layerbmp.alpha = alpha2;
		}
		public override function select():void
		{
			layerbmp.parent.alpha = alpha1;
			//layerbmp.alpha = alpha1;
			slider1.visible = true;
			//slider2.visible = false;
			super.select();
		}
		public override function deselect():void
		{
			layerbmp.parent.alpha = alpha2;
			//layerbmp.alpha = alpha2;
			slider1.visible = false;
			//slider2.visible = true;
			super.deselect();
		}
	}

}