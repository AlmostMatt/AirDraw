package airdraw.GUI 
{
	import airdraw.Frames.Tool;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * a button that hovers and, if part of a buttongroup, remains active once it has been clicked
	 *  and deselectes all of the other buttons when it is selected
	 * otherwise it can toggle or it can perform some immediate but not persistent action
	 * @author Matthew Hyndman
	 */
	public class Button extends Sprite
	{
		protected static const HOVER:uint = 0;
		protected static const NORMAL:uint = 1;
		protected static const ACTIVE:uint = 2;
		protected static const CLICKED:uint = 3;
		
		protected static const HOVERCOLOR:uint = 0x666666;
		protected static const NORMALCOLOR:uint = 0x404040;
		protected static const ACTIVECOLOR:uint = 0x323232;
		protected static const LINECOLOR:uint = 0x666666;
		protected static const ACTIVELINECOLOR:uint = 0xAAAAAA;
		//needs 3 states. selected, hover, default, and cannot "hover" on selected
		//colors		     22		  66	   4a
		
		protected var state:uint = Button.NORMAL;
		private var hovering:Boolean = false;
		private var clicking:Boolean = false;
		protected var w:int;
		protected var h:int;
		
		public var icon:Bitmap;
		
		public var group:ButtonGroup = null;
		
		protected var callback:Function;
		public var value:*;
		//and ideally an onclick
		public function Button(x1:int,y1:int,w1:int,h1:int,onclick:Function=null,v:*=null) 
		{
			x = x1;
			y = y1;
			w = w1;
			h = h1;
			
			callback = onclick;
			value = v;
			
			draw();
			addEventListener(MouseEvent.MOUSE_OVER, mouseOn);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOff);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseClick);
		}
		
		protected function draw():void
		{
			//main area
			switch (state) {
				case Button.NORMAL:
					graphics.beginFill(Button.NORMALCOLOR);
					break;
				case Button.HOVER:
					graphics.beginFill(Button.HOVERCOLOR);
					break;
				case Button.ACTIVE:
					graphics.beginFill(Button.ACTIVECOLOR);
					break;
				case Button.CLICKED:
					graphics.beginFill(Button.ACTIVECOLOR);
					break;
			}
			graphics.drawRect(0,0,w,h)
			graphics.endFill();

			//outline
			if (state == Button.ACTIVE)
				graphics.lineStyle(1, Button.ACTIVELINECOLOR);
			else
				graphics.lineStyle(1, Button.LINECOLOR);
			graphics.drawRect(0, 0, w, h)
		}
		private function setState(newstate:uint):void
		{
			if (newstate != state)
			{
				state = newstate
				graphics.clear();
				draw();
			}
		}
		
		//only count a click if the mouse is hoverign over the button for the click and for the release
		private function mouseRelease(e:MouseEvent):void
		{
			if (hovering) { //state changes to "normal" if mouse moves away
				select();
			}
			else
				setState(Button.NORMAL);
			clicking = false;
			if (stage)
				stage.removeEventListener(MouseEvent.MOUSE_UP, mouseRelease);
		}
		private function mouseClick(e:MouseEvent):void
		{
			clicking = true;
			setState(Button.CLICKED);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseRelease);
		}
		private function mouseOn(e:MouseEvent):void
		{
			hovering = true;
			if (clicking) //if mouse on, click, mouse off, mouse back on, release click, accept it as a valid mousepress
				setState(Button.CLICKED);
			else if (state != Button.ACTIVE)
				setState(Button.HOVER);
		}
		private function mouseOff(e:MouseEvent):void
		{
			hovering = false;
			if (state != Button.ACTIVE)
				setState(Button.NORMAL);
		}
		public function select():void
		{
			if (callback != null)
				callback(value);
			if (group) {
				setState(Button.ACTIVE);
				group.onSelect(this);
			} else
				setState(Button.HOVER);
		}
		public function deselect():void
		{
			//I can probably assume that hovering is false based on the fact that some other button was selected
			// but better not to assume because hotkeys might change this
			if (hovering)
				setState(Button.HOVER);
			else
				setState(Button.NORMAL);
		}
	}

}