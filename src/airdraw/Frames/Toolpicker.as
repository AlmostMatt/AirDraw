package airdraw.Frames 
{
	import airdraw.GUI.Button;
	import airdraw.GUI.ButtonGroup;
	import airdraw.GUI.ButtonGroupEvent;
	import airdraw.GUI.Frame;
	import airdraw.GUI.IconButton;
	import airdraw.Utils.CustomCursor;
	import flash.desktop.Icon;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import airdraw.GUI.DisplayText;
	import airdraw.GUI.Frame;
	
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Toolpicker extends Frame 
	{
		public static var activetool:Tool;
		private var tools:Dictionary = new Dictionary();
		public static var singleton:Toolpicker;
		
		public function Toolpicker(x1:int,y1:int,w1:int = 64,h1:int = 180)
		{
			singleton = this;
			super(x1, y1, w1, h1, "Tools",false);
			
			var toolGroup:ButtonGroup = new ButtonGroup(ButtonGroup.TOOLS);
			addChild(toolGroup);
			
			//, IconButton.WARN
			var icons:Array = [IconButton.PENCIL, IconButton.PEN, IconButton.BRUSH1, IconButton.BRUSH2, IconButton.COLORPICK,IconButton.SELECT];/*, 
				IconButton.ZOOM, IconButton.DELETE, IconButton.SELECT1, IconButton.SELECT2,
				IconButton.RIBBON1,IconButton.RIBBON2,IconButton.WARN];*/
			
			for (var i:int = 0; i < icons.length; i++) {
				var x:int = i % 2;
				var y:int = i / 2;
				var size:int = 32;
				//add these buttons to a "group"
				var toolname:String = icons[i % icons.length];
				var t:Tool = new Tool(size * x, 25 + size * y, toolname);
				tools[toolname] = t;
				activetool = t;
				toolGroup.add(t, i);	//b.value is icon			 				
			}
			toolGroup.select(0);
			toolGroup.addEventListener(ButtonGroupEvent.ON_SELECT, pickTool);

		}
		private function pickTool(e:ButtonGroupEvent):void
		{
			//e.value is the index
			//e.button is a Tool object
			activetool= (e.button as Tool);
			//Canvas.singleton.setLayer(e.value);
			//Canvas.singleton.setBrush(e.value);
			Layerpicker.activelayer.setTool(activetool.icon, activetool.toolname);
			
			
			var sp:Sprite = new Sprite();
			/*
			var icon:Bitmap = IconButton.getIcon(activetool.toolname);
			icon.scaleX = icon.scaleY = 32 / 128;
			//offset the icon to a different corner or point depending on the tool
			switch (activetool.toolname)
			{
				case IconButton.PENCIL:
					icon.x = -28;
					icon.y = -28;
					break;
				case IconButton.BRUSH1:
					icon.x = -28;
					icon.y = -28;
					break;
				case IconButton.BRUSH2:
					icon.x = -16;
					icon.y = -28;
					break;
				case IconButton.FEATHER:
					icon.x = -30;
					icon.y = -30;
					break;
				case IconButton.WARN:
					icon.x = -16;
					icon.y = -30;
					break;
				case IconButton.COLORPICK:
					icon.x = -16;
					break;
				case IconButton.SELECT:
					icon.x = -20;
					icon.y = -22;
					break;
				default:
					break;
			}
			sp.addChild(icon);
			*/
			sp.graphics.lineStyle(1, 0);
			sp.graphics.drawCircle(0, 0, Math.max(2,Layerpicker.activelayer.getBrush()/2));
			CustomCursor.setCursor(sp);
		}
		public function setTool(toolName:String):void
		{
			//get the corresponding tool button
			tools[toolName].select();
		}
	}

}