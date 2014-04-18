package airdraw.GUI 
{
	import airdraw.Main;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Frame extends Sprite
	{
		[Embed(source="../../assets/icons/Xion.png")]
		public var XIcon:Class;

		private var label:DisplayText;
		public function Frame(x1:int, y1:int, w:int, h:int, labeltext:String, optional:Boolean = true) 
		{
			//alpha
			var a:Number = 0.7;
			
			if (optional)
			{
				//corner X icon
				var size:int = 25;
				var icon:Bitmap = new XIcon();
				icon.scaleX = icon.scaleY = size / 128;
				icon.x = w - size;
				addChild(icon);
			}

			//top thing
			graphics.beginFill(0x393939, a);
			graphics.drawRect(0, 0, w, 25);
			graphics.endFill();

			//
			label = new DisplayText(1,2,labeltext,0xAAAAAA,16,w,"CENTER");
			addChild(label)
			
			x = x1;
			y = y1;
			//main area
			graphics.beginFill(0x4A4A4A,a);
			graphics.drawRect(0,25,w,h-25)
			graphics.endFill();

			//outline
			graphics.lineStyle(1, 0x666666);
			graphics.drawRect(0,0,w,h)

			//content 
			//graphics.lineStyle(1, 0xAAAAAA);
			//drawable area (content)
			
			
			this.filters = [new DropShadowFilter(10, 45, 0x000000, 0.3, 10, 10)];
			
			addEventListener(MouseEvent.MOUSE_DOWN, onClick);
		}
		private function onClick(e:MouseEvent):void
		{
			//move the actual window (proof of concept)
			//this.stage.nativeWindow.startMove();
			if (mouseY < 25)
			{
				this.startDrag();
				stage.addEventListener(MouseEvent.MOUSE_UP, onRelease);
			}
			//move to front
			var par:DisplayObjectContainer = this.parent;
			par.removeChild(this);
			par.addChild(this);
		}
		
		private function onRelease(e:MouseEvent):void
		{
			this.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onRelease);
		}
		public function setCaption(s:String):void
		{
			label.setText(s);
		}
	}

}