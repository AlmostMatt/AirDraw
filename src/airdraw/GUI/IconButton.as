package airdraw.GUI 
{
	import airdraw.Frames.Tool;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Matthew Hyndman
	 */
	public class IconButton extends Button 
	{
				[Embed(source="../../assets/icons/Writing.png")]
		protected static var Icon1:Class;
		[Embed(source="../../assets/icons/Paint.png")]
		protected static var Icon2:Class;
		[Embed(source="../../assets/icons/CCleaner.png")]
		protected static var Icon3:Class;
		[Embed(source="../../assets/icons/Screenshot.png")]
		protected static var Icon4:Class;
		[Embed(source="../../assets/icons/PhotoshopCS2.png")]
		protected static var Icon5:Class;
		[Embed(source="../../assets/icons/Search.png")]
		protected static var Icon6:Class;
		[Embed(source="../../assets/icons/Xion.png")]
		protected static var Icon7:Class;
		//arrows up/down/left/right
		[Embed(source = "../../assets/icons/Up.png")]
		protected static var Icon8:Class;
		[Embed(source = "../../assets/icons/Down.png")]
		protected static var Icon9:Class;
		[Embed(source = "../../assets/icons/Select.png")]
		protected static var Icon10:Class;
		[Embed(source = "../../assets/icons/Select2.png")]
		protected static var Icon11:Class;
		[Embed(source = "../../assets/icons/Info.png")]
		protected static var Icon12:Class;
		[Embed(source = "../../assets/icons/Bookmark.png")]
		protected static var Icon13:Class;
		[Embed(source = "../../assets/icons/Ribbon.png")]
		protected static var Icon14:Class;
		[Embed(source = "../../assets/icons/New.png")]
		protected static var Icon15:Class;
		[Embed(source = "../../assets/icons/Add.png")]
		protected static var Icon16:Class;
		[Embed(source = "../../assets/icons/symH.png")]
		protected static var symH:Class;
		[Embed(source = "../../assets/icons/symV.png")]
		protected static var symV:Class;
		[Embed(source = "../../assets/icons/asymH.png")]
		protected static var asymH:Class;
		[Embed(source = "../../assets/icons/asymV.png")]
		protected static var asymV:Class;
		[Embed(source = "../../assets/icons/symHV.png")]
		protected static var symHV:Class;
		[Embed(source = "../../assets/icons/Media-Player.png")]
		protected static var arrowR:Class;
		[Embed(source = "../../assets/icons/Restart.png")]
		protected static var radial:Class;
		[Embed(source = "../../assets/icons/70.png")]
		protected static var notradial:Class;
		[Embed(source = "../../assets/icons/36.png")]
		protected static var pointer:Class;
		[Embed(source = "../../assets/icons/drawicon.png")]
		protected static var draw:Class;
		[Embed(source = "../../assets/icons/eraseicon.png")]
		protected static var erase:Class;
		[Embed(source = "../../assets/icons/pen1.png")]
		protected static var pen1:Class;
		[Embed(source = "../../assets/icons/pen2.png")]
		protected static var pen2:Class;
		
		public static const PENCIL:String = "pencil";
		//public static const PEN:String = "pen";
		public static const BRUSH1:String = "brush1";
		public static const BRUSH2:String = "brush2";
		public static const SELECT:String = "select";
		public static const ZOOM:String = "zoom";
		public static const DELETE:String = "delete";
		public static const FEATHER:String = "feather";
		public static const UP:String = "up";
		public static const DOWN:String = "down";
		public static const SELECT1:String = "select2";
		public static const SELECT2:String = "select3";
		public static const WARN:String = "WARN";
		public static const RIBBON1:String = "RIBBON1";
		public static const RIBBON2:String = "RIBBON2";
		public static const NEW:String = "new";
		public static const PLUS:String = "plus";
		public static const SYMV:String = "SYMV";
		public static const SYMH:String = "SYMH";
		public static const ASYMH:String = "ASYMH";
		public static const ASYMV:String = "ASYMV";
		public static const SYMHV:String = "SYMHV";
		public static const RIGHT:String = "RIGHT";
		public static const RADIAL:String = "RADIAL";
		public static const NOTRADIAL:String = "NOTRADIAL";
		public static const COLORPICK:String = "colorpicker";
		public static const DRAW:String = "draw";
		public static const ERASE:String = "erase";
		public static const PEN:String = "pen1";
		
		public static function getIcon(type:String):Bitmap
		{
			var newicon:Bitmap;
			switch (type)
			{
				case PENCIL:
					newicon = new pen1();
					break;
				case BRUSH1:
					newicon = new Icon2();
					break;
				case BRUSH2:
					newicon = new Icon3();
					break;
				case SELECT:
					newicon = new Icon4();
					break;
				case FEATHER:
					newicon = new Icon5();
					break;
				case ZOOM:
					newicon = new Icon6();
					break;
				case DELETE:
					newicon = new Icon7();
					break;
				case UP:
					newicon = new Icon8();
					break;
				case DOWN:
					newicon = new Icon9();
					break;
				case SELECT1:
					newicon = new Icon10();
					break;
				case SELECT2:
					newicon = new Icon11();
					break;
				case WARN:
					newicon = new Icon12();
					break;
				case RIBBON1:
					newicon = new Icon13();
					break;
				case RIBBON2:
					newicon = new Icon14();
					break;
				case NEW:
					newicon = new Icon15();
					break;
				case PLUS:
					newicon = new Icon16();
					break;
				case SYMH:
					newicon = new symH();
					break;
				case SYMV:
					newicon = new symV();
					break;
				case ASYMH:
					newicon = new asymH();
					break;
				case ASYMV:
					newicon = new asymV();
					break;
				case SYMHV:
					newicon = new symHV();
					break;
				case RIGHT:
					newicon = new arrowR();
					break;
				case RADIAL:
					newicon = new radial();
					break;;
				case NOTRADIAL:
					newicon = new notradial();
					break;
				case COLORPICK:
					newicon = new pointer();
					break;
				case DRAW:
					newicon = new draw();
					break;
				case ERASE:
					newicon = new erase();
					break;
				case PEN:
					newicon = new pen2();
					break;
			}
			return newicon;
		}

		public function IconButton(x1:int,y1:int,iconname:String,size:int,onclick:Function=null,v:*=null) 
		{	
			icon = getIcon(iconname);
			icon.scaleX = icon.scaleY = size / 128;
			//center this
			addChild(icon);

			super(x1, y1, size, size, onclick, v);
		}
		
	}

}