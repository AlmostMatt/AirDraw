package airdraw.Canvas 
{
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class AddLayer extends Undoable
	{
		//one implementation would be to create layer, remove the layer, and then undo the remove, pop the remove from the undolist, and use the remove's do and undo functions for this onee's undo and do
		//alternatively make a new layer every time
		//and undo only has to worry about deleting an empty topMost layer, no index variation
		public function AddLayer() 
		{
			
			super();
		}
		public override function Do():void
		{
			
		}
		public override function Undo():void
		{
			
		}
	}

}