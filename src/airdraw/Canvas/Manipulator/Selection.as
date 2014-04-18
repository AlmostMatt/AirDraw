package airdraw.Canvas.Manipulator 
{
	import airdraw.Canvas.Canvas;
	import airdraw.Frames.Layerpicker;
	import airdraw.Utils.Utils;
	import airdraw.Utils.V;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Selection extends Sprite
	{
		//private var center:
		private var radius:Number;
		private var point1:Point;
		private var point2:Point;
		
		public var manip1:Manipulator;
		public var manip2:Manipulator;
		//select area visible for user to see
		public var selectArea:Sprite;
		//selectMask masks the selectionbuffer and is not rendered
		public var selectMask:Sprite;
		//selectEraser has max alpha and is used to erase the selectArea from the activelayer once it has been copied to the selectionBuffer
		public var selectEraser:Sprite;
		//due to bug with transformed bmp and transformed mask and bitmapdata.draw I need the bmp and mask to have a common parent other than selectArea
		private var bmpHolder:Sprite;
		
		private var hasBuffer:Boolean = false;
		
		//private var manipAngle:Number = Math.PI * 7 / 8;
		private var manipAngle:Number = Math.PI * 3/4;
		
		public var rot:Sprite;
		
		public function Selection()
		{
			addChild(selectArea = new Sprite());
			selectArea.addChild(bmpHolder = new Sprite());
			selectMask = new Sprite();
			selectEraser = new Sprite();
//addChild(selectMask);
			addChild(manip1 = new Manipulator(this,manipAngle));
			addChild(manip2 = new Manipulator(this, manipAngle - Math.PI));
			addChild(rot = new Sprite());
			rot.visible = manip1.visible = manip2.visible = false;			
		}
		public function startSelect(p:Point):void
		{
			graphics.clear();
			selectArea.graphics.clear();
			selectMask.graphics.clear();
			selectEraser.graphics.clear();
			selectArea.rotation = 0;
			point1 = point2 = p;
			rot.visible = manip1.visible = manip2.visible = false;
		}
		public function endSelect(p:Point):void
		{	
			if (p.x == point1.x || p.y == point1.y)
				return
			setPoint2(p);
			var cosa:Number = Math.cos(manipAngle);
			var sina:Number = Math.sin(manipAngle);
			manip1.moveTo(new Point(cosa * radius, sina * radius));
			manip2.moveTo(new Point(-cosa * radius, -sina * radius));
			rot.visible = manip1.visible = manip2.visible = true;
			
			//redraw rotTool
			rot.graphics.clear();
			var rotCurveSize:Number = Math.PI / 4;
			var rotWidth:Number = 25;
			rot.graphics.beginFill(0xff8844);
			rot.graphics.lineStyle(2, 0);
			Utils.fillArcs(rot.graphics, 0, 0, radius, radius + rotWidth, manipAngle + Math.PI / 2, rotCurveSize, rotCurveSize);
			Utils.fillArcs(rot.graphics, 0, 0, radius, radius + rotWidth, manipAngle - Math.PI / 2, rotCurveSize, rotCurveSize);
			rot.graphics.endFill();
		}
		public function setPoint2(p:Point):void
		{
			graphics.clear();
			selectArea.graphics.clear();
			selectMask.graphics.clear();
			selectEraser.graphics.clear();
			point2 = p;
			var c:Point = V.avg(point1, point2);
			radius = V.dist(c, point1);
			x = c.x;
			y = c.y;
			graphics.lineStyle(1, 0);
			graphics.drawCircle(0, 0, radius);
			
			//draw the selection area transparent with outline
			selectArea.graphics.lineStyle(1, 0);
			selectArea.graphics.beginFill(0x000088, 0.1);
			selectArea.graphics.drawRect(point1.x-x, point1.y-y, point2.x - point1.x, point2.y - point1.y);
			selectArea.graphics.endFill();
			
			//draw the selection mask full opacity and no outline (and snap to bmpdata)
			selectMask.graphics.beginFill(0x000000);
			selectMask.graphics.drawRect(point1.x-x+radius, point1.y-y+radius, point2.x - point1.x, point2.y - point1.y);
			selectMask.graphics.endFill();			
			selectEraser.graphics.beginFill(0x000000);
			selectEraser.graphics.drawRect(point1.x-x, point1.y-y, point2.x - point1.x, point2.y - point1.y);
			selectEraser.graphics.endFill();			
		}
		//copies active layer to the selection buffer
		public function toBuffer():void
		{
			//this is a child of canvas
			var selectBmp:Bitmap = Canvas.singleton.selectionBuffer;
			//clear it
			selectBmp.bitmapData.fillRect(selectBmp.bitmapData.rect, 0);
			//matrix of selectBmp with respect to canvas
			bmpHolder.x = bmpHolder.y = -radius;
			var matrix:Matrix = bmpHolder.transform.matrix.clone(); //matrix representing the selectBmp
			var matrix2:Matrix = selectArea.transform.matrix.clone(); // matrix representing the eraser
			matrix2.concat(transform.matrix);
			matrix.concat(matrix2);
			matrix.invert();
			
			selectBmp.smoothing = true;
			selectBmp.bitmapData.drawWithQuality(Layerpicker.activelayer.layerbmp,matrix,null,null,null,true,StageQuality.BEST);
			//matrix = selectArea.transform.matrix.clone();
			//erase the selection area from the canvas
			Layerpicker.activelayer.layerbmp.bitmapData.draw(selectEraser, matrix2, null, BlendMode.ERASE);
			//then mask the new selection
			bmpHolder.addChild(selectMask);
			selectBmp.mask = selectMask;
			//and add the bmp as a child of the selection
			bmpHolder.addChild(selectBmp);
			hasBuffer = true;
		}
		//copies selection buffer to the activelayer
		public function fromBuffer():void
		{
			if (hasBuffer)
			{
				hasBuffer = false;
				var selectBmp:Bitmap = Canvas.singleton.selectionBuffer;
				//Canvas.singleton.selector.selectArea.transform.matrix
				var matrix:Matrix = bmpHolder.transform.matrix.clone();
				matrix.concat(selectArea.transform.matrix);
				matrix.concat(transform.matrix);
				//it's being drawn in the right spot but the mask has a different parent so it is masked incorrectly
				//(it assumes the mask and bmp have the same transform);
				//maybe draw to a highRes unrotated Bmp to "smooth" it
				
				/*
				var mult:Number = 8;
				var tmp:BitmapData = new BitmapData(Canvas.singleton.w * mult, Canvas.singleton.h * mult, true, 0);
				//var tmp:BitmapData = new BitmapData(2 * radius * mult, 2 * radius * mult, true, 0);
				
				var newmatrix:Matrix = new Matrix();
				newmatrix.concat(matrix);
				newmatrix.scale(mult, mult);
				tmp.draw(bmpHolder, newmatrix,null,null,null,true);
				Layerpicker.activelayer.layerbmp.bitmapData.draw(new Bitmap(tmp),new Matrix(1/mult,0,0,1/mult),null,null,null,true);
				*/
				
				Layerpicker.activelayer.layerbmp.bitmapData.drawWithQuality(bmpHolder,matrix,null,null,null,false,StageQuality.BEST);
				selectBmp.mask = null;
				bmpHolder.removeChild(selectBmp);
				bmpHolder.removeChild(selectMask);
			}
		}
	}

}