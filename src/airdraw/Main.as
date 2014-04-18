package airdraw
{
	import airdraw.Canvas.Manipulator.Manipulator;
	import airdraw.Frames.Colorpalette;
	import airdraw.Frames.Layerpicker;
	import airdraw.Frames.Preview;
	import airdraw.Frames.Toolpicker;
	import airdraw.Canvas.UndoList;
	import airdraw.Frames.Colorpicker;
	import airdraw.GUI.Button;
	import airdraw.GUI.ButtonGroup;
	import airdraw.GUI.ColorButton;
	import airdraw.GUI.IconButton;
	import airdraw.GUI.Slider;
	import airdraw.GUI.ToggleButton;
	import airdraw.Utils.CustomCursor;
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.utils.getTimer;
	import airdraw.Canvas.Canvas;
	import airdraw.GUI.Frame;
	import airdraw.GUI.DisplayText;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class Main extends Sprite 
	{
		private var FPS:DisplayText = new DisplayText(100,10,"FPS: ?",0xAAAAAA,14,70);
		public var Info:DisplayText = new DisplayText(200,700- 40,"Size: ?",0xAAAAAA,14,200);
		private var totaltime:Number = 0;
		private var frame:uint = 0;
		private var interval:Number = 0;
		
		public static var canvas:Canvas;
		public static var editMenu:NativeMenu;
		public static var fileMenu:NativeMenu;
		public static var manipTool:Manipulator;
		
		public var file:File = null;
		
		public function Main():void 
		{
			
			CustomCursor.init(stage);
			/*var sp:Sprite = new Sprite();
			var icon:Bitmap = IconButton.getIcon(IconButton.COLORPICK);
			icon.scaleX = icon.scaleY = 32 / 128;
			icon.x = -16;
			sp.addChild(icon);
			sp.graphics.lineStyle(1, 0);
			sp.graphics.drawCircle(0, 0, 5);
			CustomCursor.setCursor(sp);
			*/
			//at 185,50
			//640 x 520, 630 x 520 - 35
			//var mainframe:Frame = new Frame(85, 20, 800, 600, "Drawable Canvas");
			var w:int = 860;
			var h:int = 620;
			canvas = new Canvas((stage.stageWidth - w)/2, (stage.stageHeight - h)/2, w,h);
			//canvas.frame = mainframe;
			//mainframe.addChild(canvas);
			addChild(canvas);
			
			//file menu
			fileMenu = new NativeMenu();
			var cmd:NativeMenuItem;
			cmd = new NativeMenuItem("New"); 
			cmd.keyEquivalent = "n"; 
			cmd.addEventListener(Event.SELECT, canvas.newCanvas);
			fileMenu.addItem(cmd);
			cmd = new NativeMenuItem("Open"); 
			cmd.keyEquivalent = "o"; 
			cmd.addEventListener(Event.SELECT, canvas.loadAdraw);
			fileMenu.addItem(cmd);
			cmd = new NativeMenuItem("Import PNG"); 
			//cmd.keyEquivalent = "S"; 
			cmd.addEventListener(Event.SELECT, canvas.importPng);
			fileMenu.addItem(cmd);
			cmd = new NativeMenuItem("Save"); 
			cmd.keyEquivalent = "s"; 
			cmd.addEventListener(Event.SELECT, canvas.saveAdraw);
			fileMenu.addItem(cmd);
			cmd = new NativeMenuItem("Save as"); 
			cmd.keyEquivalent = "S"; 
			cmd.addEventListener(Event.SELECT, canvas.saveAsAdraw);
			fileMenu.addItem(cmd);
			cmd = new NativeMenuItem("Export PNG"); 
			//cmd.keyEquivalent = "S"; 
			cmd.addEventListener(Event.SELECT, canvas.exportPng);
			fileMenu.addItem(cmd);
			//cmd.mnemonicIndex = 0; // index of letter to underline
			cmd = new NativeMenuItem("Quit"); 
			cmd.keyEquivalent = "q"; 
			cmd.addEventListener(Event.SELECT, NativeApplication.nativeApplication.exit);
			fileMenu.addItem(cmd);
			
			editMenu = new NativeMenu()
			cmd = new NativeMenuItem("Copy"); 
			cmd.name = "Copy";
			//cmd.enabled = false;
			cmd.keyEquivalent = "c"; 
			cmd.addEventListener(Event.SELECT, canvas.copy);
			editMenu.addItem(cmd);
			cmd = new NativeMenuItem("Paste"); 
			cmd.name = "Paste";
			//cmd.enabled = false;
			cmd.keyEquivalent = "v"; 
			cmd.addEventListener(Event.SELECT, canvas.paste);
			editMenu.addItem(cmd);
			cmd = new NativeMenuItem("Undo"); 
			cmd.name = "Undo";
			cmd.enabled = false;
			cmd.keyEquivalent = "z"; 
			cmd.addEventListener(Event.SELECT, UndoList.Undo);
			editMenu.addItem(cmd);
			cmd = new NativeMenuItem("Redo"); 
			cmd.name = "Redo";
			cmd.enabled = false;
			cmd.keyEquivalent = "y"; 
			cmd.addEventListener(Event.SELECT, UndoList.Redo);
			editMenu.addItem(cmd);
			//UndoList.Undo();
			
			var windowMenu:NativeMenu = new NativeMenu();
			windowMenu.addItem(new NativeMenuItem("Layers"));
			windowMenu.addItem(new NativeMenuItem("Preview"));
			windowMenu.addItem(new NativeMenuItem("Tools"));
			windowMenu.addItem(new NativeMenuItem("Color Selector"));
			windowMenu.addItem(new NativeMenuItem("Color Palette"));
			windowMenu.addItem(new NativeMenuItem("UndoableList"));
			windowMenu.addItem(new NativeMenuItem("Reflections"));
			
			//NativeWindow
			var rootMenu:NativeMenu = new NativeMenu();
			rootMenu.addSubmenu(fileMenu,"File");
			rootMenu.addSubmenu(editMenu,"Edit");
			rootMenu.addSubmenu(windowMenu,"Windows");
			// Assign application menu (Mac OS X) 
			if(NativeApplication.supportsMenu){ 
				var app:NativeApplication = NativeApplication.nativeApplication;
				app.menu = rootMenu; 
			}
			// Assign window menu (MS Windows) 
			if(NativeWindow.supportsMenu ){ 
				stage.nativeWindow.menu = rootMenu; 
			} 
			
			var tools:Frame = new Toolpicker(5, 10);
			var layers:Frame = new Layerpicker(stage.stageWidth - 155, 10);
			var prev:Preview = new Preview(stage.stageWidth - 155 - 5 - 128, 10);
			var colorpicker:Colorpicker = new Colorpicker(5, 375);
			var colorpalette:Colorpalette = new Colorpalette(stage.stageWidth - 185, 345);
			
			var s:int = 40;
			var symmetrypicker:Frame = new Frame(5, 245, 15+2*s, 45+2*s, "More", false);
			symmetrypicker.addChild(new ToggleButton(5, 30, IconButton.DRAW, IconButton.ERASE, s, Canvas.singleton.setErasing));
			symmetrypicker.addChild(new ToggleButton(5, 35+s, IconButton.ASYMH, IconButton.SYMH, s, Canvas.singleton.setReflectH));
			symmetrypicker.addChild(new ToggleButton(10+s, 35+s, IconButton.ASYMV, IconButton.SYMV, s, Canvas.singleton.setReflectV));
			symmetrypicker.addChild(new ToggleButton(10+s, 30, IconButton.NOTRADIAL, IconButton.RADIAL, s, Canvas.singleton.setRadial));
			Canvas.singleton.setRadial(false);
			//symmetrypicker.addChild(new IconButton(35, 30, IconButton.ASYMH, 25));
			//symmetrypicker.addChild(new IconButton(35, 60, IconButton.ASYMV, 25));
			
			
			//addChild(mainframe);
			addChild(prev);
			addChild(colorpicker);
			addChild(tools);
			addChild(layers);
			addChild(colorpalette);
			addChild(symmetrypicker);
			
			//manipTool = new Manipulator(600,300);
			//addChild(manipTool);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//trace(stage.scaleMode);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addChild(FPS);
			stage.addChild(Info);
			stage.addEventListener(Event.ENTER_FRAME, update);			
		}
		private function update(e:Event):void
		{
			var t:uint = getTimer();
			var dt:Number =  (t - totaltime) / 1000;
			interval += dt;
			totaltime = t;
			frame++;
			
			Info.setText("Size: " + Canvas.singleton.w + " x " + Canvas.singleton.h);
			if (interval > 0.2)
			{
				// 1/dt
				FPS.setText("FPS: " + int(frame / interval));
				frame = 0;
				interval = 0;
			}
			//UIupdate(input);
			//input.update(null);
		}
		private function keyDown(e:KeyboardEvent):void
		{
			/*
			private function keyfromcode(code:uint):String {
			var key:String;
			switch (code) {
				case Keyboard.ESCAPE:
					key = "ESC"; break;
				case Keyboard.UP:
					key = "UP"; break;
				case Keyboard.DOWN:
					key = "DOWN"; break;
				case Keyboard.LEFT:
					key = "LEFT"; break;
				case Keyboard.RIGHT:
					key = "RIGHT"; break;
				default: 
					key = String.fromCharCode(code);
			}
			return key;*/
			var key:String = String.fromCharCode(e.keyCode);
			if (key == "Z")
				canvas.clear();			
			if (key == "X")
			{
			}
			if (key == "C")
			{
			}
		}
	}
	
}