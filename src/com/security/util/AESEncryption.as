package com.security.util
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.IVMode;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	/**
	 * @author andy
	 */
	public class AESEncryption
	{
		private var _key1:ByteArray;
		private var _cbcKey:ByteArray;
		
		/**
		 * AES CBC encryption
		 * @param key1				Secret key
		 * @param key2				CBC key		
		 */
		/*public function AESEncryption(key1:String, key2:String)
		{
			_key1 = Hex.toArray(Hex.fromString(key1));
			_cbcKey = Hex.toArray(Hex.fromString(key2));
		}*/
		public function AESEncryption(){
		}
		
		/**
		 * Encrypt a string
		 * @param msg			String to encrypt
		 * @return				encrypted string			
		 */
		public function encrypt(msg:String):String
		{
			var data:ByteArray = Hex.toArray(Hex.fromString(msg));         
			var pad:IPad = new NullPad();
			var mode:ICipher = Crypto.getCipher("aes256-cbc", _key1, pad);
			//var mode:ICipher = Crypto.getCipher("aes128-cbc", _key1, pad);
			pad.setBlockSize(mode.getBlockSize());
			var ivmode:IVMode = mode as IVMode;
			ivmode.IV = _cbcKey;            
			mode.encrypt(data);
			return Base64.encodeByteArray(data);
		}
		
		/**
		 * Decrypt a string
		 * @param msg			String to decrypt
		 * @return				decrypted string
		 */
		public function decrypt(key:String, msg:String):String
		{
			_key1 = Hex.toArray(Hex.fromString(key));
			
			var data:ByteArray = Base64.decodeToByteArray(msg);
			var pad:IPad = new NullPad();
			var mode:ICipher = Crypto.getCipher("aes256-cbc", _key1, pad);
			//var mode:ICipher = Crypto.getCipher("aes128-cbc", _key1, pad);
			var ivmode:IVMode = mode as IVMode;
			ivmode.IV = _cbcKey;
			pad.setBlockSize(mode.getBlockSize());        
			mode.decrypt(data);
			return Hex.toString(Hex.fromArray(data));
		}
	}
}