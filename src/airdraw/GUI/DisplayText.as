package airdraw.GUI
{
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class DisplayText extends TextField 
	{
		/*[Embed(source = '../assets/PapposBlues.ttf',
				fontName = "PapposBlues",
				//mimeType = "application/x-font-truetype",
				embedAsCFF = "false")]
		private var PapposBlues:Class;
		*/
		
		public function DisplayText(posx:Number, posy:Number, defaulttext:String, color:uint =0x000000, size:Number=16,linewidth:Number = 0,align:String = "LEFT",font:String="Century Gothic",cancopy:Boolean = false):void//basically just a bunch of predefined settings.
		{
			//linewidth = 640 normally
			if (linewidth == 0) {
				switch (align)
				{
				case "CENTER": this.autoSize = TextFieldAutoSize.CENTER; break;
				case "RIGHT": this.autoSize = TextFieldAutoSize.RIGHT; break;
				default: this.autoSize = TextFieldAutoSize.LEFT;
				}
			} else {
				this.width = linewidth;
				this.wordWrap = true;
				//this.width = x2 - x1;
				//this.height = size * 1.5;
			}
			this.x = posx;
			this.y = posy-3;
			
			var tf:TextFormat = new TextFormat(font, size,color);
			if (font != "Century Gothic")
				this.embedFonts = true;
			
			switch (align)
			{
			case "CENTER": tf.align = TextFormatAlign.CENTER; break;
			case "RIGHT": tf.align = TextFormatAlign.RIGHT; break;
			default: tf.align = TextFormatAlign.LEFT;
			}
			this.text = defaulttext;
			this.type = TextFieldType.DYNAMIC;
			//this.selectable = false;
			this.selectable = cancopy;
			this.setTextFormat(tf);
			
			this.filters = [new DropShadowFilter(2,45,0x000000,0.6,4,4)];
		}
		public function setText(t:String):void
		{
			var tf:TextFormat = this.getTextFormat();
			this.text = t;
			this.setTextFormat(tf);
		}
	}
	
}