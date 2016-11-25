package com.security.util
{
	import flash.display.*;
	import com.hurlant.crypto.*;
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.crypto.symmetric.*;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import flash.utils.ByteArray;
	
	public class AESCrypto extends Sprite
	{
		
		public static var kdata:ByteArray = null; //key data bytearray
		public static var data:ByteArray = null;
		
		//for decryption
		public static var pad:IPad = null;
		public static var mode:ICipher = null;
		
		public function AESCrypto(){}
		
		public static function decrypt(encText:String, key16:String):String {
			
			data = Base64.decodeToByteArray(encText);
			
			kdata = Hex.toArray(Hex.fromString(key16)); //plain text
			
			var pad:IPad = new PKCS5;
			var mode:ICipher = Crypto.getCipher("aes-cbc", kdata, pad);
			
			if (mode is IVMode) {
				var ivmode:IVMode = mode as IVMode;
				ivmode.IV = Base64.decodeToByteArray(Base64.encodeByteArray(kdata));					
			}
			pad.setBlockSize(mode.getBlockSize());
			mode.decrypt(data);
			
			return Hex.toString(Hex.fromArray(data));;
		}
		
		
	}
}