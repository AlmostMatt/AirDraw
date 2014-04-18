package airdraw.GUI
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Slider extends Sprite
	{
		//NotE: slider setvalue is not calling function when it is created due to specific instance bug, possibly move setvalue to init and enable reactBoolean
		private var isVertical:Boolean;
		private var valuemin:int;
		private var valuerange:int;
		private var value:Number = -1; //0 to 1 for leftmost or lowermost to rightmost or uppermost
		
		private var selector:Sprite;
		private var callback:Function;

		private var w:int;
		private var h:int;
		
		private static const fillcolor:uint = 0x333333;
		private static const emptycolor:uint = 0x666666;
		private static const linecolor:uint = 0xAAAAAA;
		private static const selectorcolor:uint = 0x222222;
		
		public function Slider(sx:int, sy:int, sw:int = 10, sh:int = 50, action:Function = null, initvalue:Number=0.5):void 
		{
			x = sx;
			y = sy;
			this.w = sw;
			this.h = sh;
			
			callback = action;
			
			isVertical = h > w;
			//
			valuemin = isVertical ? w/2 : h/2;
			valuerange = Math.abs(h - w);
			//selector
			selector = new Sprite();
			selector.graphics.beginFill(selectorcolor);
			selector.graphics.lineStyle(1, linecolor);
			var s:int = 1 + (Math.min(w, h) / 2);
			//selector.graphics.drawRoundRect(-s,-s,2*s,2*s,s,s)
			selector.graphics.drawCircle(0, 0, Math.min(w,h) / 2 + 1);
			selector.graphics.endFill();
			addChild(selector);
			//selector
			if (isVertical) {
				selector.x = w / 2;
			} else {
				selector.y = h / 2;
			}
 			//
			setValue(initvalue,false);
			//
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event=null):void {
			//selector.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown)  
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			//if (Config.debugMode)
			//else
			//	setValue(Config.initialVolume);
		}
		
		private function mouseDown(event:MouseEvent):void 
		{ 
			var bounds:Rectangle = (isVertical) ? new Rectangle(w / 2, w / 2, 0, h - w) : new Rectangle(h / 2, h / 2, w - h, 0);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, dragging);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseReleased); 
			selector.startDrag(true, bounds); 
			dragging(); //call it once to handle the case where a click moves the selector but the mouse does not move
		} 
		 
		private function mouseReleased(event:MouseEvent):void 
		{ 
			dragging(); //call it once to handle the case where an instant click moves the selector but no frames pass
			selector.stopDrag(); 
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dragging);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseReleased); 
		}
		
		private function dragging(event:Event = null):void {
			var oldvalue:Number = value;
			value = (isVertical ? h - 1 -  valuemin - selector.y : selector.x - valuemin) / valuerange ; // the -1 is a fix for dumb rounding
			if (callback != null && value != oldvalue) 
				callback(value);
			draw();
		}
		
		private function draw():void {
			graphics.clear();
			if (isVertical) {
				graphics.lineStyle(1,linecolor)
				//bkg
				graphics.beginFill(emptycolor);
				graphics.drawRoundRect(0,0,w,h,w/2,w/2)
				graphics.endFill();
				//filled part
				graphics.beginFill(fillcolor)
				graphics.drawRoundRect(0, h-(valuemin+valuerange*value), w, (valuemin+valuerange*value), w / 2, w / 2)
				graphics.endFill();
			} else {
				graphics.lineStyle(1, linecolor)
				//bkg
				graphics.beginFill(emptycolor);
				graphics.drawRoundRect(0,0,w,h,h/2,h/2)
				graphics.endFill();
				//filled part
				graphics.beginFill(fillcolor)
				graphics.drawRoundRect(0,0,valuemin + valuerange*value,h,h/2,h/2)
				graphics.endFill();
			}
		}
		
		public function setValue(v:Number,react:Boolean=true):void {
			if (v != value) {
				value = v;
				//set selector position and apply callback
				if (isVertical) {
					selector.y = h - (valuemin + valuerange * value);
				} else {
					selector.x = valuemin + valuerange * value;
				}
				if (react)
					callback(v);
				draw();
			}
		}
	}
	
}