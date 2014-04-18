package airdraw.GUI 
{
	import flash.events.Event;
	/**
	 * when a button is selected within a button group it will fire this event
	 * event has properties:
		 * button value
		 * group name
	 * @author Matthew Hyndman
	 */
	public class ButtonGroupEvent extends Event
	{
		public static const ON_SELECT:String = "onSelect";
		
		public var group:String;
		public var value:*;
		public var button:Button;
		//, bubbles:Boolean = false, cancelable:Boolean = false
		public function ButtonGroupEvent(bgroup:ButtonGroup,b:Button):void 
		{
			group = bgroup.type;
			value = bgroup.getValue();
			button = b;
			super(ON_SELECT);//, bubbles, cancelable
		}
		
	}

}