package airdraw.Canvas 
{
	/**
	 * This probably should be done with an interface but I like calling this constructor with super()
	 * Maybe I will add pseudoconstructors to undolist class that will create and add to list
	 * and this can truely be an interface then
	 * calling new Draw() is weird
	 * Undolist.draw() looks much nicer
	 * 
	 * an action that can be undone, base class.
	 * contains virtual functions to do and undo an action.
	 * @author Matthew Hyndman
	 */
	public class Undoable 
	{
		public function Undoable() 
		{
			UndoList.append(this);
		}
		public function Do():void
		{
		}
		public function Undo():void
		{
		}
	}

}