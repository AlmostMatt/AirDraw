package airdraw.Canvas 
{
	import airdraw.Main;
	import flash.automation.ActionGenerator;
	import flash.events.Event;
	/**
	 * manages a set of undoable actions,
	 * new actions are done immediately and can be undone and undone actions can be redone
	 * @author Matthew Hyndman
	 */
	public class UndoList
	{
		//doing or redoing enables undo
		//undoing enables redo
		//too many undos or redoes disables them
		//doing disables redo
		private static var actions:Array = new Array();
		private static var undone:Array = new Array();
		
		private static const MAXLENGTH:int = 30;
		
		//singleton list of undoable actions
		public function UndoList() 
		{
			
		}
		public static function append(action:Undoable):void
		{
			action.Do();
			actions.push(action);
			if (actions.length == 1)
				Main.editMenu.getItemByName("Undo").enabled = true;
			Main.editMenu.getItemByName("Redo").enabled = false;
			undone = new Array();
			//a max length
			if (actions.length > MAXLENGTH)
				actions.splice(0, actions.length-MAXLENGTH);
		}
		public static function Undo(e:Event = null):void
		{
			if (actions.length > 0)
			{
				var a:Undoable = actions.pop();
				a.Undo();
				undone.push(a);
				Main.editMenu.getItemByName("Redo").enabled = true;
			}
			if (actions.length == 0)
				Main.editMenu.getItemByName("Undo").enabled = false;;
		}
		public static function Redo(e:Event = null):void
		{
			if (undone.length > 0)
			{
				var a:Undoable = undone.pop();
				a.Do();
				actions.push(a);
				if (actions.length == 1)
					Main.editMenu.getItemByName("Undo").enabled = true;
				if (undone.length == 0)
					Main.editMenu.getItemByName("Redo").enabled = false;
			}
		}
		
	}

}