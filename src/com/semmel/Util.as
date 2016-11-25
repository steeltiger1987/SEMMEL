package com.semmel
{
	
	import com.hurlant.crypto.*;
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.crypto.symmetric.*;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import core.hash.crc32;
	
	import de.polygonal.ds.HashMap;
	
	import flash.display.*;
	import flash.filesystem.*;
	import flash.utils.*;
	
	import mx.collections.*;
	import mx.formatters.*;
	
	public class Util extends Sprite
	{
		
		//Item
		//- parse date dMy
		//- decrypt
		//- download
		// - crc32 check
		
		public static var hmMonth:HashMap = new HashMap();
		
		public function Util()
		{
			trace("Init Util");
		}
		
		public static function crc32Check(fileName:String):String{
		
			var file:File = File.applicationStorageDirectory.resolvePath(fileName);
			var stream:FileStream = new FileStream()
			stream.open(file, FileMode.READ);
			var s:String = stream.readUTFBytes(stream.bytesAvailable).toString();
			var bytes:ByteArray = new ByteArray();
			bytes.writeMultiByte( s, "UTF-8" );				
			var crc:crc32 = new crc32();
			crc.update( bytes );
			//trace( "CRC 32 = " + crc.toString() );
			return crc.toString();
		}
		
		public static function doCalcPercentage(cnt:Number, ttl:Number):Number
			
		{
			
			if(ttl==0){
				return 0;
			}
			
			// Initialize the NumberFormatter Object
			//act.pect = percentageFormat((act.cnt/overAllCnt)*100);
			var value:Number = (cnt/ttl)*100;
			
			var fmt:NumberFormatter = new NumberFormatter();
			
			var formattedString:String;
			
			// Set some of the options available
			
			fmt.precision = 2;
			fmt.useThousandsSeparator = false;
			
			// Format our value and return a formatted string
			
			formattedString = fmt.format(value);
			
			return Number(formattedString);
			// Do something with our newly formatted string
			
			//someobject.sometextfield.text = formattedString;
			
		}

		
		
		public function doDecrypt(data:ByteArray, sKey:String):String{
		
			var kdata:ByteArray = null; //key data bytearray
			//var data:ByteArray = null;
			var raw:String = ""; //raw data
			var jsonRaw:Object = null;
			
			kdata = Hex.toArray(Hex.fromString(sKey)); //plain text
			
			//for decryption
			var pad:IPad = null;
			var mode:ICipher = null;
			
			var pad:IPad = new PKCS5;
			//var mode:ICipher = Crypto.getCipher("aes-cbc", kdata, pad);
			mode = Crypto.getCipher("aes-cbc", kdata, pad);
			
			trace("pad: " + pad);
			trace("kdata: " + kdata);
			trace("mode: " + mode);
			
			if (mode is IVMode) {
				var ivmode:IVMode = mode as IVMode;
				// Just remember this is just a cast. The IV is still being set on the mode variable.
				//MThmZDk3NWQzZjI3ZmYxMQ== //for licne key 16 char
				
				//WORKING!
				//ivmode.IV = Base64.decodeToByteArray("MThmZDk3NWQzZjI3ZmYxMQ==");
				
				ivmode.IV = Base64.decodeToByteArray(Base64.encodeByteArray(kdata));
				
			}
			pad.setBlockSize(mode.getBlockSize());
			
			//trace(this.data);
			mode.decrypt(data);
			
			var fetchXMLData:String = "";
			
			fetchXMLData = Hex.toString(Hex.fromArray(data));
			trace( "Decrypt AES: " +  fetchXMLData);
			return fetchXMLData;
		}
		
		
		
		public static function getDaysBetweenDates(date1:Date,date2:Date):int
		{
			var one_day:Number = 1000 * 60 * 60 * 24
			var date1_ms:Number = date1.getTime();
			var date2_ms:Number = date2.getTime();		    
			var difference_ms:Number = Math.abs(date1_ms - date2_ms)		    
			return Math.round(difference_ms/one_day);
		}
		
		
		public static function getShortMonthName(month:String):String{	
			
			
			if(hmMonth.size()==0){
				hmMonth.set("1", "Jan");
				hmMonth.set("2", "Feb");
				hmMonth.set("3", "Mar");
				hmMonth.set("4", "Apr");
				hmMonth.set("5", "May");
				hmMonth.set("6", "Jun");
				hmMonth.set("7", "Jul");
				hmMonth.set("8", "Aug");
				hmMonth.set("9", "Sep");
				hmMonth.set("10", "Oct");
				hmMonth.set("11", "Nov");
				hmMonth.set("12", "Dec");
			}
			
			//trace("moht: " + month);
			//trace("return: " + hmMonth.get(month));
			return String(hmMonth.get(month));			
		}
		
	}
}