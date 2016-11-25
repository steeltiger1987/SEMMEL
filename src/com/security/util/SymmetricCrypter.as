package com.security.util
{
	import com.hurlant.crypto.*;
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.DESKey;
	import com.hurlant.crypto.symmetric.ISymmetricKey;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	
	public class SymmetricCrypter {
		
		private var crypter:ISymmetricKey;
		
		public static function createDESCrypter(key:String):SymmetricCrypter {
			
			return new SymmetricCrypter(DESKey, key);
		}
		public static function createAESCrypter(key:String):SymmetricCrypter {
			
			return new SymmetricCrypter(AESKey, key);
		}
		public function SymmetricCrypter(crypterClass:Class, key:String) {
			
			var keyBin:ByteArray = Hex.toArray(Hex.fromString(key));
			crypter = new crypterClass(keyBin);
			
			//Crypto.getCipher(
			
		}
		
		public function encrypt(plainText:String):String {
			
			var textBin:ByteArray = Hex.toArray(Hex.fromString(plainText));
			crypter.encrypt(textBin);
			
			var cipherText:String = Base64.encodeByteArray(textBin);
			return cipherText;
		}
		public function decrypt(cipherText:String):String {
			
			var decodedTextBin:ByteArray = Base64.decodeToByteArray(cipherText);
			crypter.decrypt(decodedTextBin);	
			
			var decryptedText:String = Hex.toString(Hex.fromArray(decodedTextBin));
			return decryptedText;
		}
	}
}