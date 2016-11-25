package core.hash
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * A class to compute the CRC-32 checksum of a data stream.
	 * Other names: CRC-32/ADCCP, PKZIP
	 */
	public final class crc32
	{
		
		private static var lookup:Vector.<uint> = make_crc_table();
		
		private static function make_crc_table():Vector.<uint>
		{
			var table:Vector.<uint> = new Vector.<uint>();
			
			var c:uint;
			var i:uint;
			var j:uint;
			
			for( i=0; i < 256; i++ )
			{
				c = i;
				for( j=0; j < 8; j++ )
				{
					if( (c & 0x00000001) != 0 )
					{
						c = (c >>> 1) ^ _poly;
					}
					else
					{
						c = (c >>> 1);
					}
				}
				table[i] = c;
			}
			
			return table;
		}
		
		// ---- CONFIG ----
		
		private static var _poly:uint = 0xedb88320;
		private static var _init:uint = 0xffffffff;
		
		// ---- CONFIG ----
		
		private var _crc:uint;
		private var _length:uint;
		private var _endian:String;
		
		/**
		 * Creates a CRC-32 object. 
		 */
		public function crc32()
		{
			_length = 0xffffffff;
			_endian = Endian.LITTLE_ENDIAN;
			reset();
		}
		
		/**
		 * Returns the byte order for the CRC;
		 * either Endian.BIG_ENDIAN for "Most significant bit first"
		 * or Endian.LITTLE_ENDIAN for "Least significant bit first".
		 * 
		 * see: http://en.wikipedia.org/wiki/Computation_of_CRC#Bit_ordering_.28Endianness.29
		 */
		public function get endian():String { return _endian; }
		
		/**
		 * Returns the length the CRC;
		 */
		public function get length():uint { return _length; }
		
		/**
		 * Updates the CRC-32 with a specified array of bytes.
		 * 
		 * @param bytes The ByteArray object
		 * @param offset (default = 0) -- A zero-based index indicating the position into the array to begin reading.
		 * @param length (default = 0) -- An unsigned integer indicating how far into the buffer to read (if 0, the length of the ByteArray is used).
		 */
		public function update( bytes:ByteArray, offset:uint = 0, length:uint = 0 ):void
		{
			if( length == 0 ) { length = bytes.length; }
			
			bytes.position = offset;
			
			var i:uint;
			var c:uint;
			var crc:uint = _length & (_crc);
			
			for( i = offset; i < length; i++ )
			{
				c    = uint( bytes[ i ] );
				crc  = (crc >>> 8) ^ lookup[(crc ^ c) & 0xff];
			}
			
			_crc = ~crc;
		}
		
		/**
		 * Resets the CRC-32 to its initial value. 
		 */
		public function reset():void
		{
			_crc = _init;
		}
		
		/**
		 * Returns the primitive value type of the CRC-32 object (unsigned integer).
		 * 
		 * @return a 32bits digest
		 */
		public function valueOf():uint
		{
			return _crc;
		}
		
		/**
		 * Returns the string representation of the CRC-32 value.
		 * 
		 * @param radix (default = 16) -- Specifies the numeric base (from 2 to 36) to use for the uint-to-string conversion. If you do not specify the radix parameter, the default value is 16.
		 * @return The numeric representation of the CRC-32 object as a string.
		 */ 
		public function toString( radix:Number = 16 ):String
		{
			return _crc.toString( radix );
		}
		
	}

}