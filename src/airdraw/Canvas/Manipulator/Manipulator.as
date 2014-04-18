package airdraw.Canvas.Manipulator 
{
	import airdraw.Utils.Utils;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * pan / rotate / zoom / scale tool for canvas / selection
	 * @author Matthew Hyndman
	 */
	public class Manipulator extends Sprite
	{
		
		private var rect1:Sprite;
		private var rect2:Sprite;
		private var rect3:Sprite;
		private var rect4:Sprite;
		private var pan:Sprite;
		private var rot:Sprite;
		
		//angle used in rotate drag
		private var angle:Number;
		//point used in diagonal line drag
		private var initPoint:Point;
		//slope of diagonal line along which dragging
		private var slope:Number;
		private var verticalSlope:Boolean;
		//used to detect change in mouse position
		private var prevMouse:Point;
		
		
		private var selector:Selection;
		public function Manipulator(selection:Selection, angle:Number=0 ) 
		{
			selector = selection;
			//directional pan (1 per axis of symmetry / coordinate axis?)
			pan = new Sprite();
			rot = new Sprite();
			
			//size of the pan tools
			var w:int = 22;
			var l:int = 30;
			var panradius:int = 30;
			
			//rot Tool
			pan.graphics.beginFill(0xff8844);
			pan.graphics.lineStyle(2, 0);
			Utils.drawArc(pan.graphics, w/2, 0, panradius, -Math.PI / 2, Math.PI, false);
			pan.graphics.lineTo( 0, panradius);
			pan.graphics.lineTo( 0, -panradius);
			pan.graphics.lineTo( w/2, -panradius);
			//pan.graphics.drawRect(0,-36,w/2,72);
			pan.graphics.endFill();
			pan.rotation = angle * 180 / Math.PI;
			//Utils.fillArcs(pan.graphics, 0, 0, 20, 36, angle, Math.PI, Math.PI*1.2);
			//rot.graphics.drawCircle(0, 0, 36);
			//graphics.drawCircle(0, 0, 20);
			//rot.graphics.endFill();
			
			rect1 = new Sprite();
			rect2 = new Sprite();
			rect3 = new Sprite();
			rect4 = new Sprite();
			var i:int = 0;
			rect1.graphics.beginFill(0xcc4444);//horizontal
			rect2.graphics.beginFill(0x8888cc);
			rect3.graphics.beginFill(0x5ac45a);//vertical
			rect4.graphics.beginFill(0x8888cc);
			for each (var rect:Sprite in [rect1, rect2, rect3, rect4])
			{
				//rotate the rectangles with respect to the "center of the arc"
				rect.x = Math.cos(angle) * w / 2;
				rect.y = Math.sin(angle) * w / 2;
				//
				rect.graphics.lineStyle(2, 0);
				rect.graphics.drawRect(panradius - 10, -w/2, l, w);
				rect.rotation = 45 * i;
				var anglediff:Number = Math.abs(Utils.angleDiff(rect.rotation, angle * 180 / Math.PI));
				if (anglediff == 90)
					//draw the rectangle twice
					rect.graphics.drawRect(10 - panradius, -w/2, -l, w);
				if (anglediff > 90)
					rect.rotation = rect.rotation + 180;
				i++;
				rect.graphics.endFill();
			}
			
			
			//centre circle
			//pan.graphics.beginFill(0xffdd88);
			//pan.graphics.lineStyle(2, 0);
			//pan.graphics.drawCircle(0, 0, 20);
			//pan.graphics.endFill();

			addChild(rect1);
			addChild(rect2);
			addChild(rect3);
			addChild(rect4);
			addChild(pan);
			//addChild(rot);
			
			selector.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
		}
		
		//handles click event on the objects to begin some sort of mouseDrag
		private function onClick(e:MouseEvent):void
		{
			//e.target.alpha = 0.3;
			switch (e.target)
			{
				case rect1:
					//0 degrees - horizontal
					selector.toBuffer();
					startDiagonalDrag(0);
					break;
				case rect2:
					//45 degrees (y = x)
					selector.toBuffer();
					startDiagonalDrag(1);
					break;
				case rect3:
					//90 degrees - vertical
					selector.toBuffer();
					startDiagonalDrag(0, true);
					break;
				case rect4:
					//135 degrees (y = -x)
					selector.toBuffer();
					startDiagonalDrag(-1);
					break;
				case pan:
					selector.toBuffer();
					selector.startDrag(false, new Rectangle( 0, 0, stage.width, stage.height));
					break;
				case selector.rot:
					if (this == selector.manip1) //two manip objects but only 1 rot
						selector.toBuffer();
						startRotate();
					break
			}
			stage.addEventListener(MouseEvent.MOUSE_UP,onRelease);
		}
		
		//slope of 1 for 45 degree -1 for 135 degree
		//constrains the object to a line during a mousedrag
		private function startDiagonalDrag(lineSlope:Number,isVertical:Boolean=false):void
		{
			slope = lineSlope;
			verticalSlope = isVertical;
			//either compare to 
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onDiagonalDrag);
			initPoint = new Point(selector.x, selector.y);
			prevMouse = new Point(mouseX, mouseY);
		}
		
		private function startRotate():void
		{
			//begin rotation
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onRotate);
			angle = Math.atan2(selector.mouseY,selector.mouseX);
		}
		private function onRotate(e:MouseEvent):void
		{
			var a:Number = Math.atan2(selector.mouseY, selector.mouseX);
			selector.selectArea.rotation += (a - angle) * 180 / Math.PI;
			angle = a;
		}
		private function onDiagonalDrag(e:MouseEvent):void
		{
			if (verticalSlope)
			{
				//change y only
				selector.y += mouseY - prevMouse.y;
			} else if (slope > 1) {	
				//use mouseY as estimate
				selector.y += mouseY - prevMouse.y;
				selector.x = (1/slope) * (selector.y - initPoint.y) + initPoint.x;
			} else {	
				//use mouseX as estimate
				selector.x += mouseX - prevMouse.x;
				selector.y = slope * (selector.x - initPoint.x) + initPoint.y;
			}
			prevMouse = new Point(mouseX, mouseY);
		}
		private function onRelease(e:MouseEvent):void
		{
			//this.stopDrag();
			selector.stopDrag();
			this.stopRotate();
			this.stopDiagonalDrag();
			//
			selector.fromBuffer();
			stage.removeEventListener(MouseEvent.MOUSE_UP,onRelease);
		}
		private function stopRotate():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onRotate);
		}
		private function stopDiagonalDrag():void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDiagonalDrag);
		}
		//repositions the manipulator object
		public function moveTo(p:Point):void
		{
			x = p.x;
			y = p.y;
		}
	}

}