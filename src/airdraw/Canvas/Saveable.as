package airdraw.Canvas 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	/**
	 * class that can be saved or imported / opened from a file
	 * saving is done by setting bytes to some bytearray and calling save(filename)
	 * loading is done by calling load(filename) and then doing something with the bytearray
	 * @author Matthew Hyndman
	 */
	public class Saveable extends Sprite
	{
		protected var bytes:ByteArray;
		protected var filename:String = null;
		protected var filetype:String = ".png";
		
		public static var PNG:String = "png";
		public static var ADRAW:String = "adr";
		public static var DOTPNG:String = "." + PNG;
		public static var DOTADRAW:String = "." + ADRAW;
		
		public static var saveDir:String;
		
		public function Saveable() 
		{
			var so:SharedObject = SharedObject.getLocal("AirDraw");
			saveDir = so.data.saveDir;
		}
		
		//brose for a file to open
		public function browseFiles(caption:String, filters:Array /* of FileFilter */):void
		{
			var file:File;
			if (saveDir != null)
				file = new File(saveDir);
			else
				file = File.documentsDirectory;
			file = file.resolvePath(filters[0].extension);
			file.addEventListener(Event.SELECT, onOpenSelect);
			file.browseForOpen(caption,filters);
		}
		
		//after a file has been selected, read it to a bytearray and call the function to interpret the bytearray
		protected function onOpenSelect(e:Event):void
		{
			var f:File = e.currentTarget as File;
			//loads file to bytearray
			var fs:FileStream = new FileStream();
			filename = f.nativePath;
			setDir(filename);
			filetype = f.extension;
			fs.open(f, FileMode.READ);
			bytes = new ByteArray();
			fs.readBytes(bytes)
			fs.close();
			fromBytes(filetype);
			f.removeEventListener(Event.SELECT, onOpenSelect);
		}
		
		//overwrite this
		protected function toBytes(filetype:String):void
		{
			
		}
		//overwrite this
		protected function fromBytes(filetype:String):void
		{
			
		}
		
		protected function save(e:Event=null):void
		{
			// use existing filepath/name if it exists
			if (filename)
			{
				bytes = new ByteArray();
				toBytes(filetype);
				var f:File = new File(filename);
				var fs:FileStream = new FileStream();
				fs.open(f, FileMode.WRITE);
				fs.writeBytes(bytes);
				fs.close();
			}
			else //prompt user to enter a filename
				saveAs(e);
		}
		protected function saveAs(e:Event=null):void
		{
			bytes = new ByteArray();
			toBytes(filetype);
			//prompt user to enter a filename even if one was previously used
			var file:File;
			if (saveDir != null)
				file = new File(saveDir);
			else
				file = File.documentsDirectory;
			file = file.resolvePath("*." + filetype);
			file.addEventListener(Event.SELECT, onSaveSelect);
			file.browseForSave("Save as");
		}
		private function onSaveSelect(e:Event):void
		{
			var f:File = e.currentTarget as File;
			if (!f.extension || f.extension != filetype)
				f.nativePath += "." + filetype;
			filename = f.nativePath;
			setDir(filename);
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.WRITE);
			fs.writeBytes(bytes);
			fs.close();
			f.removeEventListener(Event.SELECT, onSaveSelect);
		}
		private function setDir(filename:String):void {
			var dirs:Array = filename.split("\\");
			dirs.pop();
			saveDir = dirs.join("\\");
			var so:SharedObject = SharedObject.getLocal("AirDraw");
			so.setProperty("saveDir", saveDir);
			so.flush();
			//save(null);
		}
	}

}