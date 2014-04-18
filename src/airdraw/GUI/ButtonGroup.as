package airdraw.GUI 
{
	import airdraw.Main;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class ButtonGroup extends Sprite
	{
		private var buttons:Array = new Array();
		private var index:uint = 0;
		private var values:Array = new Array();

		//potential group names/types
		public static const LAYERS:String = "LAYERS";
		public static const TOOLS:String = "TOOLS";
		public static const COLORS:String = "COLORS";
		public var type:String;
		
		public function ButtonGroup(groupName:String)//w,h,vertical or horizontal 
		{	
			type = groupName;
		}
		public function add(b:Button,v:Object=null):Button
		{
			b.group = this;
			buttons.push(b);
			values.push(v);
			addChild(b);
			return b;
		}
		//removes the corresponding button from the list
		//returns a boolean of whether or not it was selected
		public function remove(i:int):Boolean
		{
			var wasselected:Boolean = false;
			//ideally remove values and buttons[i]
			buttons.splice(i, 1);
			values.splice(i, 1);
			if (index == i)
			{
				//select next button, or previous if this was the last button
				select(Math.max(0, i - 1));
				wasselected = true;
			}
			else if (index > i)
				index--; //fix the index
			//removeChild(b);
			return wasselected;
		}
		//meant to "undo" a remove
		//allows reinsertion
		public function addAt(b:Button,v:Object=null,i:int=0,isselected:Boolean=false):Button
		{
			b.group = this;
			buttons.splice(i, 0, b);
			values.splice(i, 0, v);
			if (isselected)
				select(i);
			else if (index >= i)
				index++;
			//addChild(b);
			return b;
		}
		//reorders the items in the list
		public function swap(i1:int, i2:int):void
		{
			if (i1 > i2)
				swap(i2, i1);
			else {
				if (index == i2) index = i1;
				if (index == i1) index = i2;
				//i1 < i2, and in fact i2 = i1 + 1
				var removed:Array = buttons.splice(i2, 1);
				buttons.splice(i1, 0, removed[0]);
				
				removed = values.splice(i2, 1);
				values.splice(i1, 0, removed[0]);
			}
		}
		public function select(i:uint):void
		{
			index = i;
			buttons[i].select();
		}
		public function onSelect(selected:Button):void
		{
			//buttonGroup.onselect(this);
			//for (var i:int = 0; i < buttons.length; i++)
			var i:uint = 0;
			for each (var b:Button in buttons)
			{
				if (b != selected)
					b.deselect();
				else
					index = i;
				i++;
			}
			//do something with selected button
			//stage.dispatch to make it global I think
			dispatchEvent(new ButtonGroupEvent(this,buttons[index]));
		}
		public function getValue(i:int = -1):*
		{
			if (i == -1)
				return values[index];
			else
				return values[i];
		}
		public function getButton(i:int = -1):Button
		{
			if (i == -1)
				return buttons[index];
			else
				return buttons[i];
		}
	}

}