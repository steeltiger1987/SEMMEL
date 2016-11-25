package com
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.sampler.NewObjectSample;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;

	public class FileUtils
	{
	    public static function saveCSV(file:File, data:String):void {
			var stream:FileStream = new FileStream();
			stream.addEventListener(IOErrorEvent.IO_ERROR, function() {
				Alert.show("CSV export failed.");
			});
			
//			var file:File = File.desktopDirectory.resolvePath(filename);
			stream.open(file, FileMode.WRITE);
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(data);
			stream.writeBytes(bytes);
			stream.close();
		}
		
	}
}