package airdraw.GUI 
{
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class ColorButton extends Button
	{
		private var color:uint;
		public function ColorButton(x1:int,y1:int,w1:int,h1:int,color1:uint,callback:Function=null) 
		{
			this.color = color1;
			super(x1, y1, w1, h1,callback,color1);
		}
		
		//override draw and override setstate to avoid redundant draw
		
		public function setColor(col:uint):void
		{
			this.color = col;
			this.value = col;
			draw();
		}
		
		protected override function draw():void
		{
			/*
			switch (state) {
				case Button.NORMAL:
					graphics.beginFill(Button.NORMALCOLOR);
					break;
				case Button.ACTIVE:
					graphics.beginFill(Button.ACTIVECOLOR);
					break;
				case Button.HOVER:
					graphics.beginFill(Button.HOVERCOLOR);
					break;
			}*/
			
			graphics.beginFill(color);
			graphics.drawRect(0,0,w,h)
			graphics.endFill();

			//outline
			if (state == Button.ACTIVE)
			{
				graphics.lineStyle(2, 0xffff00);
				graphics.drawRect( -1, -1, w + 2, h + 2)
			} else if (state == Button.HOVER) {
				graphics.lineStyle(1, 0xffffff);
				graphics.drawRect(0, 0, w, h)			
				//graphics.drawRect( -1, -1, w + 2, h + 2)
			} else {
				graphics.lineStyle(1, Button.LINECOLOR);
				graphics.drawRect(0, 0, w, h)				
			}
		}
	}

}