package com.report.handhygiene
{
	
	import com.report.*;
	import com.security.util.AESCrypto;
	import com.semmel.*;
	
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.utils.StringUtil;
	
	public class HandHygieneController extends Sprite
	{
		
		//download file function 
		var loadedSize:Number = 0;
		var theAFileSize:Number= 0;
		private var fileDownload:File;
		private var fileDownloadTemp:File;
		private var fileStream:FileStream = new FileStream;
		
		private var stream:URLStream;
		private var ioError:Boolean = false;
		
		private var sponImage:String = "";
		
		public static const DOWNLOADED_EVENT:String = "Downloaded_Event";
		public static const CHECKUPDATE_EVENT:String = "CheckUpdate_Event";
		
		public var returnData:String = "";
		
		public function HandHygieneController() 
		{
		}
		
		
		private var isRawData:Boolean;
		public function initDownload(targetFilename:String):void{
			
			
			fileDownload = File.applicationStorageDirectory.resolvePath(targetFilename);
			fileDownloadTemp = File.applicationStorageDirectory.resolvePath(targetFilename + ".tmp");
			
			if(targetFilename.search('rawdata') != -1)
				isRawData = true;
			else 
				isRawData = false;
			
			var header0:URLRequestHeader=null;
			
			//var req:URLRequest = new URLRequest(this.parentApplication.url_mapi.replace("mapi","images/") + strFileName + "?rnd="+ String(Math.round(Math.random() * (9999999 - 0) + 0)));
			
			var req:URLRequest = new URLRequest(Constants.url_mapi+"?rnd="+ String(Math.round(Math.random() * (9999999 - 0) + 0)));
			
			
			req.method = URLRequestMethod.POST;
			req.contentType = "application/x-www-form-urlencoded";
			req.data = "act=download_handhygiene&hid="+Constants.getHospitalId()+"&key="+Constants.getLicenseKey().substring(0,16)+"&fn="+targetFilename;
			
			stream = new URLStream();
			stream.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			stream.addEventListener(ProgressEvent.PROGRESS, writeFile);
			stream.addEventListener(Event.COMPLETE, completeDownloadFile);
			
			stream.load(req);
			
//			fileStream.open(fileDownloadTemp, fileDownload.exists ? FileMode.WRITE:FileMode.WRITE);
		}
		
		
		private function completeDownloadFile(evt:Event):void {
			trace("Download Complete " + stream.bytesAvailable);

			var raw:String = stream.readUTFBytes(stream.bytesAvailable);
			var s = AESCrypto.decrypt(raw, Constants.getLicenseKey().substring(0,16));
			
			if(StringUtil.trim(s) != "") {
				fileStream.open(fileDownloadTemp, fileDownload.exists ? FileMode.WRITE:FileMode.WRITE);
				
				if(!isRawData)
					s = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><report>" + s + "</report>";
					
//				trace("dec: " + s);
				
				fileStream.writeUTFBytes(s);
				
				fileStream.close();
				fileDownloadTemp.copyTo(fileDownload, true);
				
				fileDownloadTemp.deleteFile();
			} else {
				trace("============== No data available for the file. Skipped the file creation. ");
			}
			
			//must need a Sprite
			dispatchEvent(new Event(DOWNLOADED_EVENT));
		}
		
		
		private function writeFile(event:ProgressEvent):void {
			trace("Downloading... " + (((loadedSize+event.bytesLoaded)/event.bytesTotal)*100).toFixed(0)+ "%");
			
			// chunk of new data
//			var fileDataChunk:ByteArray = new ByteArray();
			// read bytes from the internet using URLStream
//			stream.readBytes(fileDataChunk,0,stream.bytesAvailable);
			// write bytes to the disk using FileStream
//			fileStream.writeBytes(fileDataChunk,0,fileDataChunk.length);
		}
		
		protected function onIOError(e:IOErrorEvent):void
		{
			ioError = true;
			trace(e);
			//isLoaded = true;
			
			//force update even if the file fails to download and proceed to next
			dispatchEvent(new Event(DOWNLOADED_EVENT));
		}
		
		
		
		
		public function doCheckUpdate(licenseKey:String):void{
			
			//aa5c4f1abc0361b9 66df0f1c22f41e56843673ef
			//key: aa5c4f1abc0361b9
			
			trace("check update: " + licenseKey);
			
			var urlreq:URLRequest = new URLRequest (Constants.url_mapi);
			urlreq.method = URLRequestMethod.POST; 
			
			var urlvars:URLVariables = new URLVariables(); 
			urlvars.act = "doReport"; //get report data
			//urlvars.contentType = "application/x-www-form-urlencoded";
			//urlvars.license = licenseKey;
			
			urlvars.v = "2.0"; //to support latest report model generate engine, without v: is older version engine!
			urlvars.key = licenseKey
			urlreq.data = urlvars;          
			
			var loader:URLLoader = new URLLoader (urlreq); 
			loader.addEventListener(Event.COMPLETE, doPostComplete); 
			//loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.load(urlreq); 
			
		}
		
		private function doPostComplete (event:Event):void{
			//var variables:URLVariables = new URLVariables( event.target.data );
			trace("dopost complete: " + event.target.data);
			this.returnData = event.target.data;
			//resptxt.text = variables.done;
			//dispatchEvent(new Event(CHECKUPDATE_EVENT, false, this.returnData));
			dispatchEvent(new Event(CHECKUPDATE_EVENT));
		}
		
		
		
	}
}