package airdraw.Utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class CustomCursor
	{
		private static var cursor:Sprite;
		private static var stage:Stage;

		public static function init(stg:Stage):void
		{
            stage = stg;
			//child.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            //child.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

            //stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveHandler);
		}
		public static function setCursor(obj:Sprite):void
		{
			if (cursor != null)
			{	
				//cursor.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
				stage.removeChild(cursor);
			}
			cursor = obj;
			cursor.mouseEnabled = false;
            //cursor.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addChild(cursor);
            cursor.x = stage.mouseX; // event.localX;
            cursor.y = stage.mouseY; // localY;
			//Mouse.hide();
		}
		
		
        private static function mouseMoveHandler(event:MouseEvent):void {
        //    trace("mouseMoveHandler");
            cursor.x = event.stageX; // event.localX;
            cursor.y = event.stageY; // localY;
            event.updateAfterEvent();
        //    cursor.visible = true;
        }
	}

}