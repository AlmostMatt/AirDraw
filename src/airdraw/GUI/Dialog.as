package airdraw.GUI 
{
	import flash.display.Stage;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Dialog extends Frame
	{
		private var buttonGrp:ButtonGroup;
		public function Dialog(stg:Stage,label:String="!!!",message:String="Ok.",buttons:Array=null /*of string*/,functions:Array=null /*of functions*/) 
		{
			if (buttons == null) {
				buttons = ["Ok"];
				functions = [function ():void { } ];
			}

			var w1:int = 200;
			var h1:int = 300; //*buttons.length
			super((stg.width - w1) / 2, (stg.height - h1) / 2, w1, h1, label,false);
			stg.addChild(this);
			
			addChild(new DisplayText(5, 40, message, 0xaaaaaa, 14, w1 - 10, "CENTER"));
			buttonGrp = new ButtonGroup(label);
			addChild(buttonGrp);
			//if buttons.length == 0 or ~0 functions.length: error
			//button autoSize and then self.autosize based on that
			for (var i:int = 0; i < buttons.length; i++)
			{
				//, w1 - 40, 25
				var tb:TextButton = new TextButton(buttons[i], 0, 140 + 32 * i);
				tb.x = (w1 - tb.width) / 2;
				buttonGrp.add(tb,functions[i]);
			}
			buttonGrp.addEventListener(ButtonGroupEvent.ON_SELECT, pickButton);
		}

		private function pickButton(e:ButtonGroupEvent):void
		{
			(e.value as Function)(); //value of the button is the function
			stage.removeChild(this);
		}
		
		//onSelect
		//dismiss()
		//function()
	}

}